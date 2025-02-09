-- init

aura_env.hasVoidReaver = false
aura_env.painbringerStacks = 0
aura_env.soulCleaveTarget = ""
aura_env.frailtyStacks = {} -- maps from unit GUID to number of frailty stacks

-- TSU: TRIGGER:2:3:4:5, PLAYER_TARGET_CHANGED

function(allstates, event, triggerNum, triggerStates)
    if event == "PLAYER_TARGET_CHANGED" then
        local changed = false
        local targetGuid = UnitGUID("target")

        for _, state in pairs(allstates) do
            if state["targetGuid"] == targetGuid then
                changed = true
                state["changed"] = true
                state["isTarget"] = true
            elseif state["isTarget"] then
                changed = true
                state["changed"] = true
                state["isTarget"] = false
            end
        end

        return changed
    end

    if event ~= "TRIGGER" then
        return false
    end

    if triggerNum == 5 then     -- Soul Cleave cast
        -- There's at most one trigger state, but the key for the state is
        -- some arbitrary and non-constant value.  Upon the trigger's timed
        -- expiration, the `triggerStates` table is empty.

        for _, triggerState in pairs(triggerStates) do
            aura_env.soulCleaveTarget = triggerState["destGUID"]
        end

        return false
    end

    if triggerNum == 4 then     -- talent check
        local triggerState = triggerStates[""]
        aura_env.hasVoidReaver = triggerState and
                                 triggerState.stacks and true or false
        return false
    end

    if triggerNum == 2 then     -- Painbringer
        local triggerState = triggerStates[""]
        local newStacks = triggerState and triggerState.stacks or 0
        for i = aura_env.painbringerStacks + 1, newStacks do
            local key = "painbringer " .. i .. " " .. GetTime()
            allstates[key] = {
                ["show"] = true,
                ["changed"] = true,
                ["progressType"] = "timed",
                ["expirationTime"] = GetTime() + 6,
                ["duration"] = 6,
                ["autoHide"] = true,
                ["drSpell"] = "painbringer",
            }
        end

        aura_env.painbringerStacks = newStacks

        return aura_env.painbringerStacks < newStacks
    end

    if triggerNum == 3 and aura_env.hasVoidReaver then  -- Frailty
        local seenTargets = {}
        local changed = false

        for _, triggerState in pairs(triggerStates) do
            local targetGuid = triggerState["GUID"]
            seenTargets[targetGuid] = true

            local oldStacks = aura_env.frailtyStacks[targetGuid] or 0
            local newStacks = triggerState["stacks"]

            for i = oldStacks + 1, newStacks do
                local key = "frailty " .. targetGuid .. " " .. i .. " " ..
                                                                      GetTime()

                -- If this is the last Soul Cleave target, then set this
                -- Frailty stack on this target to have an 8-second duration,
                -- but reset the Soul Cleave target so that all future stacks
                -- have a 6-second duration.

                local duration = 6
                if aura_env.soulCleaveTarget == targetGuid then
                    duration = 8
                    aura_env.soulCleaveTarget = ""
                end

                allstates[key] = {
                    ["show"] = true,
                    ["changed"] = true,
                    ["progressType"] = "timed",
                    ["expirationTime"] = GetTime() + duration,
                    ["duration"] = duration,
                    ["autoHide"] = true,
                    ["drSpell"] = "frailty",
                    ["targetGuid"] = targetGuid,
                    ["isTarget"] = UnitGUID("target") == targetGuid,
                }

                changed = true
            end

            aura_env.frailtyStacks[targetGuid] = newStacks
        end

        -- Clean out `aura_env.frailtyStacks` for units that no longer have
        -- frailty.

        for k, _ in pairs(aura_env.frailtyStacks) do
            if seenTargets[k] == nil then
                aura_env.frailtyStacks[k] = nil
            end
        end

        return changed
    end
end

-- custom variables

{
    ["expirationTime"] = true,
    ["duration"] = true,

    ["drSpell"] = {
        ["display"] = "DR Spell",
        ["type"] = "select",
        ["values"] = {
            ["frailty"] = "Frailty",
            ["painbringer"] = "Painbringer",
        }
    },
    ["isTarget"] = "bool"
}
