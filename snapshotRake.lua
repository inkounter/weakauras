-------------------------------------------------------------------------------
-- TSU: UNIT_AURA:player, UNIT_AURA:nameplate, NAME_PLATE_UNIT_REMOVED, NAME_PLATE_UNIT_ADDED, PLAYER_TARGET_CHANGED

function(allstates, event, unit, updateInfo)
    if event == 'UNIT_AURA' and unit == 'player' then
        if not aura_env.hasSuddenAmbush then
            -- Check if Sudden Ambush is being added.  If it is, then set
            -- 'aura_env.hasSuddenAmbush'.  Return 'false'.

            if updateInfo['addedAuras'] == nil then
                return false
            end

            for _, data in ipairs(updateInfo['addedAuras']) do
                if data['spellId'] == 391974 then
                    aura_env.hasSuddenAmbush = data['auraInstanceID']
                    return false
                end
            end

            return false
        else
            -- Check if Sudden Ambush is being removed.  If it is, then clear
            -- 'aura_env.hasSuddenAmbush'.  Return 'false'.

            if updateInfo['removedAuraInstanceIDs'] == nil then
                return false
            end

            for _, auraInstanceId in ipairs(
                                       updateInfo['removedAuraInstanceIDs']) do
                if auraInstanceId == aura_env.hasSuddenAmbush then
                    aura_env.hasSuddenAmbush = nil
                    return false
                end
            end
        end
    elseif event == 'UNIT_AURA' then
        -- Check if we already have a state for Rake on this unit.

        local unitGuid = UnitGUID(unit)
        local state = allstates[unitGuid]
        if state == nil then
            -- Check if the aura being added is Rake from the player.  If it
            -- is, then create a state for it.  Include in the state whether
            -- 'aura_env.hasSuddenAmbush' is not 'nil'. 

            if updateInfo['addedAuras'] == nil then
                return false
            end

            for _, data in ipairs(updateInfo['addedAuras']) do
                if (data['sourceUnit'] == 'player' 
                                            and data['spellId'] == 155722) then
                    allstates[unitGuid] = {
                        ['show'] = true,
                        ['changed'] = true,
                        ['progressType'] = 'timed',
                        ['autoHide'] = true,
                        ['name'] = data['name'],
                        ['icon'] = data['icon'],
                        ['spellId'] = data['spellId'],

                        ['unit'] = unit,
                        ['expirationTime'] = data['expirationTime'],
                        ['duration'] = data['duration'],

                        ['auraInstanceId'] = data['auraInstanceID'],
                        ['suddenAmbush'] = aura_env.hasSuddenAmbush and true or false,
                        ['isTarget'] = UnitIsUnit(unit, 'target')
                    }

                    return true
                end
            end
        else
            -- Check if the Rake from the player is being updated.

            if updateInfo['updatedAuraInstanceIDs'] == nil then
                return false
            end

            for _, auraInstanceId in ipairs(
                                       updateInfo['updatedAuraInstanceIDs']) do
                if state['auraInstanceId'] == auraInstanceId then
                    local data = C_UnitAuras.GetAuraDataByAuraInstanceID(
                                                                unit,
                                                                auraInstanceId)

                    -- The expiration time sometimes gets micro-adjusted with
                    -- updates.  Don't update the 'suddenAmbush' value for
                    -- these jitters.

                    local timeDifference = math.abs(state['expirationTime']
                                                      - data['expirationTime'])
                    if timeDifference >= 0.5 then
                        state['suddenAmbush'] = aura_env.hasSuddenAmbush and true or false
                    end

                    state['changed'] = true

                    state['unit'] = unit
                    state['expirationTime'] = data['expirationTime']
                    state['duration'] = data['duration']

                    return true
                end
            end

            return false
        end
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        -- Check if this unit has a state.  If it does, set its 'unit' value to
        -- 'nil'.

        local unitGuid = UnitGUID(unit)
        local state = allstates[unitGuid]

        if state == nil then
            return false
        end

        state['changed'] = true
        state['unit'] = nil

        return true
    elseif event == 'NAME_PLATE_UNIT_ADDED' then
        -- Check if this unit has a state.  If it does, set its 'unit' value to
        -- this unit.

        local unitGuid = UnitGUID(unit)
        local state = allstates[unitGuid]

        if state == nil then
            return false
        end

        state['changed'] = true
        state['unit'] = unit

        return true
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- If the previous target has a state, clear its 'isTarget' value.

        local changed = false

        if aura_env.targetGuid ~= nil then
            local state = allstates[aura_env.targetGuid]
            if state ~= nil then
                state['changed'] = true
                state['isTarget'] = false

                changed = true
            end
        end

        aura_env.targetGuid = UnitGUID("target")
        if aura_env.targetGuid ~= nil then
            local state = allstates[aura_env.targetGuid]
            if state ~= nil then
                state['changed'] = true
                state['isTarget'] = true

                changed = true
            end
        end

        return changed
    elseif event == 'OPTIONS' then
        -- Create a dummy state to test out the display options.

        local rakeSpellId = 155722
        local name, _, icon = GetSpellInfo(rakeSpellId)

        allstates['dummy'] = {
            ['show'] = true,
            ['changed'] = true,
            ['progressType'] = 'timed',
            ['autoHide'] = true,
            ['name'] = name,
            ['icon'] = icon,
            ['spellId'] = rakeSpellId,

            ['unit'] = 'nameplate1',
            ['expirationTime'] = GetTime() + 12,
            ['duration'] = 12,

            ['auraInstanceId'] = 0,
            ['suddenAmbush'] = true,
            ['isTarget'] = true
        }
    end
end

-------------------------------------------------------------------------------
-- Custom Variables

{
    ['expirationTime'] = true,
    ['duration'] = true,

    ['unit'] = 'string',
    ['suddenAmbush'] = 'bool',
    ['isTarget'] = 'bool',
}
