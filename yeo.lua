local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==================== LÓGICA DE ESP (NOMBRES) ====================
local ESPEnabled = false
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "YeoESP"
    billboard.Adornee = target:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target:FindFirstChild("Head")

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = target.Name
    label.Font = "GothamBold"
    label.TextSize = 14
    label.TextColor3 = target:IsA("Player") and Color3.new(0, 1, 1) or Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Parent = billboard
    
    table.insert(ESPObjects, billboard)
end

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj then obj:Destroy() end
    end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            CreateESP(p.Character)
        end
    end
    
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in pairs(enemies:GetChildren()) do
            CreateESP(npc)
        end
    end
end

-- ==================== LÓGICA DE RED (FAST ATTACK) ====================
local FastAttackEnabled = false
local FastAttackRange = 5000
local FastAttackConnection = nil
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit = Net["RE/RegisterHit"]
local RegisterAttack = Net["RE/RegisterAttack"]

local function AttackMultipleTargets(targets)
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, char in pairs(targets) do
            local head = char:FindFirstChild("Head")
            if head then table.insert(allTargets, {char, head}) end
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
            RunService.Stepped:Wait()
            local myChar = Players.LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local targets = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, player.Character)
                    end
                end
            end
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, npc in pairs(enemies:GetChildren()) do
                    local hum = npc:FindFirstChild("Humanoid")
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, npc)
                    end
                end
            end
            if #targets > 0 then AttackMultipleTargets(targets) end
        end
    end)
end

-- ==================== INTERFAZ PRINCIPAL ====================
local pgui = Players.LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("YeoHub_Pro") then pgui.YeoHub_Pro:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "YeoHub_Pro"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
local normalSize, minimizedSize = UDim2.new(0, 380, 0, 300), UDim2.new(0, 150, 0, 35)
mainFrame.Size = normalSize; mainFrame.Position = UDim2.new(0.5, -190, 0.3, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30); mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.6, 0, 1, 0); titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Text = "YEO HUB"; titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255); titleLabel.Font = "GothamBlack"; titleLabel.TextSize = 14; titleLabel.TextXAlignment = "Left"; titleLabel.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 25, 0, 25); closeBtn.Position = UDim2.new(1, -30, 0, 5); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); closeBtn.Font = "GothamBold"; Instance.new("UICorner", closeBtn)

local maximizeBtn = Instance.new("TextButton", topBar)
maximizeBtn.Size = UDim2.new(0, 25, 0, 25); maximizeBtn.Position = UDim2.new(1, -60, 0, 5); maximizeBtn.Text = "+"; maximizeBtn.TextColor3 = Color3.new(1,1,1); maximizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,60); maximizeBtn.TextSize = 18; Instance.new("UICorner", maximizeBtn)

local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 25, 0, 25); minimizeBtn.Position = UDim2.new(1, -90, 0, 5); minimizeBtn.Text = "-"; minimizeBtn.TextColor3 = Color3.new(1,1,1); minimizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,60); minimizeBtn.TextSize = 18; Instance.new("UICorner", minimizeBtn)

local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, -20, 0, 35); tabContainer.Position = UDim2.new(0, 10, 0, 40); tabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", tabContainer).FillDirection = "Horizontal"; tabContainer.UIListLayout.Padding = UDim.new(0, 5); tabContainer.UIListLayout.HorizontalAlignment = "Center"

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -90); contentFrame.Position = UDim2.new(0, 10, 0, 80); contentFrame.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("ScrollingFrame", contentFrame); p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 2; p.CanvasSize = UDim2.new(0,0,0,350)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8); p.UIListLayout.HorizontalAlignment = "Center"; return p
end

-- PÁGINAS
local combatPage = createPage("Combate")
local movePage = createPage("Movimiento")
local sea2Page = createPage("sea 2")
local sea3Page = createPage("Sea 3 tp")

local function showPage(page)
    for _, v in pairs(contentFrame:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
    page.Visible = true
end

local function createTab(name, page)
    local b = Instance.new("TextButton", tabContainer); b.Size = UDim2.new(0, 85, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 50); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() showPage(page) end)
end

-- PESTAÑAS
createTab("⚔️ Combate", combatPage)
createTab("🏃 Mov", movePage)
createTab("🌊 sea 2", sea2Page)
createTab("🏰 sea 3", sea3Page)

showPage(combatPage)

local function addBtn(txt, color, parent)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0.95, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55); btn.Text = txt; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn); Instance.new("UIStroke", btn).Color = color; return btn
end

-- ==================== BOTONES Y LÓGICA ====================

-- TELEPORTS SEA 2
addBtn("Barco Maldito (Sea 2)", Color3.new(0, 1, 0.5), sea2Page).MouseButton1Click:Connect(function() 
    Players.LocalPlayer.Character:PivotTo(CFrame.new(923, 126, 32852)) 
end)

-- TELEPORTS SEA 3
addBtn("Castillo (Sea 3)", Color3.new(0.5, 0, 1), sea3Page).MouseButton1Click:Connect(function() 
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-5085, 316, -3156)) 
end)
addBtn("Mansión (Sea 3)", Color3.fromRGB(255, 170, 0), sea3Page).MouseButton1Click:Connect(function() 
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-12463, 375, -7523)) 
end)

-- COMBATE
local fBtn = addBtn("Fast Attack: OFF", Color3.new(1, 1, 0), combatPage)
fBtn.MouseButton1Click:Connect(function() FastAttackEnabled = not FastAttackEnabled; fBtn.Text = FastAttackEnabled and "Fast Attack: ON" or "Fast Attack: OFF"; if FastAttackEnabled then StartFastAttack() else if FastAttackConnection then task.cancel(FastAttackConnection) end end end)

addBtn("Hitbox: 2048 STUDS", Color3.new(1, 0, 0), combatPage)

local espBtn = addBtn("ESP: OFF", Color3.new(1, 0.5, 0), combatPage)
espBtn.MouseButton1Click:Connect(function() 
    ESPEnabled = not ESPEnabled; 
    espBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    UpdateESP()
end)

task.spawn(function()
    while true do task.wait(5) if ESPEnabled then UpdateESP() end end
end)

-- MOVIMIENTO
local sBtn = addBtn("Speed Controller: OFF", Color3.new(0, 1, 0.5), movePage)
local speedPanel = Instance.new("Frame", screenGui); speedPanel.Size = UDim2.new(0, 130, 0, 45); speedPanel.Position = UDim2.new(0, 20, 0.45, 0); speedPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45); speedPanel.Visible = false; speedPanel.Active = true; speedPanel.Draggable = true; Instance.new("UICorner", speedPanel); Instance.new("UIStroke", speedPanel).Color = Color3.fromRGB(150, 150, 150)
local btnM = Instance.new("TextButton", speedPanel); btnM.Size = UDim2.new(0, 30, 0, 30); btnM.Position = UDim2.new(0.08, 0, 0.5, -15); btnM.Text = "-"; btnM.BackgroundColor3 = Color3.fromRGB(70, 70, 70); btnM.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnM)
local sDisp = Instance.new("TextLabel", speedPanel); sDisp.Size = UDim2.new(0, 50, 1, 0); sDisp.Position = UDim2.new(0.3, 0, 0, 0); sDisp.Text = "16"; sDisp.TextColor3 = Color3.new(1,1,1); sDisp.Font = "GothamBold"; sDisp.BackgroundTransparency = 1
local btnP = Instance.new("TextButton", speedPanel); btnP.Size = UDim2.new(0, 30, 0, 30); btnP.Position = UDim2.new(0.7, 0, 0.5, -15); btnP.Text = "+"; btnP.BackgroundColor3 = Color3.fromRGB(70, 70, 70); btnP.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnP)

local sVal, sAct = 16, false
sBtn.MouseButton1Click:Connect(function() sAct = not sAct; speedPanel.Visible = sAct; sBtn.Text = sAct and "Speed Controller: ON" or "Speed Controller: OFF" end)
btnP.MouseButton1Click:Connect(function() sVal = math.clamp(sVal + 10, 16, 500); sDisp.Text = tostring(sVal) end)
btnM.MouseButton1Click:Connect(function() sVal = math.clamp(sVal - 10, 16, 500); sDisp.Text = tostring(sVal) end)
RunService.Heartbeat:Connect(function() if sAct and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then local hum = Players.LocalPlayer.Character.Humanoid if hum.MoveDirection.Magnitude > 0 then Players.LocalPlayer.Character:TranslateBy(hum.MoveDirection * (sVal/55)) end end end)

local jBtn = addBtn("Infinite Jump", Color3.new(0, 0.5, 1), movePage)
local iJ = false; jBtn.MouseButton1Click:Connect(function() iJ = not iJ end)
UserInputService.JumpRequest:Connect(function() if iJ and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

local nBtn = addBtn("No Clip", Color3.new(1, 1, 1), movePage)
local ncl = false; nBtn.MouseButton1Click:Connect(function() ncl = not ncl end)
RunService.Stepped:Connect(function() if ncl then for _,v in pairs(Players.LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)

-- [WALK ON WATER V4 - SMART HEIGHT]
local walkWaterEnabled = false
local wowBtn = addBtn("Walk on Water: OFF", Color3.fromRGB(0, 200, 255), movePage)

wowBtn.MouseButton1Click:Connect(function()
    walkWaterEnabled = not walkWaterEnabled
    wowBtn.Text = walkWaterEnabled and "Walk on Water: ON" or "Walk on Water: OFF"
end)

RunService.RenderStepped:Connect(function()
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if walkWaterEnabled and hrp then
        -- Solo activamos si estamos cayendo o por encima del nivel del mar (Y=10)
        -- Si estás debajo (Y < 9), el script te deja subir libremente
        if hrp.Position.Y >= 9.5 and hrp.Velocity.Y <= 0 then
            local waterPart = workspace:FindFirstChild("YeoWaterSolid")
            if not waterPart then
                waterPart = Instance.new("Part", workspace)
                waterPart.Name = "YeoWaterSolid"
                waterPart.Size = Vector3.new(20, 1, 20)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = true
                waterPart.CanQuery = false -- No interfiere con habilidades
            end
            waterPart.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            if workspace:FindFirstChild("YeoWaterSolid") then workspace.YeoWaterSolid:Destroy() end
        end
    else
        if workspace:FindFirstChild("YeoWaterSolid") then workspace.YeoWaterSolid:Destroy() end
    end
end)

-- CONTROLES VENTANA
closeBtn.MouseButton1Click:Connect(function() 
    ESPEnabled = false; 
    ClearESP(); 
    if workspace:FindFirstChild("YeoWaterSolid") then workspace.YeoWaterSolid:Destroy() end
    screenGui:Destroy() 
end)
minimizeBtn.MouseButton1Click:Connect(function() contentFrame.Visible = false; tabContainer.Visible = false; mainFrame:TweenSize(minimizedSize, "Out", "Quint", 0.3, true) end)
maximizeBtn.MouseButton1Click:Connect(function() mainFrame:TweenSize(normalSize, "Out", "Quint", 0.3, true); task.wait(0.2); contentFrame.Visible = true; tabContainer.Visible = true end)