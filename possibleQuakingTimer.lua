-------------------------------------------------------------------------------
-- trigger (event): CLEU:SPELL_AURA_APPLIED, WA_PossibleQuaking, CHALLENGE_MODE_START, CHALLENGE_MODE_COMPLETED, UPDATE_INSTANCE_INFO

function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local destGuid = select(8, ...)
        local spellId = select(12, ...)

        if destGuid ~= UnitGUID("player") or spellId ~= 240447 then
            return false
        end

        -- Cancel the current timer, if any, and start a new one as a means of
        -- self-correction for clock skew.

        if aura_env.timer then
            aura_env.timer:Cancel()
        end

        aura_env.timer = C_Timer.NewTicker(
                     20,
                     function() WeakAuras.ScanEvents("WA_PossibleQuaking") end)
        return true
    elseif event == "WA_PossibleQuaking" then
        return true
    else
        -- CHALLENGE_MODE_START, CHALLENGE_MODE_COMPLETED, UPDATE_INSTANCE_INFO

        -- Reset the timer.

        if aura_env.timer then
            aura_env.timer:Cancel()
        end

        return false
    end
end
