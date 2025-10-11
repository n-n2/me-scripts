--[[
====================================================================================================
Leagues Fletcher Script
====================================================================================================
Version: 1.0
Author: RainRS
Description: Automatically makes arrows with the ranged guild vendor NPC
Starting Location: Inside the ranged guild building with the vendor NPC

Requirements:
- Access to the ranged guild building with the vendor NPC

How it works:
0. Have lots of feathers and GP in the inventory to buy arrows tips and shafts
1. Start at the ranged guild building with the vendor NPC
2. Script will buy arrow shafts and make headless arrows
3. Script will buy arrowheads and make arrows with the headless arrows
4. Script will buy arrows shafts and arrowheads and make more arrows until you run out of GP or feathers

====================================================================================================
]]
--

--[[ CHANGELOG
2025-10-07 - V1.0 - Initial release
]]

--[[ 
====================================================================================================
SETTINGS: CHANGE THIS TO THE ARROWHEADS YOU ARE USING & MINIMUM AMOUNT TO HAVE/REBUY BEFORE WE BEGIN FLETCHING

Options: "Adamant", "Steel", "Mithril", "Rune", "Iron"
====================================================================================================
]] --
local ARROW_TYPE = "Rune"
local BUY_AMOUNT = 1000

-- DO NOT CHANGE THIS
print("LeaguesFletcher started!")

local API = require("api")

local FLETCHING_STORE = {683}

local REAGENT2_ID = 0
local REAGENT2 = ARROW_TYPE .. " arrowheads" -- "Adamant", "Steel", "Mithril", "Rune", "Iron"

local arrowAbility = API.GetABs_name1("Headless arrow")
local featherShaftAbility = API.GetABs_name1("Arrow shaft")

local startingXP = API.GetSkillXP("FLETCHING")
print("Starting XP: " .. startingXP)

local STATE = "inv_check"
local EXPLAINER = ""

local fletchingInterface = {
    InterfaceComp5.new(1251,8,-1,0),
    InterfaceComp5.new(1251,38,-1,0)
}

local arrowCreationInterface = {
    InterfaceComp5.new(1370,0,-1,0),
    InterfaceComp5.new(1370,2,-1,0)
    --InterfaceComp5.new(1370,24,-1,0),
    --InterfaceComp5.new(1370,27,-1,0),
    --InterfaceComp5.new(1370,28,-1,0),
    --InterfaceComp5.new(1370,30,-1,0)
}

local function formatNumber(num)
    if num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

local function isInterfacePresent(interface)
    local result = API.ScanForInterfaceTest2Get(true, interface)
    if #result > 0 then
        return true
    else return false end
end

local function makeHeadlessArrows()
    print("Making headless arrows")
    EXPLAINER = "We have no more headless arrows."
    while Inventory:InvStackSize(314) > 0 and Inventory:InvStackSize(52) > 0 and API.Read_LoopyLoop() do -- Check for feathers and arrow shafts
        print("We have " .. Inventory:InvStackSize(314) .. " feathers and " .. Inventory:InvStackSize(52) .. " arrow shafts.")
        if API.DoAction_Ability_Direct(featherShaftAbility, 1, API.OFF_ACT_GeneralInterface_route) then
            print("We have started making headless arrows!")
            API.RandomSleep2(3000, 500, 200)
            while not isInterfacePresent(arrowCreationInterface) and API.Read_LoopyLoop() do -- Wait for arrow creation to finish
                API.RandomSleep2(1000, 500, 200)
                print("Waiting for arrow creation interface to appear.")
            end
            API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option)
            EXPLAINER = "We asleeping waiting for headless arrows to finish."
            API.RandomSleep2(3000, 500, 200)
            while isInterfacePresent(fletchingInterface) and API.Read_LoopyLoop() do -- Wait for fletching to finish
                API.RandomSleep2(1000, 500, 200)
            end
        end
    end
    STATE = "inv_check"
end

local function makeArrows()
    print("Making arrows - " .. ARROW_TYPE)
    while Inventory:InvStackSize(53) > 0 and Inventory:InvStackSize(REAGENT2_ID) > 0 and API.Read_LoopyLoop() do -- Check for headless arrows and arrowheads
        if API.DoAction_Ability_Direct(arrowAbility, 1, API.OFF_ACT_GeneralInterface_route) then
            print("Making arrows!")
            API.RandomSleep2(3000, 500, 200)
            while not isInterfacePresent(arrowCreationInterface) and API.Read_LoopyLoop() do -- Wait for arrow creation to finish
                API.RandomSleep2(1000, 500, 200)
                print("Waiting for arrow creation interface to appear.")
            end
            API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option)
            EXPLAINER = "We are sleeping waiting for fletching " .. ARROW_TYPE .. " arrows to finish."
            API.RandomSleep2(3000, 500, 200)
            while isInterfacePresent(fletchingInterface) and API.Read_LoopyLoop() do -- Wait for fletching to finish
                API.RandomSleep2(1000, 500, 200)
            end
        else
            print("Failed to make arrow!")
            API.Write_LoopyLoop(false)
        end
    end
    STATE = "inv_check"
end

local function shopHandler(itemName)
    print("Going to shop to buy " .. itemName .. "!")
    EXPLAINER = "We are low on " .. itemName .. "."
    API.RandomSleep2(1000, 500, 200)
    API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2,{ FLETCHING_STORE[1] },50)
    EXPLAINER = "Clicked on NPC to open shop."
    API.RandomSleep2(3000, 500, 200)
    if itemName == "Arrow shaft" then
        EXPLAINER = "We are low on arrow shafts."
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,0,API.OFF_ACT_GeneralInterface_route) -- Select arrow shafts in store
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0x2e,0xffffffff,1,1265,89,-1,API.OFF_ACT_GeneralInterface_route) -- Select MAX amount
        API.RandomSleep2(1000, 500, 200)
        while Inventory:InvStackSize(52) < BUY_AMOUNT and API.Read_LoopyLoop() do
            EXPLAINER = "Buying arrow shafts until we have " .. BUY_AMOUNT .. " or more in inventory."
            API.DoAction_Interface(0x24,0xffffffff,1,1265,144,-1,API.OFF_ACT_GeneralInterface_route) -- Keep clicking buy until we have 1K or more arrow shafts in inventory
            API.RandomSleep2(500, 500, 200)
        end
    elseif itemName == REAGENT2 then
        EXPLAINER = "We are low on " .. REAGENT2 .. "."
        if ARROW_TYPE == "Adamant" then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,5,API.OFF_ACT_GeneralInterface_route) -- Select adamant arrowheads in store
            REAGENT2_ID = 43
        elseif ARROW_TYPE == "Steel" then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,3,API.OFF_ACT_GeneralInterface_route) -- Select steel arrowheads in store
            REAGENT2_ID = 41
        elseif ARROW_TYPE == "Mithril" then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,4,API.OFF_ACT_GeneralInterface_route) -- Select mithril arrowheads in store
            REAGENT2_ID = 42
        elseif ARROW_TYPE == "Rune" then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,6,API.OFF_ACT_GeneralInterface_route) -- Select rune arrowheads in store
            REAGENT2_ID = 44
        elseif ARROW_TYPE == "Iron" then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1265,20,2,API.OFF_ACT_GeneralInterface_route) -- Select iron arrowheads in store
            REAGENT2_ID = 40
        end
        API.RandomSleep2(1000, 500, 200)
        API.DoAction_Interface(0x2e,0xffffffff,1,1265,89,-1,API.OFF_ACT_GeneralInterface_route) -- Select MAX amount
        API.RandomSleep2(1000, 500, 200)
        while Inventory:InvStackSize(REAGENT2_ID) < BUY_AMOUNT and API.Read_LoopyLoop() do
            EXPLAINER = "Buying arrowheads until we have " .. BUY_AMOUNT .. " or more in inventory."
            API.DoAction_Interface(0x24,0xffffffff,1,1265,144,-1,API.OFF_ACT_GeneralInterface_route) -- Keep clicking buy until we have 1K or more arrowheads in inventory
            API.RandomSleep2(500, 500, 200)
        end
    end
    STATE = "inv_check"

end

local function checkReagents()
    EXPLAINER = "Checking inventory for reagents."
    if Inventory:InvStackSize(53) > 0 then -- Check for headless arrows
        EXPLAINER = "Headless arrows found, checking for arrowheads!"
        print("Headless arrows found, checking for arrowheads!")
        if Inventory:InvStackSize(REAGENT2_ID) > 0 then -- Check for arrowheads
            print("Arrowheads found, making arrows!")
            EXPLAINER = "Arrowheads found, making arrows!"
            STATE = "make_arrows"
        else
            print("No arrowheads, buying more!")
            EXPLAINER = "No arrowheads, buying more!"
            STATE = "buy_arrowheads"
        end
    else
        if Inventory:InvStackSize(314) > 0 then -- Check for feathers
            print("Feathers found, checking for arrow shafts!")
            if Inventory:InvStackSize(52) > 0 then -- check for arrow shafts
                print("Arrow shafts found, making headless arrows!")
                EXPLAINER = "Arrow shafts found, making headless arrows!"
                STATE = "make_headless_arrows"
            else
                print("No arrow shafts, buying more!")
                EXPLAINER = "No arrow shafts, buying more!"
                STATE = "buy_shafts"
            end
        else
            print("No feathers, stopping script!")
            EXPLAINER = "No feathers, stopping script!"
           API.Write_LoopyLoop(false)
        end
    end
end

local function calculateMetrics()
    local timeElapsed = API.ScriptRuntime()
    local currentXP = API.GetSkillXP("FLETCHING")
    local xpGained = currentXP - startingXP
    local expPH = timeElapsed > 0 and math.floor((xpGained * 3600) / timeElapsed) or 0

    local metrics = {
        { "XP/hr:", formatNumber(expPH) },
        { "Script State:", STATE },
        { "Because:", EXPLAINER }
    }
    return metrics
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

    API.DrawTable(calculateMetrics())

    if STATE == "inv_check" then
        checkReagents()
    elseif STATE == "buy_arrowheads" then
        shopHandler(REAGENT2)
    elseif STATE == "buy_shafts" then
        shopHandler("Arrow shaft")      
    elseif STATE == "make_arrows" then
        makeArrows()
    elseif STATE == "make_headless_arrows" then
        makeHeadlessArrows()
    elseif STATE == "banking" then
        goBank()
    end
    API.RandomSleep2(600, 600, 200)
end
