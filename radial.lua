-- VEX-PRIME 2026 Radial Wheel | Bright Purple + Black | Mouse-Centered (First-Person Ready) | Loadstring
-- Hold Middle Mouse Button (scroll wheel click) to open | Release to activate

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VEX_Radial_2026"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main radial frame - bright purple/black transparent theme
local RadialFrame = Instance.new("Frame")
RadialFrame.Size = UDim2.new(0, 400, 0, 400)
RadialFrame.BackgroundTransparency = 0.75  -- highly see-through for game visibility
RadialFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 18)  -- deep black
RadialFrame.BorderSizePixel = 0
RadialFrame.Visible = false
RadialFrame.Parent = ScreenGui

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0.5, 0)
OuterCorner.Parent = RadialFrame

local OuterStroke = Instance.new("UIStroke")
OuterStroke.Thickness = 5
OuterStroke.Color = Color3.fromRGB(200, 0, 255)  -- bright purple
OuterStroke.Transparency = 0.2
OuterStroke.Parent = RadialFrame

local CenterLabel = Instance.new("TextLabel")
CenterLabel.Size = UDim2.new(0.38, 0, 0.38, 0)
CenterLabel.Position = UDim2.new(0.31, 0, 0.31, 0)
CenterLabel.BackgroundTransparency = 1
CenterLabel.Text = "TARGET"
CenterLabel.TextColor3 = Color3.fromRGB(200, 0, 255)  -- bright purple
CenterLabel.TextScaled = true
CenterLabel.Font = Enum.Font.GothamBold
CenterLabel.Parent = RadialFrame

-- Options (glowing purple-tinted circles)
local Options = {
    {Name = "Teleport",   Color = Color3.fromRGB(180, 0, 255), Action = "TP"},
    {Name = "Fling",      Color = Color3.fromRGB(200, 50, 255), Action = "FLING"},
    {Name = "Loop Fling", Color = Color3.fromRGB(220, 0, 255), Action = "LOOPFLING"},
    {Name = "Kill",       Color = Color3.fromRGB(255, 40, 180), Action = "KILL"},
    {Name = "Spectate",   Color = Color3.fromRGB(140, 0, 255), Action = "SPEC"},
    {Name = "Unspectate", Color = Color3.fromRGB(170, 170, 255), Action = "UNSPEC"}
}

local Buttons = {}
local Radius = 145
local NumOptions = #Options
local AngleStep = 360 / NumOptions

for i, opt in ipairs(Options) do
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(0, 88, 0, 88)
    BtnFrame.BackgroundColor3 = opt.Color
    BtnFrame.BackgroundTransparency = 0
    BtnFrame.BorderSizePixel = 0

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0.5, 0)
    BtnCorner.Parent = BtnFrame

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 5
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Transparency = 0.2
    BtnStroke.Parent = BtnFrame

    local BtnText = Instance.new("TextLabel")
    BtnText.Size = UDim2.new(1, 0, 1, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = opt.Name
    BtnText.TextColor3 = Color3.new(1, 1, 1)
    BtnText.TextScaled = true
    BtnText.Font = Enum.Font.GothamSemibold
    BtnText.Parent = BtnFrame

    local angle = math.rad((i - 1) * AngleStep - 90)
    local x = Radius * math.cos(angle)
    local y = Radius * math.sin(angle)
    BtnFrame.Position = UDim2.new(0.5, x - 44, 0.5, y - 44)

    BtnFrame.Parent = RadialFrame
    Buttons[i] = {Frame = BtnFrame, Data = opt}
end

-- Draggable Close Button (bottom-left, black/purple)
local CloseFrame = Instance.new("Frame")
CloseFrame.Size = UDim2.new(0, 140, 0, 42)
CloseFrame.Position = UDim2.new(0, 25, 1, -80)
CloseFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 18)
CloseFrame.BorderSizePixel = 0
CloseFrame.Parent = ScreenGui

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseFrame

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 3
CloseStroke.Color = Color3.fromRGB(200, 0, 255)
CloseStroke.Parent = CloseFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, 0, 1, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕ CLOSE WHEEL"
CloseBtn.TextColor3 = Color3.fromRGB(200, 0, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = CloseFrame

local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(CloseFrame)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    print("💜 Radial wheel fully terminated.")
end)

-- Target & lightweight FE actions
local CurrentTarget = nil
local function GetNearestPlayer()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if d < dist then dist = d; closest = plr end
        end
    end
    return closest
end

local function PerformAction(action)
    if not CurrentTarget or not CurrentTarget.Character then return end
    local tRoot = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    if action == "TP" and myRoot then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 4, 0)
    elseif action == "FLING" then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(math.random(-90,90)*35, 180, math.random(-90,90)*35)
        bv.Parent = tRoot
        Debris:AddItem(bv, 0.75)
    elseif action == "LOOPFLING" then
        task.spawn(function()
            for i = 1, 28 do
                if not CurrentTarget or not CurrentTarget.Character then break end
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = Vector3.new(0, 650, 0) + Vector3.new(math.random(-350,350), 0, math.random(-350,350))
                bv.Parent = CurrentTarget.Character.HumanoidRootPart
                Debris:AddItem(bv, 0.22)
                task.wait(0.07)
            end
        end)
    elseif action == "KILL" then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0, 1e6, 0)
        bv.Parent = tRoot
        Debris:AddItem(bv, 1.8)
    elseif action == "SPEC" then
        workspace.CurrentCamera.CameraSubject = CurrentTarget.Character:FindFirstChild("Humanoid")
    elseif action == "UNSPEC" then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end

-- Radial logic
local Selected = nil
local RenderConn, InputConn

local function ShowRadial()
    CurrentTarget = GetNearestPlayer()
    if not CurrentTarget then return end
    CenterLabel.Text = CurrentTarget.Name:upper()

    -- Position centered on mouse cursor (first-person friendly + "attached" feel)
    RadialFrame.Position = UDim2.new(0, Mouse.X - 200, 0, Mouse.Y - 200)
    RadialFrame.Visible = true

    RenderConn = RunService.RenderStepped:Connect(function()
        -- Keep wheel centered on current mouse position while held (stays attached to where you're looking)
        RadialFrame.Position = UDim2.new(0, Mouse.X - 200, 0, Mouse.Y - 200)

        local center = RadialFrame.AbsolutePosition + RadialFrame.AbsoluteSize/2
        local dir = Vector2.new(Mouse.X, Mouse.Y) - center
        local ang = math.atan2(dir.Y, dir.X) * (180 / math.pi)
        if ang < 0 then ang += 360 end

        local idx = math.floor((ang + AngleStep/2) / AngleStep) + 1
        if idx < 1 then idx = NumOptions end
        if idx > NumOptions then idx = 1 end

        if Selected ~= idx then
            if Selected then Buttons[Selected].Frame.BackgroundTransparency = 0 end
            Buttons[idx].Frame.BackgroundTransparency = 0.3
            Selected = idx
        end
    end)
end

local function HideRadial(execute)
    if RenderConn then RenderConn:Disconnect() RenderConn = nil end
    if InputConn then InputConn:Disconnect() InputConn = nil end
    RadialFrame.Visible = false
    if execute and Selected then
        PerformAction(Buttons[Selected].Data.Action)
    end
    Selected = nil
end

-- Middle Mouse hold
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        ShowRadial()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        HideRadial(true)
    end
end)

print("💜 VEX-PRIME Radial Wheel 2026 loaded | Hold Middle Mouse | Bright Purple + Black Theme")
