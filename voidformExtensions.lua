-- TSU: UNIT_SPELLCAST_SUCCEEDED:player, UNIT_AURA:player

function(allstates, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local spellId = select(3, ...)
        if spellId ~= 335467 then   -- Devouring Plague
            return false
        end

        local state = allstates[1]
        if state == nil then
            return false
        end

        state.stacks = state.stacks + 1
        state.addedDuration = state.stacks * 2.5
        state.totalDuration = 20 + state.addedDuration

        state.changed = true

        return true
    elseif event == "UNIT_AURA" then
        local updateInfo = select(2, ...)
        if updateInfo == nil then
            return false
        end

        local state = allstates[1]
        if state == nil then
            -- See if we're adding Voidform as an aura.

            local addedAuras = updateInfo.addedAuras
            if addedAuras == nil then
                return false
            end
            for _, addedAura in ipairs(addedAuras) do
                if addedAura.spellId == 194249 then     -- Voidform
                    local state = {}
                    allstates[1] = state

                    state.show = true
                    state.changed = true

                    state.progressType = "static"
                    state.value = 1
                    state.total = 1

                    state.stacks = 0
                    state.addedDuration = 0
                    state.totalDuration = 20

                    state.instanceId = addedAura.auraInstanceID

                    return true
                end
            end

            return false
        else
            -- See if we're removing Voidform as an aura.

            local removedAuras = updateInfo.removedAuraInstanceIDs
            if removedAuras == nil then
                return false
            end
            for _, instanceId in ipairs(removedAuras) do
                if state.instanceId == instanceId then
                    state.show = false
                    state.changed = true

                    return true
                end
            end

            return false
        end
    end
end

-- Custom Variables

{
    stacks = true,
    addedDuration = "number",
    totalDuration = "number"
}
