-- boost.lua (ALE for AzerothCore)
-- Command: .boost 60 | 70 | 80

local PLAYER_EVENT_ON_COMMAND = 42

local SKILL_RIDING   = 762
local SKILL_COOKING  = 185
local SKILL_FIRSTAID = 129
local SKILL_FISHING  = 356

-- Base profession spells
local SPELL_COOKING   = 2550
local SPELL_FIRSTAID  = 3273
local SPELL_FISHING   = 7731

-- Correct SetSkill wrapper for AzerothCore ALE:
-- SetSkill(skillId, max, step, curr)
local function SetSkillProper(player, skillId, step, max)
    player:SetSkill(skillId, max, step, max)
end

-- Bandage recipes by tier
local BANDAGES_60 = {
    3275, 3276, -- Linen
    3277, 3278, -- Wool
    7928, 7929, -- Silk
    10840, 10841, -- Mageweave
    18629, 18630, -- Runecloth
}

local BANDAGES_70 = {
    27032, 27033, -- Netherweave
}

local BANDAGES_80 = {
    45545, 45546, -- Frostweave
}

-- Helper to merge bandage lists safely
local function MergeBandages(...)
    local result = {}
    for _, list in ipairs({...}) do
        for _, spell in ipairs(list) do
            table.insert(result, spell)
        end
    end
    return result
end

local BOOST_CONFIG = {
    [60] = {
        level = 60,
        ridingStep = 4, ridingMax = 300,
        profStep = 4,  profMax = 300,
        ridingSpells = {
            33388, 33391, 34090,
        },
        bandages = MergeBandages(BANDAGES_60),
    },
    [70] = {
        level = 70,
        ridingStep = 5, ridingMax = 375,
        profStep = 5,  profMax = 375,
        ridingSpells = {
            33388, 33391, 34090, 34091,
        },
        bandages = MergeBandages(BANDAGES_60, BANDAGES_70),
    },
    [80] = {
        level = 80,
        ridingStep = 6, ridingMax = 450,
        profStep = 6,  profMax = 450,
        ridingSpells = {
            33388, 33391, 34090, 34091, 54197,
        },
        bandages = MergeBandages(BANDAGES_60, BANDAGES_70, BANDAGES_80),
    },
}

local function ApplyBoost(player, targetLevel)
    local cfg = BOOST_CONFIG[targetLevel]
    if not cfg then
        player:SendBroadcastMessage("Usage: .boost 60 | 70 | 80")
        return
    end

    player:SetLevel(cfg.level)

    -- Riding
    SetSkillProper(player, SKILL_RIDING, cfg.ridingStep, cfg.ridingMax)
    for _, spellId in ipairs(cfg.ridingSpells) do
        player:LearnSpell(spellId)
    end

    -- Professions
    SetSkillProper(player, SKILL_COOKING,  cfg.profStep, cfg.profMax)
    SetSkillProper(player, SKILL_FIRSTAID, cfg.profStep, cfg.profMax)
    SetSkillProper(player, SKILL_FISHING,  cfg.profStep, cfg.profMax)

    player:LearnSpell(SPELL_COOKING)
    player:LearnSpell(SPELL_FIRSTAID)
    player:LearnSpell(SPELL_FISHING)

    -- Bandage recipes
    for _, spellId in ipairs(cfg.bandages) do
        player:LearnSpell(spellId)
    end

    player:SendBroadcastMessage(
        string.format("Boosted to %d with riding, professions, and all appropriate bandages learned.", cfg.level)
    )
end

local function OnCommand(event, player, command)
    local cmd, arg = command:match("^(%S+)%s*(%S*)")
    if not cmd or cmd:lower() ~= "boost" then
        return
    end

    local level = tonumber(arg)
    if not level or not BOOST_CONFIG[level] then
        player:SendBroadcastMessage("Usage: .boost 60 | 70 | 80")
        return false
    end

    ApplyBoost(player, level)
    return false
end

RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND, OnCommand)
print("[ALE] Character Boost Enabled (60|70|80)")
