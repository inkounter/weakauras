-------------------------------------------------------------------------------
-- init

aura_env.stanceResponses = { [1] = { "roar" },                  -- bear
                             [2] = { "hiss", "meow", "purr" } } -- cat

-------------------------------------------------------------------------------
-- TSU: CHAT_MSG_TEXT_EMOTE

function(allstates, event, message, senderName)
    if event ~= "CHAT_MSG_TEXT_EMOTE" then
        return false
    end

    local fullSenderName

    local pattern = " pets you.$"
    if message:match(pattern) then
        fullSenderName = message:gsub(pattern, "")
    else
        return false
    end

    local state = allstates[fullSenderName]
    if state ~= nil then
        -- The sender is spamming.  Ignore this emote from them until the state
        -- expires.

        return false
    end

    local duration = 1
    state = { ["show"] = true,
              ["changed"] = true,
              ["progressType"] = "timed",
              ["duration"] = duration,
              ["expirationTime"] = GetTime() + duration,
              ["autoHide"] = true,
              ["fullSenderName"] = fullSenderName }
    allstates[fullSenderName] = state

    return true
end

-------------------------------------------------------------------------------
-- on show

local sender = aura_env.states[1]["fullSenderName"]
local stance = aura_env.states[2]["form"]

local stanceResponseOptions = aura_env.stanceResponses[stance]
if stanceResponseOptions then
    local index = random(#stanceResponseOptions)
    DoEmote(stanceResponseOptions[index], sender)
end
