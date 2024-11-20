function(allstates, event, triggerNum, triggerStates)
    if event ~= "TRIGGER" then
        return false
    end

    local state = allstates[""]
    for k, _ in pairs(triggerStates) do
        state = allstates[""]
        if state == nil then
            state = { ["show"] = true, ["changed"] = true }
            allstates[""] = state

            return true
        else
            return false
        end
    end

    if state then
        state["show"] = false
        state["changed"] = true

        return true
    else
        return false
    end
end
