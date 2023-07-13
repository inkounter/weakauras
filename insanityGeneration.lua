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

-- TSU: UNIT_SPELLCAST_START:player, UNIT_SPELLCAST_STOP:player

function(allstates, event, _, _, spellId)
    if event == "UNIT_SPELLCAST_STOP" then
        local state = allstates[""]
        if state == nil then
            return false
        end

        state.show = false
        state.changed = true
        return true
    else
        local gainOnCast = aura_env.generators[spellId]
        if gainOnCast == nil then
            return false
        end

        allstates[""] = {
            ["show"] = true,
            ["changed"] = true,
            ["gainOnCast"] = gainOnCast
        }
        return true
    end
end

-- custom variables

{ ["gainOnCast"] = "number" }
