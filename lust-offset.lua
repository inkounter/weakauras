-------------------------------------------------------------------------------
-- TSU: TRIGGER:1, TRIGGER:2

function(allstates, event, triggerNum, triggerStates)
    if event ~= 'TRIGGER' then
        return false
    end

    local state = allstates['']
    local triggerState = triggerStates['']

    if triggerNum == 1 and triggerState == nil then
        -- The Sated debuff has expired.  Hide this state.

        if state == nil then
            return false
        end

        state['show'] = false
        state['changed'] = true
        return true
    end

    -- We need to populate data into 'state'.

    if state == nil then
        state = {
            ['show'] = true,
            ['progressType'] = 'timed',
            ['autoHide'] = false,
        }
        allstates[''] = state
    end

    if triggerNum == 1 then
        state['satedExpiration'] = triggerState['expirationTime']
        state['satedDuration'] = triggerState['duration']
    else
        if triggerState == nil then
            state['spellCdExpiration'] = nil
            state['spellCdDuration'] = nil
        else
            state['spellCdExpiration'] = triggerState['expirationTime']
            state['spellCdDuration'] = triggerState['duration']
        end
    end

    if state['satedExpiration'] == nil then
        -- Wait for this trigger to come in.

        return false
    end

    if state['spellCdExpiration'] ~= nil then
        -- The spell is on CD.  Show the difference.

        local difference = state['satedExpiration'] - state['spellCdExpiration']
        local absDifference = math.abs(difference)

        state['sign'] = difference < 0 and '-' or '+'
        state['difference'] = difference
        state['absDifference'] = absDifference

        state['paused'] = true
        state['expirationTime'] = state['spellCdExpiration']
        state['duration'] = absDifference
        state['remaining'] = absDifference
    else
        -- The spell is not on CD.  Show the remaining duration on Sated.

        state['paused'] = false
        state['expirationTime'] = state['satedExpiration']
        state['duration'] = state['satedDuration']
    end

    state['changed'] = true
    return true
end


-------------------------------------------------------------------------------
-- Custom Variables

{
    ['expirationTime'] = true,
    ['duration'] = true,

    ['paused'] = 'bool',

    ['sign'] = 'string',
    ['difference'] = 'number',
    ['absDifference'] = 'number',
}
