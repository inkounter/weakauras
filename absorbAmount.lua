-- TSU: TRIGGER:1

function(allstates, event, triggerNum, triggerStates)
    if event ~= "TRIGGER" or triggerNum ~= 1 then
        return false
    end

    -- Reuse the same state table.

    local state = triggerStates[""]
    allstates[""] = state
    state["changed"] = true
    state["absorbPercent"] = state["absorb"] / state["maxhealth"] * 100

    return true
end

-- custom variables

{
    ["absorbPercent"] = "number",
    ["absorb"] = "number",
}
