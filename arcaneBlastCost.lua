-- Calculate the cost of Arcane Blast at max Arcane Charges.

-- TSU: (none)

function(allstates, event, ...)
    local state = allstates['']
    if state == nil then
        state = {
            ['show'] = true,
        }
        allstates[''] = state
    end

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

    state['changed'] = true
    state['baseCost'] = baseCost
    state['maxCost'] = maxCost

    return true
end

-- custom variables

{
    ['baseCost'] = 'number',
    ['maxCost'] = 'number',
}
