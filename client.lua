local PlayerData = {}
local HoseActivated = false
local ButtonPressed = false
local SelectedPedWeapon = false
local stop = true
local usedScript = false
local SyncedParticles = {}
local weapon = GetHashKey("WEAPON_HOSE")

TriggerEvent('chat:addSuggestion', '/' .. Config.HoseCommand, 'Equip/Unequip your hose')

RegisterCommand(Config.HoseCommand, function()
    QBCore.Functions.TriggerCallback('Server:CheckPermission', function(hasPermission)
        if hasPermission then
            if HoseActivated then
                HoseActivated = false
                ButtonPressed = false
                RemoveWeaponFromPed(PlayerPedId(), GetHashKey("WEAPON_HOSE"))
            else
                if not usedScript then    
                    usedScript = true
                end
                if IsAllowedVehicleNearby() then
                    HoseActivated = true
                    local weapon = GetHashKey("WEAPON_HOSE")
                    local ped = PlayerPedId()
                    GiveWeaponToPed(ped, weapon, 1000, false, false)
                    SetCurrentPedWeapon(ped, weapon, true)
                    ContinueHose(ped)
                else
                    TriggerEvent("QBCore:Notify", "You must be near an allowed vehicle to use the hose.", "error")
                end
            end
        else
            TriggerEvent("QBCore:Notify", "You do not have permission to use this command.", "error")
        end
    end)
end)

RegisterNetEvent("Client:SyncAtOffset")
AddEventHandler("Client:SyncAtOffset", function(coords, offset, heading, pitch)
    UseParticleFxAssetNextCall("core")
    SetParticleFxShootoutBoat(1)
    local handle = StartParticleFxLoopedAtCoord("water_cannon_jet", coords.X, coords.Y, coords.Z, pitch, 0, heading, 0.5, false, false, false, false)
    Offset(offset, heading, pitch)
    Wait(200)
    StopParticleFxLooped(handle, false)
end)

RegisterNetEvent("Client:SyncEntityLoop")
AddEventHandler("Client:SyncEntityLoop", function(netId, pitch, type)
    if type == 1 then
        SyncedParticles[netId] = pitch
        ContinueParticles(netId, NetToPed(netId))
    elseif type == 2 then 
        if SyncedParticles[netId] ~= nil then
            SyncedParticles[netId] = nil     
        end                   
    elseif type == 3 then 
        SyncedParticles[netId] = pitch
    end
end)

function ContinueParticles(netId, entity)
    UseParticleFxAssetNextCall("core")
    local handle = StartParticleFxLoopedOnEntity("water_cannon_jet", entity, 0.2, 0.15, 0.0, 0.1, 0.0, 0.0, 0.7, false, false, false)
    local coords = GetEntityCoords(entity, true)
    UseParticleFxAssetNextCall("core")
    local handleOffset = StartParticleFxLoopedOnEntity("water_cannon_spray", entity, 0.2, 9.0 + SyncedParticles[netId] * 0.4, 0, 0.1, 0.0, 0.0, 0.9, false, false, false)     
    UseParticleFxAssetNextCall("core")
    local handleOffset2 = StartParticleFxLoopedOnEntity("water_cannon_spray", entity, 0.2, 9.0 + SyncedParticles[netId] * 0.4, 0, 0.1, 0.0, 0.0, 0.001, false, false, false)
    while SyncedParticles[netId] ~= nil do
        SetParticleFxLoopedOffsets(handle, 0.26, 0.2, 0.13, SyncedParticles[netId], 0.0, 0.0)
        SetParticleFxLoopedOffsets(handleOffset, 0.2, 9.5 + SyncedParticles[netId] * 0.4, -0.6, SyncedParticles[netId], 0.0, 0.8)
        SetParticleFxLoopedOffsets(handleOffset2, 0.2, 5.0 + SyncedParticles[netId] * 0.4, SyncedParticles[netId] - 23.0, SyncedParticles[netId], 0.0, 0.0)
        Citizen.Wait(100)
    end
    StopParticleFxLooped(handle, false)
    StopParticleFxLooped(handleOffset, false)
    StopParticleFxLooped(handleOffset2, false)
end

function Offset(offset, heading, pitch)
    UseParticleFxAssetNextCall("core")
    SetParticleFxShootoutBoat(1)
    local handle = StartParticleFxLoopedAtCoord("water_cannon_spray", offset.X, offset.Y, offset.Z, pitch, 0, heading, 1, false, false, false, false)
    Wait(200)
    StopParticleFxLooped(handle, false)
end

function ControlParticles()
    Citizen.CreateThread(function()
        local net = PedToNet(PlayerPedId())
        if IsPlayerFreeAiming(PlayerId()) then
            TriggerServerEvent("Server:SyncEntityLoop", net, GetGameplayCamRelativePitch(), 2)
            TriggerServerEvent("Server:SyncEntityLoop", net, GetGameplayCamRelativePitch(), 1)
            while ButtonPressed do 
                local relativePitch = GetGameplayCamRelativePitch()
                local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.2, 9.0 + relativePitch * 0.4, 0.0)
                local _, groundZ = GetGroundZFor_3dCoord(offset.x, offset.y, offset.z, false)
                TriggerServerEvent("Server:SyncEntityLoop", net, GetGameplayCamRelativePitch(), 3)
                Citizen.Wait(100)
            end
            TriggerServerEvent("Server:SyncEntityLoop", net, GetGameplayCamRelativePitch(), 2)
        end
    end)
end

function ContinueHose(ped)
    local playerId = GetPlayerPed(-1)
    while HoseActivated do
        if GetSelectedPedWeapon(playerId) == weapon and IsDisabledControlPressed(0, 24) then
            ButtonPressed = true
            ControlParticles()
            while IsDisabledControlPressed(0, 24) do
                if IsPlayerFreeAiming(playerId) then 
                    break
                end
                if IsPedInAnyVehicle(ped, true) or IsPauseMenuActive() or not IsAllowedVehicleNearby() then
                    ButtonPressed = false
                    break
                end
                Citizen.Wait(1)
            end
            ButtonPressed = false
        end
        if not IsAllowedVehicleNearby() then
            HoseActivated = false
            RemoveWeaponFromPed(playerId, weapon)
            TriggerEvent("QBCore:Notify", "You moved too far away from the allowed vehicle.", "error")
        end
        Citizen.Wait(1)
    end
end

Citizen.CreateThread(function()
    while true do
        if HoseActivated then 
            local player = PlayerPedId()
            if GetSelectedPedWeapon(player) == weapon then
                DisableControlAction(0, 24, true)
                DisablePlayerFiring(PlayerId(), true)
            end
        end
        Citizen.Wait(2)
    end
end)

function IsAllowedVehicleNearby()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    for _, vehicle in ipairs(Config.AllowedVehicles) do
        local vehicleHash = GetHashKey(vehicle)
        local nearbyVehicle = GetClosestVehicle(playerCoords, Config.MaxDistance, vehicleHash, 70)
        if DoesEntityExist(nearbyVehicle) then
            return true
        end
    end
    return false
end

function RequestParticles()
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(100)
    end
    UseParticleFxAsset("core")
end
