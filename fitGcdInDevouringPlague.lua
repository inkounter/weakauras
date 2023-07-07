-- On init

WeakAuras.WatchGCD()

local border = {
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_1px.tga]],
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_5px.tga]],
  [[Interface\AddOns\WeakAuras\Media\Textures\square_border_10px.tga]]
}
aura_env.region.cooldown:SetSwipeTexture(border[aura_env.config.b])
aura_env.region.cooldown:SetSwipeColor(unpack(aura_env.config.c))

-- Condition Custom Check

function(states)
    if not states[1].show then
        return false
    end

    local gcdCutoff = states[1].expirationTime - WeakAuras.gcdDuration()
    local currentTime = GetTime()

    if currentTime >= gcdCutoff then
        aura_env.region.cooldown:SetSwipeColor(unpack(aura_env.config.c2))
    else
        aura_env.region.cooldown:SetSwipeColor(unpack(aura_env.config.c))

        if aura_env.timer then
            aura_env.timer:Cancel()
        end

        local recolorAsTooLate = function()
            aura_env.region.cooldown:SetSwipeColor(unpack(aura_env.config.c2))
        end

        aura_env.timer = C_Timer.NewTimer(gcdCutoff - GetTime(),
                                          recolorAsTooLate)
    end
end
