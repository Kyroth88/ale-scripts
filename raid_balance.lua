-- ============================================
-- ALE Raid Damage Aura Scaler (Players + Pets + Group)
-- ============================================

local AURA_ID = 90001 -- Custom aura created via SQL

-- Stacks = how many *10%* reductions to apply
local RAID_AURA_STACKS = {

    [409] = 5,  -- Molten Core (default:5)
    [469] = 4,  -- BWL (default:4)
    [509] = 4,  -- AQ20 (default:4)
    [531] = 3,  -- AQ40 (default:3)
    [309] = 5,  -- ZG (default:5)
    [533] = 2,  -- Naxx (default:2)
}

-- Apply or update aura on a single unit (player or pet)
local function ApplyAuraToUnit(unit, stacks)
    if stacks > 0 then
        if not unit:HasAura(AURA_ID) then
            unit:AddAura(AURA_ID, unit)
        end
        local aura = unit:GetAura(AURA_ID)
        if aura then
            aura:SetStackAmount(stacks)
        end
    else
        if unit:HasAura(AURA_ID) then
            unit:RemoveAura(AURA_ID)
        end
    end
end

-- Apply aura to player, pet, and group members
local function ApplyAuraToGroup(player)
    local stacks = RAID_AURA_STACKS[player:GetMapId()] or 0

    -- Player
    ApplyAuraToUnit(player, stacks)

    -- Player pet
    local pet = player:GetPet()
    if pet then
        ApplyAuraToUnit(pet, stacks)
    end

    -- Group / raid members
    local group = player:GetGroup()
    if group then
        for _, member in ipairs(group:GetMembers()) do
            ApplyAuraToUnit(member, stacks)

            local mPet = member:GetPet()
            if mPet then
                ApplyAuraToUnit(mPet, stacks)
            end
        end
    end
end

-- When player changes map
local function OnMapChanged(event, player)
    ApplyAuraToGroup(player)
end
RegisterPlayerEvent(27, OnMapChanged)

-- When pet is summoned
local function OnPetSpawned(event, player, pet)
    ApplyAuraToGroup(player)
end
RegisterPlayerEvent(28, OnPetSpawned)

-- When player logs in
local function OnLogin(event, player)
    ApplyAuraToGroup(player)
end
RegisterPlayerEvent(3, OnLogin)

print("[ALE] Raid Damage Aura Scaler Loaded: AURA 90001 MUST BE IN SPELL_DBC")
