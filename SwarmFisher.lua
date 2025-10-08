--[[
====================================================================================================
SwarmFisher Script
====================================================================================================
Version: 1.1
Author: RainRS
Description: Automatically fishes at the deep sea swarm and banks catches
Starting Location: Deep Sea Fishing Swarm

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

--[[ CHANGELOG
2025-10-07 - V1.1 - Added Gregg ring check, fishing notes, bottle messages, bait barrels, broken rods, and tangled fish bowls check, tracking for fish caught, exp rates, and fish rates per valuable catch
2025-10-07 - V1.0 - Initial release
]]

print("SwarmFisher started!")

local API = require("api")

local BANK_NET = {110857}
local SWARM_SPOTS = {25220}
local FISHING_ANIMATION = {24932}

local startingXP = API.GetSkillXP("FISHING")
print("Starting XP: " .. startingXP)

-- FISH CAUGHT
local fishCaught = {start = 0, current = 0, gained = 0}
local sailfishCaught = {start = 0, current = 0, gained = 0}
local mantaRayCaught = {start = 0, current = 0, gained = 0}
local blueJellyCaught = {start = 0, current = 0, gained = 0}
local monkfishCaught = {start = 0, current = 0, gained = 0}
local rocktailCaught = {start = 0, current = 0, gained = 0}
local cavefishCaught = {start = 0, current = 0, gained = 0}
local greatSharkCaught = {start = 0, current = 0, gained = 0}
local seaTurtleCaught = {start = 0, current = 0, gained = 0}


-- EXP ITEMS
local fishingNotes = {start = 0, current = 0, gained = 0}
local bottleMessages = {start = 0, current = 0, gained = 0}
local baitBarrels = {start = 0, current = 0, gained = 0}
local brokenRods = {start = 0, current = 0, gained = 0}
local tangledFishBowl = {start = 0, current = 0, gained = 0}


-- RARES
local greggRings = {start = 0, current = 0, gained = 0}

local startTime = 0
local STATE = "fishing"

local function formatNumber(num)
    if num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

local function calculateFishCaught()
    if Inventory:InvItemcount_String("Raw sailfish") > 0 then
        sailfishCaught.current = Inventory:InvItemcount_String("Raw sailfish")
        sailfishCaught.gained = sailfishCaught.current - sailfishCaught.start
    end
    if Inventory:InvItemcount_String("Raw manta ray") > 0 then
        mantaRayCaught.current = Inventory:InvItemcount_String("Raw manta ray")
        mantaRayCaught.gained = mantaRayCaught.current - mantaRayCaught.start
    end   
    if Inventory:InvItemcount_String("Raw blue blubber jellyfish") > 0 then
        blueJellyCaught.current = Inventory:InvItemcount_String("Raw blue blubber jellyfish")
        blueJellyCaught.gained = blueJellyCaught.current - blueJellyCaught.start
    end
    if Inventory:InvItemcount_String("Raw monkfish") > 0 then
        monkfishCaught.current = Inventory:InvItemcount_String("Raw monkfish")
        monkfishCaught.gained = monkfishCaught.current - monkfishCaught.start
    end
    if Inventory:InvItemcount_String("Raw rocktail") > 0 then
        rocktailCaught.current = Inventory:InvItemcount_String("Raw rocktail")
        rocktailCaught.gained = rocktailCaught.current - rocktailCaught.start
    end
    if Inventory:InvItemcount_String("Raw cavefish") > 0 then
        cavefishCaught.current = Inventory:InvItemcount_String("Raw cavefish")
        cavefishCaught.gained = cavefishCaught.current - cavefishCaught.start
    end
    if Inventory:InvItemcount_String("Raw great white shark") > 0 then
        greatSharkCaught.current = Inventory:InvItemcount_String("Raw great shark")
        greatSharkCaught.gained = greatSharkCaught.current - greatSharkCaught.start
    end
    if Inventory:InvItemcount_String("Raw sea turtle") > 0 then
        seaTurtleCaught.current = Inventory:InvItemcount_String("Raw sea turtle")
        seaTurtleCaught.gained = seaTurtleCaught.current - seaTurtleCaught.start
    end
    fishCaught.current = sailfishCaught.current + mantaRayCaught.current + blueJellyCaught.current + monkfishCaught.current + rocktailCaught.current + cavefishCaught.current + greatSharkCaught.current + seaTurtleCaught.current
    fishCaught.gained = fishCaught.current - fishCaught.start
end

local function countExpItems()
    -- Count fishing notes
    local notesCount = Inventory:InvItemcount_String("Fishing notes")
    if notesCount > fishingNotes.current then
        fishingNotes.current = notesCount
        fishingNotes.gained = fishingNotes.current - fishingNotes.start
    end
    
    -- Count message in a bottle
    local bottleCount = Inventory:InvItemcount_String("Message in a bottle")
    if bottleCount > bottleMessages.current then
        bottleMessages.current = bottleCount
        bottleMessages.gained = bottleMessages.current - bottleMessages.start
    end
    
    -- Count barrel of bait
    local barrelCount = Inventory:InvItemcount_String("Barrel of bait")
    if barrelCount > baitBarrels.current then
        baitBarrels.current = barrelCount
        baitBarrels.gained = baitBarrels.current - baitBarrels.start
    end
    
    -- Count broken fishing rod
    local rodCount = Inventory:InvItemcount_String("Broken fishing rod")
    if rodCount > brokenRods.current then
        brokenRods.current = rodCount
        brokenRods.gained = brokenRods.current - brokenRods.start
    end
    
    -- Count tangled fishbowl
    local bowlCount = Inventory:InvItemcount_String("Tangled fishbowl")
    if bowlCount > tangledFishBowl.current then
        tangledFishBowl.current = bowlCount
        tangledFishBowl.gained = tangledFishBowl.current - tangledFishBowl.start
    end
end

local function useExpItem(itemName, maxRetries)
    maxRetries = maxRetries or 3
    local retryCount = 0
    
    while Inventory:InvItemcount_String(itemName) > 0 and API.Read_LoopyLoop() do
        local currentXP = API.GetSkillXP("FISHING")
        print("Using " .. itemName .. " (have " .. Inventory:InvItemcount_String(itemName) .. " remaining)")
        
        -- Use the item
        API.DoAction_Inventory3(itemName, 0, 0, API.OFF_ACT_Bladed_interface_route)
        API.RandomSleep2(800, 200, 100)
        
        -- Check if XP was gained
        local newXP = API.GetSkillXP("FISHING")
        if newXP > currentXP then
            print("XP gained from " .. itemName .. ": " .. (newXP - currentXP))
            retryCount = 0 -- Reset retry count on success
        else
            retryCount = retryCount + 1
            print("No XP gained, retry " .. retryCount .. "/" .. maxRetries)
            
            if retryCount >= maxRetries then
                print("Max retries reached for " .. itemName .. ", skipping remaining")
                break
            end
            API.RandomSleep2(500, 200, 100)
        end
    end
end

local function useAllExpItems()
    -- Use all fishing notes
    if Inventory:InvItemcount_String("Fishing notes") > 0 then
        useExpItem("Fishing notes")
    end
    
    -- Use all message in a bottle
    if Inventory:InvItemcount_String("Message in a bottle") > 0 then
        useExpItem("Message in a bottle")
    end
    
    -- Use all barrel of bait
    if Inventory:InvItemcount_String("Barrel of bait") > 0 then
        useExpItem("Barrel of bait")
    end
    
    -- Use all broken fishing rod
    if Inventory:InvItemcount_String("Broken fishing rod") > 0 then
        useExpItem("Broken fishing rod")
    end
    
    -- Use all tangled fishbowl
    if Inventory:InvItemcount_String("Tangled fishbowl") > 0 then
        useExpItem("Tangled fishbowl")
    end
end

local function checkRares()
    if Inventory:InvItemcount_String("Gregg 'groggy' herring's ring") > 0 then
        greggRings.current = Inventory:InvItemcount_String("Gregg 'groggy' herring's ring")
        greggRings.gained = greggRings.current - greggRings.start
    end
end

local function calculateMetrics()
    local timeElapsed = API.ScriptRuntime()
    local currentXP = API.GetSkillXP("FISHING")
    local xpGained = currentXP - startingXP
    local expPH = timeElapsed > 0 and math.floor((xpGained * 3600) / timeElapsed) or 0
    local fishCaughtPH = timeElapsed > 0 and math.floor((fishCaught.gained * 3600) / timeElapsed) or 0
    local sailfishCaughtPH = timeElapsed > 0 and math.floor((sailfishCaught.gained * 3600) / timeElapsed) or 0
    local mantaRayCaughtPH = timeElapsed > 0 and math.floor((mantaRayCaught.gained * 3600) / timeElapsed) or 0
    local blueJellyCaughtPH = timeElapsed > 0 and math.floor((blueJellyCaught.gained * 3600) / timeElapsed) or 0
    local monkfishCaughtPH = timeElapsed > 0 and math.floor((monkfishCaught.gained * 3600) / timeElapsed) or 0
    local rocktailCaughtPH = timeElapsed > 0 and math.floor((rocktailCaught.gained * 3600) / timeElapsed) or 0
    local cavefishCaughtPH = timeElapsed > 0 and math.floor((cavefishCaught.gained * 3600) / timeElapsed) or 0
    local greatSharkCaughtPH = timeElapsed > 0 and math.floor((greatSharkCaught.gained * 3600) / timeElapsed) or 0
    local seaTurtleCaughtPH = timeElapsed > 0 and math.floor((seaTurtleCaught.gained * 3600) / timeElapsed) or 0
    local fishingNotesPH = timeElapsed > 0 and math.floor((fishingNotes.gained * 3600) / timeElapsed) or 0
    local bottleMessagesPH = timeElapsed > 0 and math.floor((bottleMessages.gained * 3600) / timeElapsed) or 0
    local baitBarrelsPH = timeElapsed > 0 and math.floor((baitBarrels.gained * 3600) / timeElapsed) or 0
    local brokenRodsPH = timeElapsed > 0 and math.floor((brokenRods.gained * 3600) / timeElapsed) or 0
    local tangledFishBowlPH = timeElapsed > 0 and math.floor((tangledFishBowl.gained * 3600) / timeElapsed) or 0

    local metrics = {
        { "XP/hr:", formatNumber(expPH) },
        { "Total fish caught:", formatNumber(fishCaught.gained) .. " (" .. formatNumber(fishCaughtPH) .. "/h)" },
        { "Sailfish caught:", formatNumber(sailfishCaught.gained) .. " (" .. formatNumber(sailfishCaughtPH) .. "/h)" },
        { "Manta ray caught:", formatNumber(mantaRayCaught.gained) .. " (" .. formatNumber(mantaRayCaughtPH) .. "/h)" },
        { "Blue jelly caught:", formatNumber(blueJellyCaught.gained) .. " (" .. formatNumber(blueJellyCaughtPH) .. "/h)" },
        { "Monkfish caught:", formatNumber(monkfishCaught.gained) .. " (" .. formatNumber(monkfishCaughtPH) .. "/h)" },
        { "Rocktail caught:", formatNumber(rocktailCaught.gained) .. " (" .. formatNumber(rocktailCaughtPH) .. "/h)" },
        { "Cavefish caught:", formatNumber(cavefishCaught.gained) .. " (" .. formatNumber(cavefishCaughtPH) .. "/h)" },
        { "Great shark caught:", formatNumber(greatSharkCaught.gained) .. " (" .. formatNumber(greatSharkCaughtPH) .. "/h)" },
        { "Sea turtle caught:", formatNumber(seaTurtleCaught.gained) .. " (" .. formatNumber(seaTurtleCaughtPH) .. "/h)" },
        { "Fishing notes caught:", formatNumber(fishingNotes.gained) .. " (" .. formatNumber(fishingNotesPH) .. "/h)" },
        { "Message in a bottle caught:", formatNumber(bottleMessages.gained) .. " (" .. formatNumber(bottleMessagesPH) .. "/h)" },
        { "Barrel of bait caught:", formatNumber(baitBarrels.gained) .. " (" .. formatNumber(baitBarrelsPH) .. "/h)" },
        { "Broken fishing rod caught:", formatNumber(brokenRods.gained) .. " (" .. formatNumber(brokenRodsPH) .. "/h)" },
        { "Tangled fish bowl caught:", formatNumber(tangledFishBowl.gained) .. " (" .. formatNumber(tangledFishBowlPH) .. "/h)" }
    }

    if greggRings.gained > 0 then
        table.insert(metrics, { "Gregg ring:", "Yes" })
    end
    return metrics
end

local function goBank()
    print("Going to bank")
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ BANK_NET[1] },50)
    API.WaitUntilMovingEnds()
    while API.Read_LoopyLoop() and Inventory:IsFull() do
        print("Inventory is full, waiting to deposit fish")
        API.RandomSleep2(3000, 500, 200)
    end
    API.RandomSleep2(1000, 500, 200)
    if not Inventory:IsFull() then
        print("Inventory is empty, returning to fishing spot!")
        STATE = "fishing"
    end
end

local function checkPlayerState()
    if API.GetLocalPlayerAddress() == 0 or API.GetGameState2() ~= 3 then
        print("ERROR: Bad player state detected!")
        print("Script terminated.")
        API.Write_LoopyLoop(false)
        return false
    end
    return true
end

API.SetMaxIdleTime(5)
while API.Read_LoopyLoop() do
    if not checkPlayerState() then
        break
    end

    calculateFishCaught()
    countExpItems()
    checkRares()

    API.DrawTable(calculateMetrics())

    if STATE == "fishing" then
        if Inventory:IsFull() then
            print("Inventory is full, using exp items before banking")
            
            -- Use all exp items before banking to free up inventory space
            useAllExpItems()
            
            print("Banking fish")
            STATE = "banking"
        else
            print("Inventory is not full, fishing")
            if API.GetPlayerAnimation_(API.GetLocalPlayerName()) == FISHING_ANIMATION[1] then
                print("Player is fishing, waiting for animation to end")
                API.RandomSleep2(2500, 500, 200)
            else
                print("Player is not fishing, fishing")
                API.DoAction_NPC(0x3c,API.OFF_ACT_InteractNPC_route,{ SWARM_SPOTS[1] },50)
                API.RandomSleep2(2500, 500, 200)
            end
        end
    elseif STATE == "banking" then
        goBank()
    end
    API.RandomSleep2(600, 600, 200)
end
