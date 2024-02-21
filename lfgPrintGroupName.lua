-------------------------------------------------------------------------------
-- init

local scan = _G['INK_PRINT_LFG_GROUP_NAME_INITIALIZED']
if scan == nil then
    _G['INK_PRINT_LFG_GROUP_NAME_INITIALIZED'] = true

    local popupFrame = LFGListInviteDialog
    local callback = function()
        WeakAuras.ScanEvents("INK_PRINT_LFG_GROUP_NAME",
                             popupFrame.ActivityName:GetText(),
                             popupFrame.GroupName:GetText())
    end

    popupFrame:SetScript("OnShow", callback)
end


-------------------------------------------------------------------------------
-- TSU: INK_PRINT_LFG_GROUP_NAME

function(allstates, event, activityName, groupName)
    if event ~= 'INK_PRINT_LFG_GROUP_NAME' then
        return false
    end

    if aura_env.activityName ~= activityName
                                        or aura_env.groupName ~= groupName then
        aura_env.activityName = activityName
        aura_env.groupName = groupName

        allstates[''] = {
            ['show'] = true,
            ['changed'] = true,
            ['progressType'] = 'timed',
            ['expirationTime'] = GetTime() + 0.01,
            ['duration'] = 0.01,
            ['autoHide'] = true,
            ['activityName'] = activityName,
            ['groupName'] = groupName
        }

        return true
    end

    return false
end

-------------------------------------------------------------------------------
-- custom variables

{
    ['activityName'] = 'string',
    ['groupName'] = 'string'
}
