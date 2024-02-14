-- TSU: TRIGGER:1, TRIGGER:2, TRIGGER:3

function(allstates, event, triggerNum, triggerStates)
    if event ~= 'TRIGGER' then
        return false
    end

    local state = allstates['']
    if triggerNum == 1 then
        -- Spell cast succeeded.

        if state == nil then
            state = {
                ['show'] = true,
                ['progressType'] = 'timed',
                ['duration'] = 40,
                ['autoHide'] = true,
            }

            allstates[''] = state
        end

        state['expirationTime'] = GetTime() + 40
        state['stacks'] = 3
        state['changed'] = true

        return true
    end

    if state == nil then
        -- We don't have a state to modify.  Return early.

        return false
    end

    -- Not sure why we're getting duplicate events for the same trigger, but
    -- ignore the one with a nil CLEU timestamp.

    local eventTime, _ = CombatLogGetCurrentEventInfo()
    if eventTime == nil then
        return false
    end

    if triggerNum == 2 then
        -- Spell aura removed dose.

        state['stacks'] = state['stacks'] - 1
        state['changed'] = true

        return true
    elseif triggerNum == 3 then
        -- Spell aura removed.

        state['show'] = false
        state['changed'] = true

        return true
    end

    return false
end
