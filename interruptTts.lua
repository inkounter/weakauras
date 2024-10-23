-------------------------------------------------------------------------------
-- TSU: INK_FOCUS_CAST_START, INK_FOCUS_CAST_STOP

function(allstates, event, eventState, customCastColor, customSpellName)
    local state = allstates[""]

    if event == "INK_FOCUS_CAST_START"
        and customCastColor ~= nil
        and eventState["interruptible"] then
        -- Show.

        if state == nil then
            state = {}
            allstates[""] = state
        end

        state["show"] = true
        state["changed"] = true

        return true
    end

    -- Hide.

    if state ~= nil then
        state["show"] = false
        state["changed"] = true

        return true
    end

    return false
end
