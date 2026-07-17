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

local function OnPlayerCommand(event, player, command)
    -- Split the command string into arguments
    local args = {}
    for word in string.gmatch(command, "%S+") do
        table.insert(args, word)
    end

    local trigger = args[1]
    if not trigger then 
        return 
    end

    trigger = trigger:lower()

    -- Correctly match ".boost" or "boost" (in case the core automatically strips the prefix)
    if trigger == ".boost" or trigger == "boost" then
        local levelArg = tonumber(args[2])

        -- Validate the level argument (60, 70, or 80)
        if not levelArg or not BOOST_CONFIG[levelArg] then
            player:SendAreaTriggerMessage("Syntax: .boost <60 | 70 | 80>")
            return false -- Handled, prevent "command not found" system errors
        end

        local config = BOOST_CONFIG[levelArg]

        -- 1. Set Level
        player:SetLevel(config.level)

        -- 2. Set Riding Skill & Teach Riding Spells
        SetSkillProper(player, SKILL_RIDING, config.ridingStep, config.ridingMax)
        for _, spellId in ipairs(config.ridingSpells) do
            player:LearnSpell(spellId)
        end

        -- 3. Set Profession Skills (Cooking, First Aid, Fishing)
        player:LearnSpell(SPELL_COOKING)
        SetSkillProper(player, SKILL_COOKING, config.profStep, config.profMax)

        player:LearnSpell(SPELL_FISHING)
        SetSkillProper(player, SKILL_FISHING, config.profStep, config.profMax)

        player:LearnSpell(SPELL_FIRSTAID)
        SetSkillProper(player, SKILL_FIRSTAID, config.profStep, config.profMax)

        -- 4. Teach Bandage Recipes
        for _, spellId in ipairs(config.bandages) do
            player:LearnSpell(spellId)
        end

        player:SendAreaTriggerMessage("Character successfully boosted to level " .. levelArg .. "!")
        return false -- Returning false stops further core command processing
    end
end

-- Register the command event
RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND, OnPlayerCommand)

print("[ALE] Character Boost Enabled (60|70|80) via .boost")
