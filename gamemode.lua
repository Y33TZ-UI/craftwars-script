local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = PlayersService.LocalPlayer

local Flags = {
    Enabled = false,
    AutoEnemies = false,
    AutoMines = false,
    AttackCooldown = 0.5,
    HitMode = "Damage",
    MineTargets = {
        Mine = true,
        Mine2 = true,
        Mine3 = true,
    },
}

local MineOptions = {
    "Mine",
    "Mine2",
    "Mine3",
}

local CooldownTimer = 0

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/theneutral0ne/wally-modified/refs/heads/main/wally-modified.lua"))()
local MainWindow = Library:CreateWindow("Hyperion Hub", {
    persistwindow = false,
    itemspacing = 2,
    togglestyle = "checkmark",
    underlinecolor = "rainbow",
})

MainWindow:Section("Main")

MainWindow:Toggle("Enabled", {
    location = Flags,
    flag = "Enabled",
    default = Flags.Enabled,
    tooltip = "Master switch for this script. If off, no attacks are sent.",
})

MainWindow:Toggle("Mobs", {
    location = Flags,
    flag = "AutoEnemies",
    default = Flags.AutoEnemies,
    tooltip = "Automatically hits all valid enemy humanoids in workspace.",
})

MainWindow:Toggle("Mines", {
    location = Flags,
    flag = "AutoMines",
    default = Flags.AutoMines,
    tooltip = "Automatically hits ore nodes in the selected mine folders below.",
})

MainWindow:Dropdown("Mode", {
    location = Flags,
    flag = "HitMode",
    list = { "Damage", "Heal" },
}, function(Value)
    Flags.HitMode = Value
end)

MainWindow:Slider("Cooldown", {
    location = Flags,
    flag = "AttackCooldown",
    min = 0.1,
    max = 2,
    default = Flags.AttackCooldown,
    precise = true,
    decimals = 2,
    step = 0.05,
}, function(Value)
    Flags.AttackCooldown = Value
end)

MainWindow:Section("Mine Targets")

MainWindow:MultiSelectList("Mines", {
    location = Flags,
    flag = "MineTargets",
    list = MineOptions,
    default = Flags.MineTargets,
    search = true,
    sort = true,
    maxVisibleRows = 6,
    listHeight = 110,
}, function(SelectedMap)
    Flags.MineTargets = SelectedMap
end)

MainWindow:Section("Troll")

MainWindow:Button("God All", {
    tooltip = "God all players, You must have armour in your backpack to work",
}, function()
    for _, Child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(Child.Name, "Armour") and Child:FindFirstChild("RemoteFunction") then
            for _, Player in ipairs(PlayersService:GetPlayers()) do
                task.wait()
                local Character = Player.Character
                local Humanoid = Character and Character:FindFirstChild("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    Child.RemoteFunction:InvokeServer("protect", { Character, Humanoid, 6000000 })
                end
            end
        end
    end
end)

MainWindow:Button("Kill All", {
    tooltip = "Kills all players, requires armour in backpack to work",
}, function()
    for _, Child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(Child.Name, "Armour") and Child:FindFirstChild("RemoteFunction") then
            for _, Player in ipairs(PlayersService:GetPlayers()) do
                task.wait()
                local Character = Player.Character
                local Humanoid = Character and Character:FindFirstChild("Humanoid")
                if Player.Name ~= LocalPlayer.Name and Humanoid and Humanoid.Health > 0 then
                    Child.RemoteFunction:InvokeServer("protect", { Character, Humanoid, -math.huge })
                end
            end
        end
    end
end)

MainWindow:Button("Set Enemies To 1 HP", {
    tooltip = "Calculates enemy HP and deals exact damage to leave each one at 1 HP.",
}, function()
    local Weapon = nil
    for _, Child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if Child:FindFirstChild("SwordControl") and Child:FindFirstChild("RemoteFunction") then
            Weapon = Child
            break
        end
    end

    if not Weapon then
        return
    end

    for _, Humanoid in ipairs((function()
        local EnemyHumanoids = {}
        local Seen = {}

        for _, Descendant in ipairs(workspace:GetDescendants()) do
            if Descendant:IsA("Model") and Descendant:FindFirstChild("EnemyMain") then
                local EnemyHumanoid = Descendant:FindFirstChild("Humanoid")
                if EnemyHumanoid and not Seen[EnemyHumanoid] then
                    Seen[EnemyHumanoid] = true
                    table.insert(EnemyHumanoids, EnemyHumanoid)
                end
            end
        end

        return EnemyHumanoids
    end)()) do
        local Health = Humanoid.Health
        local IsValidHealth = type(Health) == "number" and Health == Health and math.abs(Health) ~= math.huge

        if IsValidHealth and Health > 1 then
            local DamageNeeded = Health - 1
            Weapon.RemoteFunction:InvokeServer("hit", { Humanoid, DamageNeeded })
        end
    end
end)

local function IsUsableHealth(Health)
    return type(Health) == "number"
        and Health > 0
        and Health == Health
        and math.abs(Health) ~= math.huge
end

local function GetOreHealth(Ore)
    local Ok, PropertyHealth = pcall(function()
        return Ore.Health
    end)
    if Ok and type(PropertyHealth) == "number" then
        return PropertyHealth
    end

    local HealthValue = Ore:FindFirstChild("Health")
    if HealthValue and type(HealthValue.Value) == "number" then
        return HealthValue.Value
    end

    local AttributeHealth = Ore:GetAttribute("Health")
    if type(AttributeHealth) == "number" then
        return AttributeHealth
    end

    return nil
end

local function GetEnemyHumanoids()
    local EnemyHumanoids = {}
    local Seen = {}

    for _, Descendant in ipairs(workspace:GetDescendants()) do
        if Descendant:IsA("Model") and Descendant:FindFirstChild("EnemyMain") then
            local Humanoid = Descendant:FindFirstChild("Humanoid")
            if Humanoid and not Seen[Humanoid] then
                Seen[Humanoid] = true
                table.insert(EnemyHumanoids, Humanoid)
            end
        end
    end

    return EnemyHumanoids
end

RunService.RenderStepped:Connect(function(DeltaTime)
    CooldownTimer += DeltaTime

    if Flags.Enabled ~= true then
        return
    end

    local Weapon = nil
    for _, Child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if Child:FindFirstChild("SwordControl") and Child:FindFirstChild("RemoteFunction") then
            Weapon = Child
            break
        end
    end

    local Cooldown = tonumber(Flags.AttackCooldown) or 0.5
    if CooldownTimer < Cooldown or not Weapon then
        return
    end

    local HitValue = (Flags.HitMode == "Heal") and -math.huge or math.huge

    if Flags.AutoEnemies == true then
        for _, Humanoid in ipairs(GetEnemyHumanoids()) do
            if IsUsableHealth(Humanoid.Health) then
                Weapon.RemoteFunction:InvokeServer("hit", { Humanoid, HitValue })
            end
        end
    end

    if Flags.AutoMines == true and type(Flags.MineTargets) == "table" then
        for MineName, IsSelected in pairs(Flags.MineTargets) do
            if IsSelected == true and type(MineName) == "string" then
                local MineFolder = workspace:FindFirstChild(MineName)
                if MineFolder then
                    for _, Child in ipairs(MineFolder:GetChildren()) do
                        local Ore = Child:FindFirstChild("Ore")
                        if Ore then
                            local OreHealth = GetOreHealth(Ore)
                            if OreHealth == nil or IsUsableHealth(OreHealth) then
                                Weapon.RemoteFunction:InvokeServer("hit", { Ore, HitValue })
                            end
                        end
                    end
                end
            end
        end
    end

    CooldownTimer = 0
end)




      
