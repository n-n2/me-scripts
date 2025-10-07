--[[
====================================================================================================
SwarmFisher Script
====================================================================================================
Version: 1.0
Author: RainRS
Description: Automatically fishes at the deep sea swarm and banks catches
Starting Location: Shantay Pass

Requirements:
- Access to the deep sea fishing swarm

How it works:
1. Start at the deep sea fishing swarm
2. Fish until inventory is full
3. Bank catches
4. Repeats the cycle continuously

====================================================================================================
]]
--

print("SwarmFisher started!")

local API = require("api")

local BANK_NET = {110857}
local SWARM_SPOTS = {25220}
local FISHING_ANIMATION = {24932}

local STATE = "fishing"

local function run_to_tile(x, y, z)
    math.randomseed(os.time())

    local rand1 = math.random(-2, 2)
    local rand2 = math.random(-2, 2)
    local tile = WPOINT.new(x + rand1, y + rand2, z)

    API.DoAction_WalkerW(tile)


    local threshold = math.random(4, 6)
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > threshold do
        API.RandomSleep2(200, 200, 200)
    end
end 
    local function goBank()
    print("Going to bank")
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route2,{ BANK_NET[1] },50)
    API.WaitUntilMovingEnds()
    while Inventory:IsFull() do
        print("Inventory is full, waiting to deposit fish")
        API.RandomSleep2(3000, 500, 200)
    end
    API.RandomSleep2(1000, 500, 200)
    if not Inventory:IsFull() then
        print("Inventory is empty, returning to fishing spot!")
        STATE = "fishing"
    end
end

while API.Read_LoopyLoop() do
    if STATE == "fishing" then
        if Inventory:IsFull() then
            print("Inventory is full, banking fish")
            STATE = "banking"
        else
            print("Inventory is not full, fishing")
            if API.GetPlayerAnimation_(API.GetLocalPlayerName()) == FISHING_ANIMATION[1] then
                print("Player is fishing, waiting for animation to end")
                API.RandomSleep2(1000, 500, 200)
            else
                print("Player is not fishing, fishing")
                API.DoAction_NPC(0x3c,API.OFF_ACT_InteractNPC_route,{ SWARM_SPOTS[1] },50)
                API.RandomSleep2(2500, 500, 200)
            end
        end
    elseif STATE == "banking" then
        goBank()
    end
    API.RandomSleep2(1000, 500, 200)
end
