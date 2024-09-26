-------------------------------------------------------------------------------
-- init

aura_env.singleState = {
    ["icon"] = C_Spell.GetSpellInfo(190456)['iconID'],
    ["progressType"] = "static",
    ["autoHide"] = not aura_env.config.alwaysShow,
    ["show"] = aura_env.config.alwaysShow
}

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

    -- Provide additional calculated values, derived from the above retrieved
    -- values.

    local absorbCap = UnitHealthMax("player") * 0.3

    state["absorbCap"] = absorbCap
    state["total"] = absorbCap
    state["percentOfCap"] = currentAbsorb / absorbCap * 100
    state["percentOfMaxHp"] = currentAbsorb / UnitHealthMax("player") * 100
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

    ["absorbCap"] = "number",
        -- Formula: 'UnitHealthMax("player") * 0.3'
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

    ---------------------------------------------------------------------------
    -- DEFAULT STATE VARIABLES

    ["expirationTime"] = true,
    ["duration"] = true,
    ["value"] = true,
    ["total"] = true
}
