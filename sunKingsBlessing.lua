-- TSU: TRIGGER:1

function(allstates, event, _, updatedTriggerStates)
    if event == "OPTIONS" then
        return false
    end

    local state = allstates[""]
    if state == nil then
        state = {
            ["show"] = true,
            ["changed"] = true,
            ["progressType"] = "static",
            ["stacks"] = 0,
            ["value"] = 0,
            ["total"] = 8
        }
        allstates[""] = state
    end

    if event == "STATUS" then
        return true
    end

    local triggerState = updatedTriggerStates[""]
    if triggerState == nil then
        state["stacks"] = 0
        state["value"] = state["stacks"]
        state["changed"] = true

        return true
    end

    if triggerState["spellId"] == 383883 then   -- Fury of the Sun King
        state["stacks"] = 8
        state["value"] = state["stacks"]
        state["changed"] = true

        return true
    else                                        -- Sun King's Blessing
        state["stacks"] = triggerState["stacks"]
        state["value"] = state["stacks"]
        state["changed"] = true

        return true
    end
end

-- custom variables

{
    ["value"] = true,
    ["total"] = true,
    ["stacks"] = true
}
