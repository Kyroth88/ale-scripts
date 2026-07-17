-- This script keeps instant flights defaulted to OFF when server config allows the gossip menu to select instant flights.
local InstantFlightReset = {}

function InstantFlightReset.OnLogin(event, player)
    -- Reset any session-only instant flight flag
    player:SetData("instant_flight", false)

    -- Reset PlayerTaxi instant flight if your gossip uses this
    local taxi = player:GetTaxi()
    if taxi then
        taxi:SetInstantTaxi(false)
    end
end

-- Register player login event (PLAYER_EVENT_ON_LOGIN = 3)
RegisterPlayerEvent(3, InstantFlightReset.OnLogin)

print("[ALE] InstantFlightReset module loaded.")
