-------------------------------------------------------------------------------
-- init

aura_env.latestStates = {}  -- an array of the 5 states with the latest
                            -- expiration times, where the state at index 5 is
                            -- the closest to expiring.

-------------------------------------------------------------------------------
-- TSU: CLEU:SPELL_DAMAGE

function(allstates, event, ...)
    local sourceFlags = select(6, ...)
    if sourceFlags == nil
    or bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0 then
        return false
    end

    local spellId = select(12, ...)
    if spellId ~= 100780        -- tiger palm
    and spellId ~= 100784       -- blackout kick
    and spellId ~= 185099       -- rising sun kick
    and spellID ~= 261947 then  -- fist of the white tiger
        return false
    end

    local latestStates = aura_env.latestStates
    local targetGuid = select(8, ...)
    local state = allstates[targetGuid]

    if state == nil then
        -- This is a new target.  Create a state for it, push it into
        -- 'latestStates', then pop and hide 'latestStates[6]', if it exists.

        state = {
            ["show"] = true,
            ["changed"] = true,
            ["progressType"] = "timed",
            ["expirationTime"] = GetTime() + 20,
            ["duration"] = 20,
            ["autoHide"] = true,
        }
        allstates[targetGuid] = state

        table.insert(latestStates, 1, state)

        local oldestState = latestStates[6]
        if oldestState ~= nil then
            oldestState.show = false
            oldestState.changed = true
            latestStates[6] = nil
        end
    else
        -- This is an old target.  Refresh its duration.

        state.expirationTime = GetTime() + 20
        state.changed = true
    end

    return true
end
