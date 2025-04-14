-- TSU: TRIGGER:1

function(allstates, event, ...)
    if event ~= "TRIGGER" then
        return false
    end

    local _, triggerStates = ...
    local targets = {}  -- unit GUIDs to number of tracked casts at them
    local state = { ["numSpellsTargetedBy"] = 0 }

    for _, triggerState in pairs(triggerStates) do
        local destUnit = triggerState["destUnit"]
        if destUnit ~= nil and UnitGroupRolesAssigned(destUnit) ~= "TANK" then
            local destUnitGuid = UnitGUID(destUnit)
            if destUnitGuid ~= nil then
                targets[destUnitGuid] = (targets[destUnitGuid] or 0) + 1

                if targets[destUnitGuid] > state["numSpellsTargetedBy"] then
                    state["numSpellsTargetedBy"] = targets[destUnitGuid]
                    state["unit"] = destUnit
                    state["icon"] = triggerState["icon"]
                    state["name"] = triggerState["spell"]
                    state["spellId"] = triggerState["spellId"]
                end
            end
        end
    end

    if state["numSpellsTargetedBy"] >= 2 then
        allstates[""] = state
        state["stacks"] = state["numSpellsTargetedBy"]
        state["show"] = true
        state["changed"] = true
        return true
    else
        local state = allstates[""]
        if state == nil then
            return false
        end
            state["show"] = false
            state["changed"] = true
            return true
    end
end

-- custom variables

{
    ["stacks"] = true,

    ["numSpellsTargetedBy"] = "number",
    ["spellId"] = "number",
}
