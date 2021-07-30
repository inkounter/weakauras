-------------------------------------------------------------------------------
-- trigger (TSU): PLAYER_EQUIPMENT_CHANGED, UNIT_SPELLCAST_SUCCEEDED:player

function(allstates, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        aura_env.isWearingNaturesFury = WeakAuras.CheckForItemBonusId(7471)
    else
        local unit, castGuid, spellId = ...
        if spellId == 325886 then
            local state = allstates[1]
            if state == nil then
                state = {}
                allstates[1] = state
            end

            state.show = true
            state.isWearingNaturesFury = aura_env.isWearingNaturesFury
            state.progressType = "timed"
            state.duration = 12 + (state.isWearingNaturesFury and 3 or 0)
            state.expirationTime = GetTime() + state.duration
            state.autoHide = true

            state.changed = true
            return true
        end
    end
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["expirationTime"] = true,
    ["duration"] = true,
    ["isWearingNaturesFury"] = "bool",
}
