-------------------------------------------------------------------------------
-- TSU: TRIGGER:1, TRIGGER:2

function(allstates, event, ...)
    if event == 'TRIGGER' then
        local triggerNum, triggerStates = ...
        local triggerState = triggerStates['']

        if triggerNum == 2 then
            -- Cache this state.

            if triggerState['charges'] == 0 then
                -- Call Dreadstalkers is on CD.

                aura_env.cdExpiration = triggerState['expirationTime']

                return false
            else
                -- Call Dreadstalkers is now off CD.  Unpause the state if
                -- there is one.

                aura_env.cdExpiration = nil

                local state = allstates['']
                if state == nil then
                    return false
                end

                state['changed'] = true
                state['paused'] = false

                return true
            end
        elseif triggerNum == 1 then
            if triggerState == nil then
                -- Trigger 1 just untriggered.  Do nothing.

                return false
            end

            local state = allstates['']

            if state == nil then
                state = {
                    ['show'] = true,
                    ['progressType'] = 'timed',
                    ['autoHide'] = true,
                }

                allstates[''] = state
            end

            local procExpiration = triggerState['expirationTime']
            local difference = nil

            if aura_env.cdExpiration ~= nil then
                difference = procExpiration - aura_env.cdExpiration
                state['paused'] = true
                state['remaining'] = difference
            else
                difference = 20
                state['paused'] = nil
            end

            state['changed'] = true
            state['expirationTime'] = procExpiration
            state['duration'] = difference

            return true
        end
    end
end


-------------------------------------------------------------------------------
-- Custom Variables

{
    ['expirationTime'] = true,
    ['duration'] = true,

    ['paused'] = 'bool',
}
