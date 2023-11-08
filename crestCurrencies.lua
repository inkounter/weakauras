-- init

aura_env.enabledCrests = {}
if aura_env.config.whelpling then aura_env.enabledCrests[2706] = true end
if aura_env.config.drake then aura_env.enabledCrests[2707] = true end
if aura_env.config.wyrm then aura_env.enabledCrests[2708] = true end
if aura_env.config.aspect then aura_env.enabledCrests[2709] = true end

-- TSU: CURRENCY_DISPLAY_UPDATE

function(allstates, event, currencyType, quantity)
    if event == 'STATUS' then
        for currencyId, _ in pairs(aura_env.enabledCrests) do
            local info = C_CurrencyInfo.GetCurrencyInfo(currencyId)

            allstates[currencyId] = {
                ["show"] = true,
                ["changed"] = true,
                ["link"] = C_CurrencyInfo.GetCurrencyLink(currencyId),
                ["index"] = currencyId,
                ["name"] = info.name,
                ["icon"] = info.iconFileID,
                ["progressType"] = "static",
                ["value"] = info.quantity
            }
        end

        return true
    end

    local state = allstates[currencyType]
    if state == nil then
        return false
    end

    state.changed = true
    state.value = quantity

    return true
end

-- custom variables

{
    ["value"] = true
}
