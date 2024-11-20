-- init

aura_env.gossip = "Here, give this one a try!"

-- custom: GOSSIP_SHOW

function(event)
    if event == "GOSSIP_SHOW"
                   and nil ~= C_GossipInfo.GetText():find(aura_env.gossip) then
        C_GossipInfo.CloseGossip()
    end

    return false
end
