--[[ PLAN

TSU:
    - as an added (optional) feature: gray/alpha out CDs for players who are
      dead or more than 100 (?) yards away

group sort could sort by any of the following:
    - remaining CD, CD
    - remaining CD, custom options priority
    - CD
    - custom options priority
]]

-------------------------------------------------------------------------------
-- init

-- Convert the custom options to a lookup table that maps from spell ID to the
-- index for that spell ID in the user's custom options.  This index can be
-- used as a proxy for priority.

local configuredSpells = {}

for index, spellEntry in ipairs(aura_env.config.spells) do
    if spellEntry.enabled then
        configuredSpells[spellEntry.spellId] = index
    end
end

-- Register callbacks with 'LibOpenRaid'.

local libOr = LibStub:GetLibrary("LibOpenRaid-1.0")

if _G["INK_GROUPCDS_CALLBACKS_INSTALLED"] == nil then
    _G["INK_GROUPCDS_CALLBACKS_INSTALLED"] = true

    -- Note that we ignore the 'CooldownListWipe' event from 'LibOpenRaid',
    -- since this WeakAura should unload when the player is not in a group.

    local callbacks = {
        ["CooldownListUpdate"] = (
            function(unitId, unitCooldowns, allUnitsCds)
                WeakAuras.ScanEvents("INK_GROUPCDS_LIST_UPDATE", unitId)
            end),

        ["CooldownUpdate"] = (
            function(unitId, spellId, cooldownInfo, unitCooldowns, allUnitsCds)
                WeakAuras.ScanEvents("INK_GROUPCDS_CD_UPDATE", unitId, spellId)
            end),
    }

    for event, _ in pairs(callbacks) do
        libOr.RegisterCallback(callbacks, event, event)
    end
end

-- Define some helper functions.

local generateCloneId = function(unitId, spellId)
    return GetUnitName(unitId, true) .. spellId
end

aura_env.setCooldownListForUnit = function(allstates, unitId)
    -- Insert or update a state in the specified 'allstates' for each
    -- configured spell that is known to the specified 'unitId'.

    local unitCds = libOr.GetUnitCooldowns(unitId)
    for spellId, cdInfo in pairs(unitCds) do
        local configuredSpellPriority = configuredSpells[spellId]
        if configuredSpellPriority ~= nil then
            local cloneId = generateCloneId(unitId, spellId)
            local state = allstates[cloneId]

            if state == nil then
                local spellName, _, spellIcon = GetSpellInfo(spellId)

                state = {
                    ["name"] = spellName,
                    ["icon"] = spellIcon,
                    ["progressType"] = "timed",
                    ["autoHide"] = false,
                    ["spellId"] = spellId,
                }

                allstates[cloneId] = state
            end

            state["show"] = true
            state["changed"] = true
            state["index"] = configuredSpellPriority
            state["unit"] = unitId

            local _, _, _, charges, _, maxValue, _, duration =
                                libOr.GetCooldownStatusFromCooldownInfo(cdInfo)

            state["stacks"] = charges
            state["expirationTime"] = maxValue
            state["duration"] = duration
        end
    end
end

aura_env.updateCooldownForUnit = function(allstates, unitId, spellId)
    -- Update the state for in the specified 'allstates' for the specified
    -- 'unitId' and 'spellId', if one exists, to reflect the new cooldown info.
    -- Return 'true' if a state was updated.  Otherwise, return 'false'.

    local cloneId = generateCloneId(unitId, spellId)
    local state = allstates[cloneId]

    if state == nil then
        return false
    end

    local _, _, _, charges, _, maxValue, _, duration =
                        libOr.GetCooldownStatusFromUnitSpellID(unitId, spellId)

    state["changed"] = true
    state["stacks"] = charges
    state["expirationTime"] = maxValue
    state["duration"] = duration

    return true
end

-------------------------------------------------------------------------------
-- TSU: GROUP_ROSTER_UPDATE, INK_GROUPCDS_LIST_UPDATE, INK_GROUPCDS_CD_UPDATE

function(allstates, event, ...)
    if (event == "OPTIONS"
            or event == "STATUS"
            or event == "GROUP_ROSTER_UPDATE") then

        -- Hide all states in order to remove spells for units no longer in the
        -- group.

        for _, state in pairs(allstates) do
            state["show"] = false
            state["changed"] = true
        end

        -- Set the states for each configured spell for each group unit.

        for unit in WA_IterateGroupMembers() do
            aura_env.setCooldownListForUnit(allstates, unit)
        end

        return true
    elseif event == "INK_GROUPCDS_LIST_UPDATE" then
        local unit = ...

        -- Hide any states associated with this unit in order to remove spells
        -- that the unit no longer has.

        for _, state in pairs(allstates) do
            if state["unit"] == unit then
                state["show"] = false
                state["changed"] = true
            end
        end

        -- Set the states for this unit.

        aura_env.setCooldownListForUnit(allstates, unit)

        return true
    elseif event == "INK_GROUPCDS_CD_UPDATE" then
        local unit, spellId = ...
        return aura_env.updateCooldownForUnit(allstates, unit, spellId)
    end
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["expirationTime"] = true,
    ["duration"] = true,
    ["stacks"] = true,

    ["index"] = "number",
    ["spellId"] = "number",
}

-------------------------------------------------------------------------------
-- group sort: stacks, expirationTime, index

WeakAuras.ComposeSorts(
    WeakAuras.SortDescending{"region", "state", "stacks"},
    WeakAuras.SortAscending{"region", "state", "expirationTime"},
    WeakAuras.SortAscending{"region", "state", "index"}
)
