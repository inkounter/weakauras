-------------------------------------------------------------------------------
-- init

aura_env.healingSpells = {
    [1064] = true, -- Chain Heal
    [61295] = true, -- Riptide
    [77472] = true, -- Healing Wave
    [197995] = true, -- Wellspring
    [73920] = true, -- Healing Rain
    [8004] = true, -- Healing Surge
    [73685] = true, -- Unleash Life
    [108280] = true, -- Healing Tide Totem
    [98008] = true, -- Spirit Link Totem
    [207778] = true, -- Downpour
    [320746] = true, -- Surge of Earth
    [5394] = true, -- Healing Stream Totem
    [108281] = true, -- Ancestral Guidance
    [201764] = true, -- Recall Cloudburst Totem
    [77130] = true, -- Purify Spirit
    [312411] = true, -- Bag of Tricks (Vulpera racial)
}

aura_env.damageSpells = {
    [51505] = true, -- Lava Burst
    [188196] = true, -- Lightning Bolt
    [188389] = true, -- Flame Shock
    [188443] = true, -- Chain Lightning
    [117014] = true, -- Elemental Blast
    [320125] = true, -- Echoing Shock
    [192222] = true, -- Liquid Magma Totem
    [210714] = true, -- Icefury
    [51490] = true, -- Thunderstorm
    [61882] = true, -- Earthquake
    [196840] = true, -- Frost Shock
    [187874] = true, -- Crash Lightning
    [17364] = true, -- Stormstrike
    [60103] = true, -- Lava Lash
    [333974] = true, -- Fire Nova
    [196884] = true, -- Feral Lunge
    [197214] = true, -- Sundering
    [188089] = true, -- Earthen Spike
    [73899] = true, -- Primal Strike
    [8042] = true, -- Earth Shock
    [342243] = true, -- Static Discharge
}

aura_env.healingCharges = 0
aura_env.damageCharges = 0

-------------------------------------------------------------------------------
-- TSU: UNIT_SPELLCAST_SUCCEEDED:player, PLAYER_TOTEM_UPDATE

function(allstates, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local spellId = select(3, ...)

        if spellId == 324386 then   -- Vesper Totem

            local expirationTime = GetTime() + 30

            for i = 1, 6 do
                local chargeType
                local chargeNum
                local sortIndex

                if i < 4 then
                    chargeType = "damage"
                    chargeNum = i
                    sortIndex = -chargeNum
                else
                    chargeType = "healing"
                    chargeNum = i - 3
                    sortIndex = chargeNum
                end

                local stateKey = chargeType .. chargeNum

                local state = {
                    ["show"] = true,
                    ["changed"] = true,
                    ["progressType"] = "timed",
                    ["autoHide"] = true,
                    ["expirationTime"] = expirationTime,
                    ["duration"] = 30,
                    ["index"] = sortIndex,

                    ["chargeType"] = chargeType,
                }

                allstates[stateKey] = state
            end

            aura_env.healingCharges = 3
            aura_env.damageCharges = 3

            return true
        elseif aura_env.healingCharges > 0 or aura_env.damageCharges > 0 then
            if aura_env.healingSpells[spellId] then
                if aura_env.healingCharges > 0 then
                    local index = "healing" .. aura_env.healingCharges
                    local state = allstates[index]

                    state.show = false
                    state.changed = true

                    aura_env.healingCharges = aura_env.healingCharges - 1

                    return true
                end
            elseif aura_env.damageSpells[spellId] then
                if aura_env.damageCharges > 0 then
                    local index = "damage" .. aura_env.damageCharges
                    local state = allstates[index]

                    state.show = false
                    state.changed = true

                    aura_env.damageCharges = aura_env.damageCharges - 1

                    return true
                end
            end

            return false
        end
    elseif event == "PLAYER_TOTEM_UPDATE"
    and (aura_env.healingCharges > 0 or aura_env.damageCharges > 0) then
        -- Check for "PLAYER_TOTEM_UPDATE" in case the player cancels the
        -- totem.

        local vesperTotemName = GetSpellInfo(324386)

        for i = 1, MAX_TOTEMS do
            local _, totemName = GetTotemInfo(i)
            if totemName == vesperTotemName then
                -- Vesper Totem is still active.  Do nothing.

                return false
            end
        end

        -- Vesper Totem is inactive.  Disable all of the states.

        for index, state in pairs(allstates) do
            state.show = false
            state.changed = true
        end

        -- Clear the charge counters.

        aura_env.healingCharges = 0
        aura_env.damageCharges = 0

        return true
    end
end

-------------------------------------------------------------------------------
-- Custom Variables

{
    ["expirationTime"] = true,
    ["duration"] = true,

    ["chargeType"] = {
        ["display"] = "Charge Type",
        ["type"] = "select",
        ["values"] = {
            ["damage"] = "Damage",
            ["healing"] = "Healing",
        },
    },
}

-------------------------------------------------------------------------------
-- Custom Grow

function(positions, activeRegions)
    -- This grow algorithm places each region such that damage charges "grow
    -- right" from (0, 0), and healing charges "grow left" from (0, 0).  Custom
    -- Options can also reconfigure this algorithm to inverse the directions
    -- and to grow vertically instead of horizontally.

    local config = aura_env.child_envs[1].config
    local growVertically = config.growVertically
    local inverse = config.inverse
    local spacing = config.spacing

    for i, regionData in ipairs(activeRegions) do
        local region = regionData.region
        local index = region.state.index

        if index == nil then
            return
        end

        local sign = index > 0 and 1 or -1

        if inverse then
            index = -index
            sign = -sign
        end

        if growVertically then
            positions[i] = {
                0,
                (index - sign / 2) * (region:GetHeight() + spacing)
            }
        else
            positions[i] = {
                (index - sign / 2) * (region:GetWidth() + spacing),
                0
            }
        end
    end
end
