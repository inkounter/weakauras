-------------------------------------------------------------------------------
-- init

-- Spell IDs for astral power generators.
aura_env.generatorId = {
    ["Wrath"] = 190984,
    ["Starfire"] = 194153,
    ["StellarFlare"] = 202347,
}

-- Base astral power generation values for each of these spells.
local generatorBase = {
    [aura_env.generatorId["Wrath"]]        = 6,
    [aura_env.generatorId["Starfire"]]     = 8,
    [aura_env.generatorId["StellarFlare"]] = 12,
}

aura_env.hasTalent = {
    ["SoulOfTheForest"] = false,
    ["WildSurges"] = false,
    ["MoonGuardian"] = false,
}

aura_env.generator = {}

aura_env.eclipseId = {
    ["Solar"] = 48517,
    ["Lunar"] = 48518,
}

-- A mapping from eclipse spell ID to its end time (as a `GetTime()` value),
-- which may be in the past.
aura_env.eclipseExpirationTime = {
    [aura_env.eclipseId["Solar"]] = 0,
    [aura_env.eclipseId["Lunar"]] = 0,
}

-- Read the state of `aura_env.hasTalent` and update `aura_env.generator` with
-- each spell's generated value (outside of eclipses).
aura_env.calculateGenerators = function()
    for k, v in pairs(generatorBase) do
        aura_env.generator[k] = v
    end

    if aura_env.hasTalent["WildSurges"] then
        aura_env.generator[aura_env.generatorId["Wrath"]] = 2 +
                              aura_env.generator[aura_env.generatorId["Wrath"]]
        aura_env.generator[aura_env.generatorId["Starfire"]] = 2 +
                           aura_env.generator[aura_env.generatorId["Starfire"]]
    end

    if aura_env.hasTalent["MoonGuardian"] then
        aura_env.generator[aura_env.generatorId["Starfire"]] = 2 +
                           aura_env.generator[aura_env.generatorId["Starfire"]]
    end
end

-------------------------------------------------------------------------------
-- TSU: TRIGGER:1:2:3:4:5:6

function(allstates, event, triggerNum, triggerStates)
    local state = allstates[""]
    if state == nil or event ~= "TRIGGER" then
        -- Reset `allstates[""]`.

        state = {
            ["show"] = true,
            ["changed"] = true,
            ["progressType"] = "static",
            ["total"] = UnitPowerMax("player", Enum.PowerType.LunarPower),
            ["value"] = UnitPower("player", Enum.PowerType.LunarPower),
            ["additionalProgress"] = {
                [1] = {
                    ["direction"] = "forward",
                    ["width"] = 0,
                }
            },
            ["pendingProgress"] = 0,
            ["pendingValue"] = UnitPower("player", Enum.PowerType.LunarPower),
        }
        allstates[""] = state

        -- Also reset the talents.

        for k, _ in pairs(aura_env.hasTalent) do
            aura_env.hasTalent[k] = false
        end

        if event ~= "TRIGGER" then
            return true
        end
    end

    local triggerState = triggerStates[""]

    if triggerNum == 1 then         -- power
        state["value"] = triggerState["value"]
        state["pendingValue"] = math.min(
                                     state["total"],
                                     state["value"] + state["pendingProgress"])
    elseif triggerNum == 2 then     -- cast
        local pendingProgress = 0
        if triggerState ~= nil
                    and triggerState["spellId"] ~= nil
                    and aura_env.generator[triggerState["spellId"]] ~= nil then
            local spellId = triggerState["spellId"]
            pendingProgress = aura_env.generator[spellId]

            -- Apply modifiers for Wrath and Starfire depending on eclipses.

            if spellId == aura_env.generatorId["Wrath"]
                            or spellId == aura_env.generatorId["Starfire"] then
                local castFinishesInSolarEclipse =
                            triggerState["expirationTime"] <=
                                    aura_env.eclipseExpirationTime[
                                                   aura_env.eclipseId["Solar"]]
                local castFinishesInLunarEclipse =
                            triggerState["expirationTime"] <=
                                    aura_env.eclipseExpirationTime[
                                                   aura_env.eclipseId["Lunar"]]

                if spellId == aura_env.generatorId["Wrath"] then
                    if castFinishesInLunarEclipse then
                        -- 4P tier bonus gives +2 for each active eclipse.

                        pendingProgress = 2 + pendingProgress
                    end

                    if castFinishesInSolarEclipse then
                        -- 4P tier bonus gives +2 for each active eclipse.

                        pendingProgress = 2 + pendingProgress

                        -- Soul of the Forest gives x1.6.

                        pendingProgress = 1.6 * pendingProgress
                    end
                elseif spellId == aura_env.generatorId["Starfire"] then
                    if castFinishesInSolarEclipse then
                        -- 4P tier bonus gives +5 for each active eclipse.

                        pendingProgress = 5 + pendingProgress
                    end

                    if castFinishesInLunarEclipse then
                        -- 4P tier bonus gives +5 for each active eclipse.

                        pendingProgress = 5 + pendingProgress
                    end

                    -- Soul of the Forest gives up to x1.6, but for simplicity,
                    -- we assume that Starfire will hit only one target, so we
                    -- don't apply a multiplier.
                end

                -- Round the value to the nearest integer.

                pendingProgress = math.floor(pendingProgress + 0.5)
            end
        end

        state["additionalProgress"][1]["width"] = pendingProgress
        state["pendingProgress"] = pendingProgress
        state["pendingValue"] = math.min(state["total"],
                                         state["value"] + pendingProgress)
    elseif triggerNum == 3 then     -- eclipses
        for _, eclipseState in pairs(triggerStates) do
            aura_env.eclipseExpirationTime[eclipseState["spellId"]] =
                                                 eclipseState["expirationTime"]
        end
        return false
    elseif triggerNum == 4 then     -- talent: Soul of the Forest
        aura_env.hasTalent["SoulOfTheForest"] = triggerState and true or false
        aura_env.calculateGenerators()
        return false
    elseif triggerNum == 5 then     -- talent: Wild Surges
        aura_env.hasTalent["WildSurges"] = triggerState and true or false
        aura_env.calculateGenerators()
        return false
    elseif triggerNum == 6 then     -- talent: Moon Guardian
        aura_env.hasTalent["MoonGuardian"] = triggerState and true or false
        aura_env.calculateGenerators()
        return false
    end

    state["changed"] = true
    return true
end

-- Custom Variables

{
    ["value"] = true,
    ["total"] = true,

    ["additionalProgress"] = 1,
    ["pendingProgress"] = "number",
    ["pendingValue"] = "number",
}
