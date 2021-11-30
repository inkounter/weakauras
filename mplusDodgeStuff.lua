-------------------------------------------------------------------------------
-- init

aura_env.spells = {}
for _, v in pairs(aura_env.config.spells) do
    aura_env.spells[v.spellId] = true
end

-------------------------------------------------------------------------------
-- TSU: UNIT_SPELLCAST_START:nameplate

function(allstates, event, _, _, spellId)
    if spellId == nil or aura_env.spells[spellId] == nil then
        return false
    end

    allstates[WeakAuras.GenerateUniqueID()] = {
        ["show"] = true,
        ["progressType"] = "timed",
        ["duration"] = 1,
        ["autoHide"] = true,
        ["spellId"] = spellId,
        ["changed"] = true,
    }

    return true
end
