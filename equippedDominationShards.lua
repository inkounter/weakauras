-------------------------------------------------------------------------------
-- init

local clothSlots   = { 1, 3, 5, 6, 9 }
local leatherSlots = { 1, 3, 5, 8, 10 }
local mailSlots    = { 1, 3, 5, 6, 8 }
local plateSlots   = { 1, 3, 5, 9, 10 }

local classSlots = {
    ["WARRIOR"]     = plateSlots,
    ["PALADIN"]     = plateSlots,
    ["HUNTER"]      = mailSlots,
    ["ROGUE"]       = leatherSlots,
    ["PRIEST"]      = clothSlots,
    ["DEATHKNIGHT"] = plateSlots,
    ["SHAMAN"]      = mailSlots,
    ["MAGE"]        = clothSlots,
    ["WARLOCK"]     = clothSlots,
    ["MONK"]        = leatherSlots,
    ["DRUID"]       = leatherSlots,
    ["DEMONHUNTER"] = leatherSlots,
}

local playerClass = select(2, UnitClass("player"))

aura_env.playerSlots = classSlots[playerClass]

aura_env.shardData = {
    -- itemId    type       shortName   rank
    [187057] = { "Blood",   "Bek",      1 },
    [187284] = { "Blood",   "Bek",      2 },
    [187293] = { "Blood",   "Bek",      3 },
    [187302] = { "Blood",   "Bek",      4 },
    [187312] = { "Blood",   "Bek",      5 },
    [187059] = { "Blood",   "Jas",      1 },
    [187285] = { "Blood",   "Jas",      2 },
    [187294] = { "Blood",   "Jas",      3 },
    [187303] = { "Blood",   "Jas",      4 },
    [187313] = { "Blood",   "Jas",      5 },
    [187061] = { "Blood",   "Rev",      1 },
    [187286] = { "Blood",   "Rev",      2 },
    [187295] = { "Blood",   "Rev",      3 },
    [187304] = { "Blood",   "Rev",      4 },
    [187314] = { "Blood",   "Rev",      5 },
    [187073] = { "Unholy",  "Dyz",      1 },
    [187290] = { "Unholy",  "Dyz",      2 },
    [187299] = { "Unholy",  "Dyz",      3 },
    [187308] = { "Unholy",  "Dyz",      4 },
    [187318] = { "Unholy",  "Dyz",      5 },
    [187076] = { "Unholy",  "Oth",      1 },
    [187291] = { "Unholy",  "Oth",      2 },
    [187300] = { "Unholy",  "Oth",      3 },
    [187309] = { "Unholy",  "Oth",      4 },
    [187319] = { "Unholy",  "Oth",      5 },
    [187079] = { "Unholy",  "Zed",      1 },
    [187292] = { "Unholy",  "Zed",      2 },
    [187301] = { "Unholy",  "Zed",      3 },
    [187310] = { "Unholy",  "Zed",      4 },
    [187320] = { "Unholy",  "Zed",      5 },
    [187063] = { "Frost",   "Cor",      1 },
    [187287] = { "Frost",   "Cor",      2 },
    [187296] = { "Frost",   "Cor",      3 },
    [187305] = { "Frost",   "Cor",      4 },
    [187315] = { "Frost",   "Cor",      5 },
    [187065] = { "Frost",   "Kyr",      1 },
    [187288] = { "Frost",   "Kyr",      2 },
    [187297] = { "Frost",   "Kyr",      3 },
    [187306] = { "Frost",   "Kyr",      4 },
    [187316] = { "Frost",   "Kyr",      5 },
    [187071] = { "Frost",   "Tel",      1 },
    [187289] = { "Frost",   "Tel",      2 },
    [187298] = { "Frost",   "Tel",      3 },
    [187307] = { "Frost",   "Tel",      4 },
    [187317] = { "Frost",   "Tel",      5 },
}

aura_env.getSocketedShardItemId = function(itemLink)
    -- Return the item ID for the domination shard socketed in the specified
    -- 'itemLink'.  If no domination shard is socketed, return 'nil' instead.

    local gemId = string.match(itemLink, "item:%d*:%d*:(%d*):")

    if gemId ~= "" then
        gemId = tonumber(gemId)

        if aura_env.shardData[gemId] ~= nil then
            return gemId
        end
    end

    return nil
end

-------------------------------------------------------------------------------
-- TSU: UNIT_INVENTORY_CHANGED:player

function(allstates, event, ...)
    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end

    for _, slot in ipairs(aura_env.playerSlots) do
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(slot)
        if itemLoc:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLoc)
            local shardItemId = aura_env.getSocketedShardItemId(itemLink)

            if shardItemId ~= nil then
                local shardFullName = GetItemInfo(shardItemId)
                local shardData = aura_env.shardData[shardItemId]

                -- Sort by shard type and (short) name.

                local index = shardData[1] .. shardData[2]

                allstates[slot] = {
                    ["show"] = true,
                    ["changed"] = true,

                    ["icon"] = GetItemIcon(shardItemId),
                    ["itemId"] = shardItemId,
                    ["index"] = index,
                    ["name"] = shardData[2],    -- short name

                    ["shortName"] = shardData[2],
                    ["fullName"] = shardFullName,
                    ["description"] = aura_env.config[shardData[2]],
                    ["type"] = shardData[1],
                    ["rank"] = shardData[3],
                }
            end
        end
    end

    return true
end

-------------------------------------------------------------------------------
-- custom variables

{
    ["itemId"] = "number",
    ["name"] = "string",

    ["shortName"] = "string",
    ["fullName"] = "string",
    ["description"] = "string",

    ["type"] = {
        ["type"] = "select",
        ["values"] = {
            ["Blood"] = "Blood",
            ["Frost"] = "Frost",
            ["Unholy"] = "Unholy",
        },
    },
    ["rank"] = "number",
}
