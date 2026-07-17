-- This script keeps instant flights defaulted to OFF when server config allows the gossip menu to select instant flights.
local InstantFlightReset = {}

function InstantFlightReset.OnLogin(event, player)
    -- Reset any session-only instant flight flag
    player:SetData("instant_flight", false)

    -- Reset PlayerTaxi instant flight if your gossip uses this
    if player:GetTaxi() then
        player:GetTaxi():SetInstantTaxi(false)
    end
end

RegisterPlayerEvent(3, InstantFlightReset.OnLogin)
