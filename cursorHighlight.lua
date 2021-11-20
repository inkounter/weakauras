-------------------------------------------------------------------------------
-- TSU: MODIFIER_STATE_CHANGED, PLAYER_STARTED_TURNING, PLAYER_STOPPED_TURNING, PLAYER_STARTED_LOOKING, PLAYER_STOPPED_LOOKING

function(allstates, event, ...)
    if event == "MODIFIER_STATE_CHANGED" then
        local modifier, active = ...
        active = (active == 1)

        -- Initialize the state.

        local state = allstates[1]
        if state == nil then
            state = {
                ["show"] = true,
                ["changed"] = true,
                ["modify"] = false,
            }

            allstates[1] = state

            return true
        end

        -- Return early if ignoring modifiers.

        if (aura_env.config.blockModifierWhenLooking and aura_env.looking)
        or (aura_env.config.blockModifierWhenTurning and aura_env.turning) then
            return false
        end

        -- Update the state.

        local wasModified = state.modify
        if not wasModified and active then
            state.modify = true
            state.changed = true
            return true
        elseif wasModified and not active then
            state.modify = false
            state.changed = true
            return true
        end

        return false
    else
        if aura_env.config.blockModifierWhenLooking then
            if event == "PLAYER_STARTED_LOOKING" then
                aura_env.looking = true

                -- Reset the state to be not modified.

                local state = allstates[1]
                if state.modify then
                    state.modify = false
                    state.changed = true
                    return true
                end

                return false
            elseif event == "PLAYER_STOPPED_LOOKING" then
                aura_env.looking = false
                return false
            end
        end

        if aura_env.config.blockModifierWhenTurning then
            if event == "PLAYER_STARTED_TURNING" then
                aura_env.turning = true

                -- Reset the state to be not modified.

                local state = allstates[1]
                if state.modify then
                    state.modify = false
                    state.changed = true
                    return true
                end

                return false
            elseif event == "PLAYER_STOPPED_TURNING" then
                aura_env.turning = false
                return false
            end
        end
    end
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["modify"] = "bool"
}
