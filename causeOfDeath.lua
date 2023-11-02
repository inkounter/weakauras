-- TODO:
-- - Count damage done to 'Regenerating Wildseed' (NPC ID 164589) during
--   Podtender.
--
-- - Add option to truncate lists of repeated damage events.

-------------------------------------------------------------------------------
-- init

aura_env.damageHistory = {}
aura_env.ignoreUnitGuidDeath = {}   -- For priests' Spirit of Redemption
aura_env.cheatDebuffs = {}

for _, debuff in ipairs(aura_env.config.cheatDebuffs) do
    aura_env.cheatDebuffs[debuff.spellId] = true
end

aura_env.getSpellText = function(spell, school)
    -- Return a formatted string describing the specified 'spell' of the
    -- optionally specified 'school'.  If 'spell' is a string, the returned
    -- human-readable string will contain 'spell' directly.  Otherwise, if
    -- 'spell' is a number, the returned string will link to 'spell'. 'school'
    -- is a bitmask where each bit keys into
    -- 'COMBATLOG_DEFAULT_COLORS.schoolColoring'.

    local text = nil
    if type(spell) == "number" then
        local spellName, _ = GetSpellInfo(spell)
        text = "|Hspell:" .. spell .. "|h[" .. spellName .. "]|h"
    else
        text = "[" .. spell .. "]"
    end

    local schoolColor = _G.COMBATLOG_DEFAULT_COLORS.schoolColoring[school]
    if schoolColor ~= nil then
        -- The input 'school' is not exactly one spell school.  Default to
        -- white.

        schoolColor = CreateColor(schoolColor.r,
                                  schoolColor.g,
                                  schoolColor.b,
                                  1)
        text = schoolColor:WrapTextInColorCode(text)
    end

    return text
end

aura_env.isWipe = function()
    -- Return 'true' if too much of the raid is dead (the threshold for which
    -- is configured in "Custom Options").  Otherwise, return 'false'.

    local wipeThreshold = aura_env.config.wipeThreshold

    if wipeThreshold == 0 then
        -- The wipe threshold is disabled.

        return false
    end

    -- Count the number of players dead.

    local numDead = 0

    for unit in WA_IterateGroupMembers() do
        if UnitIsDeadOrGhost(unit) then
            numDead = numDead + 1
        end
    end

    return numDead >= wipeThreshold
end

aura_env.clearDamageHistory = function(unitGuid)
    -- Clear the damage history for the specified 'unitGuid'.

    local unitHistory = aura_env.damageHistory[unitGuid]

    if unitHistory ~= nil then
        unitHistory.events = {}
        unitHistory.sum = 0
    end
end

aura_env.reportCauseOfDeath = function(unitGuid, unit)
    -- Print a report for the cause of death for the specified 'unitGuid',
    -- which is also referred to by 'unit', and clear the damage taken history
    -- for 'unitGuid'.

    local deathReport = "Cause of Death [" .. WA_ClassColorName(unit) .. "]:"
    local unitHistory = aura_env.damageHistory[unitGuid]

    if unitHistory == nil or #unitHistory.events == 0 then
        deathReport = deathReport .. "\n  <<Unknown>>"
    else
        -- Group events by spell ID.  Also record the spell school for each
        -- spell.

        local eventsBySpell = {}
        local spellSchools = {}

        for i = 1, #unitHistory.events do
            local event = unitHistory.events[i]

            local spellEvents = eventsBySpell[event.spell]
            if spellEvents == nil then
                spellEvents = {}
                eventsBySpell[event.spell] = spellEvents

                spellSchools[event.spell] = event.school
            end

            table.insert(spellEvents, event.amount)
        end

        for spell, events in pairs(eventsBySpell) do
            deathReport = (deathReport .. "\n  "
                          .. aura_env.getSpellText(spell, spellSchools[spell]))

            local numEvents = #events

            if numEvents == 1 then
                deathReport = (deathReport .. ": "
                                               .. AbbreviateNumbers(events[1]))
            else
                deathReport = deathReport .. " x" .. numEvents .. ": "

                local spellEventsSum = 0
                local spellEventsReport = ""
                for i = 1, numEvents do
                    local eventAmount = events[i]
                    spellEventsSum = spellEventsSum + eventAmount

                    if i ~= 1 then
                        spellEventsReport = spellEventsReport .. ", "
                    end

                    spellEventsReport = (spellEventsReport
                                             .. AbbreviateNumbers(eventAmount))
                end

                deathReport = (deathReport .. AbbreviateNumbers(spellEventsSum)
                                           .. " (" .. spellEventsReport .. ")")
            end
        end

        -- Clear the history.

        aura_env.clearDamageHistory(unitGuid)
    end

    print(deathReport)
end

aura_env.spellIsRecentlyApplied = function(unit, spellId)
    -- Return 'true' if the specified 'spellId' was recently applied to the
    -- specified 'unit'.  Otherwise, return 'false'.

    local name, _, _, _, duration, expirationTime = WA_GetUnitDebuff(unit,
                                                                     spellId)

    if name == nil then
        _, _, _, _, duration, expirationTime = WA_GetUnitBuff(unit, spellId)
    end

    local applicationTime = expirationTime - duration
    return applicationTime > GetTime() - 3
end

aura_env.recordDamageEvent = function(unit,
                                      damageAmount,
                                      damageSpell,
                                      damageSchool)
    -- Add a damage event with the specified 'damageAmount', 'damageSpell', and
    -- 'damageSchool' to the damage history for the specified 'unit', then
    -- prune old damage events from the history until it contains just enough
    -- events to sum over the configured %MaxHP.

    local unitGuid = UnitGUID(unit)

    local unitHistory = aura_env.damageHistory[unitGuid]
    if unitHistory == nil then
        unitHistory = { events = {}, sum = 0 }
        aura_env.damageHistory[unitGuid] = unitHistory
    end

    -- Add the new damage event to the history (at the end of the array).

    unitHistory.sum = unitHistory.sum + damageAmount
    table.insert(unitHistory.events,
                 { amount = damageAmount,
                   spell  = damageSpell,
                   school = damageSchool })

    -- Remove damage events from the history (at the beginning of the
    -- array) until removing one more would reduce the sum below the
    -- configured %MaxHP for history.

    local maxHealth = UnitHealthMax(unit)
    local sumCutoff = maxHealth * aura_env.config.percentHealthHistory / 100

    while #unitHistory.events > 0 do
        local sumAfterRemoval = unitHistory.sum - unitHistory.events[1].amount
        if sumAfterRemoval < sumCutoff then
            break
        end

        unitHistory.sum = sumAfterRemoval
        table.remove(unitHistory.events, 1)
    end
end

-------------------------------------------------------------------------------
-- trigger: WA_CAUSEOFDEATH_DEFERRED, CLEU:UNIT_DIED, CLEU:SPELL_AURA_APPLIED, CLEU:SWING_DAMAGE, CLEU:RANGE_DAMAGE, CLEU:SPELL_DAMAGE, CLEU:SPELL_PERIODIC_DAMAGE, CLEU:SPELL_BUILDING_DAMAGE, CLEU:ENVIRONMENTAL_DAMAGE, CLEU:SWING_MISSED, CLEU:RANGE_MISSED, CLEU:SPELL_MISSED, CLEU:SPELL_PERIODIC_MISSED, CLEU:SPELL_BUILDING_MISSED, CLEU:ENVIRONMENTAL_MISSED, CLEU:SWING_INSTAKILL, CLEU:RANGE_INSTAKILL, CLEU:SPELL_INSTAKILL, CLEU:SPELL_PERIODIC_INSTAKILL, CLEU:SPELL_BUILDING_INSTAKILL, CLEU:ENVIRONMENTAL_INSTAKILL

function(event, ...)
    -- Note that this function never triggers because we're not interested in
    -- displaying anything except by 'print'ing.

    if event == "WA_CAUSEOFDEATH_DEFERRED" then
        aura_env.reportCauseOfDeath(...)
        return
    end

    local subevent = select(2, ...)
    if subevent == nil then
        return
    end

    -- Ignore events affecting units not in the group.

    local unitGuid = select(8, ...)
    local unit = nil
    for groupMember in WA_IterateGroupMembers() do
        if UnitGUID(groupMember) == unitGuid then
            unit = groupMember
            break
        end
    end
    if unit == nil then
        return
    end

    -- If Self Only mode is enabled, ignore events affecting anyone other than
    -- the current player.

    if aura_env.config.selfOnly and not UnitIsUnit(unit, "player") then
        return
    end

    if subevent == "UNIT_DIED" then
        if not UnitIsDeadOrGhost(unit) then
            -- This unit is using Feign Death.  Ignore this event.

            return
        end

        if aura_env.ignoreUnitGuidDeath[unitGuid] ~= nil then
            aura_env.ignoreUnitGuidDeath[unitGuid] = nil

            -- Also clear the damage history, in case the unit racked up damage
            -- taken events since their death was reported (e.g., during
            -- Forgeborne Reveries).

            aura_env.clearDamageHistory(unitGuid)
        elseif not aura_env.isWipe() then
            aura_env.reportCauseOfDeath(unitGuid, unit)
        end
    elseif subevent == "SPELL_AURA_APPLIED" then
        local spellId = select(12, ...)
        spellId = tonumber(spellId)

        if spellId == 27827 then    -- Spirit of Redemption
            -- Ignore this event if the aura was not just applied or if it's a
            -- wipe.

            if not aura_env.spellIsRecentlyApplied(unit, spellId)
            or aura_env.isWipe() then
                return
            end

            -- Delay the report by a second, since this aura is applied before
            -- the combat log reports the damage event that took the unit to 0
            -- health.

            C_Timer.After(1, function() WeakAuras.ScanEvents("WA_CAUSEOFDEATH_DEFERRED", unitGuid, unit) end)

            -- Also save this unit GUID so that we can ignore its impending
            -- 'UNIT_DIED' event.

            aura_env.ignoreUnitGuidDeath[unitGuid] = true
        elseif aura_env.cheatDebuffs[spellId] ~= nil then
            -- Ignore this event if the aura was not just applied or if it's a
            -- wipe.

            if not aura_env.spellIsRecentlyApplied(unit, spellId)
            or aura_env.isWipe() then
                return
            end

            aura_env.reportCauseOfDeath(unitGuid, unit)
        end
    elseif subevent:find("_DAMAGE") ~= nil then
        -- Extract the event's information.

        local spell = nil
        local amount = nil
        local school = nil
        local absorbed = nil
        local _ = nil
        if subevent:find("SWING_") then
            spell = "Melee"
            amount, _, school, _, _, absorbed = select(12, ...)
        elseif subevent:find("ENVIRONMENTAL_") then
            spell = select(12, ...)
            amount, _, school, _, _, absorbed = select(13, ...)
        else
            spell = select(12, ...)
            spell = tonumber(spell)
            amount, _, school, _, _, absorbed = select(15, ...)
        end

        -- Record the damage event.  Include the absorbed amount in the damage
        -- taken.

        if absorbed ~= nil then
            amount = amount + absorbed
        end
        aura_env.recordDamageEvent(unit, amount, spell, school)
    elseif subevent:find("_MISSED") ~= nil then
        -- Extract the event's information.

        local spell = nil
        local school = nil
        local amount = nil
        local missType = nil
        local _ = nil
        if subevent:find("SWING_") then
            spell = "Melee"
            school = 1  -- physical
            missType, _, amount = select(12, ...)
        elseif subevent:find("ENVIRONMENTAL_") then
            spell = select(12, ...)
            school = 1  -- physical...?
            missType, _, amount = select(13, ...)
        else
            spell, _, school = select(12, ...)
            spell = tonumber(spell)
            missType, _, amount = select(15, ...)
        end

        -- Record the damage event, but only if it's absorbed.

        if missType == "ABSORB" then
            aura_env.recordDamageEvent(unit, amount, spell, school)
        end
    elseif subevent:find("_INSTAKILL") ~= nil then
        -- Replace the damage history table for this unit to contain just this
        -- instakill event.

        local amount = UnitHealthMax(unit)
        local unitHistory = { events = {}, sum = 0 }
        aura_env.damageHistory[unitGuid] = unitHistory

        local spell = nil
        local school = nil
        local _ = nil
        if subevent:find("SWING_") then
            spell = "Melee Instakill"
        elseif subevent:find("ENVIRONMENTAL_") then
            spell = select(12, ...)
            spell = spell .. " Instakill"
        else
            spell, _, school = select(12, ...)
            spell = tonumber(spell)
        end

        -- Insert the damage event into the new damage history array.

        unitHistory.sum = unitHistory.sum + amount
        table.insert(unitHistory.events, { amount = amount, spell = spell, school = school })
    end
end
