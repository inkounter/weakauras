-- trigger: every frame

function()
    return true
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
