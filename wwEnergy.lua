-------------------------------------------------------------------------------
-- TSU: UNIT_POWER_FREQUENT:player, UNIT_SPELL_HASTE:player

function(allstates, event, ...)
    if event == "UNIT_POWER_FREQUENT" then
        -- Don't update the state in response to 'UNIT_SPELL_HASTE' events.

        local powerType = select(2, ...)
        if powerType ~= "ENERGY" and powerType ~= nil then
            return false
        end

        local maxPower = UnitPowerMax("player", Enum.PowerType.Energy)

        -- Set the state for the energy bar.

        local state = allstates[1]
        if state == nil then
            state = {
                ["show"] = true,
                ["progressType"] = "static"
            }
            allstates[1] = state
        end

        state.changed = true
        state.total = maxPower
        state.value = UnitPower("player", Enum.PowerType.Energy)
    end

    -- Still return 'true' for 'UNIT_SPELL_HASTE' events.  This allows the
    -- custom text code to run additional code to manipulate the regions in
    -- response to these events.

    return true
end

-------------------------------------------------------------------------------
-- custom text code

function()
    local tickNum = 0

    for _, subregion in ipairs(aura_env.region.subRegions) do
        if subregion.type and subregion.type == "subtick" then
            tickNum = tickNum + 1

            if tickNum == 1 then
                -- Treat this as the Fists of Fury energy limit.  Note that the
                -- energy gained during a Fists of Fury channel does not vary
                -- with haste; more haste increases the energy regen rate, but
                -- it also reduces the channel time of Fists of Fury by the
                -- exact same multiplier.  The energy gained does change,
                -- however, based on whether the Ascension talent is selected,
                -- which increases energy regeneration without modifying haste.

                local hasAscension = select(
                                4,
                                GetTalentInfoByID(22098, GetActiveSpecGroup()))
                subregion:SetTickPlacement(hasAscension and 44 or 40)
            elseif tickNum == 2 then
                -- Treat this as the GCD energy limit.  Note that the majority
                -- of windwalker rotational abilities incur a GCD of exactly
                -- 1.0 second, regardless of haste.

                local energyRegenRate = GetPowerRegen()
                subregion:SetTickPlacement(energyRegenRate)

                -- Break the loop.

                break
            end
        end
    end
end
