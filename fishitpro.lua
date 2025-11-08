-- // FISH IT ULTIMATE (PRO UI EDITION) //
-- // by Lynx & ChatGPT //

-- Protection to prevent double execution
if getgenv().FishItLoaded then
    warn("[Fish It] Already running, aborting reload.")
    return
end
getgenv().FishItLoaded = true

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Try fetching Rayfield
local function fetchUrl(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and res ~= "" then return res end
    local wrappers = {
        function(u) if syn and syn.request then return syn.request({Url=u,Method="GET"}).Body end end,
        function(u) if http and http.request then return http.request({Url=u,Method="GET"}).Body end end,
        function(u) if request then return request({Url=u,Method="GET"}).Body end end,
        function(u) if http_request then return http_request({Url=u,Method="GET"}).Body end end
    }
    for _, fn in ipairs(wrappers) do
        local ok2, res2 = pcall(fn, url)
        if ok2 and res2 and res2 ~= "" then return res2 end
    end
    return nil
end

local Rayfield
local loaderSources = {
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
    "https://raw.githubusercontent.com/uchil404/fish-it/refs/heads/main/fish_it_premiumV1_script.lua"
}
for _, src in ipairs(loaderSources) do
    local body = fetchUrl(src)
    if body then
        local ok, ret = pcall(function() return loadstring(body)() end)
        if ok and ret then
            Rayfield = ret
            break
        end
    end
end
if not Rayfield then
    warn("⚠️ Rayfield failed to load, GUI may not appear.")
    Rayfield = {CreateWindow = function() end}
end

--=============================================
-- 🎨 PRO UI SETTINGS
--=============================================
local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It | Ultimate Pro UI",
    LoadingTitle = "🐟 Lynx Fish It",
    LoadingSubtitle = "Professional Edition",
    Theme = "Ocean",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FishItPro",
        FileName = "Settings"
    },
    Discord = {
        Enabled = true,
        Invite = "4xFjJK4G",
        RememberJoins = true
    },
    KeySystem = false
})

-- Make UI smooth
pcall(function()
    Rayfield:SetTheme({
        Background = Color3.fromRGB(15, 20, 40),
        Topbar = Color3.fromRGB(25, 30, 60),
        Text = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(25, 25, 50),
        Accent = Color3.fromRGB(80, 120, 255),
        Accent2 = Color3.fromRGB(150, 80, 255),
        Outline = Color3.fromRGB(50, 50, 90),
    })
end)

--=============================================
-- 🛠 SETTINGS TAB
--=============================================
local Settings = Window:CreateTab("⚙️ Settings", 4483362458)
Settings:CreateLabel("Optimize & Utility Tools")

Settings:CreateToggle({
    Name = "🧊 Anti Lag Mode",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AntiLag = v
        if v then
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj:Destroy()
                elseif obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic end
            end
        end
    end
})

Settings:CreateToggle({
    Name = "💤 Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        if v then
            pcall(function()
                for _, c in pairs(getconnections(LocalPlayer.Idled)) do c:Disable() end
            end)
        end
    end
})

Settings:CreateButton({Name = "🔁 Rejoin Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})

--=============================================
-- 🎣 FISHING TAB
--=============================================
local Fishing = Window:CreateTab("🎣 Fishing", 4483362458)
local Rep = ReplicatedStorage.Remotes
local function findRod()
    return (LocalPlayer.Backpack:FindFirstChild("Fishing Rod") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Fishing Rod")))
end

local function cast() pcall(function() Rep.CastRod:FireServer() end) end
local function catch() pcall(function() Rep.CatchFish:FireServer() end) end

Fishing:CreateToggle({
    Name = "⚡ Auto Fish & Catch",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoFish = v
        task.spawn(function()
            while getgenv().AutoFish do
                task.wait(1.5)
                if findRod() then cast() task.wait(0.4) catch() end
            end
        end)
    end
})

--=============================================
-- 💰 AUTO SELL TAB
--=============================================
local Sell = Window:CreateTab("💰 Auto Sell", 4483362458)
Sell:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoSell = v
        task.spawn(function()
            while getgenv().AutoSell do
                task.wait(3)
                Rep.SellAllFish:FireServer()
            end
        end)
    end
})

Sell:CreateSlider({
    Name = "Sell Threshold",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 50,
    Callback = function(v) getgenv().SellThreshold = v end
})

--=============================================
-- 🧍 PLAYER TAB
--=============================================
local Player = Window:CreateTab("🧍 Player", 4483362458)
Player:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})
Player:CreateToggle({
    Name = "🪶 Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        getgenv().InfiniteJump = v
    end
})
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--=============================================
-- 🗺️ TELEPORT TAB
--=============================================
local Teleport = Window:CreateTab("🗺️ Teleport", 4483362458)
local spots = {
    ["Kohana"] = Vector3.new(-645,16,606),
    ["Crater Island"] = Vector3.new(1019,20,5071),
    ["Lost Isle"] = Vector3.new(-3672,70,-912)
}
for name, pos in pairs(spots) do
    Teleport:CreateButton({
        Name = "📍 "..name,
        Callback = function()
            if LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end
    })
end

--=============================================
-- 🌧 WEATHER TAB
--=============================================
local Weather = Window:CreateTab("🌧 Weather", 4483362458)
local weathers = {"Cloud","Storm","Wind","Radiant","Snow"}
for _, w in pairs(weathers) do
    Weather:CreateButton({
        Name = "Spawn "..w,
        Callback = function()
            Rep.SpawnWeather:FireServer(w)
        end
    })
end

--=============================================
-- 🦈 SHARK TAB
--=============================================
local Shark = Window:CreateTab("🦈 Shark Hunt", 4483362458)
Shark:CreateToggle({
    Name = "Auto Shark Hunt",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoShark = v
        task.spawn(function()
            while getgenv().AutoShark do
                task.wait(2)
                Rep.StartSharkHunt:FireServer()
            end
        end)
    end
})

--=============================================
-- 🔖 FOOTER / WATERMARK
--=============================================
Settings:CreateLabel("────────────────────────────")
Settings:CreateLabel("🐟 Fish It Pro UI by Lynx x ChatGPT")
Settings:CreateLabel("💬 Discord: discord.gg/4xFjJK4G")
