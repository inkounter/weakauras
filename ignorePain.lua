-------------------------------------------------------------------------------
-- init

aura_env.singleState = {
    ["icon"] = select(3, GetSpellInfo(190456)),
    ["progressType"] = "static",
    ["autoHide"] = not aura_env.config.alwaysShow,
    ["show"] = aura_env.config.alwaysShow
}

local getSpellTooltipAmount = function()
    -- Return the absorption amount listed in Ignore Pain's spell tooltip.

    local amount = GetSpellDescription(190456):match("%%.+%d")

    -- On game restart, the returned description is sometimes an empty string,
    -- so the match is 'nil'.  When it is, use an arbitrary, nonzero amount.

    if amount == nil then
        return 1
    else
        amount = amount:gsub("%D","")
        return tonumber(amount)
    end
end

aura_env.calculateState = function(state)
    -- Calculate the Ignore Pain values and store the results into the
    -- specified 'state'.

    -- Retrieve the state of the current Ignore Pain buff, if present.

    local _, _, _, _, duration, expirationTime, _, _, _, _, _, _, _, _, _, currentAbsorb = WA_GetUnitBuff("player", 190456)

    if currentAbsorb == nil then
        currentAbsorb = 0
    end

    state["duration"] = duration
    state["expirationTime"] = expirationTime
    state["currentAbsorb"] = currentAbsorb
    state["value"] = currentAbsorb

    -- Retrieve how much absorption a new cast would give based on the tooltip
    -- value.

    local castAbsorb = getSpellTooltipAmount()

    state["castAbsorb"] = castAbsorb

    -- Provide additional calculated values, derived from the above retrieved
    -- values.

    local absorbCap = UnitHealthMax("player") * 0.3
    local additionalAbsorbOnCast = math.min(
                                        math.max(0, absorbCap - currentAbsorb),
                                        castAbsorb)

    state["absorbCap"] = absorbCap
    state["total"] = absorbCap
    state["percentOfCap"] = currentAbsorb / absorbCap * 100
    state["percentOfMaxHp"] = currentAbsorb / UnitHealthMax("player") * 100
    state["additionalAbsorbOnCast"] = additionalAbsorbOnCast
    state["castBenefitPercent"] = additionalAbsorbOnCast / castAbsorb * 100
end

-------------------------------------------------------------------------------
-- trigger (TSU): UNIT_AURA:player, UNIT_ATTACK_POWER:player, UNIT_STATS:player, UNIT_MAXHEALTH:player

function(allstates, event, ...)
    -- Point 'allstates[""]' to 'aura_env.singleState'.  Note that we use a TSU
    -- even though we have only one state because we include custom variables.

    local state = allstates[""]
    if state == nil then
        state = aura_env.singleState
        allstates[""] = state
    end

    -- Update the 'autoHide' and 'show' values on receipt of the 'OPTIONS'
    -- event.

    local alwaysShow = aura_env.config.alwaysShow
    if event == "OPTIONS" then

        state["autoHide"] = not alwaysShow
        state["show"] = alwaysShow or (state["value"] ~= 0)

        state["changed"] = true
        return true
    end

    -- Calculate the state.

    local wasShown = state["show"]
    aura_env.calculateState(state)

    -- Do not update the clone if it was hidden and is to remain hidden.

    if not alwaysShow and not wasShown and state["value"] == 0 then
        return false
    else
        state["show"] = (alwaysShow or state["value"] ~= 0)

        state["changed"] = true
        return true
    end
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["currentAbsorb"] = "number",
        -- The amount of absorption currently active on the player from Ignore
        -- Pain, taken from the Ignore Pain buff tooltip, or 0 if the buff is
        -- absent.
        --
        -- This is an alias of 'value'.

    ["castAbsorb"] = "number",
        -- The additional amount of absorption that Ignore Pain would give if
        -- cast right now.  This is equal to the value in the Ignore Pain spell
        -- tooltip, increased by the Never Surrender multiplier, if applicable.
        -- Note that this value does not factor in the absorption cap.  To see
        -- how much "real" absorption would be added with the absorption cap
        -- factored in, see 'additionalAbsorbOnCast'.

    ["absorbCap"] = "number",
        -- Formula: 'castAbsorb * 2'
        --
        -- The max amount of absorbtion that the player can build up right now.
        -- If 'currentAbsorb' is greater than 'absorbCap', then a re-cast would
        -- refresh the duration on Ignore Pain but would not change
        -- 'currentAbsorb'.
        --
        -- This is an alias of 'total'.

    ["percentOfCap"] = "number",
        -- Formula: 'currentAbsorb / absorbCap * 100'

    ["percentOfMaxHp"] = "number",
        -- Formula: 'currentAbsorb / UnitHealthMax("player") * 100'

    ["additionalAbsorbOnCast"] = "number",
        -- Formula: 'math.min(math.max(0, absorbCap - currentAbsorb), castAbsorb)'
        --
        -- The amount of absorption that would be added to 'currentAbsorb' if
        -- the player were to cast Ignore Pain right now.

    ["castBenefitPercent"] = "number",
        -- Formula: 'additionalAbsorbOnCast / castAbsorb * 100'
        --
        -- The percentage amount of 'castAbsorb' that the player would benefit
        -- from if he/she were to cast Ignore Pain right now.

    ---------------------------------------------------------------------------
    -- DEFAULT STATE VARIABLES

    ["expirationTime"] = true,
    ["duration"] = true,
    ["value"] = true,
    ["total"] = true
}
