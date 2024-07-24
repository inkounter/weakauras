-- TSU: every frame

function(allstates, ...)
    local state = allstates['']
    if state == nil then
        state = { ['show'] = true }
        allstates[''] = state
    end

    local now = GetTime()
    if aura_env.lastTime == nil or aura_env.lastTime < now - 0.1 then
        aura_env.lastTime = now

        local isGliding, _, speed = C_PlayerInfo.GetGlidingInfo()
        if not isGliding then
            speed = GetUnitSpeed("player")
        end

        state['changed'] = true
        state['isGliding'] = isGliding
        state['speed'] = speed / 7 * 100

        return true
    else
        return false
    end
end

-- custom variables

{
  ['speed'] = 'number',
  ['isGliding'] = 'bool'
}
