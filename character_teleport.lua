--[[
    Universal ALE Teleport Command
    Optimized & Verified for AzerothCore Lua Engine
--]]

local TeleportLocations = {}

---------------------------------------------------------------------
-- LOAD TELEPORT LOCATIONS
---------------------------------------------------------------------
local function LoadTeleports()
    print("[ALE] Loading teleport locations from game_tele...")
    local query = WorldDBQuery("SELECT name, map, position_x, position_y, position_z, orientation FROM game_tele")
    
    if not query then
        print("[ALE] ERROR: No entries found in game_tele!")
        return
    end

    local count = 0
    repeat
        local name = query:GetString(0):lower()
        TeleportLocations[name] = {
            map = query:GetUInt32(1),
            x   = query:GetFloat(2),
            y   = query:GetFloat(3),
            z   = query:GetFloat(4),
            o   = query:GetFloat(5)
        }
        count = count + 1
    until not query:NextRow()
    
    print("[ALE] Loaded " .. count .. " teleport locations.")
end
LoadTeleports()

---------------------------------------------------------------------
-- MAIN TELEPORT HANDLER
---------------------------------------------------------------------
local function OnPlayerCommand(event, player, command)
    -- Normalize command
    command = command:lower()

    -- Check for .tp command
    if command:sub(1, 3) == "tp " then
        local args = command:sub(4) -- everything after "tp "
        local dest = Teleports[args]

        if dest then
            player:Teleport(dest.map, dest.x, dest.y, dest.z, dest.o)
        else
            player:SendBroadcastMessage("Unknown teleport: " .. args)
        end

        return false -- block default handling
    end
end

        ----------------------------------------------------------------
        -- #tele player <name>
        ----------------------------------------------------------------
        if subCommand:lower() == "player" then
            local targetName = args[3]
            if not targetName or targetName == "" then
                player:SendBroadcastMessage("Usage: #tele player <name>")
                return false
            end

            local target = GetPlayerByName(targetName)
            if target then
                player:Teleport(target:GetMapId(), target:GetX(), target:GetY(), target:GetZ(), target:GetO())
                player:SendBroadcastMessage("Teleported to player: " .. targetName)
            else
                player:SendBroadcastMessage("Player not found or not online.")
            end
            return false
        end

        ----------------------------------------------------------------
        -- #tele <location>
        ----------------------------------------------------------------
        -- Safely pieces the string back together if a location has spaces (e.g., #tele iron forge)
        local locName = table.concat(args, " ", 2):lower()
        local loc = TeleportLocations[locName]

        if loc then
            player:Teleport(loc.map, loc.x, loc.y, loc.z, loc.o)
            player:SendBroadcastMessage("Teleported to: " .. locName)
        else
            player:SendBroadcastMessage("Unknown location: " .. locName)
        end

        return false -- Returning false safely stops AzerothCore command processing
    end
end

-- Hook directly into PLAYER_EVENT_ON_COMMAND (Event 42)
RegisterPlayerEvent(42, OnPlayerCommand)
print("[ALE] #tele Command Engine Hooked via Event 42.")
