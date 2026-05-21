-- =============================================
-- VEX-PRIME // Dog Abuser v1 - Velocity Optimized
-- Master Roach authorized red-team research build
-- Auto self-update + Alt+X full destroy
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
    print("💜 Dog Abuser v1: Previous injection cleaned for seamless update")
end

local Config = {
    Version = "v1",
    DoorToggle = false,
    InfStaminaToggle = false,
    ESPToggle = false,
    OriginalDoorStates = {},
    ESPObjects = {},
    Keybinds = { Doors = Enum.KeyCode.F1, Guns = Enum.KeyCode.F2, Stamina = Enum.KeyCode.F3, ESP = Enum.KeyCode.F4 },
    Connections = {}
}

local function getCharacter() 
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- ====================== FULL CLEANUP FUNCTION ======================
local function fullCleanup()
    Config.DoorToggle = false
    Config.InfStaminaToggle = false
    Config.ESPToggle = false
    
    if Config.DoorConnection then
        Config.DoorConnection:Disconnect()
        Config.DoorConnection = nil
    end
    
    for _, conn in ipairs(Config.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Config.Connections = {}
    
    for _, drawing in pairs(Config.ESPObjects) do
        pcall(function() drawing:Remove() end)
    end
    Config.ESPObjects = {}
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild(guiName)
    if gui then gui:Destroy() end
    
    print("💜 Dog Abuser v1: Fully destroyed (Alt+X triggered)")
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

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(120, 0, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
Title.Text = "💜 Dog Abuser v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

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

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(80, 80, 100)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ====================== DOOR TOGGLE ======================
local function hideDoors(enable)
    if enable then
        Config.OriginalDoorStates = {}
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local pn = obj.Parent.Name:lower()
                if n:find("door") or n:find("gate") or n:find("jail") or n:find("cage") or n:find("fence") or 
                   n:find("cell") or n:find("bar") or n:find("barrier") or 
                   pn:find("door") or pn:find("gate") or pn:find("cage") or pn:find("jail") then
                    Config.OriginalDoorStates[obj] = {Transparency = obj.Transparency, CanCollide = obj.CanCollide}
                    obj.Transparency = 1
                    obj.CanCollide = false
                    count += 1
                end
            end
        end
        print("💜 Dog Abuser v1: Hid " .. count .. " door-related parts")
        
        Config.DoorConnection = Workspace.DescendantAdded:Connect(function(desc)
            if Config.DoorToggle and desc:IsA("BasePart") then
                local n = desc.Name:lower()
                local pn = desc.Parent.Name:lower()
                if n:find("door") or n:find("gate") or n:find("jail") or n:find("cage") or n:find("fence") or 
                   n:find("cell") or n:find("bar") or n:find("barrier") or 
                   pn:find("door") or pn:find("gate") or pn:find("cage") or pn:find("jail") then
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
        print("💜 Dog Abuser v1: Doors restored")
    end
end

-- ====================== GRAB GUNS ======================
local function grabAllGuns()
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    print("🔫 Dog Abuser v1 scanning for gun interactables...")
    local grabbed = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local nameStr = (parent.Name .. (obj.Name or "")):lower()
            if nameStr:find("gun") or nameStr:find("rifle") or nameStr:find("weapon") or nameStr:find("table") or nameStr:find("armory") then
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
    print("✅ Dog Abuser v1 grabbed " .. grabbed .. " gun(s)")
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
                
                for _, v in ipairs(char:GetChildren()) do
                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("stamina") or v.Name:lower():find("energy") or v.Name:lower():find("fatigue")) then
                        v.Value = 100
                    end
                end
                
                hum.JumpPower = 60
                hum.WalkSpeed = 16
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- ====================== ESP (clean tight boxes) ======================
local function createOrUpdateESP()
    if not Config.ESPToggle then return end

    for _, drawing in pairs(Config.ESPObjects) do
        drawing.Visible = false
    end

    -- Players (Dogs yellow / Guards blue)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then continue end

        local root = char.HumanoidRootPart
        local head = char.Head
        local rootPos = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        
        if rootPos.Z > 0 then
            local height = math.abs(headPos.Y - legPos.Y) * 1.1
            local width = height * 0.65

            local teamColor = plr.Team and plr.Team.Name:lower():find("guard") and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(255, 215, 0)

            local boxKey = plr.Name .. "_box"
            if not Config.ESPObjects[boxKey] then
                Config.ESPObjects[boxKey] = Drawing.new("Square")
                Config.ESPObjects[boxKey].Thickness = 2
                Config.ESPObjects[boxKey].Filled = false
            end
            local box = Config.ESPObjects[boxKey]
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
            box.Color = teamColor
            box.Visible = true

            local nameKey = plr.Name .. "_name"
            if not Config.ESPObjects[nameKey] then
                Config.ESPObjects[nameKey] = Drawing.new("Text")
                Config.ESPObjects[nameKey].Size = 15
                Config.ESPObjects[nameKey].Center = true
                Config.ESPObjects[nameKey].Outline = true
            end
            local nameDraw = Config.ESPObjects[nameKey]
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            nameDraw.Text = plr.Name .. " [" .. math.floor(distance) .. "m]"
            nameDraw.Position = Vector2.new(rootPos.X, headPos.Y + height + 2)
            nameDraw.Color = teamColor
            nameDraw.Visible = true
        end
    end

    -- Stray dogs (dark purple)
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and not isPlayerCharacter(model) and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Head") then
            local root = model.HumanoidRootPart
            local head = model.Head
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if rootPos.Z > 0 then
                local height = math.abs(headPos.Y - legPos.Y) * 1.1
                local width = height * 0.65

                local boxKey = model.Name .. "_box"
                if not Config.ESPObjects[boxKey] then
                    Config.ESPObjects[boxKey] = Drawing.new("Square")
                    Config.ESPObjects[boxKey].Thickness = 2
                    Config.ESPObjects[boxKey].Filled = false
                end
                local box = Config.ESPObjects[boxKey]
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
                box.Color = Color3.fromRGB(100, 0, 150)
                box.Visible = true

                local nameKey = model.Name .. "_name"
                if not Config.ESPObjects[nameKey] then
                    Config.ESPObjects[nameKey] = Drawing.new("Text")
                    Config.ESPObjects[nameKey].Size = 14
                    Config.ESPObjects[nameKey].Center = true
                    Config.ESPObjects[nameKey].Outline = true
                end
                local nameDraw = Config.ESPObjects[nameKey]
                local distance = (root.Position - Camera.CFrame.Position).Magnitude
                nameDraw.Text = "Stray Dog [" .. math.floor(distance) .. "m]"
                nameDraw.Position = Vector2.new(rootPos.X, headPos.Y + height + 2)
                nameDraw.Color = Color3.fromRGB(100, 0, 150)
                nameDraw.Visible = true
            end
        end
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
    task.delay(1.5, function() if gunsBtn then gunsBtn.Text = "Grab All Guns" end end)
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
        createOrUpdateESP()
    else
        for _, drawing in pairs(Config.ESPObjects) do drawing.Visible = false end
    end
end))

table.insert(Config.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Alt + X full destroy
    if (input.KeyCode == Enum.KeyCode.X) and (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
        fullCleanup()
        return
    end
    
    if input.KeyCode == Config.Keybinds.Doors then doorsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.Guns then gunsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.Stamina then staminaBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.ESP then espBtn.MouseButton1Click:Fire() end
end))

print("💜 Dog Abuser v1 injected successfully. Drag menu | F1-F4 hotkeys | Alt+X = full destroy")
