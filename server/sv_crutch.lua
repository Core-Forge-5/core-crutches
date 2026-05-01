--Init
local activeCrutches = {}
local DEFAULT_MINUTES = 15
local EMS_MIN_MINUTES = 8
local MAX_MINUTES = 15

local function isAdmin(src)
    return IsPlayerAceAllowed(src, 'admin')
end

local function isEMS(src)
    local ply = Player(src)
    return ply and ply.state and ply.state.job == 'ambulance'
end

local function setCrutched(src, minutes)
    minutes = math.min(minutes, MAX_MINUTES)
    local expires = os.time() + (minutes * 60)

    activeCrutches[src] = expires
    Player(src).state.crutchExpires = expires

    TriggerClientEvent('Core-Crutches:client:setInjured', src, true)
end

local function clearCrutch(src, notify)
    activeCrutches[src] = nil

    local ply = Player(src)
    if ply then
        ply.state.crutchExpires = nil
        TriggerClientEvent('Core-Crutches:client:setInjured', src, false)

        if notify then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'You have recovered.'
            })
        end
    end
end

RegisterCommand('applycrutch', function(source, args)
    local target = tonumber(args[1]) or source
    local minutes = tonumber(args[2])

    if not GetPlayerPing(target) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid player ID.'
        })
        return
    end

    if activeCrutches[target] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Player is already injured.'
        })
        return
    end

    local finalMinutes = DEFAULT_MINUTES

    if minutes then
        if isEMS(source) then
            finalMinutes = math.min(
                MAX_MINUTES,
                math.max(EMS_MIN_MINUTES, minutes)
            )
        elseif isAdmin(source) then
                finalMinutes = math.min(
                MAX_MINUTES,
                math.max(EMS_MIN_MINUTES, minutes)
            )
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'You do not have permission to set crutch time.'
            })
            return
        end
    end

    setCrutched(target, finalMinutes)

    TriggerClientEvent('ox_lib:notify', target, {
        type = 'inform',
        description = ('Injured for %d minutes.'):format(finalMinutes)
    })
end, false)

RegisterCommand('crutchtime', function(source)
    local expires = activeCrutches[source]

    if not expires then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'inform',
            description = 'You are not injured.'
        })
        return
    end

    local remaining = expires - os.time()

    if remaining <= 0 then
        clearCrutch(source, true)
        return
    end

    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'inform',
        description = ('Crutch time left: %d:%02d'):format(minutes, seconds)
    })
end, false)

RegisterNetEvent('Core-Crutches:server:useCrutch', function()
    local src = source

    if not activeCrutches[src] then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'You are not injured.'
        })
        return
    end

    local count = exports.ox_inventory:Search(src, 'count', 'crutch')
    if count < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'No crutch item.'
        })
        return
    end

    exports.ox_inventory:RemoveItem(src, 'crutch', 1)
    clearCrutch(src, true)
end)

CreateThread(function()
    while true do
        local now = os.time()

        for src, expires in pairs(activeCrutches) do
            if expires <= now then
                if GetPlayerPing(src) then
                    clearCrutch(src, true)
                else
                    activeCrutches[src] = nil
                end
            end
        end

        Wait(10000)
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    for _, src in ipairs(GetPlayers()) do
        local ply = Player(src)
        local expires = ply and ply.state and ply.state.crutchExpires
        
        if expires and expires > os.time() then
            activeCrutches[src] = expires
            TriggerClientEvent('Core-Crutches:client:setInjured', src, true)
        end
    end
end)
AddEventHandler('playerDropped', function()
    activeCrutches[source] = nil
end)

RegisterNetEvent('Core-Crutches:server:onSpawn', function()
    local src = source
    local ply = Player(src)
    local expires = ply and ply.state.crutchExpires

    if expires and expires > os.time() then
        activeCrutches[src] = expires
        TriggerClientEvent('Core-Crutches:client:setInjured', src, true)
    else
        if ply then
            ply.state.crutchExpires = nil
        end
    end
end)