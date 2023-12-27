-------------------------------------------------------------------------------
-- TSU: TRIGGER:1, TRIGGER:3

function(allstates, event, triggerNum, updatedTriggerStates)
    if event == 'OPTIONS' then
        return false
    end

    local state = allstates['']
    if state == nil then
        state = {
            ['show'] = true,
            ['changed'] = true,
            ['progressType'] = 'static',
            ['stacks'] = 0,
            ['value'] = 0,
            ['total'] = aura_env.config.maxStacks
        }
        allstates[''] = state
    end

    if event == 'STATUS' then
        return true
    end

    local triggerState = updatedTriggerStates['']

    if triggerNum == 3 then
        if triggerState == nil then
            -- The max-stack buff just dropped, so We're at 0 stacks.

            state['stacks'] = 0
            state['atMaxStacks'] = false
        else
            -- We just gained the max-stack buff.

            state['stacks'] = state['total']
            state['atMaxStacks'] = true
        end

        state['value'] = state['stacks']
        state['changed'] = true

        return true
    else
        if triggerState == nil then
            -- The stacking buff just dropped.  Check if we're at max stacks.

            if state['atMaxStacks'] then
                return false
            end

            state['stacks'] = 0
        else
            state['stacks'] = triggerState['stacks']
        end

        state['atMaxStacks'] = false
        state['value'] = state['stacks']
        state['changed'] = true

        return true
    end
end


-------------------------------------------------------------------------------
-- Custom Variables

{
    ['value'] = true,
    ['total'] = true,
    ['stacks'] = true,

    ['atMaxStacks'] = 'bool'
}
