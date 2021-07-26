-------------------------------------------------------------------------------
-- init

if aura_env.button == nil then
    local button = CreateFrame("Button")

    local buttonScript = function()
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local itemId = GetContainerItemID(bag,slot)
                if itemId and C_Item.IsAnimaItemByID(itemId) then
                    UseContainerItem(bag, slot)
                end
            end
        end
    end

    button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    button:SetScript("OnClick", buttonScript)

    button:SetParent(aura_env.region)
    button:SetAllPoints()

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.2)

    aura_env.button = button
end

-------------------------------------------------------------------------------
-- trigger: BANKFRAME_OPENED, BANKFRAME_CLOSED

function(event)
    return event == "BANKFRAME_OPENED"
end

-------------------------------------------------------------------------------
-- untrigger

function()
    return true
end
