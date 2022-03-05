isVehicleClassMatch = function(class,...)
    return optsMatch(class,...)
end 

IsClassACar = function(class)
    return isVehicleClassMatch(class,0,1,2,3,4,5,6,7,9,10,11,12,17,18,19,20)
end 

IsClassModernCar = function(class)
    return isVehicleClassMatch(class,2,5,6,7)
end 

IsClassServiceCar = function(class)
    return isVehicleClassMatch(class,17,18,20)
end 

GetClassName = function(class) 
    return (IsClassModernCar(class) and 'sport') or (IsClassServiceCar(class) and 'service') or 'normal'
end 


GetTieAnimDictAndName = function(isEquip)
    local dict = 'clothingtie'
    local anim = isEquip and 'try_tie_neutral_a' or 'try_tie_neutral_b'
    local starttime = 0.1 
    local endtime = isEquip and 0.52 or 0.49
    return dict,anim,starttime,endtime
end 

local randomFloat = function (lower, greater)
    return lower + math.random()  * (greater - lower);
end

function playAnim(ped, dict, name, startat, pauseat)
   local startat = startat or 0.0
   if not HasEntityAnimFinished(ped, dict, name) then StopAnimPlayback(ped, dict, name) end
   if not HasAnimDictLoaded(dict) then 
       RequestAnimDict(dict)
       while not HasAnimDictLoaded(dict) do Wait(0) end
   end 
   TaskPlayAnim(ped, dict, name, 8.0, 2.0, -1, 48, 2, 0, 0, 0)
   SetEntityAnimCurrentTime(ped, dict, name, startat)
   if pauseat then 
       local currentTime = 0.0
       local rand = nil
       while not IsEntityPlayingAnim(ped, dict, name, 3) do Wait(0) end 
       while IsEntityPlayingAnim(ped, dict, name, 3) and isPlayerInACar do 
           Wait(0)
           rand = math.random(1,10)
           if rand >= 4 then 
               if GetEntitySpeed(PlayerVehicle) > 3.0 then 
                   SetControlNormal(2, 59 , randomFloat(-100.0,95.0))
               else 
                   DisableControlAction(2,59,true)
               end 
           end 
           DisableControlAction(2,75,true)
           currentTime = GetEntityAnimCurrentTime(ped, dict, name);
           if currentTime >= pauseat then
               SetEntityAnimCurrentTime(ped, dict, name, currentTime);
               SetEntityAnimSpeed(ped, dict, name, 0);
               StopAnimPlayback(ped,dict, name)
           end
       end  
   end 
end

PedPlayTieAnim = function (ped, isEquip)
    local animdict, animname, starttime, endtime = GetTieAnimDictAndName(isEquip)
    playAnim(ped, animdict, animname, starttime, endtime)
end 

IsPedTieAniming = function() 
    return IsEntityPlayingAnim(ped, 'clothingtie','try_tie_neutral_a', 3) or IsEntityPlayingAnim(ped, 'clothingtie','try_tie_neutral_b', 3)
end 


RequestScriptAudioBank("SEATBELT\\SEATBELT", false)
RequestScriptAudioBank("SEATBELT\\SEATBELT_DEBUG", false)
local soundId_normal = GetSoundId()
local soundId_sport =  GetSoundId()
local soundId_service = GetSoundId()
local soundId_debug = GetSoundId()
function StopAlarmSounds()
    StopSound(soundId_sport) 
    StopSound(soundId_service) 
    StopSound(soundId_normal)
    StopSound(soundId_debug)
end 

GetSoundDictAndName = function(isEquip,soundId) 
    local dict = "SEATBELT_SOUNDSET_BUCKLE"
    local name = isEquip and "seatbelt_buckle" or "seatbelt_unbuckle"
    return soundId or -1, dict, name 
end 

PlayEntitySound = function(entity, soundid , sounddict, soundname)
    return PlaySoundFromEntity(soundid, soundname, entity, sounddict, true, 15)
end 
PlayPedSound = PlayEntitySound

PlayPedEquipSound = function(ped, isEquip) 
    PlayPedSound(ped, GetSoundDictAndName(isEquip))
end 

function PedPlayVehicleAlarmByClass(ped,class)
    StopAlarmSounds()
    local classes = {}
    local className = GetClassName(class) 
    classes['sport'] = function()
        PlayPedSound(ped, soundId_sport, "SEATBELT_SOUNDSET_SPORT", "seatbelt_alarm_sport")
    end 
    classes['service'] = function()
        PlayPedSound(ped, soundId_service, "SEATBELT_SOUNDSET_SERVICE", "seatbelt_alarm_service")
    end 
    local default = function()
        PlayPedSound(ped, soundId_normal, "SEATBELT_SOUNDSET_NORMAL", "seatbelt_alarm_normal")
    end 
    (classes[className] or default)()
    Tasksync.addlooponce('CheckSoundStop',500,function(duration)
        if isPlayerBeltTied or not isPlayerInACar then 
            StopAlarmSounds()
            duration('break')
        end 
    end)
end 

AddEventHandler('Seatbelt:Alarm', function(class)
    local ped = PlayerPedId()
    PedPlayVehicleAlarmByClass(ped, class)
end)


LockPlayerVehicle = function() 
    local lockCheck = function(duration) 
        if isPlayerInACar and isPlayerBeltTied then 
            DisableControlAction(2,75,true)
        else 
            duration("break")
        end 
    end
    local unlockCheck = function() DisableControlAction(2,75,false) end
    Tasksync.addlooponce("CheckLock",0, lockCheck , unlockCheck ) 
end 

AddEventHandler('Seatbelt:Switch', function(isEquip)
    local ped = PlayerPedId()
    PlayPedEquipSound(ped, isEquip)
    PedPlayTieAnim(ped, isEquip)
    BeltTied("set",isEquip)
    
    if Config.LocalMessage then 
        TriggerEvent('chatMessage', isEquip and Config.Locale.on or Config.Locale.off)
    end 
    
    if isEquip then 
        LockPlayerVehicle()
    end 
    
end)


SwitchBelt = function()
    local ped = PlayerPed
    if ped and IsPedInAnyVehicle(ped) then
        if PlayerVehicle ~= GetVehiclePedIsIn(ped) then 
            if ThisVarsUpdate then ThisVarsUpdate() end 
        end
        if isPlayerInACar and not IsPedTieAniming(ped)  then
            TriggerEvent('Seatbelt:Switch',not isPlayerBeltTied)
            TriggerServerEvent('Seatbelt:Switch',not isPlayerBeltTied)
        end 
    end 
end 

Tasksync.addloop("Main",3200,function(mainduration)
    local ped = PlayerPedId()
    if PlayerPed ~= ped or PlayerVehicle ~= GetVehiclePedIsIn(ped) or not isPlayerInACar then 
        BeltTied("reset")
        mainduration("set",3200)
    end
    ThisVarsUpdate()
    
    if isPlayerBeltTied then 
        SetFlyThroughWindscreenParams(45.0, 46.0 , 17.0, 1.0) --m/s 
    else 
        if isPlayerInACar then 
            local minV = 9.8 * 1.2 * (isMale and 1.0 or 0.8) 
            SetFlyThroughWindscreenParams(minV, minV + 1, 17.0, 2000.0)
            SetPedConfigFlag(PlayerPedId(), 32, true)
            SetPedConfigFlag(PlayerPedId(), 250, true);
        end 
    end 
    
    if isPlayerInACar then 
        if not isPlayerBeltTied then 
            mainduration("set",500)
            if Config.showAlarmSound then 
                if PlayerAlarmTimer == 0 then 
                    PlayerAlarmTimer          =     GetGameTimer() + Config.StopAlarmAferTimer
                    Tasksync.addlooponce('CheckAlarm',3200,function(alarmduration)
                        if not isPlayerInACar or isPlayerBeltTied or not isPlayerVehicleDriver or GetGameTimer() > PlayerAlarmTimer  then 
                            alarmduration('break')  
                        else  
                            TriggerEvent('Seatbelt:Alarm',PlayerVehicleClass)
                            TriggerServerEvent('Seatbelt:Alarm',PlayerVehicleClass)
                        end 
                    end)
                end 
            end 
            if Config.showClassicWarningIcon then 
                Tasksync.addlooponce('CheckShouldIcon',500,function(iconduration)
                    if not isPlayerInACar or isPlayerBeltTied then 
                        iconduration('break') 
                    else
                        local nuix,nuiy = 419,622
                        SendNUIMessage({setPosition = {x=nuix,y=nuiy}})
                        SendNUIMessage({showIcon = 'true'})
                    end 
                end, function()
                    SendNUIMessage({showIcon = 'false'})
                end)
            end 
        end 
    else
        BeltTied("set",false)
        mainduration("set",3200)
    end
end ) 



