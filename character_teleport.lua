--[[ 
    Universal ALE Teleport Command
    Works on all ALE builds without knowing the command event ID.
    Features:
      - .tp <location>
      - .tp player <name>
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
local function HandleTP(player, msg)
    if not msg then return end

    local args = msg:lower()

    -- Only handle .tp commands
    if args:sub(1, 3) ~= "tp " then
        return
    end

    local param = args:sub(4)

    ----------------------------------------------------------------
    -- .tp player <name>
    ----------------------------------------------------------------
    if param:sub(1, 7) == "player " then
        local targetName = param:sub(8)

        if targetName == "" then
            player:SendBroadcastMessage("Usage: .tp player <name>")
            return
        end

        local target = GetPlayerByName(targetName)

        if target then
            player:Teleport(
                target:GetMapId(),
                target:GetX(),
                target:GetY(),
                target:GetZ(),
                target:GetO()
            )
            player:SendBroadcastMessage("Teleported to player: " .. targetName)
        else
            player:SendBroadcastMessage("Player not found or not online.")
        end

        return
    end

    ----------------------------------------------------------------
    -- .tp <location>
    ----------------------------------------------------------------
    local loc = TeleportLocations[param]

    if loc then
        player:Teleport(loc.map, loc.x, loc.y, loc.z, loc.o)
        player:SendBroadcastMessage("Teleported to: " .. param)
    else
        player:SendBroadcastMessage("Unknown location.")
        player:SendBroadcastMessage("Use .tele list (GM command) to see all available locations.")
    end
end

---------------------------------------------------------------------
-- UNIVERSAL EVENT REGISTRATION
-- We hook ALL player events safely.
-- Only the correct one will fire for commands.
---------------------------------------------------------------------
for id = 1, 73 do
    RegisterPlayerEvent(id, function(event, player, msg)
        -- Only process if msg is a string (command/chat)
        if type(msg) == "string" then
            HandleTP(player, msg)
        end
    end)
end

print("[ALE] Universal Teleport Command Loaded.")
