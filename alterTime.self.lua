-------------------------------------------------------------------------------
-- TSU: TRIGGER:1

function(allstates, event, _, triggerStates)
    if event == 'TRIGGER' then
        local triggerState = triggerStates['']
        if triggerState == nil then
            -- The aura has dropped.

            local state = allstates['']
            if state == nil then
                return false
            end

            state['show'] = false
            state['changed'] = true

            return true
        else
            -- The aura has applied.

            allstates[''] = {
                ['show'] = true,
                ['changed'] = true,
                ['progressType'] = 'static',
                ['total'] = UnitHealthMax('player'),
                ['value'] = UnitHealth('player')
            }

            return true
        end
    end
end
