-- init

aura_env.difficultyId = -1

local button = _G["InkGfdButton"]
if button == nil then
    button = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate")
    button:RegisterForClicks("AnyDown")
    button:SetScript("OnClick",
                     function() WeakAuras.ScanEvents("INK_GFD_CLICKED") end)

    _G["InkGfdButton"] = button
end
aura_env.button = button

local timeRanges = {}
for _, range in ipairs(aura_env.config.timeRanges) do
    timeRanges[#timeRanges + 1] = range
end

-- Return `true` if the current local time falls within any of the configured
-- active time ranges, or if there are no configured active time ranges.
-- Otherwise, return `false`.
aura_env.isInAnyTimeRange = function()
    if #timeRanges == 0 then
        return true
    end

    local currentTime = tonumber(date("%H%M"))

    for _, range in ipairs(timeRanges) do
        if range["start"] <= currentTime and currentTime <= range["end"] then
            return true
        end
    end

    return false
end

-- on show

aura_env.button:SetParent(aura_env.region)
aura_env.button:SetAllPoints()

-- TSU: UPDATE_INSTANCE_INFO, INK_GFD_CLICKED

function(allstates, event, ...)
    if event == "UPDATE_INSTANCE_INFO" or event == "STATUS" then
        local lastDifficultyId = aura_env.difficultyId
        local difficultyId = select(3, GetInstanceInfo())
        aura_env.difficultyId = difficultyId

        if difficultyId == 0
        and lastDifficultyId > 0
        and aura_env.isInAnyTimeRange() then
            allstates[""] = {
                ["show"] = true,
                ["changed"] = true,
            }

            return true
        end
    elseif event == "INK_GFD_CLICKED" then
        local state = allstates[""]

        state["show"] = false
        state["changed"] = true

        return true
    end
end
