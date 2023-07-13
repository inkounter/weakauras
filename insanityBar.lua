-- init

aura_env.generators = {
    [73510]  = 4,   -- Mind Spike
    [407466] = 6,   -- Mind Spike: Insanity
    [8092]   = 6,   -- Mind Blast
    [34914]  = 4,   -- Vampiric Touch
    [375901] = 10,  -- Mindgames
    [120644] = 10,  -- Halo
    [391109] = 30,  -- Dark Ascension
    [32375]  = 4,   -- Mass Dispel
}

-- TSU: UNIT_SPELLCAST_START:player, UNIT_SPELLCAST_STOP:player, UNIT_POWER_FREQUENT:player, UNIT_MAXPOWER:player, STATUS

function(allstates, event, ...)
    local state = allstates[""]
    if state == nil then
        state = {
            ["show"] = true,
            ["progressType"] = "static",
            ["additionalProgress"] = {
                [1] = {
                    ["direction"] = "forward",
                    ["width"] = 0
                }
            },
            ["castingGain"] = 0
        }
        allstates[""] = state
    end

    if event == "STATUS" or event == "UNIT_MAXPOWER" then
        state["total"] = UnitPowerMax("player", Enum.PowerType.Insanity)
        state["value"] = UnitPower("player", Enum.PowerType.Insanity)
        state["valueDeficit"] = state["total"] - state["value"]
        state["valueAfterCast"] = math.min(
                                         state["value"] + state["castingGain"],
                                         state["total"])
        state["valueDeficitAfterCast"] = (state["total"]
                                                     - state["valueAfterCast"])
        state["changed"] = true

        return true
    elseif event == "UNIT_POWER_FREQUENT" then
        local powerType = select(2, ...)
        if powerType ~= "INSANITY" then
            return false
        end

        state["value"] = UnitPower("player", Enum.PowerType.Insanity)
        state["valueDeficit"] = state["total"] - state["value"]
        state["valueAfterCast"] = math.min(
                                         state["value"] + state["castingGain"],
                                         state["total"])
        state["valueDeficitAfterCast"] = (state["total"]
                                                     - state["valueAfterCast"])
        state["changed"] = true

        return true
    elseif event == "UNIT_SPELLCAST_STOP" then
        if 0 == state["castingGain"] then
            return false
        end

        state["castingGain"] = 0
        state["additionalProgress"][1]["width"] = 0
        state["valueAfterCast"] = state["value"]
        state["valueDeficitAfterCast"] = (state["total"]
                                                     - state["valueAfterCast"])
        state["changed"] = true

        return true
    elseif event == "UNIT_SPELLCAST_START" then
        local spellId = select(3, ...)
        local castingGain = aura_env.generators[spellId]
        if castingGain == nil then
            return false
        end

        state["castingGain"] = castingGain
        state["additionalProgress"][1]["width"] = castingGain
        state["valueAfterCast"] = math.min(state["value"] + castingGain,
                                           state["total"])
        state["valueDeficitAfterCast"] = (state["total"]
                                                     - state["valueAfterCast"])
        state["changed"] = true

        return true
    end
end

-- custom variables

{
    ["value"] = true,
    ["total"] = true,

    ["additionalProgress"] = 1,

    ["castingGain"] = "number",
    ["valueDeficit"] = "number",
    ["valueAfterCast"] = "number",
    ["valueDeficitAfterCast"] = "number"
}
