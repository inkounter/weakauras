-------------------------------------------------------------------------------
-- init

aura_env.lgf = LibStub("LibGetFrame-1.0")

-------------------------------------------------------------------------------
-- show

local region = aura_env.region
local frame = aura_env.lgf.GetFrame(aura_env.state.unit)

if frame ~= nil then
    region:ClearAllPoints()
    region:SetPoint("CENTER", frame, "CENTER")
    region:SetRegionWidth(frame:GetWidth())
    region:SetRegionHeight(frame:GetHeight())
    region:SetParent(frame)

    region.bar.spark:SetHeight(frame:GetHeight() * 1.5)
end

-------------------------------------------------------------------------------
-- trigger (TSU): TRIGGER:1

function(allstates, event, _, triggerStates)
    if event ~= 'TRIGGER' then
        return false
    end

    local changed = false

    -- Hide expired states.

    for key, state in pairs(allstates) do
        local triggerState = triggerStates[key]

        if triggerState == nil or not triggerState['show'] then
            state['show'] = false
            state['changed'] = true

            changed = true
        end
    end

    -- Add new states.

    for key, trigger1State in pairs(triggerStates) do
        local state = allstates[key]
        if state == nil or not state['show'] then
            local unit = trigger1State['unit']
            state = {
                ['show'] = true,
                ['changed'] = true,
                ['unit'] = unit,
                ['progressType'] = 'static',
                ['value'] = UnitHealth(unit),
                ['total'] = UnitHealthMax(unit)
            }

            allstates[key] = state
            changed = true
        end
    end

    return changed
end
