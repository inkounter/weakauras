-------------------------------------------------------------------------------
-- trigger (TSU): COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED

function(allstates, event)
    local renownLevel = C_CovenantSanctumUI.GetRenownLevel()
    local state = allstates[1]
    if state == nil then
        state = {}
        allstates[1] = state
    end

    local previousLevel = state.level

    state.show = true
    state.level = C_CovenantSanctumUI.GetRenownLevel()
    state.weeklyCapped = C_CovenantSanctumUI.IsWeeklyRenownCapped()

    if previousLevel == state.level then
        return false
    end

    state.changed = true
    return true
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["level"] = "number",
    ["weeklyCapped"] = "bool",
}
