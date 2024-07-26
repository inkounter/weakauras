-- Show the number of Arcane Charges.  Add an overlay when casting Arcane
-- Blast.

-- TSU: TRIGGER:1:2

function(allstates, event, triggerNum, triggerStates)
    local state = allstates['']
    if state == nil or event ~= 'TRIGGER' then
        -- If this is an 'OPTIONS' event, 'allstates[""]' is a weird state, so
        -- we just overwrite it with a new one.

        state = {
            ['show'] = true,
            ['changed'] = true,
            ['progressType'] = 'static',
            ['total'] = 4,
            ['value'] = UnitPower('player', Enum.PowerType.ArcaneCharges),
            ['additionalProgress'] = {
                [1] = {
                    ['direction'] = 'forward',
                    ['width'] = 0,
                }
            },
        }
        allstates[''] = state

        if event ~= 'TRIGGER' then
            -- This additionally catches 'STATUS' events, which will not have a
            -- 'triggerStates' table.

            return true
        end
    end

    local triggerState = triggerStates['']

    if triggerNum == 1 then
        state['value'] = triggerState['value']
    elseif triggerNum == 2 then
        state['additionalProgress'][1]['width'] = triggerState and 1 or 0
    end

    state['changed'] = true
    return true
end

-- Custom variables

{
    ['value'] = true,
    ['total'] = true,

    ['additionalProgress'] = 1,
}
