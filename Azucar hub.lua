# Azucar hub  
  
-- -- Azúcar Hub 🍭 - ESP FIXED & KILL FLASH INDEPENDIENTE  
local Success, Rayfield = pcall(function()  
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()  
end)  
  
if not Success or not Rayfield then return end  
  
-- ==========================================  
-- VARIABLES GLOBALES  
-- ==========================================  
getgenv().SelectedPlayers = {}   
getgenv().TrackingActive = false  
getgenv().KillTrackerActive = false   
getgenv().EspActive = false  
getgenv().AutoEscapeEnabled = true  
getgenv().AntiV4 = false  
getgenv().FullBright = false  
getgenv().AntiPerrasActive = false  
getgenv().OrbitDistance = 5  
getgenv().Height = 2  
getgenv().FastAttackEnabled = false  
getgenv().TargetMode = "None"   
getgenv().FastAttackRange = 1200  
getgenv().StayTime = 0.3  
getgenv().TrackerHeight = 300   
getgenv().TweenSpeed = 350  
getgenv().TweenTracking = false  
getgenv().AutoAwakening = false  
  
local lp = game.Players.LocalPlayer  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local TweenService = game:GetService("TweenService")  
local RunService = game:GetService("RunService")  
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")  
local RegisterHit = Net["RE/RegisterHit"]  
local RegisterAttack = Net["RE/RegisterAttack"]  
  
local rot = 0  
local v4Connection = nil  
  
-- ==========================================  
-- SISTEMA ESP 🌸  
-- ==========================================  
local function CreateESP(plr)  
    local NameTag = Drawing.new("Text")  
    NameTag.Visible = false  
    NameTag.Center = true  
    NameTag.Outline = true  
    NameTag.Font = 2  
    NameTag.Size = 14  
    NameTag.Color = Color3.fromRGB(255, 20, 147)  
  
    local connection  
    connection = RunService.RenderStepped:Connect(function()  
        if getgenv().EspActive and plr and plr.Parent and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= lp then  
            local hrp = plr.Character.HumanoidRootPart  
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))  
              
            if onScreen then  
                local dist = (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude  
                NameTag.Position = Vector2.new(pos.X, pos.Y)  
                NameTag.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"  
                NameTag.Visible = true  
            else  
                NameTag.Visible = false  
            end  
        else  
            NameTag.Visible = false  
            if not plr or not plr.Parent then  
                NameTag:Remove()  
                connection:Disconnect()  
            end  
        end  
    end)  
end  
  
for _, v in pairs(game.Players:GetPlayers()) do CreateESP(v) end  
game.Players.PlayerAdded:Connect(CreateESP)  
  
-- ==========================================  
-- LÓGICA DE ATAQUE ⚔️  
-- ==========================================  
local function AttackMultipleTargets(targets)  
    pcall(function()  
        if not targets or #targets == 0 then return end  
        local allTargets = {}  
        for _, targetChar in pairs(targets) do  
            local head = targetChar:FindFirstChild("Head")  
            if head then table.insert(allTargets, { targetChar, head }) end  
        end  
        RegisterAttack:FireServer(0)  
        local hitArgs = {allTargets[1][2], allTargets}  
        RegisterHit:FireServer(unpack(hitArgs))  
    end)  
end  
  
local function StartFastAttack()  
    task.spawn(function()  
        while getgenv().FastAttackEnabled do  
            task.wait(0.01)  
            local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")  
            if not myHRP then continue end  
            local targetsInRange = {}  
  
            if getgenv().TargetMode == "NPCsPlayers" then  
                for _, player in pairs(game.Players:GetPlayers()) do  
                    if player ~= lp and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then  
                        if (player.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude <= getgenv().FastAttackRange then  
                            table.insert(targetsInRange, player.Character)  
                        end  
                    end  
                end  
            end  
  
            local enemiesFolder = workspace:FindFirstChild("Enemies")  
            if enemiesFolder then  
                for _, npc in pairs(enemiesFolder:GetChildren()) do  
                    if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then  
                        if (npc.HumanoidRootPart.Position - myHRP.Position).Magnitude <= getgenv().FastAttackRange then  
                            table.insert(targetsInRange, npc)  
                        end  
                    end  
                end  
            end  
            if #targetsInRange > 0 then AttackMultipleTargets(targetsInRange) end  
        end  
    end)  
end  
  
-- ==========================================  
-- INTERFAZ  
-- ==========================================  
local Window = Rayfield:CreateWindow({  
   Name = "Azúcar Hub 🍭",  
   LoadingTitle = "Azúcar Hub 🍭 | Samuel",  
   LoadingSubtitle = "Preparando Script...",  
   ConfigurationSaving = { Enabled = false }  
})  
  
-- --- COMBATE ⚔️ ---  
local CombatTab = Window:CreateTab("Combate ⚔️", 4483362458)  
  
CombatTab:CreateSection("SELECCIÓN DE VÍCTIMAS 🎯")  
local PlayerDropdown = CombatTab:CreateDropdown({  
    Name = "Elegir Jugadores",  
    Options = (function()   
        local n = {}   
        for _,v in pairs(game.Players:GetPlayers()) do if v ~= lp then table.insert(n, v.Name) end end   
        return n   
    end)(),  
    CurrentOption = {},  
    MultipleOptions = true,  
    Callback = function(Options)   
        getgenv().SelectedPlayers = {}  
        for _, name in pairs(Options) do  
            local p = game.Players:FindFirstChild(name)  
            if p then table.insert(getgenv().SelectedPlayers, p) end  
        end  
    end,  
})  
  
CombatTab:CreateButton({ Name = "Refrescar Lista 🔄", Callback = function()   
    local n = {} for _,v in pairs(game.Players:GetPlayers()) do if v ~= lp then table.insert(n, v.Name) end end   
    PlayerDropdown:Refresh(n)   
end })  
  
CombatTab:CreateSection("BOTÓN INDEPENDIENTE 💀")  
CombatTab:CreateToggle({   
    Name = "ACTIVAR KILL FLASH ⚡⚔️",   
    CurrentValue = false,   
    Callback = function(V) getgenv().KillTrackerActive = V end   
})  
  
CombatTab:CreateSection("OTROS TPS & TRACKERS")  
CombatTab:CreateToggle({ Name = "Tracker Aéreo 🛰️", CurrentValue = false, Callback = function(V) getgenv().TrackingActive = V end })  
CombatTab:CreateToggle({ Name = "Anti-Perras (Orbit) 🐩", CurrentValue = false, Callback = function(V) getgenv().AntiPerrasActive = V end })  
CombatTab:CreateSlider({ Name = "Distancia Orbit 🚀", Range = {2, 50}, Increment = 1, CurrentValue = 5, Callback = function(V) getgenv().OrbitDistance = V end })  
CombatTab:CreateToggle({ Name = "Tween TP Seguimiento 🚀", CurrentValue = false, Callback = function(V) getgenv().TweenTracking = V end })  
CombatTab:CreateSlider({ Name = "Altura Tracker 🏔️", Range = {2, 1000}, Increment = 10, CurrentValue = 300, Callback = function(V) getgenv().TrackerHeight = V; getgenv().Height = V end })  
  
-- --- AUTO V4 🌟 ---  
local V4Tab = Window:CreateTab("Auto V4 🌟", 4483362458)  
V4Tab:CreateToggle({  
   Name = "Auto Awakening (V4)",  
   CurrentValue = false,  
   Callback = function(Value)  
      getgenv().AutoAwakening = Value  
      if getgenv().AutoAwakening then  
         if v4Connection then task.cancel(v4Connection) end  
         v4Connection = task.spawn(function()  
            while getgenv().AutoAwakening do  
               task.wait(0.5)  
               local tool = lp.Backpack:FindFirstChild("Awakening") or lp.Character:FindFirstChild("Awakening")  
               if tool and tool:FindFirstChild("RemoteFunction") then  
                  tool.RemoteFunction:InvokeServer(true)  
               end  
            end  
         end)  
      else  
         if v4Connection then task.cancel(v4Connection); v4Connection = nil end  
      end  
   end,  
})  
  
-- --- FAST ATTACKS ⚡ ---  
local FastTab = Window:CreateTab("Fast Attacks ⚡", 4483362458)  
FastTab:CreateToggle({ Name = "Only NPCs 🤖", CurrentValue = false, Callback = function(V) getgenv().FastAttackEnabled = V; getgenv().TargetMode = "OnlyNPCs"; if V then StartFastAttack() end end })  
FastTab:CreateToggle({ Name = "NPCs + Players 👥", CurrentValue = false, Callback = function(V) getgenv().FastAttackEnabled = V; getgenv().TargetMode = "NPCsPlayers"; if V then StartFastAttack() end end })  
  
-- --- SEGURIDAD 🛡️ ---  
local SafetyTab = Window:CreateTab("Seguridad 🛡️", 4483362458)  
SafetyTab:CreateSection("PROTECCIÓN")  
SafetyTab:CreateButton({  
    Name = "Activar Anti-Kick 🚫",  
    Callback = function()  
        local mt = getrawmetatable(game)  
        setreadonly(mt, false)  
        local old = mt.__namecall  
        mt.__namecall = newcclosure(function(self, ...)  
            if getnamecallmethod() == "Kick" then return nil end  
            return old(self, ...)  
        end)  
        Rayfield:Notify({Title = "Seguridad", Content = "Anti-Kick Activado", Duration = 3})  
    end  
})  
  
SafetyTab:CreateButton({  
   Name = "Activar Anti-AFK 💤",  
   Callback = function()  
       local vu = game:GetService("VirtualUser")  
       lp.Idled:Connect(function()  
           vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)  
           task.wait(1)  
           vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)  
       end)  
       Rayfield:Notify({Title = "Seguridad", Content = "Anti-AFK Activado", Duration = 3})  
   end,  
})  
  
-- --- MISC 🌀 ---  
local MiscTab = Window:CreateTab("Misc 🌀", 4483362458)  
MiscTab:CreateSection("VISUALES & FLY")  
MiscTab:CreateToggle({ Name = "ESP Rosa 🌸", CurrentValue = false, Callback = function(V) getgenv().EspActive = V end })  
MiscTab:CreateToggle({ Name = "Modo Invisible 👻", CurrentValue = false, Callback = function(V) if V and lp.Character:FindFirstChild("LowerTorso") then lp.Character.LowerTorso.Root:Destroy() end end })  
MiscTab:CreateButton({ Name = "Fly V3 ✈️", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end })  
  
-- --- FLAGS 🚩 ---  
local FlagsTab = Window:CreateTab("Flags 🚩", 4483362458)  
FlagsTab:CreateButton({ Name = "Modo Plástico 🧱", Callback = function() for i,v in pairs(game:GetDescendants()) do if v:IsA("Part") then v.Material = Enum.Material.SmoothPlastic end end end })  
FlagsTab:CreateToggle({ Name = "Anti-V4 🌟", CurrentValue = false, Callback = function(V) getgenv().AntiV4 = V end })  
FlagsTab:CreateToggle({ Name = "Full Bright ☀️", CurrentValue = false, Callback = function(V) getgenv().FullBright = V end })  
  
-- ==========================================  
-- BUCLE DE FONDO (REPARADO Y OPTIMIZADO)  
-- ==========================================  
task.spawn(function()  
    while true do  
        task.wait(0.01)  
        pcall(function()  
            local char = lp.Character  
            local root = char and char:FindFirstChild("HumanoidRootPart")  
            if not root then return end  
              
            local target = getgenv().SelectedPlayers[1]  
  
            -- Prioridad 1: Tween (Movimiento Suave)  
            if getgenv().TweenTracking and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then  
                local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, getgenv().TrackerHeight, 0)  
                local dist = (root.Position - targetPos).Magnitude  
                TweenService:Create(root, TweenInfo.new(dist/getgenv().TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)}):Play()  
              
            -- Prioridad 2: Orbit (Anti-Perras)  
            elseif getgenv().AntiPerrasActive and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then  
                rot = rot + 0.15  
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, rot, 0) * CFrame.new(getgenv().OrbitDistance, getgenv().Height, 0)  
              
            -- Prioridad 3: Kill Flash (Salto entre objetivos)  
            elseif getgenv().KillTrackerActive and #getgenv().SelectedPlayers > 0 then  
                for _, t in pairs(getgenv().SelectedPlayers) do  
                    if t.Character and t.Character:FindFirstChild("Humanoid") and t.Character.Humanoid.Health > 0 then  
                        root.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().TrackerHeight, 0)  
                        task.wait(0.15)  
                        root.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)  
                        task.wait(getgenv().StayTime)  
                    end  
                end  
              
            -- Prioridad 4: Tracker Aéreo Simple  
            elseif getgenv().TrackingActive and target and target.Character then  
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().TrackerHeight, 0)  
            end  
  
            -- Visuales Globales  
            if getgenv().FullBright then  
                game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)  
                game.Lighting.ClockTime = 14  
                game.Lighting.FogEnd = 9e9  
            end  
        end)  
    end  
end)  
  
Rayfield:Notify({Title = "Azúcar Hub 🍭", Content = "Auto V4 Integrado y Hub Reparado", Duration = 3})  
