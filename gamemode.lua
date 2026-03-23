--!strict
-- // variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local string_lower = string.lower
local table_insert = table.insert

-- // cleanup old gui
if getgenv().CrapwarsGUI then
    pcall(function() getgenv().CrapwarsGUI:Destroy() end)
end

-- // global state
getgenv().CrapwarsVars = getgenv().CrapwarsVars or {}
local G = getgenv().CrapwarsVars

G.godmodeEnabled = G.godmodeEnabled or false
G.godmodeTarget = G.godmodeTarget or "self"
G.godmodeHealth = G.godmodeHealth or 99999999
G.godmodeInterval = G.godmodeInterval or 1
G.godmodeTargetPlayer = G.godmodeTargetPlayer or ""

G.enabled = G.enabled or false
G.meteorLoopRunning = G.meteorLoopRunning or false

G.noCooldownEnabled = G.noCooldownEnabled or false

G.autoMineEnabled = G.autoMineEnabled or false
G.autoMineTool = G.autoMineTool or "auto"
G.autoMineLocation = G.autoMineLocation or "all"
G.autoMineOre = G.autoMineOre or ""
G.autoMineDamage = G.autoMineDamage or 99999999
G.autoMineInterval = G.autoMineInterval or 0.1
G.autoMineLoopRunning = G.autoMineLoopRunning or false

G.targetOption = G.targetOption or "Head"
G.acBypassEnabled = G.acBypassEnabled or true

-- // caching
local MINE_LOCATIONS = {"Mine", "Mine2", "Mine3", "SpaceMine"}
local cachedPickaxeRF = nil
local cachedGodmodeRF = nil
local currentRF = nil

-- (ALL YOUR FUNCTIONS ARE UNCHANGED — SAME AS YOUR ORIGINAL)

-- // ui stuff
local RayfieldLibrary = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 💜 DARK PURPLE THEME (FIXED POSITION)
RayfieldLibrary:SetTheme({
    Background = Color3.fromRGB(18, 10, 22),
    Topbar = Color3.fromRGB(25, 12, 30),
    Shadow = Color3.fromRGB(0, 0, 0),

    NotificationBackground = Color3.fromRGB(22, 12, 28),
    NotificationActionsBackground = Color3.fromRGB(30, 15, 40),

    TabBackground = Color3.fromRGB(22, 12, 28),
    TabStroke = Color3.fromRGB(50, 25, 70),
    TabBackgroundSelected = Color3.fromRGB(60, 30, 90),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

    ElementBackground = Color3.fromRGB(25, 12, 30),
    ElementBackgroundHover = Color3.fromRGB(40, 20, 55),
    SecondaryElementBackground = Color3.fromRGB(22, 12, 28),
    ElementStroke = Color3.fromRGB(60, 30, 90),
    SecondaryElementStroke = Color3.fromRGB(50, 25, 70),

    SliderBackground = Color3.fromRGB(50, 25, 70),
    SliderProgress = Color3.fromRGB(110, 60, 170),
    SliderStroke = Color3.fromRGB(70, 35, 100),

    ToggleBackground = Color3.fromRGB(40, 20, 55),
    ToggleEnabled = Color3.fromRGB(130, 70, 200),
    ToggleDisabled = Color3.fromRGB(70, 35, 100),
    ToggleEnabledStroke = Color3.fromRGB(160, 90, 255),
    ToggleDisabledStroke = Color3.fromRGB(50, 25, 70),

    DropdownSelected = Color3.fromRGB(40, 20, 55),
    DropdownUnselected = Color3.fromRGB(25, 12, 30),

    InputBackground = Color3.fromRGB(25, 12, 30),
    InputStroke = Color3.fromRGB(60, 30, 90),
    PlaceholderColor = Color3.fromRGB(150, 150, 150),

    TextColor = Color3.fromRGB(255, 255, 255),
})

local Window = RayfieldLibrary:CreateWindow({
    Name = "crapwars redardux",
    LoadingTitle = "crapwars retardux",
    LoadingSubtitle = "by bbul",
    Icon = 0,
    ConfigurationSaving = {
        Enabled = true,
        FileName = "crapwars_redux_config"
    },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = false
})

-- (ALL YOUR UI TABS + LOGIC CONTINUE EXACTLY THE SAME)

-- // init
if G.acBypassEnabled then task.spawn(Init_Bypass) end
init()

if G.enabled then
    G.meteorLoopRunning = true
    task.spawn(MeteorLoop)
end

if G.autoMineEnabled then
    G.autoMineLoopRunning = true
    task.spawn(AutoMineLoop)
end
