-- TSU: TRIGGER:1

function(allstates, event, triggerNum, triggerStates)
    if event ~= 'TRIGGER' then
        return false
    end

    -- Construct a two-dimensional mapping: 'unitCaster->spellId->stackData',
    -- where 'stackData' is information about the target count of 'spellId' for
    -- that 'unitCaster' and about the max expiration and corresponding
    -- duration.

    local spellMap = {}

    for _, state in pairs(triggerStates) do
        local spells = spellMap[state['unitCaster']]
        if spells == nil then
            spells = {}
            spellMap[state['unitCaster']] = spells
        end

        local stackData = spells[state['spellId']]
        if stackData == nil then
            stackData = {
                ['targetCount'] = 0,
                ['expirationTime'] = 0,
                ['duration'] = 0,
            }
            spells[state['spellId']] = stackData
        end

        stackData['targetCount'] = stackData['targetCount'] + 1
        if state['expirationTime'] > stackData['expirationTime'] then
            stackData['expirationTime'] = state['expirationTime']
            stackData['duration'] = state['duration']
        end
    end

    -- Prune any states in 'allstates' for spells that are not in 'spellMap'.

    local changed = false

    for key, state in pairs(allstates) do
        local unitCaster, spellId = string.match(key, '(.+)%.(.+)')
        spellId = tonumber(spellId)
        if spellMap[unitCaster] == nil
                                   or spellMap[unitCaster][spellId] == nil then
            state['show'] = false
            state['changed'] = true
            changed = true
        end
    end

    -- Add and update states from 'spellMap'.

    for unitCaster, spells in pairs(spellMap) do
        for spellId, stackData in pairs(spells) do
            local key = unitCaster .. '.' .. spellId

            local state = allstates[key]
            if state == nil then
                local spellInfo = C_Spell.GetSpellInfo(spellId)
                state = {
                    ['show'] = true,
                    ['progressType'] = 'timed',
                    ['autoHide'] = true,
                    ['spellId'] = spellId,
                    ['name'] = spellInfo['name'],
                    ['icon'] = spellInfo['iconID'],
                    ['unit'] = unitCaster,
                }
                allstates[key] = state
            end

            if state['expirationTime'] ~= stackData['expirationTime']
                            or state['duration'] ~= stackData['duration']
                            or state['stacks'] ~= stackData['targetCount'] then
                state['expirationTime'] = stackData['expirationTime']
                state['duration'] = stackData['duration']
                state['stacks'] = stackData['targetCount']
                state['changed'] = true
                changed = true
            end
        end
    end

    return changed
end
