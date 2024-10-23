-- Shows the focus target's cast bar.  Colors it according to Plater cast color
-- configs, if Plater is enabled.

--[[
TODO:
    - on show and on hide, also fire a custom event
]]

-------------------------------------------------------------------------------
-- init

aura_env.Plater = _G["Plater"]

-------------------------------------------------------------------------------
-- TSU: TRIGGER:1

function(allstates, event, triggerNum, triggerStates)
    if event ~= "TRIGGER" then
        return false
    end

    local state = allstates[""]
    local triggerState = triggerStates[""]
    if triggerState == nil then
        if state ~= nil then
            state["show"] = false
            state["changed"] = false

            return true
        elseif state == nil then
            return false
        end
    end

    if state == nil then
        state = {}
        allstates[""] = state
    end

    state["changed"] = true
    state["show"] = true

    for _, key in ipairs({ "name",
                           "progressType",
                           "expirationTime",
                           "duration",
                           "autoHide",
                           "castType",
                           "interruptible" }) do
        state[key] = triggerState[key]
    end

    state["hasCustomSpellName"] = false
    state["hasCustomCastColor"] = false

    local platerProfile = aura_env.Plater and aura_env.Plater and aura_env.Plater.db.profile
    if platerProfile then
        -- Apply the custom cast color, if any.

        local customColors = platerProfile.cast_colors
        if customColors ~= nil then
            local customColor = customColors[triggerState["spellId"]]
            if customColor ~= nil then
                local enabled, color, customSpellName = customColor[1], customColor[2], customColor[3]
                if enabled and color then
                    if customSpellName ~= nil and customSpellName ~= "" then
                        -- This cast also has a custom name.  Set it.

                        state["hasCustomSpellName"] = true
                        state["customSpellName"] = customSpellName
                        if aura_env.config.enableCustomSpellNames then
                            state["name"] = customSpellName
                            state["spellName"] = customSpellName
                        end
                    end

                    -- Note that Details uses "white" as a sentinel color for
                    -- disablement.

                    if color ~= "white" then
                        state["hasCustomCastColor"] = true
                        state["customCastColor"] = {
                                           aura_env.Plater:ParseColors(color) }
                    end
                end
            end
        end
    end

    return true
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["expirationTime"] = true,
    ["duration"] = true,

    ["hasCustomCastColor"] = "bool",
    ["hasCustomSpellName"] = "bool",
    ["customSpellName"] = "string",
}

-------------------------------------------------------------------------------
-- show

local setColor = function(r, g, b, a)
    aura_env.region:Color(r, g, b, a)
end

if aura_env.state["customCastColor"] and aura_env.config.enableCustomColors then
    setColor(unpack(aura_env.state["customCastColor"]))
elseif aura_env.config.enableDefaultColors then
    local platerProfile = aura_env.Plater and aura_env.Plater and aura_env.Plater.db.profile
    if platerProfile then
        local castType = aura_env.state["castType"]
        local interruptible = aura_env.state["interruptible"]

        local color
        if not interruptible then
            color = platerProfile.cast_statusbar_color_nointerrupt
        elseif castType == "channel" then
            color = platerProfile.cast_statusbar_color_channeling
        else
            color = platerProfile.cast_statusbar_color
        end
        setColor(unpack(color))
    end
end
