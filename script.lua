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
--  LÓGICA FAST ATTACK
-- ============================================================
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
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

local function StartFastAttack()
    if FastAttackConnection then task.cancel(FastAttackConnection) end
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myChar = LocalPlayer.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
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
if pgui:FindFirstChild("Rivals_Hub") then pgui.Rivals_Hub:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "Rivals_Hub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
    Text = "Rivals",
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
corner(99, iconWrap)
stroke(Color3.fromRGB(110, 80, 220), 2, iconWrap)

local iconImage = Instance.new("ImageLabel", iconWrap)
iconImage.Size = UDim2.new(1, -8, 1, -8)
iconImage.Position = UDim2.new(0, 4, 0, 4)
iconImage.BackgroundTransparency = 1
iconImage.Image = "rbxassetid://80118704620236"
iconImage.ScaleType = Enum.ScaleType.Fit

-- hub name
label({
    Text = "RIVALS",
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
label({Text = "◉  discord.gg/rivals", Font = Enum.Font.GothamSemibold, TextSize = 13,
    TextColor3 = C.accent2, Size = UDim2.new(1,0,1,0),
    TextXAlignment = Enum.TextXAlignment.Center}, discordRow)

discordRow.MouseEnter:Connect(function() tween(discordRow, 0.12, {BackgroundColor3 = Color3.fromRGB(25,25,65)}) end)
discordRow.MouseLeave:Connect(function() tween(discordRow, 0.12, {BackgroundColor3 = Color3.fromRGB(20,20,50)}) end)

-- ============================================================
--  COMBATE PAGE
-- ============================================================
addSectionTitle("Ataque", combatPage, 1)

local setFastAttack = addToggleRow("Fast Attack", "Multi-objetivo · "..FastAttackRange.." studs", combatPage, 2, function(on)
    FastAttackEnabled = on
    if on then
        StartFastAttack()
    else
        if FastAttackConnection then task.cancel(FastAttackConnection) end
    end
end)

local setHitbox = addToggleRow("Hitbox Expand", "2048 studs", combatPage, 3, function(on)
    -- lógica hitbox (agregar aquí)
end)

addSectionTitle("Config.", combatPage, 4)

addSliderRow("Attack Range", 100, 9999, 5000, combatPage, 5, function(val)
    FastAttackRange = val
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

-- ============================================================
--  MOVIMIENTO PAGE
-- ============================================================
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

addSectionTitle("Config.", movePage, 5)

local sVal = 16
local sAct = false
addSliderRow("Velocidad", 16, 500, 16, movePage, 6, function(val)
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
