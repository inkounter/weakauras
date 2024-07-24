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
    local speed = GetUnitSpeed("player")
    return math.floor(speed / 7 * 100 + 0.5)
end
