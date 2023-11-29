-------------------------------------------------------------------------------
--[[ TODO

- improve readability
- add separate ready check weakaura
- add logic so that if a static target is removed, its state is inserted as a
  new autohide-enabled state
]]


-------------------------------------------------------------------------------
-- init

local tryUpdateStateDuration = function(state, expirationTime, duration)
    -- Set the specified 'state' to have the specified 'expirationTime' and
    -- 'duration'.  Set 'state["changed"]' to 'true' and return 'true' if
    -- 'state' is changed.  Otherwise, return 'false'.

    if state["expirationTime"] ~= expirationTime
                                          or state["duration"] ~= duration then
        state["changed"] = true
        state["expirationTime"] = expirationTime
        state["duration"] = duration

        return true
    end

    return false
end

aura_env.handleAuraChange = function(allstates, triggerStates)
    -- Modify 'allstates' based on the auras described by the specified
    -- 'triggerStates'.  Return 'true' if any states within 'allstates' is
    -- changed.  Otherwise, return 'false'.

    local changed = false
    local activeUnitNames = {}

    -- Iterate through all instances of prescience applied by the player.

    for _, triggerState in pairs(triggerStates) do
        local unit = triggerState["unit"]
        local expirationTime = triggerState["expirationTime"]
        local duration = triggerState["duration"]

        local unitName = GetUnitName(unit, true)
        activeUnitNames[unitName] = true

        local matchingStateFound = false

        -- Update any matches (possibly multiple) within the static set.

        for index = 1, 3 do
            local state = allstates[index]
            if state["name"] == unitName then
                matchingStateFound = true

                changed = tryUpdateStateDuration(state,
                                                 expirationTime,
                                                 duration) or changed
            end
        end

        -- If this prescience is not on a unit in the static set, then add an
        -- 'autoHide'-enabled state for this unit, using the unit's name as the
        -- clone ID.

        if not matchingStateFound then
            local state = allstates[unitName]
            if state == nil then
                local classFile = select(2, UnitClass(unit))
                state = { ["show"] = true,
                          ["index"] = 99,   -- Order after the static set.
                          ["progressType"] = "timed",
                          ["autoHide"] = true,
                          ["color"] = C_ClassColor.GetClassColor(classFile),
                          ["name"] = unitName,
                          ["dead"] = false }
                allstates[unitName] = state
            end

            changed = tryUpdateStateDuration(state,
                                             expirationTime,
                                             duration) or changed
        end
    end

    -- Update any states from 'allstates' that no longer have a corresponding
    -- state in 'triggerStates'

    for cloneId, state in pairs(allstates) do
        if activeUnitNames[state["name"]] == nil then
            if cloneId == 1 or cloneId == 2 or cloneId == 3 then
                state["expirationTime"] = 1
            else
                state["show"] = false
            end

            state["changed"] = true

            changed = true
        end
    end

    return changed
end

aura_env.handleHealthChange = function(allstates, triggerStates)
    -- Modify 'allstates' based on the unit healths described by the specified
    -- 'triggerStates'.  Return 'true' if any states within 'allstates' is
    -- changed.  Otherwise, return 'false'.

    local deadUnitNames = {}

    for unit, triggerState in pairs(triggerStates) do
        local unitName = GetUnitName(unit, true)
        if unitName ~= nil then
            deadUnitNames[unitName] = true
        end
    end

    local changed = false

    for _, state in pairs(allstates) do
        local newDead = (deadUnitNames[state["name"]] ~= nil)
        if state["dead"] ~= newDead then
            state["dead"] = newDead
            state["changed"] = true

            changed = true
        end
    end

    return changed
end

aura_env.handleInit = function(allstates)
    -- Modify the static states in 'allstates' to reflect the macroed
    -- prescience targets.  Return 'true'.

    local hasEmptyTarget = false

    for index = 1, 3 do
        -- Read the macro body for its target.

        local macroName = 'Pres' .. index
        local macroBody = GetMacroBody(macroName)
        local targetBegin, targetEnd = string.find(macroBody, "@[^@]+,nodead%]")
        targetBegin = targetBegin + 1
        targetEnd = targetEnd - 8

        local target = string.sub(macroBody, targetBegin, targetEnd)
        local targetGuid = UnitGUID(target)
        local targetEmpty = false

        if targetGuid == nil or string.sub(targetGuid, 1, 6) ~= "Player" then
            -- This target either doesn't exist or is a non-player unit.

            targetEmpty = true
        end

        local state = allstates[index]
        if state == nil then
            state = { ["show"] = true,
                      ["index"] = index,
                      ["progressType"] = "timed",
                      ["autoHide"] = false }
            allstates[index] = state
        end

        state["changed"] = true
        state["name"] = target

        if targetEmpty then
            hasEmptyTarget = true

            state["color"] = CreateColor(0, 0, 0)   -- black

            state["expirationTime"] = 1
            state["duration"] = 1
            state["dead"] = false
        else
            local classFile = select(2, UnitClass(target))
            state["color"] = C_ClassColor.GetClassColor(classFile)

            local _, _, _, _, duration, expirationTime = WA_GetUnitBuff(
                                                                      target,
                                                                      410089,
                                                                      "PLAYER")

            state["expirationTime"] = expirationTime or 1
            state["duration"] = duration or 1
            state["dead"] = UnitIsDeadOrGhost(target)

            -- Also delete any other state already maintained for this target
            -- (where the clone ID is the unit name).

            local namedState = allstates[target]
            if namedState ~= nil then
                namedState["show"] = false
                namedState["changed"] = true
            end
        end

        -- Set the color for the region if it already exists.  Otherwise, rely
        -- on the "on show" custom code block to change the color.

        local region = WeakAuras.GetRegion(aura_env.id, index)
        if region ~= nil then
            region:Color(state["color"]:GetRGBA())
        end
    end

    if hasEmptyTarget then
        if event == "READY_CHECK" then
            WeakAuras.ScanEvents("INK_PRESCIENCE_TARGET_EMPTY", index)
        end
    else
        WeakAuras.ScanEvents("INK_PRESCIENCE_ALL_TARGETS_VALID", index)
    end

    return true
end


-------------------------------------------------------------------------------
-- on show

local color = aura_env.state["color"]
aura_env.region:Color(color:GetRGBA())


-------------------------------------------------------------------------------
-- TSU: TRIGGER:1:2, INK_PRESCIENCE_TARGET_CHANGED, READY_CHECK

function(allstates, event, ...)
    if event == 'TRIGGER' then
        local triggerNumber, triggerStates = ...

        if triggerNumber == 1 then
            return aura_env.handleAuraChange(allstates, triggerStates)
        else
            return aura_env.handleHealthChange(allstates, triggerStates)
        end
    else
        return aura_env.handleInit(allstates)
    end
end


-------------------------------------------------------------------------------
-- custom variables

{
    ["expirationTime"] = true,
    ["duration"] = true,

    ["name"] = "string",
    ["dead"] = "bool",
}


-------------------------------------------------------------------------------
--[[
Macro to set Prescience target:
```
local t=GetUnitName("target", true)
if t ~= nil then
    local n="Pres1"
    local m=GetMacroBody(n)
    m=string.gsub(m, "@[^@]+,nodead%]", "@"..t..",nodead]")
    EditMacro(n,n,nil,m)
    WeakAuras.ScanEvents("INK_PRESCIENCE_TARGET_CHANGED")
end
```

Sample "Pres1" macro:
```
#showtooltip Prescience
/cast [@mouseover,nodead,help][@Kamelock-Zul'jin,nodead]Prescience
```
]]

