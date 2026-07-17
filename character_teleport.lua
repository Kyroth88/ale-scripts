local TeleportLocations = {}

local function LoadTeleports()
    print("[ALE] Loading teleport locations from game_tele...")
    local query = WorldDBQuery("SELECT name, map, position_x, position_y, position_z, orientation FROM game_tele")

    if not query then
        print("[ALE] ERROR: No entries found in game_tele!")
        return
    end

    repeat
        local name = query:GetString(0):lower()
        TeleportLocations[name] = {
            map = query:GetUInt32(1),
            x   = query:GetFloat(2),
            y   = query:GetFloat(3),
            z   = query:GetFloat(4),
            o   = query:GetFloat(5)
        }
    until not query:NextRow()

    print("[ALE] Teleport locations loaded.")
end
LoadTeleports()

local function OnPlayerCommand(event, player, command)
    command = command:lower()

    -- .tp <location>
    if command:sub(1, 3) == "tp " then
        local args = command:sub(4)
        local dest = TeleportLocations[args]

        if dest then
            player:Teleport(dest.map, dest.x, dest.y, dest.z, dest.o)
        else
            player:SendBroadcastMessage("Unknown teleport: " .. args)
        end

        return false
    end
end

RegisterPlayerEvent(42, OnPlayerCommand)
print("[ALE] .tp Command Hooked via Event 42.")
