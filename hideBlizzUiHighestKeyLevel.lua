-- custom trigger: MYTHIC_PLUS_CURRENT_AFFIX_UPDATE

function()
    if ChallengesFrame == nil then
        return
    end

    RunNextFrame(function()
        for _, icon in ipairs(ChallengesFrame.DungeonIcons) do
            -- Something is asynchronously calling ':Show()', so we set its
            -- transparency instead.

            icon.HighestLevel:SetAlpha(0)
        end
    end)
end
