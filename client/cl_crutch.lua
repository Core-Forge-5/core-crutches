local isInjured = false
local crutchObject = nil

local Config = {}
Config.crutchModel = -1035084591  --v_med_crutch01
Config.clipSet    = "move_lester_CaneUp" 

local function CreateCrutch()
    if not HasModelLoaded(Config.crutchModel) then
        RequestModel(Config.crutchModel)
        local attempts = 0
        while not HasModelLoaded(Config.crutchModel) and attempts < 100 do
            Citizen.Wait(10)
            attempts = attempts + 1
        end
        if not HasModelLoaded(Config.crutchModel) then return end
    end

    local ped = PlayerPedId()
    crutchObject = CreateObject(Config.crutchModel, GetEntityCoords(ped), true, false, false)
    if not DoesEntityExist(crutchObject) then return end

    AttachEntityToEntity(crutchObject, ped, 70, 1.18, -0.36, -0.20, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
end

local function RemoveCrutch()
    if DoesEntityExist(crutchObject) then
        DeleteEntity(crutchObject)
        SetEntityAsNoLongerNeeded(crutchObject)
        crutchObject = nil
    end
end

RegisterNetEvent('Core-Crutches:client:setInjured', function(enabled)
    local ped = PlayerPedId()

    if enabled then
        if isInjured then return end

        RequestAnimSet(Config.clipSet)
        local attempts = 0
        while not HasAnimSetLoaded(Config.clipSet) and attempts < 100 do
            Citizen.Wait(10)
            attempts = attempts + 1
        end
        if HasAnimSetLoaded(Config.clipSet) then
            SetPedMovementClipset(ped, Config.clipSet, 0.25)
        end

        isInjured = true
        CreateCrutch()
    else
        if not isInjured then return end

        ResetPedMovementClipset(ped, 0.25)
        ResetPedStrafeClipset(ped)
        ClearPedTasks(ped)
        Citizen.Wait(100)
        SetPedMovementClipset(ped, 'move_m@generic', 0.0)

        RemoveCrutch()
        isInjured = false
        TriggerEvent('ox_lib:notify', { type = 'success', description = 'Crutch removed - walking normally.' })
    end
end)

exports('UseCrutch', function()
    if not isInjured then
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You are not injured.' })
        return
    end

    local ped = PlayerPedId()
    ResetPedMovementClipset(ped)
    ResetPedStrafeClipset(ped)
    ClearPedTasks(ped)
    Citizen.Wait(50)

    RemoveCrutch()
    isInjured = false
    TriggerServerEvent('Core-Crutches:server:useCrutch')
end)

--Enforce limp if someone tries to change walkstyle
Citizen.CreateThread(function()
    while true do
        if isInjured then
            local ped = PlayerPedId()

            if not HasAnimSetLoaded(Config.clipSet) then
                RequestAnimSet(Config.clipSet)
                while not HasAnimSetLoaded(Config.clipSet) do
                    Citizen.Wait(10)
                end
            end

            if GetPedMovementClipset(ped) ~= GetHashKey(Config.clipSet) then
                SetPedMovementClipset(ped, Config.clipSet, 0.25)
            end


            if not DoesEntityExist(crutchObject) then
                CreateCrutch()
            end
        end

        Citizen.Wait(800)
    end
end)
--Disable sprint and jump but this is optional 
Citizen.CreateThread(function()
    while true do
        if isInjured then
            DisableControlAction(0, 21, true) --sprint
            DisableControlAction(0, 22, true) --jump
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

--Skin reload handler
local function ReapplyIfInjured()
    if not isInjured then return end
    Citizen.Wait(800)
    RemoveCrutch()
    CreateCrutch()

    local ped = PlayerPedId()
    RequestAnimSet(Config.clipSet)
    while not HasAnimSetLoaded(Config.clipSet) do Citizen.Wait(10) end
    SetPedMovementClipset(ped, Config.clipSet, 0.25)
end

--You can add EventHandlers for your Clothing menu like the examples:
AddEventHandler('illenium-appearance:client:reloadSkin',   ReapplyIfInjured)
AddEventHandler('illenium-appearance:client:changeOutfit', function() Citizen.CreateThread(ReapplyIfInjured) end)
AddEventHandler('fivem-appearance:skinChanged',            ReapplyIfInjured)
AddEventHandler('fivem-appearance:loadPed',                ReapplyIfInjured)

--Try to catch all clothing menu's with the native
AddEventHandler('gameEventTriggered', function(name)
    if name == 'CEventNetworkPedClothingChange' or name == 'CEventNetworkPedPlayerPedChange' then
        Citizen.CreateThread(ReapplyIfInjured)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if isInjured and (not DoesEntityExist(crutchObject) or not IsEntityAttached(crutchObject)) then
            ReapplyIfInjured()
        end
    end
end)

AddEventHandler('playerSpawned', function()
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        TriggerServerEvent('Core-Crutches:server:onSpawn')
    end)
end)

exports('IsInjured', function() return isInjured end)