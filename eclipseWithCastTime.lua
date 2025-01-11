-------------------------------------------------------------------------------
-- custom text code

function()
    for _, subregion in ipairs(aura_env.region.subRegions) do
        if subregion.type and subregion.type == "subtick" then
            -- Move the two ticks to reflect Wrath and Starfire cast times.

            local starfireCastTime = C_Spell.GetSpellInfo(194153)["castTime"]
            local wrathCastTime = C_Spell.GetSpellInfo(190984)["castTime"]

            subregion:SetTickPlacementAt(1, wrathCastTime / 1000)
            subregion:SetTickPlacementAt(2, starfireCastTime / 1000)
        end
    end
end
