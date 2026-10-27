-- BINTANGHUB — Violence District (Halloween Update)
-- Delta Executor / Synapse compatible
-- Skillcheck: Normal Timing | ESP: Survivor, Killer, Generator, Pumpkin, Trap

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    ESP_Survivor = false,
    ESP_Killer = false,
    ESP_Gen = false,
    ESP_Pumpkin = false,
    ESP_Trap = false,
    Fullbright = false,
    NoShadow = false,
    Speed = false,
    NoClip = false,
    AutoSkillcheck = false,
    SpeedValue = 25
}

-- ==========================================
-- UI CREATION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BINTANGHUB_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 480)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
Title.Text = "BINTANGHUB | HALLOWEEN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local function CreateToggle(name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 210, 0, 30)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(35, 35, 35)
        callback(state)
    end)
    return btn
end

CreateToggle("ESP Survivor", 50, function(s) Config.ESP_Survivor = s end)
CreateToggle("ESP Killer", 90, function(s) Config.ESP_Killer = s end)
CreateToggle("ESP Generator", 130, function(s) Config.ESP_Gen = s end)
CreateToggle("ESP Pumpkin (Labu)", 170, function(s) Config.ESP_Pumpkin = s end)
CreateToggle("ESP Trap", 210, function(s) Config.ESP_Trap = s end)
CreateToggle("Fullbright", 250, function(s) Config.Fullbright = s end)
CreateToggle("No Shadow", 290, function(s) Config.NoShadow = s end)
CreateToggle("Speed Hack", 330, function(s) Config.Speed = s end)
CreateToggle("No Clip", 370, function(s) Config.NoClip = s end)
CreateToggle("Auto Skillcheck", 410, function(s) Config.AutoSkillcheck = s end)

-- ==========================================
-- ESP SYSTEM
-- ==========================================
local espObjects = {}

local function CreateESPObject()
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Filled = false
    box.Visible = false
    
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Visible = false
    
    return {box = box, text = text}
end

local function CleanupESP()
    for _, obj in pairs(espObjects) do
        if obj.box then obj.box:Remove() end
        if obj.text then obj.text:Remove() end
    end
    espObjects = {}
end

local function UpdateESP()
    -- ESP Players (Survivor & Killer)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    if not espObjects[plr] then
                        espObjects[plr] = CreateESPObject()
                    end
                    local esp = espObjects[plr]
                    
                    local isKiller = char:FindFirstChildOfClass("Tool") ~= nil
                    
                    if (isKiller and Config.ESP_Killer) or (not isKiller and Config.ESP_Survivor) then
                        local vec, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            local height = 1000 / dist
                            local width = height / 2
                            
                            esp.box.Size = Vector2.new(width, height)
                            esp.box.Position = Vector2.new(vec.X - width/2, vec.Y - height/2)
                            esp.box.Color = isKiller and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(255, 50, 50)
                            esp.box.Visible = true
                            
                            esp.text.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
                            esp.text.Position = Vector2.new(vec.X, vec.Y - height/2 - 16)
                            esp.text.Color = isKiller and Color3.fromRGB(200, 100, 255) or Color3.fromRGB(255, 100, 100)
                            esp.text.Visible = true
                        else
                            esp.box.Visible = false
                            esp.text.Visible = false
                        end
                    else
                        esp.box.Visible = false
                        esp.text.Visible = false
                    end
                end
            end
        end
    end

    -- ESP Objects (Generator, Pumpkin, Trap)
    for _, obj in pairs(workspace:GetDescendants()) do
        local isGen = Config.ESP_Gen and (obj.Name:lower():find("generator") or obj.Name:lower():find("gen"))
        local isPumpkin = Config.ESP_Pumpkin and (obj.Name:lower():find("pumpkin") or obj.Name:lower():find("labu") or obj.Name:lower():find("halloween"))
        local isTrap = Config.ESP_Trap and (obj.Name:lower():find("trap") or obj.Name:lower():find("beartrap"))
        
        if isGen or isPumpkin or isTrap then
            if not espObjects[obj] then
                espObjects[obj] = CreateESPObject()
            end
            local esp = espObjects[obj]
            
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart.Position or obj:GetPivot().Position) or obj.Position
                local vec, onScreen = Camera:WorldToViewportPoint(pos)
                
                if onScreen then
                    esp.text.Text = isGen and "[ GEN ]" or (isPumpkin and "[ LABU ]" or "[ TRAP ]")
                    esp.text.Position = Vector2.new(vec.X, vec.Y)
                    
                    if isGen then esp.text.Color = Color3.fromRGB(0, 255, 0)
                    elseif isPumpkin then esp.text.Color = Color3.fromRGB(255, 165, 0)
                    else esp.text.Color = Color3.fromRGB(255, 0, 0) end
                    
                    esp.text.Visible = true
                    esp.box.Visible = false
                else
                    esp.text.Visible = false
                end
            end
        else
            if espObjects[obj] then
                espObjects[obj].text.Visible = false
                espObjects[obj].box.Visible = false
            end
        end
    end
end

-- ==========================================
-- CHARACTER LOGIC (Speed, NoClip, Fullbright, NoShadow)
-- ==========================================
local function CharacterLoop()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = Config.Speed and Config.SpeedValue or 16
        end
        
        if Config.NoClip then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    if Config.Fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end

    if Config.NoShadow then
        Lighting.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.CastShadow = false end
        end
    end
end

-- ==========================================
-- AUTO SKILLCHECK (Normal Timing)
-- ==========================================
local function InitAutoSkillcheck()
    local vim = game:GetService("VirtualInputManager")
    
    for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote.OnClientEvent:Connect(function(...)
                    if not Config.AutoSkillcheck then return end
                    local args = {...}
                    for _, arg in pairs(args) do
                        if type(arg) == "string" and (arg:lower():find("skill") or arg:lower():find("hit")) then
                            task.wait(0.15) 
                            vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.08)
                            vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end
                    end
                end)
            end)
        end
    end
end

-- ==========================================
-- MAIN LOOPS
-- ==========================================
RunService.RenderStepped:Connect(UpdateESP)

task.spawn(function()
    while task.wait(0.1) do
        CharacterLoop()
    end
end)

InitAutoSkillcheck()
LocalPlayer.CharacterAdded:Connect(function()
    CleanupESP()
    task.wait(1)
    InitAutoSkillcheck()
end)

print("[BINTANGHUB] Loaded. Happy Halloween.")
