-------------------------------------------------------------------------------
-- init

aura_env.spenders ={
    [8004] = true, -- Healing Surge
    [1064] = true, -- Chain Heal
    [51505] = true, -- Lava Burst
    [188443] = true, -- Chain Lightning
    [117014] = true, -- Elemental Blast
    [188196] = true, -- Lightning Bolt
    [452201] = true, -- Tempest
    [320674] = true -- Chain Harvest
}

aura_env.maxStackConsumption = 5
aura_env.currentStacks = 0

if aura_env.saved == nil then
    aura_env.saved = {}
end

-------------------------------------------------------------------------------
-- TSU: TRIGGER:2:3, UNIT_SPELLCAST_SUCCEEDED:player, PLAYER_ENTERING_WORLD

function(allstates, event, ...)
    local state = allstates[""]

    if event == "STATUS" or event == "OPTIONS" then
        -- Pull the progress value from the saved state.

        if state == nil then
            state = {
                ["show"] = true,
                ["changed"] = true,
                ["progressType"] = "static",
                ["value"] = 0,
                ["total"] = 40,
                ["stacks"] = 0,
            }
            allstates[""] = state
        end

        local saved = aura_env.saved and aura_env.saved["value"] or 0
        state["stacks"] = saved
        state["value"] = saved
        return true
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Note that WeakAuras fires this event *after* it fires "STATUS".

        local isLogin = ...
        if isLogin then
            -- Reset the progress to 0.

            aura_env.saved["value"] = 0

            state["stacks"] = 0
            state["value"] = 0
            state["changed"] = true

            return true
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local spellId = select(3, ...)
        if aura_env.spenders[spellId] == nil
                                            or aura_env.currentStacks == 0 then
            return false
        end

        local progressValue = state["value"] +
                                         math.min(aura_env.currentStacks,
                                                  aura_env.maxStackConsumption)
        if progressValue >= 40 then
            progressValue = progressValue - 40
        end

        aura_env.saved["value"] = progressValue

        state["stacks"] = progressValue
        state["value"] = progressValue
        state["changed"] = true

        return true
	elseif event == "TRIGGER" then
        local triggerNum, triggerStates = ...

        if triggerNum == 3 then
            -- Trigger 3 gives us info on whether "Overflowing Maelstrom" is
            -- talented.

            if triggerStates[""] ~= nil then
                aura_env.maxStackConsumption = 10
            else
                aura_env.maxStackConsumption = 5
            end

            return false
        else
            -- Trigger 2 gives us info on how many Maelstrom Weapon stacks we
            -- have.

            aura_env.currentStacks = triggerStates[""]["stacks"] or 0

            return false
        end
    end
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["value"] = true,
    ["total"] = true,
    ["stacks"] = true,
}
