local TeleportLocations = {}

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

local function OnPlayerCommand(event, player, command)
    -- Extract the first word to find the trigger, keeping symbols intact
    local trigger = command:match("%S+")
    if not trigger then return end
    
    trigger = trigger:lower()

    -- Correctly match the command symbol prefix rules (.tp or tp)
    if trigger == ".tp" or trigger == "tp" then
        -- Strip the trigger from the front to extract the exact location name string
        -- This preserves case sensitivity for arguments if needed later
        local args = command:sub(#trigger + 2) 
        
        if args == "" or not args then
            player:SendBroadcastMessage("Syntax: .tp <location>")
            return false
        end

        -- Match against our lowercased database keys
        local lookupName = args:lower()
        local dest = TeleportLocations[lookupName]

        if dest then
            player:Teleport(dest.map, dest.x, dest.y, dest.z, dest.o)
            player:SendBroadcastMessage("Teleported to: " .. args)
        else
            player:SendBroadcastMessage("Unknown teleport: " .. args)
        end

        return false -- Blocks core "command not found" text
    end
end

RegisterPlayerEvent(42, OnPlayerCommand)
print("[ALE] .tp Command Hooked via Event 42.")
