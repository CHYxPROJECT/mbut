-- ============================================================
--  RIVALS HUB — Blox Fruits
--  GUI rediseñada por Bleiker
-- ============================================================

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

-- ============================================================
--  LÓGICA ESP
-- ============================================================
local ESPEnabled = false
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RivalsESP"
    billboard.Adornee = target:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target:FindFirstChild("Head")
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = target.Name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = target:IsA("Model") and Color3.fromRGB(120, 140, 255) or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.4
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
        if p ~= LocalPlayer and p.Character then
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

-- ============================================================
--  LÓGICA AIMBOT
-- ============================================================
local AimbotEnabled = false
local aimbotAiming  = false
local aimbotTarget  = nil
local aimbotLastSwitch = 0

local AIMBOT = {
    FOV          = 220,
    MAX_DISTANCE = 600,
    SMOOTHNESS   = 0.18,
    PREDICTION   = 0.14,
    TARGET_PART  = "HumanoidRootPart",
    LOCK_STRENGTH = 0.85,
    SWITCH_DELAY  = 0.2,
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not AimbotEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotAiming = false
        aimbotTarget = nil
    end
end)

local function aimbotIsValid(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    local hum  = player.Character:FindFirstChild("Humanoid")
    local part = player.Character:FindFirstChild(AIMBOT.TARGET_PART)
    if not hum or hum.Health <= 0 then return false end
    if not part then return false end
    return true
end

local function aimbotGetScore(part)
    local Camera = workspace.CurrentCamera
    local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
    if not visible then return math.huge end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    local dist3D = (part.Position - Camera.CFrame.Position).Magnitude
    if dist3D > AIMBOT.MAX_DISTANCE then return math.huge end
    return dist2D + (dist3D * 0.2)
end

local function aimbotGetBest()
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if aimbotIsValid(plr) then
            local part  = plr.Character[AIMBOT.TARGET_PART]
            local score = aimbotGetScore(part)
            if score < bestScore and score < AIMBOT.FOV then
                bestScore = score
                best = part
            end
        end
    end
    return best
end

local function aimbotPredict(part)
    local Camera   = workspace.CurrentCamera
    local velocity = part.AssemblyLinearVelocity or Vector3.zero
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    return part.Position + (velocity * (AIMBOT.PREDICTION + distance/1000))
end

local function aimbotAimAt(pos)
    local Camera  = workspace.CurrentCamera
    local camCF   = Camera.CFrame
    local targetCF = CFrame.new(camCF.Position, pos)
    Camera.CFrame = camCF:Lerp(targetCF, AIMBOT.SMOOTHNESS)
end

local function aimbotUpdateTarget()
    local now = tick()
    if aimbotTarget and aimbotTarget.Parent then
        return aimbotTarget
    end
    if now - aimbotLastSwitch < AIMBOT.SWITCH_DELAY then
        return aimbotTarget
    end
    local newTarget = aimbotGetBest()
    if newTarget ~= aimbotTarget then
        aimbotLastSwitch = now
    end
    aimbotTarget = newTarget
    return aimbotTarget
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled or not aimbotAiming then return end
    local target = aimbotUpdateTarget()
    if target then
        aimbotAimAt(aimbotPredict(target))
    end
end)
local FastAttackEnabled   = false
local FastAttackRange     = 5000
local FastAttackConnection = nil
local Net            = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit    = Net["RE/RegisterHit"]
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
        local hitArgs = { allTargets[1][2], allTargets }
        RegisterHit:FireServer(unpack(hitArgs))
    end)
end

local function StopFastAttack()
    if FastAttackConnection then
        task.cancel(FastAttackConnection)
        FastAttackConnection = nil
    end
end

local function StartFastAttack()
    StopFastAttack()
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            task.wait(0.01)
            pcall(function()
                local myChar = LocalPlayer.Character
                local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                local targets = {}
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
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
            end)
        end
    end)
end

-- ============================================================
--  HELPERS DE GUI
-- ============================================================
local function corner(r, p)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(color, thickness, p)
    local s = Instance.new("UIStroke", p)
    s.Color = color
    s.Thickness = thickness or 1
    return s
end

local function label(props, parent)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Font      = props.Font or Enum.Font.Gotham
    l.TextSize  = props.TextSize or 13
    l.TextColor3 = props.TextColor3 or Color3.fromRGB(228, 228, 232)
    l.Text      = props.Text or ""
    l.Size      = props.Size or UDim2.new(1,0,1,0)
    l.Position  = props.Position or UDim2.new(0,0,0,0)
    l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    l.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    return l
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint), props):Play()
end

-- ============================================================
--  COLORES
-- ============================================================
local C = {
    bg      = Color3.fromRGB(17, 17, 20),
    panel   = Color3.fromRGB(13, 13, 16),
    item    = Color3.fromRGB(24, 24, 29),
    itemHov = Color3.fromRGB(29, 29, 35),
    border  = Color3.fromRGB(40, 40, 50),
    accent  = Color3.fromRGB(92, 107, 255),
    accent2 = Color3.fromRGB(123, 136, 255),
    text    = Color3.fromRGB(228, 228, 232),
    sub     = Color3.fromRGB(107, 107, 120),
    white   = Color3.fromRGB(255, 255, 255),
    green   = Color3.fromRGB(92, 240, 176),
    red     = Color3.fromRGB(255, 70, 90),
}

-- ============================================================
--  SCREEN GUI
-- ============================================================
local pgui = LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("RivalsHub") then pgui.RivalsHub:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "RivalsHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1  -- bajo para que los fades de BF aparezcan encima

-- ============================================================
--  MAIN FRAME  (560 x 460)
-- ============================================================
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 560, 0, 460)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -230)
mainFrame.BackgroundColor3 = C.bg
mainFrame.Active = true
mainFrame.Draggable = true
corner(12, mainFrame)
stroke(C.border, 1, mainFrame)

-- entrada animada
mainFrame.BackgroundTransparency = 1
tween(mainFrame, 0.35, {BackgroundTransparency = 0})

-- ── TITLEBAR ──────────────────────────────────────────────
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundTransparency = 1

local titleName = label({
    Text = "Rivals Hub",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.white,
    Size = UDim2.new(0, 120, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
}, titleBar)

local titleSub = label({
    Text = "by Bleiker",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.sub,
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(0, 88, 0, 0),
}, titleBar)

-- separator line
local titleLine = Instance.new("Frame", mainFrame)
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.new(0, 0, 0, 44)
titleLine.BackgroundColor3 = C.border
titleLine.BorderSizePixel = 0

-- close button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = C.sub
closeBtn.BackgroundTransparency = 1
corner(6, closeBtn)

closeBtn.MouseEnter:Connect(function()  closeBtn.TextColor3 = C.red end)
closeBtn.MouseLeave:Connect(function()  closeBtn.TextColor3 = C.sub end)

-- minimize button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -70, 0.5, -14)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.TextColor3 = C.sub
minBtn.BackgroundTransparency = 1
corner(6, minBtn)

minBtn.MouseEnter:Connect(function()  minBtn.TextColor3 = C.text end)
minBtn.MouseLeave:Connect(function()  minBtn.TextColor3 = C.sub end)

-- ── SIDEBAR (180px) ────────────────────────────────────────
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 180, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundTransparency = 1

local sidebarLine = Instance.new("Frame", mainFrame)
sidebarLine.Size = UDim2.new(0, 1, 1, -45)
sidebarLine.Position = UDim2.new(0, 180, 0, 45)
sidebarLine.BackgroundColor3 = C.border
sidebarLine.BorderSizePixel = 0

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 2)
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop    = UDim.new(0, 8)
sidePad.PaddingLeft   = UDim.new(0, 8)
sidePad.PaddingRight  = UDim.new(0, 8)

-- ── CONTENT FRAME ─────────────────────────────────────────
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -196, 1, -61)
contentFrame.Position = UDim2.new(0, 190, 0, 51)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.BorderSizePixel = 0

local contentLayout = Instance.new("UIListLayout", contentFrame)
contentLayout.Padding = UDim.new(0, 10)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
local contentPad = Instance.new("UIPadding", contentFrame)
contentPad.PaddingTop    = UDim.new(0, 10)
contentPad.PaddingBottom = UDim.new(0, 10)
contentPad.PaddingRight  = UDim.new(0, 10)

-- ============================================================
--  TAB SYSTEM
-- ============================================================
local pages = {}
local navButtons = {}
local currentPage = nil

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    for navName, btn in pairs(navButtons) do
        if navName == name then
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            btn.TextColor3 = C.accent2
            -- active line
            if btn:FindFirstChild("ActiveLine") then
                btn.ActiveLine.BackgroundColor3 = C.accent
            end
        else
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = C.sub
            if btn:FindFirstChild("ActiveLine") then
                btn.ActiveLine.BackgroundColor3 = Color3.fromRGB(0,0,0)
                btn.ActiveLine.BackgroundTransparency = 1
            end
        end
    end
    currentPage = name
end

local function createNavBtn(name, displayText)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = displayText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = C.sub
    btn.TextXAlignment = Enum.TextXAlignment.Left
    corner(7, btn)

    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 12)

    -- left active line
    local activeLine = Instance.new("Frame", btn)
    activeLine.Name = "ActiveLine"
    activeLine.Size = UDim2.new(0, 2, 0.6, 0)
    activeLine.Position = UDim2.new(0, -8, 0.2, 0)
    activeLine.BackgroundTransparency = 1
    activeLine.BorderSizePixel = 0
    corner(2, activeLine)

    btn.MouseButton1Click:Connect(function() showPage(name) end)
    btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.12, {BackgroundTransparency = 0.92, TextColor3 = C.text})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.12, {BackgroundTransparency = 1, TextColor3 = C.sub})
        end
    end)

    navButtons[name] = btn
    return btn
end

local function createPage(name)
    local frame = Instance.new("Frame", contentFrame)
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.LayoutOrder = 1

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[name] = frame
    return frame
end

-- ============================================================
--  UI COMPONENTS
-- ============================================================

-- Section title
local function addSectionTitle(text, parent, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    label({
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.white,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    return f
end

-- Toggle row
local function addToggleRow(titleText, subText, parent, order, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, subText and 52 or 42)
    row.BackgroundColor3 = C.item
    row.LayoutOrder = order or 1
    corner(8, row)
    stroke(Color3.fromRGB(35, 35, 45), 1, row)

    label({
        Text = titleText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = C.text,
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 14, 0, subText and 8 or 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, row)

    if subText then
        label({
            Text = subText,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = C.sub,
            Size = UDim2.new(1, -60, 0, 16),
            Position = UDim2.new(0, 14, 0, 28),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end

    -- Toggle switch
    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 42, 0, 23)
    toggleBg.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBg.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
    corner(99, toggleBg)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 17, 0, 17)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
    corner(99, toggleKnob)

    local isOn = false

    local function setToggle(state)
        isOn = state
        if isOn then
            tween(toggleBg,    0.2, {BackgroundColor3 = Color3.fromRGB(50, 55, 120)})
            tween(toggleKnob,  0.2, {Position = UDim2.new(0, 22, 0.5, -8), BackgroundColor3 = C.accent2})
        else
            tween(toggleBg,    0.2, {BackgroundColor3 = Color3.fromRGB(42, 42, 50)})
            tween(toggleKnob,  0.2, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(90, 90, 105)})
        end
        if callback then callback(isOn) end
    end

    -- click area
    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.MouseButton1Click:Connect(function() setToggle(not isOn) end)

    -- hover
    row.MouseEnter:Connect(function() tween(row, 0.1, {BackgroundColor3 = C.itemHov}) end)
    row.MouseLeave:Connect(function() tween(row, 0.1, {BackgroundColor3 = C.item}) end)

    return setToggle
end

-- Teleport button
local function addTpButton(titleText, coords, dotColor, parent, order, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = C.item
    btn.Text = ""
    btn.LayoutOrder = order or 1
    corner(8, btn)
    stroke(Color3.fromRGB(35, 35, 45), 1, btn)

    -- dot
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 14, 0.5, -3)
    dot.BackgroundColor3 = dotColor
    corner(99, dot)

    label({
        Text = titleText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = C.text,
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)

    label({
        Text = coords,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = C.sub,
        Size = UDim2.new(0, 140, 1, 0),
        Position = UDim2.new(1, -150, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, btn)

    btn.MouseEnter:Connect(function() tween(btn, 0.1, {BackgroundColor3 = C.itemHov}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.1, {BackgroundColor3 = C.item}) end)
    btn.MouseButton1Click:Connect(function()
        tween(btn, 0.1, {BackgroundColor3 = Color3.fromRGB(30, 32, 60)})
        task.wait(0.2)
        tween(btn, 0.1, {BackgroundColor3 = C.item})
        if callback then callback() end
    end)
    return btn
end

-- Slider row
local function addSliderRow(titleText, minVal, maxVal, defaultVal, parent, order, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = C.item
    container.LayoutOrder = order or 1
    corner(8, container)
    stroke(Color3.fromRGB(35, 35, 45), 1, container)

    label({
        Text = titleText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = C.text,
        Size = UDim2.new(0, 150, 0, 20),
        Position = UDim2.new(0, 14, 0, 7),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, container)

    local valLabel = label({
        Text = tostring(defaultVal),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.accent2,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 7),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, container)

    -- slider track
    local track = Instance.new("Frame", container)
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(42, 42, 55)
    corner(99, track)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    corner(99, fill)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = C.white
    corner(99, knob)

    local currentVal = defaultVal
    local dragging = false

    local dragBtn = Instance.new("TextButton", container)
    dragBtn.Size = UDim2.new(1, -28, 0, 20)
    dragBtn.Position = UDim2.new(0, 14, 0, 26)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""

    local function updateSlider(x)
        local trackAbsX = track.AbsolutePosition.X
        local trackAbsW = track.AbsoluteSize.X
        local pct = math.clamp((x - trackAbsX) / trackAbsW, 0, 1)
        currentVal = math.floor(minVal + pct * (maxVal - minVal))
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        valLabel.Text = tostring(currentVal)
        if callback then callback(currentVal) end
    end

    dragBtn.MouseButton1Down:Connect(function()
        dragging = true
        updateSlider(UserInputService:GetMouseLocation().X)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return container
end

-- ============================================================
--  PAGES
-- ============================================================
local homePage     = createPage("Home")
local combatPage   = createPage("Combate")
local visualPage   = createPage("Visual")
local movePage     = createPage("Movimiento")
local tpPage       = createPage("Teleport")

-- ── NAV BUTTONS ────────────────────────────────────────────
createNavBtn("Home",        "  Home")
createNavBtn("Combate",     "  Combate")
createNavBtn("Visual",      "  Visual")
createNavBtn("Movimiento",  "  Movimiento")
createNavBtn("Teleport",    "  Teleport")

-- ============================================================
--  HOME PAGE
-- ============================================================
-- Player banner
local banner = Instance.new("Frame", homePage)
banner.Size = UDim2.new(1, 0, 0, 80)
banner.BackgroundColor3 = Color3.fromRGB(18, 16, 28)
banner.LayoutOrder = 1
corner(10, banner)
stroke(Color3.fromRGB(80, 65, 160), 1, banner)

-- glow line top
local bannerGlow = Instance.new("Frame", banner)
bannerGlow.Size = UDim2.new(0.7, 0, 0, 1)
bannerGlow.Position = UDim2.new(0.15, 0, 0, 0)
bannerGlow.BackgroundColor3 = Color3.fromRGB(130, 100, 255)
bannerGlow.BorderSizePixel = 0

-- icon circle
local iconWrap = Instance.new("Frame", banner)
iconWrap.Size = UDim2.new(0, 68, 0, 68)
iconWrap.Position = UDim2.new(0, 10, 0.5, -34)
iconWrap.BackgroundColor3 = Color3.fromRGB(22, 17, 38)
iconWrap.ClipsDescendants = true
corner(99, iconWrap)
stroke(Color3.fromRGB(110, 80, 220), 2, iconWrap)

local iconImage = Instance.new("ImageLabel", iconWrap)
iconImage.Size = UDim2.new(1, 0, 1, 0)
iconImage.Position = UDim2.new(0, 0, 0, 0)
iconImage.BackgroundTransparency = 1
iconImage.ImageTransparency = 0
iconImage.Image = "rbxassetid://127186589815047"
iconImage.ScaleType = Enum.ScaleType.Fit
iconImage.ZIndex = 10

-- hub name
label({
    Text = "RIVALS HUB",
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    TextColor3 = C.white,
    Size = UDim2.new(0, 200, 0, 24),
    Position = UDim2.new(0, 90, 0, 14),
    TextXAlignment = Enum.TextXAlignment.Left,
}, banner)

-- status
local statusRow = Instance.new("Frame", banner)
statusRow.Size = UDim2.new(0, 280, 0, 18)
statusRow.Position = UDim2.new(0, 90, 0, 42)
statusRow.BackgroundTransparency = 1

local statusDot = Instance.new("Frame", statusRow)
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(0, 0, 0.5, -3)
statusDot.BackgroundColor3 = C.green
corner(99, statusDot)

label({
    Text = "Status:",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.sub,
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusRow)

label({
    Text = "Active",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.green,
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(0, 55, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusRow)

label({
    Text = "User:",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.sub,
    Size = UDim2.new(0, 35, 1, 0),
    Position = UDim2.new(0, 115, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusRow)

-- ← nombre automático del jugador
label({
    Text = LocalPlayer.Name,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(170, 145, 255),
    Size = UDim2.new(0, 120, 1, 0),
    Position = UDim2.new(0, 148, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusRow)

-- info grid
local infoGrid = Instance.new("Frame", homePage)
infoGrid.Size = UDim2.new(1, 0, 0, 58)
infoGrid.BackgroundTransparency = 1
infoGrid.LayoutOrder = 2

local gridLayout = Instance.new("UIGridLayout", infoGrid)
gridLayout.CellSize = UDim2.new(0.5, -4, 1, 0)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 0)

local infoData = {
    {"Versión",  "v2.0"},
    {"Executor", "Delta"},
}
for _, d in ipairs(infoData) do
    local card = Instance.new("Frame", infoGrid)
    card.BackgroundColor3 = C.item
    corner(8, card)
    stroke(Color3.fromRGB(35,35,45), 1, card)
    label({Text = d[1], Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.sub,
        Size = UDim2.new(1,-24,0,16), Position = UDim2.new(0,12,0,8),
        TextXAlignment = Enum.TextXAlignment.Left}, card)
    label({Text = d[2], Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.accent2,
        Size = UDim2.new(1,-24,0,20), Position = UDim2.new(0,12,0,26),
        TextXAlignment = Enum.TextXAlignment.Left}, card)
end

-- discord row
local discordRow = Instance.new("TextButton", homePage)
discordRow.Size = UDim2.new(1, 0, 0, 38)
discordRow.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
discordRow.Text = ""
discordRow.LayoutOrder = 3
corner(8, discordRow)
stroke(Color3.fromRGB(60, 65, 140), 1, discordRow)
label({Text = "◉  discord.gg/QvpGRwDdpZ", Font = Enum.Font.GothamSemibold, TextSize = 13,
    TextColor3 = C.accent2, Size = UDim2.new(1,0,1,0),
    TextXAlignment = Enum.TextXAlignment.Center}, discordRow)

discordRow.MouseEnter:Connect(function() tween(discordRow, 0.12, {BackgroundColor3 = Color3.fromRGB(25,25,65)}) end)
discordRow.MouseLeave:Connect(function() tween(discordRow, 0.12, {BackgroundColor3 = Color3.fromRGB(20,20,50)}) end)

-- ── TAMAÑO DE GUI ──────────────────────────────────────────
addSectionTitle("Tamaño de GUI", homePage, 4)

local sizeContainer = Instance.new("Frame", homePage)
sizeContainer.Size = UDim2.new(1, 0, 0, 42)
sizeContainer.BackgroundColor3 = C.item
sizeContainer.LayoutOrder = 5
corner(8, sizeContainer)
stroke(Color3.fromRGB(35, 35, 45), 1, sizeContainer)

local sizeLayout = Instance.new("UIListLayout", sizeContainer)
sizeLayout.FillDirection = Enum.FillDirection.Horizontal
sizeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sizeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sizeLayout.Padding = UDim.new(0, 6)

local sizePad = Instance.new("UIPadding", sizeContainer)
sizePad.PaddingLeft  = UDim.new(0, 10)
sizePad.PaddingRight = UDim.new(0, 10)

local sizes = {
    { label = "Pequeño", w = 380, h = 320 },
    { label = "Mediano",  w = 470, h = 390 },
    { label = "Grande",   w = 560, h = 460 },
}

local sizeButtons = {}
local currentSize = "Grande"

local function applySizeBtn(selected)
    for _, data in ipairs(sizeButtons) do
        if data.name == selected then
            tween(data.btn, 0.15, {BackgroundColor3 = C.accent})
            data.btn.TextColor3 = C.white
        else
            tween(data.btn, 0.15, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
            data.btn.TextColor3 = C.sub
        end
    end
end

for _, s in ipairs(sizes) do
    local btn = Instance.new("TextButton", sizeContainer)
    btn.Size = UDim2.new(0, 90, 0, 28)
    btn.BackgroundColor3 = s.label == "Grande" and C.accent or Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = s.label == "Grande" and C.white or C.sub
    btn.Text = s.label
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    corner(6, btn)

    table.insert(sizeButtons, {btn = btn, name = s.label})

    btn.MouseButton1Click:Connect(function()
        currentSize = s.label
        applySizeBtn(s.label)
        -- ajustar mainFrame y reposicionar al centro
        local newW, newH = s.w, s.h
        tween(mainFrame, 0.25, {
            Size = UDim2.new(0, newW, 0, newH),
            Position = UDim2.new(0.5, -newW/2, 0.5, -newH/2),
        })
        -- ajustar sidebar y content para que escalen
        sidebar.Size     = UDim2.new(0, 180, 1, -45)
        contentFrame.Size = UDim2.new(1, -196, 1, -61)
    end)
end

-- ============================================================
--  COMBATE PAGE
-- ============================================================
addSectionTitle("Ataque", combatPage, 1)

local setFastAttack = addToggleRow("Fast Attack", "Multi-objetivo · "..FastAttackRange.." studs", combatPage, 2, function(on)
    FastAttackEnabled = on
    if on then
        StartFastAttack()
    else
        StopFastAttack()
    end
end)

local HitboxEnabled = false
local HitboxConnection = nil
local setHitbox = addToggleRow("Hitbox Expand", "2048 studs · solo NPCs", combatPage, 3, function(on)
    HitboxEnabled = on
    if on then
        HitboxConnection = RunService.Stepped:Connect(function()
            -- SOLO aplicar a NPCs enemigos, NUNCA a jugadores (evita bug de V3)
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, npc in pairs(enemies:GetChildren()) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2048, 2048, 2048)
                        hrp.Transparency = 1
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
        end
        -- restaurar NPCs
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, npc in pairs(enemies:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1) end
            end
        end
    end
end)

addSectionTitle("Config.", combatPage, 4)

addSliderRow("Attack Range", 100, 5000, 5000, combatPage, 5, function(val)
    FastAttackRange = val
end)

addSectionTitle("Aimbot", combatPage, 6)

addToggleRow("Aimbot", "Click derecho para apuntar · FOV 220", combatPage, 7, function(on)
    AimbotEnabled = on
    if not on then
        aimbotAiming = false
        aimbotTarget = nil
    end
end)

addSliderRow("FOV", 50, 500, 220, combatPage, 8, function(val)
    AIMBOT.FOV = val
end)

addSliderRow("Smoothness", 1, 20, 2, combatPage, 9, function(val)
    AIMBOT.SMOOTHNESS = val / 10
end)

-- ============================================================
--  VISUAL PAGE
-- ============================================================
addSectionTitle("ESP", visualPage, 1)

local setESP = addToggleRow("ESP Jugadores", "Nombres sobre jugadores", visualPage, 2, function(on)
    ESPEnabled = on
    UpdateESP()
end)

local setESPEnemies = addToggleRow("ESP Enemigos", "NPCs en workspace.Enemies", visualPage, 3, function(on)
    -- se controla junto con ESPEnabled en UpdateESP
end)

-- refresh ESP cada 5s
task.spawn(function()
    while true do
        task.wait(5)
        if ESPEnabled then UpdateESP() end
    end
end)

-- ── PERFORMANCE FLAGS ──────────────────────────────────────
addSectionTitle("Rendimiento", visualPage, 4)

-- Botón de apply flags
local flagsApplied = false
local flagsBtn = Instance.new("TextButton", visualPage)
flagsBtn.Size = UDim2.new(1, 0, 0, 52)
flagsBtn.BackgroundColor3 = C.item
flagsBtn.Text = ""
flagsBtn.LayoutOrder = 5
corner(8, flagsBtn)
stroke(Color3.fromRGB(35, 35, 45), 1, flagsBtn)

label({
    Text = "Performance Flags",
    Font = Enum.Font.GothamSemibold,
    TextSize = 13,
    TextColor3 = C.text,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 14, 0, 8),
    TextXAlignment = Enum.TextXAlignment.Left,
}, flagsBtn)

local flagSubLabel = label({
    Text = "Presiona para aplicar · Requiere rejoin para quitar",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.sub,
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 14, 0, 28),
    TextXAlignment = Enum.TextXAlignment.Left,
}, flagsBtn)

-- indicador de estado (punto derecha)
local flagDot = Instance.new("Frame", flagsBtn)
flagDot.Size = UDim2.new(0, 8, 0, 8)
flagDot.Position = UDim2.new(1, -22, 0.5, -4)
flagDot.BackgroundColor3 = C.sub
corner(99, flagDot)

flagsBtn.MouseEnter:Connect(function() tween(flagsBtn, 0.1, {BackgroundColor3 = C.itemHov}) end)
flagsBtn.MouseLeave:Connect(function() tween(flagsBtn, 0.1, {BackgroundColor3 = C.item}) end)

flagsBtn.MouseButton1Click:Connect(function()
    if flagsApplied then return end

    local flags = {
        ["DFIntMaxActiveAnimationTracks"]                  = "0",
        ["DFIntReplicatorAnimationTrackLimitPerAnimator"]  = "-1",
        ["DFIntAnimationLodFacsDistanceMin"]               = "0",
        ["DFIntAnimationLodFacsDistanceMax"]               = "0",
        ["TextureCompositorActiveJobs"]                    = "0",
        ["RenderShadowmapBias"]                            = "75",
        ["CSGLevelOfDetailSwitchingDistanceL34"]           = "0",
        ["CSGLevelOfDetailSwitchingDistanceL23"]           = "0",
        ["CSGLevelOfDetailSwitchingDistanceL12"]           = "0",
        ["CSGLevelOfDetailSwitchingDistance"]              = "0",
        ["FIntTerrainArraySliceSize"]                      = "0",
        ["PerformanceControlTextureQualityBestUtility"]    = "-1",
        ["FIntRenderUseTextureManager224"]                 = "0",
        ["FFlagIncludePowerSaverMode"]                     = "True",
        ["FFlagEnablePowerTraceModule"]                    = "True",
        ["FFlagDebugForceFSMCPULightCulling"]              = "True",
        ["FFlagDoNotSkipMipsBasedOnSystemMemoryPS"]        = "True",
        ["FIntDebugLimitMinTextureResolutionWhenSkipMips"] = "100",
        ["FFlagTM2SkipMipsForUnstreamable2"]               = "True",
        ["FIntDebugTextureManagerSkipMips"]                = "10",
        ["FIntTextureQualityOverride"]                     = "0",
        ["FFlagTextureQualityOverrideEnabled"]             = "True",
        ["FFlagDisablePostFx"]                             = "True",
        ["FIntTaskSchedulerTargetFps"]                     = "9999",
        ["FFlagTaskSchedulerLimitTargetFpsTo2402"]         = "False",
        ["FFlagDebugDisplayFPS"]                           = "True",
        ["FFlagDebugSkyGray"]                              = "True",
    }

    -- detectar función disponible
    local fn = setfflag or set_fflag or (getgenv and getgenv().setfflag) or nil

    if fn == nil then
        flagSubLabel.Text = "✗ setfflag no disponible en este executor"
        flagSubLabel.TextColor3 = C.red
        tween(flagDot, 0.3, {BackgroundColor3 = C.red})
        return
    end

    local applied = 0
    local failed  = 0
    for flag, value in pairs(flags) do
        local ok = pcall(fn, flag, value)
        if ok then applied += 1 else failed += 1 end
    end

    if failed == 0 then
        flagsApplied = true
        tween(flagDot, 0.3, {BackgroundColor3 = C.green})
        flagSubLabel.Text = "✓ "..applied.." flags aplicadas · Rejoin para quitar"
        flagSubLabel.TextColor3 = C.green
        tween(flagsBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(18, 28, 22)})
        stroke(Color3.fromRGB(50, 100, 70), 1, flagsBtn)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rivals Hub · Performance",
            Text = applied.." flags aplicadas correctamente",
            Duration = 3,
        })
    else
        tween(flagDot, 0.3, {BackgroundColor3 = Color3.fromRGB(255, 170, 0)})
        flagSubLabel.Text = "⚠ "..applied.." ok · "..failed.." fallaron"
        flagSubLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
    end
end)

-- FPS Booster button
local fpsBtn = Instance.new("TextButton", visualPage)
fpsBtn.Size = UDim2.new(1, 0, 0, 52)
fpsBtn.BackgroundColor3 = C.item
fpsBtn.Text = ""
fpsBtn.LayoutOrder = 6
corner(8, fpsBtn)
stroke(Color3.fromRGB(35, 35, 45), 1, fpsBtn)

label({
    Text = "FPS Booster",
    Font = Enum.Font.GothamSemibold,
    TextSize = 13,
    TextColor3 = C.text,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 14, 0, 8),
    TextXAlignment = Enum.TextXAlignment.Left,
}, fpsBtn)

local fpsSubLabel = label({
    Text = "Presiona para ejecutar el booster",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.sub,
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 14, 0, 28),
    TextXAlignment = Enum.TextXAlignment.Left,
}, fpsBtn)

local fpsDot = Instance.new("Frame", fpsBtn)
fpsDot.Size = UDim2.new(0, 8, 0, 8)
fpsDot.Position = UDim2.new(1, -22, 0.5, -4)
fpsDot.BackgroundColor3 = C.sub
corner(99, fpsDot)

fpsBtn.MouseEnter:Connect(function() tween(fpsBtn, 0.1, {BackgroundColor3 = C.itemHov}) end)
fpsBtn.MouseLeave:Connect(function() tween(fpsBtn, 0.1, {BackgroundColor3 = C.item}) end)

fpsBtn.MouseButton1Click:Connect(function()
    fpsSubLabel.Text = "Cargando..."
    fpsSubLabel.TextColor3 = C.sub
    tween(fpsDot, 0.3, {BackgroundColor3 = Color3.fromRGB(255, 170, 0)})

    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
        end)

        if ok then
            tween(fpsDot, 0.3, {BackgroundColor3 = C.green})
            fpsSubLabel.Text = "✓ FPS Booster activo"
            fpsSubLabel.TextColor3 = C.green
            tween(fpsBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(18, 28, 22)})
            stroke(Color3.fromRGB(50, 100, 70), 1, fpsBtn)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Rivals Hub · FPS Booster",
                Text = "FPS Booster ejecutado correctamente",
                Duration = 3,
            })
        else
            fpsSubLabel.Text = "✗ Error al ejecutar el booster"
            fpsSubLabel.TextColor3 = C.red
            tween(fpsDot, 0.3, {BackgroundColor3 = C.red})
        end
    end)
end)
addSectionTitle("Movimiento", movePage, 1)

local iJ = false
local setInfJump = addToggleRow("Infinite Jump", nil, movePage, 2, function(on)
    iJ = on
end)

local ncl = false
local setNoClip = addToggleRow("No Clip", "Desactiva colisiones", movePage, 3, function(on)
    ncl = on
end)

local walkWaterEnabled = false
local setWalkWater = addToggleRow("Walk on Water", "Smart height Y=9.2", movePage, 4, function(on)
    walkWaterEnabled = on
    if not on and workspace:FindFirstChild("RivalsWaterSolid") then
        workspace.RivalsWaterSolid:Destroy()
    end
end)

-- FLY toggle — lanza el script completo con su propia GUI
local flyGui = nil
local setFly = addToggleRow("Fly V6", "Abre panel de vuelo", movePage, 5, function(on)
    if on then
        -- Destruir instancia anterior si existe
        if flyGui then flyGui:Destroy() flyGui = nil end

        task.spawn(function()
            local player = LocalPlayer

            local main = Instance.new("ScreenGui")
            main.Name = "FlyV6_Rivals"
            main.Parent = player:WaitForChild("PlayerGui")
            main.ResetOnSpawn = false
            main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            flyGui = main

            local Frame = Instance.new("Frame")
            Frame.Parent = main
            Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
            Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
            Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
            Frame.Size = UDim2.new(0, 190, 0, 57)
            Frame.Active = true
            Frame.Draggable = true

            local up = Instance.new("TextButton")
            up.Name = "up"; up.Parent = Frame
            up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
            up.Size = UDim2.new(0, 44, 0, 28)
            up.Font = Enum.Font.SourceSans; up.Text = "UP"
            up.TextColor3 = Color3.fromRGB(0,0,0); up.TextSize = 14

            local down = Instance.new("TextButton")
            down.Name = "down"; down.Parent = Frame
            down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
            down.Position = UDim2.new(0, 0, 0.491228074, 0)
            down.Size = UDim2.new(0, 44, 0, 28)
            down.Font = Enum.Font.SourceSans; down.Text = "DOWN"
            down.TextColor3 = Color3.fromRGB(0,0,0); down.TextSize = 14

            local onof = Instance.new("TextButton")
            onof.Name = "onof"; onof.Parent = Frame
            onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
            onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
            onof.Size = UDim2.new(0, 56, 0, 28)
            onof.Font = Enum.Font.SourceSans; onof.Text = "fly"
            onof.TextColor3 = Color3.fromRGB(0,0,0); onof.TextSize = 14

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = Frame
            TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
            TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
            TextLabel.Size = UDim2.new(0, 100, 0, 28)
            TextLabel.Font = Enum.Font.SourceSans
            TextLabel.Text = "FLY V6 By Thiagocag23"
            TextLabel.TextColor3 = Color3.fromRGB(0,0,0)
            TextLabel.TextScaled = true; TextLabel.TextWrapped = true

            local plus = Instance.new("TextButton")
            plus.Name = "plus"; plus.Parent = Frame
            plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
            plus.Position = UDim2.new(0.231578946, 0, 0, 0)
            plus.Size = UDim2.new(0, 45, 0, 28)
            plus.Font = Enum.Font.SourceSans; plus.Text = "+"
            plus.TextColor3 = Color3.fromRGB(0,0,0)
            plus.TextScaled = true; plus.TextWrapped = true

            local speed = Instance.new("TextLabel")
            speed.Name = "speed"; speed.Parent = Frame
            speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
            speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
            speed.Size = UDim2.new(0, 44, 0, 28)
            speed.Font = Enum.Font.SourceSans; speed.Text = "1"
            speed.TextColor3 = Color3.fromRGB(0,0,0)
            speed.TextScaled = true; speed.TextWrapped = true

            local mine = Instance.new("TextButton")
            mine.Name = "mine"; mine.Parent = Frame
            mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
            mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
            mine.Size = UDim2.new(0, 45, 0, 29)
            mine.Font = Enum.Font.SourceSans; mine.Text = "-"
            mine.TextColor3 = Color3.fromRGB(0,0,0)
            mine.TextScaled = true; mine.TextWrapped = true

            local closebutton = Instance.new("TextButton")
            closebutton.Name = "Close"; closebutton.Parent = Frame
            closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
            closebutton.Font = Enum.Font.SourceSans
            closebutton.Size = UDim2.new(0, 45, 0, 28)
            closebutton.Text = "X"; closebutton.TextSize = 30
            closebutton.Position = UDim2.new(0, 0, -1, 27)

            local mini = Instance.new("TextButton")
            mini.Name = "minimize"; mini.Parent = Frame
            mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
            mini.Font = Enum.Font.SourceSans
            mini.Size = UDim2.new(0, 45, 0, 28)
            mini.Text = "-"; mini.TextSize = 40
            mini.Position = UDim2.new(0, 44, -1, 27)

            local mini2 = Instance.new("TextButton")
            mini2.Name = "minimize2"; mini2.Parent = Frame
            mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
            mini2.Font = Enum.Font.SourceSans
            mini2.Size = UDim2.new(0, 45, 0, 28)
            mini2.Text = "+"; mini2.TextSize = 40
            mini2.Position = UDim2.new(0, 44, -1, 57)
            mini2.Visible = false

            -- ── LÓGICA FLY ──
            local flySpeed = 1
            local flyActive = false
            local tpwalking = false
            local bodyVelocity2 = nil
            local bodyGyro2 = nil
            local flyConn = nil
            local upConn = nil
            local downConn = nil

            local function startFly()
                local char = player.Character
                if not char then return end
                local hum  = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end

                flyActive = true
                hum.PlatformStand = true
                local anim = char:FindFirstChild("Animate")
                if anim then anim.Disabled = true end

                for i = 1, flySpeed do
                    task.spawn(function()
                        tpwalking = true
                        local chr = player.Character
                        local h = chr and chr:FindFirstChild("Humanoid")
                        while tpwalking and chr and h and h.Parent do
                            RunService.Heartbeat:Wait()
                            if h.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(h.MoveDirection)
                            end
                        end
                    end)
                end

                local states = {
                    Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
                    Enum.HumanoidStateType.Flying,   Enum.HumanoidStateType.Freefall,
                    Enum.HumanoidStateType.GettingUp,Enum.HumanoidStateType.Jumping,
                    Enum.HumanoidStateType.Landed,   Enum.HumanoidStateType.Physics,
                    Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
                    Enum.HumanoidStateType.Running,  Enum.HumanoidStateType.RunningNoPhysics,
                    Enum.HumanoidStateType.Seated,   Enum.HumanoidStateType.StrafingNoPhysics,
                    Enum.HumanoidStateType.Swimming,
                }
                for _, s in ipairs(states) do hum:SetStateEnabled(s, false) end
                hum:ChangeState(Enum.HumanoidStateType.Swimming)

                local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if torso then
                    bodyGyro2 = Instance.new("BodyGyro", torso)
                    bodyGyro2.P = 9e4
                    bodyGyro2.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bodyGyro2.CFrame = torso.CFrame

                    bodyVelocity2 = Instance.new("BodyVelocity", torso)
                    bodyVelocity2.Velocity = Vector3.new(0, 0.1, 0)
                    bodyVelocity2.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end

                local ctrl = {f=0,b=0,l=0,r=0}
                local lastctrl = {f=0,b=0,l=0,r=0}
                local maxspeed = 50
                local currentSpeed = 0

                flyConn = RunService.Heartbeat:Connect(function()
                    if not flyActive or not player.Character then return end
                    local t = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
                    if not t or not bodyVelocity2 or not bodyGyro2 then return end

                    ctrl.f = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
                    ctrl.b = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
                    ctrl.r = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                    ctrl.l = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0

                    local mv = ctrl.f + ctrl.b
                    local ms = ctrl.l + ctrl.r

                    if mv ~= 0 or ms ~= 0 then
                        currentSpeed = math.min(currentSpeed + 0.5 + currentSpeed/maxspeed, maxspeed)
                    else
                        currentSpeed = math.max(currentSpeed - 1, 0)
                    end

                    local cam = workspace.CurrentCamera
                    if mv ~= 0 or ms ~= 0 then
                        bodyVelocity2.Velocity = (cam.CFrame.LookVector*mv + cam.CFrame.RightVector*ms) * currentSpeed
                        lastctrl = {f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
                    elseif currentSpeed ~= 0 then
                        bodyVelocity2.Velocity = (cam.CFrame.LookVector*(lastctrl.f+lastctrl.b) + cam.CFrame.RightVector*(lastctrl.l+lastctrl.r)) * currentSpeed
                    else
                        bodyVelocity2.Velocity = Vector3.new(0,0,0)
                    end

                    bodyGyro2.CFrame = cam.CFrame * CFrame.Angles(-math.rad(mv*50*currentSpeed/maxspeed), 0, 0)

                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        bodyVelocity2.Velocity += Vector3.new(0, 30, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        bodyVelocity2.Velocity -= Vector3.new(0, 30, 0)
                    end
                end)
            end

            local function stopFly()
                flyActive = false
                tpwalking = false
                if flyConn then flyConn:Disconnect() flyConn = nil end
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        local states = {
                            Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
                            Enum.HumanoidStateType.Flying,   Enum.HumanoidStateType.Freefall,
                            Enum.HumanoidStateType.GettingUp,Enum.HumanoidStateType.Jumping,
                            Enum.HumanoidStateType.Landed,   Enum.HumanoidStateType.Physics,
                            Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
                            Enum.HumanoidStateType.Running,  Enum.HumanoidStateType.RunningNoPhysics,
                            Enum.HumanoidStateType.Seated,   Enum.HumanoidStateType.StrafingNoPhysics,
                            Enum.HumanoidStateType.Swimming,
                        }
                        for _, s in ipairs(states) do hum:SetStateEnabled(s, true) end
                        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                    end
                    local anim = char:FindFirstChild("Animate")
                    if anim then anim.Disabled = false end
                    if bodyVelocity2 then bodyVelocity2:Destroy() bodyVelocity2 = nil end
                    if bodyGyro2    then bodyGyro2:Destroy()    bodyGyro2    = nil end
                end
            end

            onof.MouseButton1Click:Connect(function()
                if flyActive then
                    stopFly()
                    onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
                    onof.Text = "fly"
                else
                    startFly()
                    onof.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                    onof.Text = "stop"
                end
            end)

            up.MouseButton1Down:Connect(function()
                upConn = RunService.Heartbeat:Connect(function()
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = root.CFrame * CFrame.new(0, 1.5, 0) end
                end)
            end)
            up.MouseButton1Up:Connect(function() if upConn then upConn:Disconnect() upConn = nil end end)
            up.MouseLeave:Connect(function()    if upConn then upConn:Disconnect() upConn = nil end end)

            down.MouseButton1Down:Connect(function()
                downConn = RunService.Heartbeat:Connect(function()
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = root.CFrame * CFrame.new(0, -1.5, 0) end
                end)
            end)
            down.MouseButton1Up:Connect(function() if downConn then downConn:Disconnect() downConn = nil end end)
            down.MouseLeave:Connect(function()    if downConn then downConn:Disconnect() downConn = nil end end)

            plus.MouseButton1Click:Connect(function()
                flySpeed = flySpeed + 1
                speed.Text = tostring(flySpeed)
                if flyActive then stopFly() task.wait(0.1) startFly() end
            end)

            mine.MouseButton1Click:Connect(function()
                if flySpeed > 1 then
                    flySpeed = flySpeed - 1
                    speed.Text = tostring(flySpeed)
                    if flyActive then stopFly() task.wait(0.1) startFly() end
                end
            end)

            closebutton.MouseButton1Click:Connect(function()
                stopFly()
                main:Destroy()
                flyGui = nil
            end)

            mini.MouseButton1Click:Connect(function()
                for _, v in ipairs({up,down,onof,plus,speed,mine,mini}) do v.Visible = false end
                mini2.Visible = true
                Frame.BackgroundTransparency = 1
                closebutton.Position = UDim2.new(0, 0, -1, 57)
            end)

            mini2.MouseButton1Click:Connect(function()
                for _, v in ipairs({up,down,onof,plus,speed,mine,mini}) do v.Visible = true end
                mini2.Visible = false
                Frame.BackgroundTransparency = 0
                closebutton.Position = UDim2.new(0, 0, -1, 27)
            end)

            player.CharacterAdded:Connect(function()
                if flyActive then
                    stopFly()
                    task.wait(0.5)
                    startFly()
                end
            end)
        end)
    else
        -- Desactivar: cerrar la GUI y detener el fly
        if flyGui then
            -- buscar y detener si está volando
            flyGui:Destroy()
            flyGui = nil
        end
    end
end)

addSectionTitle("Config.", movePage, 5)

local sVal = 16
local sAct = false
local setSpeed = addToggleRow("Speed Hack", "Activa la velocidad", movePage, 6, function(on)
    sAct = on
end)

addSliderRow("Velocidad", 16, 500, 16, movePage, 7, function(val)
    sVal = val
end)

-- ============================================================
--  TELEPORT PAGE
-- ============================================================
addSectionTitle("🌊 Sea 2", tpPage, 1)

addTpButton("Barco Maldito", "923, 126, 32852",
    Color3.fromRGB(0, 220, 140), tpPage, 2, function()
    local char = LocalPlayer.Character
    if char then char:PivotTo(CFrame.new(923, 126, 32852)) end
end)

addSectionTitle("🏰 Sea 3", tpPage, 3)

addTpButton("Castillo", "-5085, 316, -3156",
    Color3.fromRGB(123, 136, 255), tpPage, 4, function()
    local char = LocalPlayer.Character
    if char then char:PivotTo(CFrame.new(-5085, 316, -3156)) end
end)

addTpButton("Mansión", "-12463, 375, -7523",
    Color3.fromRGB(255, 170, 68), tpPage, 5, function()
    local char = LocalPlayer.Character
    if char then char:PivotTo(CFrame.new(-12463, 375, -7523)) end
end)

-- ============================================================
--  RUNSERVICE LOOPS
-- ============================================================

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if iJ then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- No Clip
RunService.Stepped:Connect(function()
    if ncl and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if sAct and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(hum.MoveDirection * (sVal / 55))
        end
    end
end)

-- Walk on Water
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if walkWaterEnabled and hrp then
        if hrp.Position.Y >= 9.5 and hrp.Velocity.Y <= 0 then
            local waterPart = workspace:FindFirstChild("RivalsWaterSolid")
            if not waterPart then
                waterPart = Instance.new("Part", workspace)
                waterPart.Name = "RivalsWaterSolid"
                waterPart.Size = Vector3.new(20, 1, 20)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = true
                waterPart.CanQuery = false
            end
            waterPart.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            if workspace:FindFirstChild("RivalsWaterSolid") then
                workspace.RivalsWaterSolid:Destroy()
            end
        end
    else
        if workspace:FindFirstChild("RivalsWaterSolid") then
            workspace.RivalsWaterSolid:Destroy()
        end
    end
end)

-- ============================================================
--  WINDOW CONTROLS
-- ============================================================
local minimized = false
local normalSize = UDim2.new(0, 560, 0, 460)
local miniSize   = UDim2.new(0, 200, 0, 44)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        sidebar.Visible = false
        sidebarLine.Visible = false
        contentFrame.Visible = false
        tween(mainFrame, 0.25, {Size = miniSize})
    else
        tween(mainFrame, 0.25, {Size = normalSize})
        task.wait(0.2)
        sidebar.Visible = true
        sidebarLine.Visible = true
        contentFrame.Visible = true
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    ESPEnabled = false
    ClearESP()
    if workspace:FindFirstChild("RivalsWaterSolid") then
        workspace.RivalsWaterSolid:Destroy()
    end
    tween(mainFrame, 0.2, {BackgroundTransparency = 1})
    task.wait(0.22)
    screenGui:Destroy()
end)

-- ============================================================
--  INIT — mostrar Home
-- ============================================================
showPage("Home")
