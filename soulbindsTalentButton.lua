-------------------------------------------------------------------------------
-- init

LoadAddOn("Blizzard_TalentUI")
LoadAddOn("Blizzard_Soulbinds")

if aura_env.button == nil then
    local button = CreateFrame("Button")

    local buttonScript = function()
        if SoulbindViewer:IsVisible() then
            SoulbindViewer.CloseButton:Click()
        else
            SoulbindViewer:Open()
        end
    end

    button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    button:SetScript("OnClick", buttonScript)

    button:SetParent(aura_env.region)
    button:SetAllPoints()

    aura_env.button = button
end

-------------------------------------------------------------------------------
-- trigger: SOULBIND_ACTIVATED, WA_SOULBINDSTALENTWINDOWBUTTON_DEFERRED

function(event)
    local model = aura_env.region.model

    if model == nil then
        -- Schedule a retrigger on the next rendered frame, when 'model' is not
        -- 'nil'.

        if event == 'SOULBIND_ACTIVATED' then
            C_Timer.After(0, function() WeakAuras.ScanEvents("WA_SOULBINDSTALENTWINDOWBUTTON_DEFERRED") end)
        end

        return true
    end

    local soulbindId = C_Soulbinds.GetActiveSoulbindID()
    local modelId

    if soulbindId == 0 then
        modelId = 46720
    else
        local soulbindData = C_Soulbinds.GetSoulbindData(soulbindId)
        modelId = soulbindData.modelSceneData.creatureDisplayInfoID
    end

    model:SetDisplayInfo(modelId)

    return true
end

-------------------------------------------------------------------------------
-- untrigger

function()
    return false
end
