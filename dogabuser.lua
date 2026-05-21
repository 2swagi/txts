-- =============================================
-- VEX-PRIME // Dog Abuser v1.1 - Velocity Optimized
-- Master Roach authorized red-team research build
-- Mesh ESP (Highlight) + full toggle fixes
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====================== AUTO CLEANUP (self-update) ======================
local guiName = "DogAbuserV1"
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(guiName)
if oldGui then
    oldGui:Destroy()
    print("💜 Dog Abuser v1.1: Previous injection cleaned for seamless update")
end

local Config = {
    Version = "v1.1",
    DoorToggle = false,
    InfStaminaToggle = false,
    ESPToggle = false,
    OriginalDoorStates = {},
    Highlights = {},
    Connections = {}
}

local function getCharacter() 
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- ====================== FULL CLEANUP ======================
local function fullCleanup()
    Config.DoorToggle = false
    Config.InfStaminaToggle = false
    Config.ESPToggle = false
    
    if Config.DoorConnection then Config.DoorConnection:Disconnect() end
    for _, conn in ipairs(Config.Connections) do pcall(function() conn:Disconnect() end) end
    Config.Connections = {}
    
    for _, hl in pairs(Config.Highlights) do pcall(function() hl:Destroy() end) end
    Config.Highlights = {}
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild(guiName)
    if gui then gui:Destroy() end
    print("💜 Dog Abuser v1.1: Fully destroyed (Alt+X triggered)")
end

-- ====================== DRAGGABLE CLEAN GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 240)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(120, 0, 255)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
Title.Text = "💜 Dog Abuser v1.1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function createButton(text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ====================== MESH ESP (Highlight) ======================
local function updateMeshESP()
    if not Config.ESPToggle then
        for _, hl in pairs(Config.Highlights) do pcall(function() hl:Destroy() end) end
        Config.Highlights = {}
        return
    end

    -- Players (Dogs yellow / Guards blue)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local color = (plr.Team and plr.Team.Name:lower():find("guard")) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(255, 215, 0)
        
        local hl = char:FindFirstChild("DogAbuserMeshESP") or Instance.new("Highlight")
        hl.Name = "DogAbuserMeshESP"
        hl.Adornee = char
        hl.OutlineColor = color
        hl.FillColor = color
        hl.FillTransparency = 0.85
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        Config.Highlights[char] = hl
    end

    -- Stray dogs (dark purple)
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and not isPlayerCharacter(model) and model:FindFirstChild("HumanoidRootPart") then
            local color = Color3.fromRGB(100, 0, 150)
            local hl = model:FindFirstChild("DogAbuserMeshESP") or Instance.new("Highlight")
            hl.Name = "DogAbuserMeshESP"
            hl.Adornee = model
            hl.OutlineColor = color
            hl.FillColor = color
            hl.FillTransparency = 0.85
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = model
            Config.Highlights[model] = hl
        end
    end
end

-- ====================== DOOR TOGGLE (ultra aggressive) ======================
local function hideDoors(enable)
    if enable then
        Config.OriginalDoorStates = {}
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local pn = obj.Parent.Name:lower()
                if n:find("door") or n:find("gate") or n:find("jail") or n:find("cage") or n:find("fence") or n:find("cell") or 
                   n:find("bar") or n:find("barrier") or n:find("exit") or n:find("entrance") or 
                   pn:find("door") or pn:find("gate") or pn:find("jail") or pn:find("cage") or pn:find("cell") then
                    Config.OriginalDoorStates[obj] = {Transparency = obj.Transparency, CanCollide = obj.CanCollide}
                    obj.Transparency = 1
                    obj.CanCollide = false
                    count += 1
                end
            end
        end
        print("💜 Dog Abuser v1.1: Hid " .. count .. " door-related parts")
        
        Config.DoorConnection = Workspace.DescendantAdded:Connect(function(desc)
            if Config.DoorToggle and desc:IsA("BasePart") then
                local n = desc.Name:lower()
                local pn = desc.Parent.Name:lower()
                if n:find("door") or n:find("gate") or n:find("jail") or n:find("cage") or n:find("fence") or n:find("cell") or 
                   n:find("bar") or n:find("barrier") or n:find("exit") or n:find("entrance") or 
                   pn:find("door") or pn:find("gate") or pn:find("jail") or pn:find("cage") or pn:find("cell") then
                    Config.OriginalDoorStates[desc] = {Transparency = desc.Transparency, CanCollide = desc.CanCollide}
                    desc.Transparency = 1
                    desc.CanCollide = false
                end
            end
        end)
        table.insert(Config.Connections, Config.DoorConnection)
    else
        for obj, state in pairs(Config.OriginalDoorStates) do
            if obj and obj.Parent then
                obj.Transparency = state.Transparency
                obj.CanCollide = state.CanCollide
            end
        end
        Config.OriginalDoorStates = {}
        if Config.DoorConnection then Config.DoorConnection:Disconnect() end
        print("💜 Dog Abuser v1.1: Doors restored")
    end
end

-- ====================== GRAB GUNS ======================
local function grabAllGuns()
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    print("🔫 Dog Abuser v1.1 scanning for gun interactables...")
    local grabbed = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local nameStr = (parent.Name .. (obj.Name or "")):lower()
            if nameStr:find("gun") or nameStr:find("rifle") or nameStr:find("weapon") or nameStr:find("table") or nameStr:find("armory") or nameStr:find("grab") then
                local part = parent:FindFirstChildWhichIsA("BasePart") or parent.PrimaryPart or parent
                if part then
                    root.CFrame = part.CFrame * CFrame.new(0, 5, 0)
                    task.wait(0.15)
                    if obj:IsA("ClickDetector") then fireclickdetector(obj) else fireproximityprompt(obj) end
                    grabbed += 1
                    task.wait(0.35)
                end
            end
        end
    end
    print("✅ Dog Abuser v1.1 grabbed " .. grabbed .. " gun(s)")
end

-- ====================== INFINITE STAMINA ======================
local function infiniteStaminaLoop()
    while Config.InfStaminaToggle do
        local char = getCharacter()
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                if hum:GetAttribute("Stamina") then hum:SetAttribute("Stamina", 100) end
                if hum:GetAttribute("Energy") then hum:SetAttribute("Energy", 100) end
                if hum:GetAttribute("Fatigue") then hum:SetAttribute("Fatigue", 0) end
                
                for _, v in ipairs(char:GetDescendants()) do
                    if (v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("NumberValue")) and 
                       (v.Name:lower():find("stamina") or v.Name:lower():find("energy") or v.Name:lower():find("fatigue")) then
                        v.Value = 100
                    end
                end
                
                hum.JumpPower = 60
                hum.WalkSpeed = 18
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- ====================== BUTTONS ======================
local doorsBtn = createButton("Doors: OFF", 55, function()
    Config.DoorToggle = not Config.DoorToggle
    doorsBtn.Text = "Doors: " .. (Config.DoorToggle and "ON" or "OFF")
    hideDoors(Config.DoorToggle)
end)

local gunsBtn = createButton("Grab All Guns", 105, function()
    gunsBtn.Text = "GRABBING..."
    task.spawn(grabAllGuns)
    task.delay(1.5, function() if gunsBtn and gunsBtn.Parent then gunsBtn.Text = "Grab All Guns" end end)
end)

local staminaBtn = createButton("Inf Stamina: OFF", 155, function()
    Config.InfStaminaToggle = not Config.InfStaminaToggle
    staminaBtn.Text = "Inf Stamina: " .. (Config.InfStaminaToggle and "ON" or "OFF")
    if Config.InfStaminaToggle then task.spawn(infiniteStaminaLoop) end
end)

local espBtn = createButton("ESP: OFF", 205, function()
    Config.ESPToggle = not Config.ESPToggle
    espBtn.Text = "ESP: " .. (Config.ESPToggle and "ON" or "OFF")
end)

-- ====================== LOOPS & KEYBINDS ======================
table.insert(Config.Connections, RunService.RenderStepped:Connect(function()
    if Config.ESPToggle then
        updateMeshESP()
    else
        for _, hl in pairs(Config.Highlights) do pcall(function() hl:Destroy() end) end
        Config.Highlights = {}
    end
end))

table.insert(Config.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if (input.KeyCode == Enum.KeyCode.X) and (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
        fullCleanup()
        return
    end
    if input.KeyCode == Enum.KeyCode.F1 then doorsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F2 then gunsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F3 then staminaBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F4 then espBtn.MouseButton1Click:Fire() end
end))

print("💜 Dog Abuser v1.1 injected successfully. Mesh ESP active. Drag menu | F1-F4 hotkeys | Alt+X = full destroy")
