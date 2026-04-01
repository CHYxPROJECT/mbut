-- =========================================================
-- 🛡️ KRAZY HUB♾️ | Master Hub Final (Krazy On Top)💤
-- =========================================================
-- Versión: 20.2.9 | Ultra Lag-Free Matrix (Static Spawn)
-- Estilo: TopBuddha-AntiBuddha EXCLUSIVE
-- =========================================================

-- [0] INTRO SCREEN: STATIC MATRIX SPAWN (NO LAG)
local function RunIntro()
    local ScreenGui = Instance.new("ScreenGui")
    local Blackout = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel") 
    
    ScreenGui.Name = "KrazyIntro"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.IgnoreGuiInset = true
    
    Blackout.Name = "Blackout"
    Blackout.Size = UDim2.new(1, 0, 1, 0)
    Blackout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blackout.BorderSizePixel = 0
    Blackout.Parent = ScreenGui
    
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0.5, 0)
    Title.Position = UDim2.new(0, 0, 0.25, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Krazy Hub | TopBuddha-AntiBuddha"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.Font = Enum.Font.SpecialElite
    Title.TextSize = 50
    Title.TextStrokeTransparency = 0
    Title.TextStrokeColor3 = Color3.fromRGB(0, 100, 0)
    Title.ZIndex = 100
    Title.Parent = Blackout

    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, 0, 0.1, 0)
    Subtitle.Position = UDim2.new(0, 0, 0.6, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Inyectando Protocolos Estáticos (Sin Lag)..."
    Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Subtitle.Font = Enum.Font.Code
    Subtitle.TextSize = 18
    Subtitle.Parent = Blackout

    task.spawn(function()
        -- MATRIX SIN CAÍDA (Spawnea números en posiciones aleatorias)
        -- Esto elimina el lag porque no usa TweenService para mover objetos
        local activeNumbers = 0
        local maxNumbers = 150 -- Cantidad de números simultáneos en pantalla

        for i = 1, maxNumbers do
            task.spawn(function()
                while Blackout.Parent do
                    local m = Instance.new("TextLabel")
                    m.Text = tostring(math.random(0, 9))
                    m.Position = UDim2.new(math.random(), 0, math.random(), 0)
                    m.BackgroundTransparency = 1
                    m.TextColor3 = Color3.fromRGB(0, math.random(150, 255), 0)
                    m.Font = Enum.Font.Code
                    m.TextSize = math.random(15, 25)
                    m.TextTransparency = 1
                    m.Parent = Blackout
                    
                    -- Efecto de parpadeo simple (Aparece y Desaparece)
                    local duration = math.random(5, 15) / 10
                    game:GetService("TweenService"):Create(m, TweenInfo.new(duration/2), {TextTransparency = 0}):Play()
                    task.wait(duration)
                    game:GetService("TweenService"):Create(m, TweenInfo.new(duration/2), {TextTransparency = 1}):Play()
                    
                    game:GetService("Debris"):AddItem(m, duration)
                    task.wait(math.random(0.1, 0.5))
                end
            end)
        end
        
        task.wait(5)
        local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        game:GetService("TweenService"):Create(Blackout, fadeInfo, {BackgroundTransparency = 1}):Play()
        game:GetService("TweenService"):Create(Title, fadeInfo, {TextTransparency = 1}):Play()
        game:GetService("TweenService"):Create(Subtitle, fadeInfo, {TextTransparency = 1}):Play()
        task.wait(1)
        ScreenGui:Destroy()
    end)
end

RunIntro()
task.wait(6)

-- [[ AQUÍ COMIENZA EL RESTO DE TU SCRIPT ORIGINAL SIN NINGUNA MODIFICACIÓN ]]
-- [1] BYPASSES Y PROTECCIONES INTEGRALES
repeat task.wait() until game:GetService("ReplicatedStorage"):FindFirstChild("Util")
local ss = require(game:GetService("ReplicatedStorage").Util.CameraShaker.Main)
local xx = function() return nil end
ss.StartShake = xx
ss.ShakeOnce = xx
ss.ShakeSustain = xx
ss.CamerShakeInstance = xx
ss.Shake = xx
ss.Start = xx

pcall(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local TeleportService = game:GetService("TeleportService")
    local GuiService = game:GetService("GuiService")

    local function Rejoin()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end

    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        if (Method == "Kick" or Method == "kick") and Self == LocalPlayer then 
            task.spawn(Rejoin)
            return nil 
        end
        return OldNamecall(Self, ...)
    end))

    GuiService.ErrorMessageChanged:Connect(function()
        if GuiService:GetErrorMessage() ~= "" then
            Rejoin()
        end
    end)
end)

-- [2] VARIABLES GLOBALES Y SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FastAttackEnabled = false
local FastAttackRange = 12000
local FruitAttack = false
local InfiniteJumpEnabled = false
local TOGGLE_KEY = Enum.KeyCode.U

local FastAttackConnection = nil
local FruitAttackConnection = nil

local TeleportEnabled = false
local InstaTeleportEnabled = false
local SpectateEnabled = false
local SelectedPlayer = nil
local TeleportConnection = nil
local InstaTpConnection = nil
local SpectateConnection = nil
local ActiveTween = nil
local YOffset = 0
local PredictionStrength = 0
local TweenSpeed = {X = 350, Y = 350}

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit = Net["RE/RegisterHit"]
local RegisterAttack = Net["RE/RegisterAttack"]

-- [3] FUNCIONES DE ATAQUE (KITSUNE, T-REX, NPC, PLAYER)
local function AttackMultipleTargets(targets)
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, targetChar in pairs(targets) do
            local head = targetChar:FindFirstChild("Head")
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            if hrp and getgenv().HitboxExpander then
                hrp.Size = Vector3.new(30, 30, 30)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("White")
                hrp.Material = Enum.Material.ForceField
                hrp.CanCollide = false
            end
            if head then
                table.insert(allTargets, {
                    targetChar,
                    head
                })
            end
        end
        if #allTargets == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

local function StartFastAttack()
    if FastAttackConnection then task.cancel(FastAttackConnection) end
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            task.wait(0.005)
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local targetsInRange = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoid and hrp and humanoid.Health > 0 then
                        if (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targetsInRange, player.Character)
                        end
                    end
                end
            end
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, npc in pairs(enemiesFolder:GetChildren()) do
                    local humanoid = npc:FindFirstChild("Humanoid")
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if humanoid and hrp and humanoid.Health > 0 then
                        if (npc.HumanoidRootPart.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targetsInRange, npc)
                        end
                    end
                end
            end
            if #targetsInRange > 0 then
                AttackMultipleTargets(targetsInRange)
            end
        end
    end)
end

-- [4] SISTEMAS DE MOVIMIENTO Y TWEENING
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if #list == 0 then return {"None"} end
    return list
end

local function SetNoCollide()
    pcall(function()
        if not LocalPlayer.Character then return end
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end

local function SetCollide()
    pcall(function()
        if not LocalPlayer.Character then return end
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end)
end

local function GetNearestPlayer()
    local nearest, dist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; nearest = v end
        end
    end
    return nearest
end

local function TP(targetHRP)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    local predictedPos = targetHRP.Position + (targetHRP.Velocity * PredictionStrength)
    local targetCFrame = CFrame.new(predictedPos) * CFrame.Angles(0, math.rad(targetHRP.Orientation.Y), 0) * CFrame.new(0, YOffset, 0)
    local Distance = (targetCFrame.Position - HRP.Position).Magnitude
    if ActiveTween then ActiveTween:Cancel() end
    ActiveTween = TweenService:Create(HRP, TweenInfo.new(Distance / TweenSpeed.X, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    ActiveTween:Play()
end

-- [5] INTERFAZ RAYFIELD (GUI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Krazy Hub | Ultimate V20.2.9 ♾️",
    LoadingTitle = "Inyectando Protocolo Matrix Estático...",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Tab1 = Window:CreateTab("⚔️ Combate", 4483362458)
local Tab2 = Window:CreateTab("🟣 Player Lock", 4483362458)
local Tab3 = Window:CreateTab("⌁ TPs", 4483362458)
local Tab4 = Window:CreateTab("⚙️ Misc", 4483362458)
local TabESP = Window:CreateTab("👁️ ESP", 4483362458)

-- 💀 TAB COMBATE 💀
Tab1:CreateSection("--- Exploits de Movimiento ---")
Tab1:CreateToggle({
    Name = "🚀 Infinite Jump",
    CurrentValue = false,
    Callback = function(v) InfiniteJumpEnabled = v end
})

Tab1:CreateSection("--- Funciones de Ataque ---")
Tab1:CreateToggle({
    Name="Fruit Attack (Kitsune) Ultra Speed",
    CurrentValue=false,
    Callback=function(vatt)
        FruitAttack = vatt
        if vatt then
            FruitAttackConnection = task.spawn(function()
                while FruitAttack do
                    task.wait(0.001)
                    local targetPlayer = GetNearestPlayer()
                    if targetPlayer and targetPlayer.Character then
                        local tool = LocalPlayer.Character:FindFirstChild("Kitsune-Kitsune")
                        if tool then
                            local direction = (targetPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                            pcall(function()
                                tool:WaitForChild("LeftClickRemote"):FireServer(direction, 1, true)
                            end)
                        end
                    end
                end
            end)
        else
            if FruitAttackConnection then task.cancel(FruitAttackConnection) end
        end
    end,
})

Tab1:CreateToggle({
    Name="Fruit Attack (T-Rex) Ultra Speed",
    CurrentValue=false,
    Callback=function(v)
        FruitAttack = v
        if v then
            FruitAttackConnection = task.spawn(function()
                while FruitAttack do
                    task.wait(0.001)
                    local targetPlayer = GetNearestPlayer()
                    if targetPlayer and targetPlayer.Character then
                        local tool = LocalPlayer.Character:FindFirstChild("T-Rex-T-Rex")
                        if tool then
                            local direction = (targetPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                            pcall(function()
                                tool:WaitForChild("LeftClickRemote"):FireServer(direction, 1)
                            end)
                        end
                    end
                end
            end)
        else
            if FruitAttackConnection then task.cancel(FruitAttackConnection) end
        end
    end,
})

local FastAttackToggle = Tab1:CreateToggle({
    Name = "Fast Atack Master (U Key)🔥", 
    CurrentValue = false, 
    Callback = function(v)
        FastAttackEnabled = v
        if v then StartFastAttack() else
            if FastAttackConnection then task.cancel(FastAttackConnection) end
        end
    end
})

Tab1:CreateSlider({
    Name = "Fast Attack Range",
    Range = {0, 12000},
    Increment = 100,
    CurrentValue = 12000,
    Callback = function(Value) FastAttackRange = Value end,
})

Tab1:CreateToggle({
    Name = "⚪ HITBOX VISIBLE", 
    CurrentValue = false, 
    Callback = function(v) getgenv().HitboxExpander = v end
})

-- ♾️ TAB PLAYER LOCK 💀
local PlayerDropdown = Tab2:CreateDropdown({
    Name = "Player Selection",
    Options = GetPlayerList(),
    CurrentOption = {"None"},
    Callback = function(opt)
        if type(opt) == "table" then opt = opt[1] end
        SelectedPlayer = (opt ~= "None") and opt or nil
    end,
})

Tab2:CreateToggle({
    Name = "Tween To Player",
    CurrentValue = false,
    Callback = function(v)
        TeleportEnabled = v
        if v then
            TeleportConnection = RunService.Heartbeat:Connect(function()
                if SelectedPlayer then
                    local target = Players:FindFirstChild(SelectedPlayer)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        TP(target.Character.HumanoidRootPart)
                        SetNoCollide()
                    end
                end
            end)
        else
            if TeleportConnection then TeleportConnection:Disconnect() end
            if ActiveTween then ActiveTween:Cancel() end
            SetCollide()
        end
    end,
})

Tab2:CreateToggle({
    Name = "Insta Tp",
    CurrentValue = false,
    Callback = function(v)
        InstaTeleportEnabled = v
        if v then
            InstaTpConnection = RunService.Stepped:Connect(function()
                if SelectedPlayer then
                    pcall(function()
                        local target = Players:FindFirstChild(SelectedPlayer)
                        if target and target.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, YOffset, 0)
                            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                        end
                    end)
                end
            end)
        else
            if InstaTpConnection then InstaTpConnection:Disconnect() end
        end
    end,
})

Tab2:CreateToggle({
    Name = "Spectate Player",
    CurrentValue = false,
    Callback = function(v)
        SpectateEnabled = v
        if v then
            SpectateConnection = RunService.RenderStepped:Connect(function()
                if SelectedPlayer then
                    local target = Players:FindFirstChild(SelectedPlayer)
                    if target and target.Character then
                        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
                    end
                end
            end)
        else
            if SpectateConnection then SpectateConnection:Disconnect() end
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end,
})

Tab2:CreateButton({
    Name = "Refrescar Lista",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerList(), true)
    end
})

Tab2:CreateSlider({
    Name = "Y Offset",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value) YOffset = Value end,
})

Tab2:CreateSection("--- Automatización ---")
Tab2:CreateToggle({
    Name = "Auto V4 Awakening",
    CurrentValue = false,
    Callback = function(v)
        autoV4 = v
        task.spawn(function()
            while autoV4 do
                task.wait(0.5)
                pcall(function()
                    LocalPlayer.Backpack.Awakening.RemoteFunction:InvokeServer(true)
                end)
            end
        end)
    end,
})

-- 🌍 TAB TPs
Tab3:CreateButton({
    Name = "Tp Barco",
    Callback = function() 
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6500, 129, -123)
        end
    end
})

Tab3:CreateButton({
    Name = "Tp Krazy Vacio",
    Callback = function() 
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-11997, 332, -8837)
        end
    end
})

-- 🚨 TAB MISC
Tab4:CreateToggle({
    Name="Unbreakable",
    CurrentValue=false,
    Callback=function(v)
        _G.Unbreakable = v
        task.spawn(function()
            while _G.Unbreakable do
                task.wait(0.1)
                if LocalPlayer.Character then
                    LocalPlayer.Character:SetAttribute("UnbreakableAll", true)
                end
            end
        end)
    end,
})

Tab4:CreateButton({
    Name = "Remove TouchInterest",
    Callback = function()
        for _, descendant in pairs(game:GetDescendants()) do
            if descendant:IsA("TouchTransmitter") then descendant:Destroy() end
        end
    end
})

-- 👁️ TAB ESP
TabESP:CreateToggle({Name = "Enable ESP", CurrentValue = true, Callback = function(v) _G.ESPEnabled = v end})
TabESP:CreateToggle({Name = "Boxes", CurrentValue = true, Callback = function(v) _G.ESPBoxes = v end})
TabESP:CreateToggle({Name = "Names", CurrentValue = true, Callback = function(v) _G.ESPNames = v end})

-- [6] INPUT SYSTEM (TECLAS U Y B)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == TOGGLE_KEY then
        FastAttackEnabled = not FastAttackEnabled
        FastAttackToggle:Set(FastAttackEnabled)
    end
    if not gp and input.KeyCode == Enum.KeyCode.B then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local flag = hrp:FindFirstChild("UpLoop")
            if flag then flag:Destroy() else
                flag = Instance.new("BoolValue", hrp); flag.Name = "UpLoop"
                task.spawn(function()
                    while flag.Parent do
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 273861, 0)
                        task.wait(0.05)
                    end
                end)
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState("Jumping") end
    end
end)

Rayfield:Notify({Title = "Krazy Hub", Content = "Bienvenido a Krazy Hub♾️.", Duration = 5})
