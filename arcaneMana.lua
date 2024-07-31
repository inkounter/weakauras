-- Show a mana bar, but add additional fields and an overlay for the cost of
-- Arcane Blast at max Arcane Charges.

-- TSU: TRIGGER:1

function(allstates, event, ...)
    local state = allstates['']

    if event == 'TRIGGER' then
        if state == nil then
            -- Alias to the other trigger's state table.

            local _, triggerStates = ...
            state = triggerStates['']
            allstates[''] = state

            state['additionalProgress'] = {
                [1] = {
                    ['direction'] = 'backward',
                }
            }

            if aura_env.baseCost ~= nil then
                state['baseCost'] = aura_env.baseCost
                state['maxCost'] = aura_env.maxCost
                state['additionalProgress'][1]['width'] = aura_env.maxCost
            end
        end

        if state['maxCost'] ~= nil then
            state['maxPercentCost'] = state['maxCost'] / state['total'] * 100
        end

        state['changed'] = true

        return true
    else
        local currentCost = nil
        local currentCosts = C_Spell.GetSpellPowerCost(30451)
        for i = 1, #currentCosts do
            if currentCosts[i].type == Enum.PowerType.Mana then
                currentCost = currentCosts[i].cost
                break
            end
        end

        if currentCost == nil then
            return false
        end

        local currentCharges = UnitPower('player', Enum.PowerType.ArcaneCharges)
        local maxCharges = UnitPowerMax('player', Enum.PowerType.ArcaneCharges)
        local baseCost = currentCost / (currentCharges + 1)
        local maxCost = baseCost * (maxCharges + 1)

        if state ~= nil then
            state['changed'] = true
            state['baseCost'] = baseCost
            state['maxCost'] = maxCost
            state['maxPercentCost'] = maxCost / state['total'] * 100
            state['additionalProgress'][1]['width'] = maxCost

            return true
        else
            aura_env.baseCost = baseCost
            aura_env.maxCost = maxCost

            return false
        end
    end
end

-- custom variables

{
    ['additionalProgress'] = 1,
    ['baseCost'] = 'number',
    ['maxCost'] = 'number',
    ['maxPercentCost'] = 'number',
}
