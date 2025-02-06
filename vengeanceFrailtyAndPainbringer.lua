-- init

aura_env.hasVoidReaver = false

-- TSU: TRIGGER:1:2:3

function(allstates, event, triggerNum, triggerStates)
    local state = allstates[""]
    if state == nil then
        state = {
            ["show"] = true,
            ["changed"] = true,
            ["painbringerStacks"] = 0,
            ["frailtyStacks"] = 0,
            ["drTotal"] = 0,
        }
        allstates[""] = state
    end

    if event == "TRIGGER" then
        local triggerState = triggerStates[""]

        if triggerNum == 3 then
            aura_env.hasVoidReaver = triggerState and
                                     triggerState.stacks and true or false
        else
            if triggerNum == 1 then             -- Painbringer
                state["painbringerStacks"] = triggerState and
                                                       triggerState.stacks or 0
                state["changed"] = true
            elseif aura_env.hasVoidReaver then  -- Frailty
                state["frailtyStacks"] = triggerState and
                                                       triggerState.stacks or 0
                state["changed"] = true
            end

            state["drTotal"] = 2 * state["painbringerStacks"] +
                                                     3 * state["frailtyStacks"]
        end
    end

    return state["changed"]
end

-- custom variables

{
    ["painbringerStacks"] = "number",
    ["frailtyStacks"] = "number",
    ["drTotal"] = "number",
}
