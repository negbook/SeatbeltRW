--[=[
--Should be networked
RegisterNetEvent('Seatbelt:Switch')
AddEventHandler('Seatbelt:Switch', function(onoff) 
    --TriggerClientEvent('Seatbelt:SyncSwitch',-1,source,onoff)
end)

RegisterNetEvent('Seatbelt:Alarm')
AddEventHandler('Seatbelt:Alarm', function(class) 
    --TriggerClientEvent('Seatbelt:SyncAlarm',-1,source,class)
end)
--]=]
local Seatbelted = {}
local e = {}
RegisterNetEvent('Seatbelt:Switch')
AddEventHandler('Seatbelt:Switch', function(onoff) 
    local player = source 
    if player then 
        if Seatbelted[player] == nil then Seatbelted[player] = newObject(false) end 
        Seatbelted[player]("set",onoff)
        
    end 
end)

RegisterNetEvent('Seatbelt:GetPlayerSeatbelted')
AddEventHandler('Seatbelt:GetPlayerSeatbelted', function(targetped) 
    local targetped = targetped
    local source = source
    CreateThread(function()
        local scope = (Seatbelted or e)[targetped]
        if scope == nil then print("[GetPlayerSeatbelted] player ".. targetped .. " doesn't exist") end 
        TriggerClientEvent("Seatbelt:GetPlayerSeatbeltedResultToPlayer:"..targetped, source, scope and scope("get"))
    end)
end)

AddEventHandler('playerDropped', function (reason)
    local player = source 
    if player then 
        Seatbelted[player] = nil 
    end 
end)

