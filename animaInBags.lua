-------------------------------------------------------------------------------
-- init

aura_env.singleState = {}

local getAnimaInBagSlot = function(bag, slot)
    -- Return the amount of anima held in the item in the specified 'bag' and
    -- 'slot'.
    --
    -- based on https://wago.io/d3T2l8gld/3

    local _, stack, _, quality = GetContainerItemInfo(bag, slot)
    if stack then
        local itemId = GetContainerItemID(bag, slot);
        if C_Item.IsAnimaItemByID(itemId) then
            if itemId == 183727 then
                -- 'Resonance of Conflict'

                return 3 * stack
            elseif (quality == 2) then
                -- green, but not 'Resonance of Conflict'

                return 5 * stack
            elseif quality == 3 then
                -- blue

                return 35 * stack
            elseif quality == 4 then
                -- purple

                return 250 * stack
            end
        end
    end

    return 0
end

local getAnimaInBag = function(bag)
    -- Return the amount of anima held in the specified 'bag'.

    local amount = 0

    local bagSize = GetContainerNumSlots(bag)
    for slot = 1, bagSize do
        amount = amount + getAnimaInBagSlot(bag, slot)
    end

    return amount
end

aura_env.getInBackpack = function()
    -- Return the amount of anima that the player has in his/her backpack.

    local amount = 0

    for bag = 0, NUM_BAG_SLOTS do
        amount = amount + getAnimaInBag(bag)
    end

    return amount
end

aura_env.getInBank = function()
    -- Return the amount of anima in the primary bank (bag -1) and in all bank
    -- bags (bags 5-11)

    local amount = getAnimaInBag(BANK_CONTAINER)

    for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        amount = amount + getAnimaInBag(bag)
    end

    return amount
end

aura_env.getCurrency = function()
    -- Return the amount of anima the player has as currency.

    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(1813)
    if currencyInfo == nil then
        return 0
    end

    return currencyInfo.quantity
end

-------------------------------------------------------------------------------
-- trigger (TSU): BAG_UPDATE_DELAYED, CURRENCY_DISPLAY_UPDATE, BANKFRAME_OPENED, PLAYERBANKSLOTS_CHANGED, BANKFRAME_CLOSED

function(allstates, event, ...)
    if event == 'CURRENCY_DISPLAY_UPDATE' then
        local currencyId, _ = ...
        if currencyId ~= 1813 then
            return false
        end
    end

    local state = allstates[1]
    if state == nil then
        state = aura_env.singleState
        allstates[1] = state
    end

    state.changed = true
    state.show = true

    state.currency = aura_env.getCurrency()
    state.inBackpack = aura_env.getInBackpack()

    if event == "BANKFRAME_OPENED" then
        state.bankIsOpen = true
    elseif event == "BANKFRAME_CLOSED" then
        state.bankIsOpen = false
    end

    if state.bankIsOpen then
        state.inBank = aura_env.getInBank()
    end

    return true
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["currency"] = "number",
    ["inBackpack"] = "number",
    ["inBank"] = "number",
}

-------------------------------------------------------------------------------
-- custom anchor

function()
    for i = 1,3 do
        local frame = _G["ElvUI_ContainerFrameCurrencyButton" .. i]
        if frame.currencyID == 1813 then
            return frame
        end
    end
end
