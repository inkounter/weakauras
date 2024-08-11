-- TSU: TRIGGER:1:2:3

function(allstates, event, triggerNum, triggerStates)
    local state = allstates['']
    if state == nil or event ~= 'TRIGGER' then
        -- If this is an 'OPTIONS' event, 'allstates[""]' is a weird state, so
        -- we just overwrite it with a new one.

        state = {
            ['show'] = true,
            ['changed'] = true,
            ['progressType'] = 'static',
            ['total'] = UnitPowerMax('player', Enum.PowerType.SoulShards),
            ['value'] = UnitPower('player', Enum.PowerType.SoulShards),
            ['additionalProgress'] = {
                [1] = {
                    ['direction'] = 'forward',
                    ['width'] = 0,
                }
            },
            ['pendingProgress'] = 0,
            ['pendingValue'] = UnitPower('player', Enum.PowerType.SoulShards),
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
        state['pendingValue'] = math.min(
                                     state['total'],
                                     state['value'] + state['pendingProgress'])
    elseif triggerNum == 2 then
        local pendingProgress = 0
        if triggerState == nil then
            pendingProgress = 0
        elseif triggerState['spellId'] == 29722 then
            pendingProgress = (aura_env.hasDiabolicEmbers and 2 or 1) * 0.2
        else
            pendingProgress = 1
        end
        state['additionalProgress'][1]['width'] = pendingProgress
        state['pendingProgress'] = pendingProgress
        state['pendingValue'] = math.min(state['total'],
                                         state['value'] + pendingProgress)
    elseif triggerNum == 3 then
        aura_env.hasDiabolicEmbers = triggerState and true or false
    end

    state['changed'] = true
    return true
end

-- Custom Variables

{
    ["value"] = true,
    ["total"] = true,

    ["additionalProgress"] = 1,
    ["pendingProgress"] = "number",
    ["pendingValue"] = "number",
}
