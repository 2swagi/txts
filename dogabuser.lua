-- =============================================
-- VEX-PRIME // Dog Pound Exploit Script
-- Master Roach authorized red-team research build
-- Fully client-side, no server interaction
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====================== CONFIG ======================
local Config = {
    DoorToggle = false,
    InfStaminaToggle = false,
    ESPToggle = false,
    OriginalDoorStates = {},          -- cache for toggle restore
    ESPObjects = {},                  -- Drawing cache
    Keybinds = {
        Doors = Enum.KeyCode.F1,
        Guns = Enum.KeyCode.F2,
        Stamina = Enum.KeyCode.F3,
        ESP = Enum.KeyCode.F4,
    }
}

-- ====================== UTILITIES ======================
local function getCharacter() 
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- ====================== DOOR TOGGLE (client-side hide) ======================
local function hideDoors(enable)
    if enable then
        Config.OriginalDoorStates = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate") or obj.Parent.Name:lower():find("door")) then
                Config.OriginalDoorStates[obj] = {Transparency = obj.Transparency, CanCollide = obj.CanCollide}
                obj.Transparency = 1
                obj.CanCollide = false
            end
        end
        -- Handle dynamic doors
        Config.DoorConnection = Workspace.DescendantAdded:Connect(function(desc)
            if Config.DoorToggle and desc:IsA("BasePart") and (desc.Name:lower():find("door") or desc.Name:lower():find("gate")) then
                Config.OriginalDoorStates[desc] = {Transparency = desc.Transparency, CanCollide = desc.CanCollide}
                desc.Transparency = 1
                desc.CanCollide = false
            end
        end)
    else
        for obj, state in pairs(Config.OriginalDoorStates) do
            if obj and obj.Parent then
                obj.Transparency = state.Transparency
                obj.CanCollide = state.CanCollide
            end
        end
        Config.OriginalDoorStates = {}
        if Config.DoorConnection then Config.DoorConnection:Disconnect() end
    end
end

-- ====================== GRAB GUNS (auto-teleport + fire) ======================
local function grabAllGuns()
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    print("🔫 VEX-PRIME scanning for all gun interactables...")
    local grabbed = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) then
            local parent = obj.Parent
            local nameLower = (parent.Name .. (obj.Name or "")):lower()
            if nameLower:find("gun") or nameLower:find("rifle") or nameLower:find("weapon") or nameLower:find("table") then
                local part = parent:FindFirstChildWhichIsA("BasePart") or parent.PrimaryPart or parent
                if part then
                    -- Teleport above the gun table
                    root.CFrame = part.CFrame * CFrame.new(0, 5, 0)
                    wait(0.15)

                    if obj:IsA("ClickDetector") then
                        fireclickdetector(obj)
                    elseif obj:IsA("ProximityPrompt") then
                        fireproximityprompt(obj)
                    end
                    grabbed += 1
                    wait(0.35) -- allow pickup animation / inventory update
                end
            end
        end
    end
    print("✅ VEX-PRIME grabbed " .. grabbed .. " gun(s).")
end

-- ====================== INFINITE STAMINA ======================
local function infiniteStaminaLoop()
    while Config.InfStaminaToggle do
        local char = getCharacter()
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                -- Reset common stamina containers (adjust attribute/value name if dev console shows different)
                if hum:GetAttribute("Stamina") ~= nil then
                    hum:SetAttribute("Stamina", 100)
                end
                local staminaVal = hum:FindFirstChild("Stamina") or char:FindFirstChild("Stamina") or hum:FindFirstChild("StaminaValue")
                if staminaVal and staminaVal.Value then
                    staminaVal.Value = 100
                end

                -- Prevent drain states
                hum.JumpPower = 50
                if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- ====================== ESP (Drawing API - high performance) ======================
local function createOrUpdateESP()
    if not Config.ESPToggle then return end

    for _, drawing in pairs(Config.ESPObjects) do
        drawing.Visible = false
    end

    -- Player ESP (Dogs = yellow, Guards = blue)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then continue end

        local teamColor = Color3.fromRGB(255, 255, 0) -- default yellow (Dogs)
        if plr.Team and plr.Team.Name:lower():find("guard") then
            teamColor = Color3.fromRGB(0, 100, 255) -- blue
        end

        local root = char.HumanoidRootPart
        local head = char.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            local size = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y) * 1.5

            -- Box
            local boxKey = plr.Name .. "_box"
            if not Config.ESPObjects[boxKey] then
                Config.ESPObjects[boxKey] = Drawing.new("Square")
                Config.ESPObjects[boxKey].Thickness = 2
                Config.ESPObjects[boxKey].Filled = false
            end
            local box = Config.ESPObjects[boxKey]
            box.Size = Vector2.new(size / 1.8, size)
            box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
            box.Color = teamColor
            box.Visible = true

            -- Name + distance
            local nameKey = plr.Name .. "_name"
            if not Config.ESPObjects[nameKey] then
                Config.ESPObjects[nameKey] = Drawing.new("Text")
                Config.ESPObjects[nameKey].Size = 16
                Config.ESPObjects[nameKey].Center = true
                Config.ESPObjects[nameKey].Outline = true
            end
            local nameDraw = Config.ESPObjects[nameKey]
            nameDraw.Text = plr.Name .. " [" .. math.floor(distance) .. "m]"
            nameDraw.Position = Vector2.new(screenPos.X, screenPos.Y - box.Size.Y / 2 - 20)
            nameDraw.Color = teamColor
            nameDraw.Visible = true
        end
    end

    -- Stray Dog / NPC ESP (dark purple)
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and not isPlayerCharacter(model) and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            local root = model.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local distance = (root.Position - Camera.CFrame.Position).Magnitude
                local size = 80

                local boxKey = model.Name .. "_box"
                if not Config.ESPObjects[boxKey] then
                    Config.ESPObjects[boxKey] = Drawing.new("Square")
                    Config.ESPObjects[boxKey].Thickness = 2
                    Config.ESPObjects[boxKey].Filled = false
                end
                local box = Config.ESPObjects[boxKey]
                box.Size = Vector2.new(size / 1.5, size)
                box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
                box.Color = Color3.fromRGB(80, 0, 120) -- dark purple
                box.Visible = true

                local nameKey = model.Name .. "_name"
                if not Config.ESPObjects[nameKey] then
                    Config.ESPObjects[nameKey] = Drawing.new("Text")
                    Config.ESPObjects[nameKey].Size = 15
                    Config.ESPObjects[nameKey].Center = true
                    Config.ESPObjects[nameKey].Outline = true
                end
                local nameDraw = Config.ESPObjects[nameKey]
                nameDraw.Text = (model.Name:find("Dog") and "Stray Dog" or model.Name) .. " [" .. math.floor(distance) .. "m]"
                nameDraw.Position = Vector2.new(screenPos.X, screenPos.Y - box.Size.Y / 2 - 18)
                nameDraw.Color = Color3.fromRGB(80, 0, 120)
                nameDraw.Visible = true
            end
        end
    end
end

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VEX_PRIME_DogPound"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
Title.Text = "💜 VEX-PRIME — Dog Pound"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local function createButton(name, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local doorsBtn = createButton("Doors: OFF", 50, function()
    Config.DoorToggle = not Config.DoorToggle
    doorsBtn.Text = "Doors: " .. (Config.DoorToggle and "ON" or "OFF")
    doorsBtn.BackgroundColor3 = Config.DoorToggle and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 55)
    hideDoors(Config.DoorToggle)
end)

local gunsBtn = createButton("Grab All Guns", 95, function()
    gunsBtn.Text = "GRABBING..."
    task.spawn(grabAllGuns)
    wait(1.5)
    gunsBtn.Text = "Grab All Guns"
end)

local staminaBtn = createButton("Inf Stamina: OFF", 140, function()
    Config.InfStaminaToggle = not Config.InfStaminaToggle
    staminaBtn.Text = "Inf Stamina: " .. (Config.InfStaminaToggle and "ON" or "OFF")
    staminaBtn.BackgroundColor3 = Config.InfStaminaToggle and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 55)
    if Config.InfStaminaToggle then
        task.spawn(infiniteStaminaLoop)
    end
end)

local espBtn = createButton("ESP: OFF", 185, function()
    Config.ESPToggle = not Config.ESPToggle
    espBtn.Text = "ESP: " .. (Config.ESPToggle and "ON" or "OFF")
    espBtn.BackgroundColor3 = Config.ESPToggle and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 55)
end)

-- ====================== MAIN LOOPS ======================
RunService.RenderStepped:Connect(function()
    if Config.ESPToggle then
        createOrUpdateESP()
    else
        for _, drawing in pairs(Config.ESPObjects) do
            drawing.Visible = false
        end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Keybinds.Doors then
        doorsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.Guns then
        gunsBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.Stamina then
        staminaBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.Keybinds.ESP then
        espBtn.MouseButton1Click:Fire()
    end
end)

print("💜 VEX-PRIME Dog Pound script injected successfully. Menu is in top-left. Use F1-F4 or click buttons.")
