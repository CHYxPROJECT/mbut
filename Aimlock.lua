-- ts file was generated at discord.gg/25ms

local _Players = game:GetService('Players')
local _RunService = game:GetService('RunService')
local _LocalPlayer = _Players.LocalPlayer

game.Players.LocalPlayer:GetMouse()

local u4 = false
local u5 = 0.13683333
local v6 = game:GetService('Players').LocalPlayer:GetMouse()
local u7 = true

getgenv().Key = 'q'

game.StarterGui:SetCore('SendNotification', {
    Title = 'PresetsCamlock',
    Text = 'Credits Zatirohood',
})

function FindNearestEnemy()
    local _huge = math.huge
    local v9 = Vector2.new(game:GetService('GuiService'):GetScreenResolution().X / 2, game:GetService('GuiService'):GetScreenResolution().Y / 2)
    local v10, v11, v12 = ipairs(game:GetService('Players'):GetPlayers())
    local v13 = nil

    while true do
        local v14

        v12, v14 = v10(v11, v12)

        if v12 == nil then
            break
        end
        if v14 ~= _LocalPlayer then
            local _Character = v14.Character

            if _Character and (_Character:FindFirstChild('HumanoidRootPart') and _Character.Humanoid.Health > 0) then
                local v16, v17 = game:GetService('Workspace').CurrentCamera:WorldToViewportPoint(_Character.HumanoidRootPart.Position)

                if v17 then
                    local _Magnitude = (v9 - Vector2.new(v16.X, v16.Y)).Magnitude

                    if _Magnitude < _huge then
                        v13 = _Character.HumanoidRootPart
                        _huge = _Magnitude
                    end
                end
            end
        end
    end

    return v13
end

local u19 = nil

_RunService.Heartbeat:Connect(function()
    if u4 == true and u19 then
        local _CurrentCamera = workspace.CurrentCamera

        _CurrentCamera.CFrame = CFrame.new(_CurrentCamera.CFrame.p, u19.Position + u19.Velocity * u5)
    end
end)
v6.KeyDown:Connect(function(p21)
    if p21 == getgenv().Key then
        u7 = not u7

        if u7 then
            u19 = FindNearestEnemy()
            u4 = true
        elseif u19 ~= nil then
            u19 = nil
            u4 = false
        end
    end
end)

local _ScreenGui = Instance.new('ScreenGui')
local _Frame = Instance.new('Frame')
local _UICorner = Instance.new('UICorner')
local _ImageLabel = Instance.new('ImageLabel')
local _TextButton = Instance.new('TextButton')

Instance.new('UICorner')

_ScreenGui.Name = 'PRESETS'
_ScreenGui.Parent = game.CoreGui
_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_Frame.Parent = _ScreenGui
_Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
_Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
_Frame.BorderSizePixel = 0
_Frame.Position = UDim2.new(0.133798108, 0, 0.20107238, 0)
_Frame.Size = UDim2.new(0, 195, 0, 65)
_Frame.Active = true
_Frame.Draggable = true

local function v27()
    _Frame.Position = UDim2.new(0.5, -_Frame.AbsoluteSize.X / 2, 0, -_Frame.AbsoluteSize.Y / 2)
end

v27()

local v28 = _Frame

_Frame.GetPropertyChangedSignal(v28, 'AbsoluteSize'):Connect(v27)

_UICorner.Parent = _Frame
_ImageLabel.Name = 'Logo'
_ImageLabel.Parent = _Frame
_ImageLabel.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
_ImageLabel.BackgroundTransparency = 3
_ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
_ImageLabel.BorderSizePixel = 0
_ImageLabel.Position = UDim2.new(0.326732665, 0, 0, 0)
_ImageLabel.Size = UDim2.new(0, 64, 0, 65)
_ImageLabel.Image = 'rbxassetid://830610397'
_ImageLabel.ImageTransparency = 0.3
_TextButton.Parent = _Frame
_TextButton.BackgroundColor3 = Color3.fromRGB(75, 80, 255)
_TextButton.BackgroundTransparency = 5
_TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
_TextButton.BorderSizePixel = 0
_TextButton.Position = UDim2.new(0.0792079195, 0, 0.18571429, 0)
_TextButton.Size = UDim2.new(0, 170, 0, 44)
_TextButton.Font = Enum.Font.SourceSansSemibold
_TextButton.Text = 'PRESETS'
_TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
_TextButton.TextScaled = true
_TextButton.TextSize = 18
_TextButton.TextWrapped = true

local u29 = true

_TextButton.MouseButton1Click:Connect(function()
    u29 = not u29

    if u29 then
        _TextButton.Text = 'PRESETS OFF'
        u4 = false
        u19 = nil
    else
        _TextButton.Text = 'PRESETS ON'
        u4 = true
        u19 = FindNearestEnemy()
    end
end)

local function v32()
    local v30 = 0

    while true do
        local v31 = v30 + 5

        v30 = v31 > 360 and 0 or v31
        _TextButton.TextColor3 = Color3.fromHSV(v30 / 360, 1, 1)

        wait(0.01)
    end
end

spawn(v32)
