-- trigger: every frame

function()
    local now = GetTime()
    if aura_env.lastTime == nil or aura_env.lastTime < now - 0.1 then
        aura_env.lastTime = now
        return true
    else
        return false
    end
end

-- untrigger

function()
    return false
end

-- name

function()
    local speed = select(3, C_PlayerInfo.GetGlidingInfo())
    if speed == 0 then
        speed = GetUnitSpeed("player")
    end
    return math.floor(speed / 7 * 100 + 0.5)
end
