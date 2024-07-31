QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("Server:SyncAtOffset")
AddEventHandler("Server:SyncAtOffset", function(coords, offset, heading, pitch)
    TriggerClientEvent("Client:SyncAtOffset", -1, coords, offset, heading, pitch)
end)

RegisterNetEvent("Server:DripFromHose")
AddEventHandler("Server:DripFromHose", function(coords, heading)
    TriggerClientEvent("Client:DripFromHose", -1, coords, heading)
end)

RegisterNetEvent("Server:SyncEntityLoop")
AddEventHandler("Server:SyncEntityLoop", function(netId, pitch, type)
    TriggerClientEvent("Client:SyncEntityLoop", -1, netId, pitch, type)
end)

QBCore.Functions.CreateCallback('Server:CheckPermission', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'ambulance' then
        cb(true)
    else
        cb(false)
    end
end)
