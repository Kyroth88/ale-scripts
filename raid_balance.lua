-- ============================================
-- ALE Raid Damage Aura Scaler (Level <= 70 Only)
-- ============================================

local AURA_ID = 90001 -- Custom aura created via SQL

-- Stacks = how many *10%* reductions to apply
local RAID_AURA_STACKS = {
    [409] = 5,  -- Molten Core (default:5)
    [249] = 5,  -- Onyxia's Lair (default:5)
    [469] = 4,  -- BWL (default:4)
    [509] = 4,  -- AQ20 (default:4)
    [531] = 3,  -- AQ40 (default:3)
    [309] = 5,  -- ZG (default:5)
    [533] = 2,  -- Naxx (default:2)
}

-- Apply or update aura on a single unit (player or pet)
local function ApplyAuraToUnit(unit, stacks)
    if not unit then return end
    
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

-- Safely updates an individual player and their current pet if they are level 70 or lower
local function UpdatePlayerAndPet(player)
    -- LEVEL RESTRICTION CHECK: Only apply if player level is <= 70
    if player:GetLevel() > 70 then
        -- Clean up the aura if they are level 80 or higher
        ApplyAuraToUnit(player, 0)
        local pet = player:GetPet()
        if pet then ApplyAuraToUnit(pet, 0) end
        return 
    end

    local stacks = RAID_AURA_STACKS[player:GetMapId()] or 0
    
    -- Update the player
    ApplyAuraToUnit(player, stacks)
    
    -- Update the player's pet
    local pet = player:GetPet()
    if pet then
        ApplyAuraToUnit(pet, stacks)
    end
end

-- When an individual player changes map
local function OnMapChanged(event, player)
    UpdatePlayerAndPet(player)
end
RegisterPlayerEvent(27, OnMapChanged) -- PLAYER_EVENT_ON_MAP_CHANGE

-- When a pet is explicitly summoned/spawned
local function OnPetSpawned(event, player, pet)
    -- Check if the owner matches the level criteria before applying to the pet
    if player:GetLevel() <= 70 then
        local stacks = RAID_AURA_STACKS[player:GetMapId()] or 0
        ApplyAuraToUnit(pet, stacks)
    else
        ApplyAuraToUnit(pet, 0)
    end
end
RegisterPlayerEvent(28, OnPetSpawned) -- PLAYER_EVENT_ON_PET_TO_PLAYER

-- When an individual player logs in
local function OnLogin(event, player)
    UpdatePlayerAndPet(player)
end
RegisterPlayerEvent(3, OnLogin) -- PLAYER_EVENT_ON_LOGIN

print("[ALE] Raid Damage Aura Scaler Loaded: AURA 90001 MUST BE IN SPELL_DBC")
