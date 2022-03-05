
ThisVarsUpdate = function() 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local class = GetVehicleClass(veh)
    PlayerPed                 =     ped 
    PlayerVehicle             =     veh 
    PlayerVehicleClass        =     class 
    isPlayerInVehicle         =     veh ~= 0
    isPlayerInACar            =     isPlayerInVehicle and IsClassACar(class)
    isPlayerVehicleDriver     =     isPlayerInACar and GetPedInVehicleSeat(PlayerVehicle, -1) == PlayerPed
    isPlayerBeltTied          =     BeltTied("get")
    PlayerAlarmTimer          =     (not isPlayerBeltTied and 0) or (PlayerAlarmTimer or 0)
    isMale                    =     IsPedMale(ped)
    
end 

BeltTied = newObject(false,function()
    ThisVarsUpdate()
end)

RegisterCommand("switchSeatbelt", function() SwitchBelt() end, false)
RegisterCommand("switchSeatbeltJoy", function() SwitchBelt() end, false)
RegisterKeyMapping("switchSeatbelt", "Seatbelt Equipment", "keyboard", Config.Keys.Keyboard)
RegisterKeyMapping("switchSeatbeltJoy", "Seatbelt Equipment", "PAD_DIGITALBUTTONANY", "RDOWN_INDEX")

local SeatbeltCallback = {} 
local e = {}
local function newObject(value,onchange)
    local changeCB = onchange
    local haschange = false 
    local default = value
    local await = nil
    return function(action,v) 
        if action == 'get' then 
            return value 
        elseif action == 'set' then 
            if value ~= v then 
                haschange = true
                value = v 
                if changeCB then changeCB(value,v) end 
            else 
                haschange = false 
            end 
        elseif action == 'setawait' then 
            await = v 
        elseif action == 'resetawait' then 
            await = nil
        elseif action == 'getawait' then 
            return await
        elseif action == 'reset' then 
            value = default
        elseif action == 'has' then 
            return value ~= nil
        elseif action == 'haschange' then 
            local r = haschange
            haschange = false 
            return r
        else 
            error "invalid action"
        end 
    end 
end 
GetPlayerSeatBelted = function (player)
   
    local playerServerId = GetPlayerServerId(player)
    if SeatbeltCallback[playerServerId] == nil  then 
        SeatbeltCallback[playerServerId] = newObject()
    end 
    local scope = (SeatbeltCallback or e)[playerServerId]
    if scope("getawait") == nil then 
        TriggerServerEvent('Seatbelt:GetPlayerSeatbelted',playerServerId)
        local p = promise.new() 
        scope("setawait",p) 
        local tempEvent
        tempEvent = RegisterNetEvent('Seatbelt:GetPlayerSeatbeltedResultToPlayer:'..playerServerId, function(onoff)
            local resultscope = (SeatbeltCallback or e)[playerServerId]
            if resultscope then 
                resultscope("getawait"):resolve(onoff);
                resultscope("resetawait")
            end 
            RemoveEventHandler(tempEvent)
        end)
        scope("set",Citizen.Await(p))
        return scope("get") or false --[[targetplayer not exist]]
    else 
        local scope = (SeatbeltCallback or e)[playerServerId]
        return scope("get") or false --[[no callback result or targetplayer not exist at the server]]
    end 
end 

GetPlayerSeatBeltedByPed = function(ped)
    return GetPlayerSeatBelted(NetworkGetPlayerIndexFromPed(ped))
end 

exports('GetPlayerSeatBelted',GetPlayerSeatBelted)	
exports('GetPlayerSeatBeltedByPed',GetPlayerSeatBeltedByPed)	