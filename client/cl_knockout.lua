local knockedOut = false
local wasKnockedOut = false
local durationTime = 5400
local regen = Config.Knockout.Regeneration --store this for lookup
local regenInterval = Config.Knockout.RegenInterval
local function CleanupEffects()
    Wait(500)
    StopGameplayCamShaking(true)
    StopAllScreenEffects()
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
end
--0.02 ms peak
Citizen.CreateThread(function()
    if Config.Knockout.Enabled ~= true then return end
    while true do
        local ped = PlayerPedId()
        local sleep = 500
        if knockedOut then
            sleep = 50
            SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
            SetTimecycleModifier('Bloom')
            SetTimecycleModifierStrength(0.4)
            SetExtraTimecycleModifier("Drunk")
            SetExtraTimecycleModifierStrength(0.4)
            local health = GetEntityHealth(ped)
            if  (GetGameTimer() % regenInterval) < 50 then
                local currentHealth = GetEntityHealth(ped)
                SetEntityHealth(ped, math.min(200, currentHealth + regen)) --200 or current health plus regen
            end
            wasKnockedOut = true

        elseif wasKnockedOut then
            CleanupEffects()
            wasKnockedOut = false
        end
        if not knockedOut and IsPedInMeleeCombat(ped) then --input
            sleep = 30

            if GetEntityHealth(ped) < Config.Knockout.HealthAmount then --calculate damage
                SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
                ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.2)
                knockedOut = true
                Citizen.SetTimeout(durationTime, function()
                    knockedOut = false
                end)
            end
        end
        Citizen.Wait(sleep) --loose
    end
end)