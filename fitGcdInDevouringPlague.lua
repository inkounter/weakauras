-- On init

WeakAuras.WatchGCD()

local border = {
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_1px.tga]],
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_5px.tga]],
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_10px.tga]]
}
aura_env.region.cooldown:SetSwipeTexture(border[aura_env.config.b])
aura_env.region.cooldown:SetSwipeColor(unpack(aura_env.config.c))

-- Custom Trigger: TRIGGER:1, UNIT_SPELL_HASTE:player, INK_SCHEDULED_DEVOURING_PLAGUE_GCD_CUTOFF

function(event, ...)
    if event == "TRIGGER" then
        local triggerStates = select(2, ...)
        local state = triggerStates[""]
        if state == nil then
            return false
        end
        aura_env.expirationTime = state.expirationTime
    end

    if aura_env.expirationTime == nil then
        return false
    end

    local gcdCutoff = aura_env.expirationTime - WeakAuras.gcdDuration()
    local currentTime = GetTime()

    if aura_env.timer ~= nil then
        aura_env.timer:Cancel()
    end

    if currentTime >= gcdCutoff then
        return true
    else
        local retrigger = function()
            WeakAuras.ScanEvents("INK_SCHEDULED_DEVOURING_PLAGUE_GCD_CUTOFF")
        end

        aura_env.timer = C_Timer.NewTimer(gcdCutoff - GetTime(), retrigger)
        return false
    end
end

-- Untrigger

function()
    return true
end
