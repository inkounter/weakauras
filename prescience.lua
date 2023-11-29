-------------------------------------------------------------------------------
--[[ TODO

- improve readability
- add separate ready check weakaura
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

local black = CreateColor(0, 0, 0)

local addAutohideEnabledState = function(allstates, unitName)
    -- Insert into 'allstates' an autohide-enabled state for the specified
    -- 'unitName'.  The inserted state will not include any progress
    -- information.  Return the inserted state.

    local className, classFile = UnitClass(unitName)
    local classColor = classFile and C_ClassColor.GetClassColor(classFile) or black
    local state = { ["show"] = true,
                    ["changed"] = true,
                    ["index"] = 99,   -- Order after the static set.
                    ["progressType"] = "timed",
                    ["autoHide"] = true,
                    ["color"] = classColor,
                    ["unitName"] = unitName,
                    ["unitClass"] = className,
                    ["dead"] = false }
    allstates[unitName] = state

    return state
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
            if state["unitName"] == unitName then
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
                state = addAutohideEnabledState(allstates, unitName)

                changed = true
            end

            changed = tryUpdateStateDuration(state,
                                             expirationTime,
                                             duration) or changed
        end
    end

    -- Update any states from 'allstates' that no longer have a corresponding
    -- state in 'triggerStates'

    for cloneId, state in pairs(allstates) do
        if activeUnitNames[state["unitName"]] == nil then
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
        local newDead = (deadUnitNames[state["unitName"]] ~= nil)
        if state["dead"] ~= newDead then
            state["dead"] = newDead
            state["changed"] = true

            changed = true
        end
    end

    return changed
end

local assignStaticState = function(state, unitName)
    -- Set the specified 'state' for the specified 'unitName'.  Return 'true'
    -- if 'unitName' is an addressable player unit.  Otherwise, return 'false'.

    state["changed"] = true
    state["unitName"] = unitName

    local targetGuid = UnitGUID(unitName)
    if targetGuid == nil or string.sub(targetGuid, 1, 6) ~= "Player" then
        -- This unit either doesn't exist or is a non-player unit.

        hasEmptyTarget = true

        state["color"] = black
        state["unitClass"] = nil

        state["expirationTime"] = 1
        state["duration"] = 1
        state["dead"] = false

        return false
    else
        local className, classFile = UnitClass(unitName)
        state["color"] = C_ClassColor.GetClassColor(classFile)
        state["unitClass"] = className

        local _, _, _, _, duration, expirationTime = WA_GetUnitBuff(unitName,
                                                                    410089,
                                                                    "PLAYER")

        state["expirationTime"] = expirationTime or 1
        state["duration"] = duration or 1
        state["dead"] = UnitIsDeadOrGhost(unitName)

        return true
    end
end

aura_env.handleInit = function(allstates)
    -- Modify the static states in 'allstates' to reflect the macroed
    -- prescience targets.  Return 'true' if any state is changed.  Otherwise,
    -- return 'false'.

    local changed = false
    local hasEmptyTarget = false

    local newStaticTargetNames = {}
    local removedStaticTargetStates = {}

    for index = 1, 3 do
        -- Read the macro body for its target.

        local macroName = 'Pres' .. index
        local macroBody = GetMacroBody(macroName)
        local targetBegin, targetEnd = string.find(macroBody, "@[^@]+,nodead%]")
        targetBegin = targetBegin + 1
        targetEnd = targetEnd - 8

        local targetName = string.sub(macroBody, targetBegin, targetEnd)
        newStaticTargetNames[targetName] = true

        local state = allstates[index]
        if state == nil then
            state = { ["show"] = true,
                      ["changed"] = true,
                      ["index"] = index,
                      ["progressType"] = "timed",
                      ["autoHide"] = false }
            allstates[index] = state

            changed = true
        end

        local oldTargetName = state["unitName"]
        if oldTargetName ~= targetName then
            if oldTargetName ~= nil
                       and removedStaticTargetStates[oldTargetName] == nil then
                -- Cache the preexisting state's duration info in case we need
                -- to add an autohide-enabled state for its target.

                removedStaticTargetStates[oldTargetName] = {
                                  ["expirationTime"] = state["expirationTime"],
                                  ["duration"] = state["duration"] }
            end

            -- Reassign this state.

            hasEmptyTarget = not assignStaticState(state, targetName) or hasEmptyTarget

            changed = true

            -- Set the color for the region if it already exists.  Otherwise,
            -- rely on the "on show" custom code block to change the color.

            local region = WeakAuras.GetRegion(aura_env.id, index)
            if region ~= nil then
                region:Color(state["color"]:GetRGBA())
            end

            -- Also delete any autohide-enabled state maintained for this unit
            -- (where the clone ID is the unit name).

            local namedState = allstates[targetName]
            if namedState ~= nil then
                namedState["show"] = false
                namedState["changed"] = true

                changed = true
            end
        end
    end

    -- Check if any of the removed static targets have to be inserted as
    -- autohide-enabled states.

    for targetName, semiState in pairs(removedStaticTargetStates) do
        if newStaticTargetNames[targetName] == nil then
            -- 'targetName' no longer matches any of the static targets.  Add
            -- an autohide-enabled state for it and merge the duration info in.


            local state = addAutohideEnabledState(allstates, targetName)
            for k, v in pairs(semiState) do
                state[k] = v
            end

            changed = true
        end
    end

    if hasEmptyTarget then
        if event == "READY_CHECK" then
            WeakAuras.ScanEvents("INK_PRESCIENCE_TARGET_EMPTY", index)
        end
    else
        WeakAuras.ScanEvents("INK_PRESCIENCE_ALL_TARGETS_VALID", index)
    end

    return changed
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

    ["unitName"] = "string",
    ["unitClass"] = "string",
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

