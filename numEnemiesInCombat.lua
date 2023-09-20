-------------------------------------------------------------------------------
-- TSU: TRIGGER:1

function(allstates, event, triggerNum, updatedStates)
    local state = allstates[""]
    if state == nil then
        state = {
            ["show"] = true,
            ["stacks"] = 0,
            ["changed"] = true,
        }
        allstates[""] = state
    end

    if event == "TRIGGER" then
        local numEnemies = 0
        for _, _ in pairs(updatedStates) do
            numEnemies = numEnemies + 1
        end

        if state["stacks"] ~= numEnemies then
            state["stacks"] = numEnemies
            state["changed"] = true
        end
    end

    return state["changed"]
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["stacks"] = true
}
