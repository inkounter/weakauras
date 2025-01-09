-------------------------------------------------------------------------------
-- init

-- Note that the cvar value is "0" or "1" (and 0 is truthy, not falsey).

local cvarName = "autoLootDefault"

local getAutoLoot = function()
    return C_CVar.GetCVar(cvarName)
end

aura_env.setAutoLoot = function(enabled)
    if getAutoLoot() ~= enabled then
        C_CVar.SetCVar(cvarName, enabled)
        print(CreateColor(0.5, 0.5, 0.5, 0):WrapTextInColorCode(
                "Keystone Fisher: "
                .. (enabled == "0"
                   and CreateColor(1, 0, 0, 0):WrapTextInColorCode("DISABLING")
                    or CreateColor(0, 1, 0, 0):WrapTextInColorCode("ENABLING"))
              .. " auto-loot"))
    end
end

-------------------------------------------------------------------------------
-- show

local keystoneMapId = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
if keystoneMapId == nil then
    aura_env.setAutoLoot("0")
else
    aura_env.setAutoLoot("1")
end

-------------------------------------------------------------------------------
-- hide

aura_env.setAutoLoot("1")

-------------------------------------------------------------------------------
-- TSU:

function(allstates, event, ...)
    -- Always show a dummy state so that we get "On Hide" functionality for
    -- free when the WeakAura unloads.

    local state = {
        ["show"] = true,
        ["changed"] = true,
    }

    allstates[""] = state
    return true
end
