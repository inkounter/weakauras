-- Shows the focus target's cast bar.  Colors it according to Plater cast color
-- configs, if Plater is enabled.

--[[
TODO:
    - add custom options to disable each of the features (rename, custom color,
      default color)
    - test that conditions don't override the color:
        1. disable default plater coloring
        2. add condition to color the cast differently for cast vs. channel
        3. check that a cast without a custom Plater color is colored according
           to the conditions
        4. check that a cast with a custom Plater color is colored according to
           Plater
    - make a TSU for elegance
        - renaming the spell is more conventional
        - the state can contain a variable that indicates whether the thing is
          renamed or recolored
]]

-------------------------------------------------------------------------------
-- init

aura_env.Plater = _G["Plater"]

-------------------------------------------------------------------------------
-- show

local setColor = function(r, g, b, a)
    aura_env.region:Color(r, g, b, a)
end

local platerProfile = aura_env.Plater and aura_env.Plater and aura_env.Plater.db.profile
if platerProfile then
    -- Apply the custom cast color, if any.

    local customColors = platerProfile.cast_colors
    if customColors ~= nil then
        local spellId = aura_env.state["spellId"]
        local customColor = customColors[spellId]
        if customColor ~= nil then
            local enabled, color, customSpellName = customColor[1], customColor[2], customColor[3]
            if enabled and color then
                if customSpellName ~= nil and customSpellName ~= "" then
                    -- This cast also has a custom name.  Set it.

                    -- TODO: Test this. This probably doesn't work in `on
                    -- show`.

                    aura_env.state["spellName"] = customSpellName
                end

                -- Note that Details uses "white" as a sentinel color for
                -- disablement.

                if color ~= "white" then
                    setColor(aura_env.Plater:ParseColors(color))

                    -- Skip setting the default cast color.

                    return
                end
            end
        end
    end

    -- Use the default Plater cast color.

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
