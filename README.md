# Installation
server.cfg 
```
setr game_enableFlyThroughWindscreen 1
```
```
start SeatbeltRW
```

# Get Player Seatbelt State

You can use GetPlayerSeatBelted or GetPlayerSeatBeltedByPed to get if the player is seat-belt equipped.
by
## Method 1
Import :
```
load(LoadResourceFile("SeatbeltRW", 'import'))()
```
Example : 
```
load(LoadResourceFile("SeatbeltRW", 'import'))()
CreateThread(function()
        
        while true do Wait(0)
            print(GetPlayerSeatBelted(PlayerId())) -- false or true
            print(GetPlayerSeatBeltedByPed(PlayerPedId()))  -- false or true
        end 
 end )
```

## Method 2
```
exports['SeatbeltRW']:GetPlayerSeatBelted
exports['SeatbeltRW']:GetPlayerSeatBeltedByPed(...) 
```

Make sure load SeatbeltRW before you Get State or Import.
