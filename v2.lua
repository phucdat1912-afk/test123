--==================================================
-- INSTANT TOKEN COLLECTOR V5.2
-- STRUCTURE:
-- Workspace.Systems.ActiveVariantTokenSpawns
-- Workspace.Systems.ActiveCollectableObjects
-- Workspace.Systems.CollectableObjects
--
-- FEATURES:
-- - Variant Token monitor
-- - Active Collectable monitor
-- - CollectableObjects monitor
-- - Position change monitor
-- - Instant TP
-- - Anti-AFK
-- - Hide / Show
-- - Draggable UI
-- - Debug logs
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    Enabled = true,

    TeleportDelay = 0.08,
    CollectDistance = 5,

    ScanInterval = 0.15,
    PositionCheckInterval = 0.05,

    AntiAFK = true,

    Debug = true
}

--==================================================
-- CHARACTER
--==================================================

local Character
local Root

local function updateCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Root = Character:WaitForChild("HumanoidRootPart", 10)
end

updateCharacter()

Player.CharacterAdded:Connect(function(char)
    Character = char
    Root = char:WaitForChild("HumanoidRootPart", 10)
end)

--==================================================
-- SYSTEMS
--==================================================

local Systems = workspace:WaitForChild("Systems")

local ActiveVariantTokenSpawns =
    Systems:WaitForChild("ActiveVariantTokenSpawns")

local ActiveCollectableObjects =
    Systems:WaitForChild("ActiveCollectableObjects")

local CollectableObjects =
    Systems:WaitForChild("CollectableObjects")

--==================================================
-- DEBUG
--==================================================

local function log(...)
    if CONFIG.Debug then
        print("[V5.2]", ...)
    end
end

local function warnLog(...)
    warn("[V5.2]", ...)
end

--==================================================
-- UI
--==================================================

local oldGui =
    Player:WaitForChild("PlayerGui"):FindFirstChild("InstantTokenCollectorV52")

if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InstantTokenCollectorV52"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 310, 0, 245)
Main.Position = UDim2.new(0.5, -155, 0.5, -122)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 38)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "INSTANT TOKEN COLLECTOR V5.2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- HIDE BUTTON
--==================================================

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 32, 0, 28)
HideButton.Position = UDim2.new(1, -38, 0, 5)
HideButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
HideButton.Text = "-"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = Main

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 6)
HideCorner.Parent = HideButton

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 30)
Status.Position = UDim2.new(0, 12, 0, 45)
Status.BackgroundTransparency = 1
Status.Text = "Status: RUNNING"
Status.TextColor3 = Color3.fromRGB(100, 255, 100)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Current = Instance.new("TextLabel")
Current.Size = UDim2.new(1, -24, 0, 25)
Current.Position = UDim2.new(0, 12, 0, 75)
Current.BackgroundTransparency = 1
Current.Text = "Target: None"
Current.TextColor3 = Color3.fromRGB(220, 220, 220)
Current.TextSize = 13
Current.Font = Enum.Font.Gotham
Current.TextXAlignment = Enum.TextXAlignment.Left
Current.Parent = Main

local FolderStatus = Instance.new("TextLabel")
FolderStatus.Size = UDim2.new(1, -24, 0, 55)
FolderStatus.Position = UDim2.new(0, 12, 0, 103)
FolderStatus.BackgroundTransparency = 1
FolderStatus.Text =
    "Variant: 0\n" ..
    "Active: 0\n" ..
    "Collectable: 0"

FolderStatus.TextColor3 = Color3.fromRGB(180, 180, 190)
FolderStatus.TextSize = 12
FolderStatus.Font = Enum.Font.Gotham
FolderStatus.TextXAlignment = Enum.TextXAlignment.Left
FolderStatus.Parent = Main

--==================================================
-- TOGGLE
--==================================================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -24, 0, 35)
ToggleButton.Position = UDim2.new(0, 12, 1, -47)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 130, 65)
ToggleButton.Text = "COLLECTOR: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = ToggleButton

--==================================================
-- HIDDEN BUTTON
--==================================================

local ShowButton = Instance.new("TextButton")
ShowButton.Size = UDim2.new(0, 55, 0, 35)
ShowButton.Position = UDim2.new(0, 15, 0.5, -17)
ShowButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ShowButton.Text = "TOKEN"
ShowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowButton.TextSize = 11
ShowButton.Font = Enum.Font.GothamBold
ShowButton.Visible = false
ShowButton.Parent = ScreenGui

local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius = UDim.new(0, 8)
ShowCorner.Parent = ShowButton

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)
    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            updateDrag(input)
        end
    end
end)

--==================================================
-- HIDE / SHOW
--==================================================

HideButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    ShowButton.Visible = false
end)

--==================================================
-- ENABLE / DISABLE
--==================================================

ToggleButton.MouseButton1Click:Connect(function()

    CONFIG.Enabled = not CONFIG.Enabled

    if CONFIG.Enabled then

        ToggleButton.Text = "COLLECTOR: ON"
        ToggleButton.BackgroundColor3 =
            Color3.fromRGB(40, 130, 65)

        Status.Text = "Status: RUNNING"
        Status.TextColor3 =
            Color3.fromRGB(100, 255, 100)

        log("Collector ENABLED")

    else

        ToggleButton.Text = "COLLECTOR: OFF"
        ToggleButton.BackgroundColor3 =
            Color3.fromRGB(130, 45, 45)

        Status.Text = "Status: PAUSED"
        Status.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        Current.Text = "Target: None"

        log("Collector DISABLED")
    end
end)

--==================================================
-- GET POSITION
--==================================================

local function getPosition(obj)

    if not obj then
        return nil
    end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then

        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end

        local part =
            obj:FindFirstChildWhichIsA("BasePart", true)

        if part then
            return part.Position
        end
    end

    return nil
end

--==================================================
-- VALID OBJECT
--==================================================

local function isValidObject(obj)

    if not obj then
        return false
    end

    if not obj.Parent then
        return false
    end

    local position = getPosition(obj)

    if not position then
        return false
    end

    return true
end

--==================================================
-- COLLECT OBJECT
--==================================================

local collecting = false
local lastTarget = nil
local lastTargetPosition = nil

local function collectObject(obj, folderName)

    if not CONFIG.Enabled then
        return
    end

    if collecting then
        return
    end

    if not isValidObject(obj) then
        return
    end

    if not Root or not Root.Parent then
        updateCharacter()
    end

    local position = getPosition(obj)

    if not position then
        return
    end

    collecting = true
    lastTarget = obj
    lastTargetPosition = position

    Current.Text =
        "Target: " ..
        tostring(obj.Name) ..
        " [" ..
        tostring(folderName) ..
        "]"

    log(
        "TP ->",
        obj.Name,
        "| Folder:",
        folderName,
        "| Position:",
        tostring(position)
    )

    pcall(function()

        Root.CFrame =
            CFrame.new(position + Vector3.new(0, 2, 0))

    end)

    task.wait(CONFIG.TeleportDelay)

    pcall(function()

        if Root and isValidObject(obj) then

            local newPosition =
                getPosition(obj)

            if newPosition then

                Root.CFrame =
                    CFrame.new(
                        newPosition +
                        Vector3.new(0, 2, 0)
                    )
            end
        end

    end)

    task.wait(0.05)

    collecting = false
end

--==================================================
-- GET OBJECTS
--==================================================

local function getObjects(folder)

    local result = {}

    if not folder then
        return result
    end

    for _, obj in ipairs(folder:GetChildren()) do

        if isValidObject(obj) then
            table.insert(result, obj)
        end

    end

    return result
end

--==================================================
-- PRIORITY SCAN
--==================================================

local function scanAndCollect()

    if not CONFIG.Enabled then
        return
    end

    --==============================================
    -- PRIORITY 1
    -- ActiveVariantTokenSpawns
    --==============================================

    local variants =
        getObjects(ActiveVariantTokenSpawns)

    if #variants > 0 then

        for _, obj in ipairs(variants) do

            if CONFIG.Enabled then
                collectObject(
                    obj,
                    "ActiveVariantTokenSpawns"
                )
            end

        end
    end

    --==============================================
    -- PRIORITY 2
    -- ActiveCollectableObjects
    --==============================================

    local activeCollectables =
        getObjects(ActiveCollectableObjects)

    if #activeCollectables > 0 then

        for _, obj in ipairs(activeCollectables) do

            if CONFIG.Enabled then
                collectObject(
                    obj,
                    "ActiveCollectableObjects"
                )
            end

        end
    end

    --==============================================
    -- PRIORITY 3
    -- CollectableObjects
    --==============================================

    local collectables =
        getObjects(CollectableObjects)

    if #collectables > 0 then

        for _, obj in ipairs(collectables) do

            if CONFIG.Enabled then
                collectObject(
                    obj,
                    "CollectableObjects"
                )
            end

        end
    end
end

--==================================================
-- UPDATE COUNTER
--==================================================

local function updateCounters()

    local variantCount =
        #getObjects(ActiveVariantTokenSpawns)

    local activeCount =
        #getObjects(ActiveCollectableObjects)

    local collectableCount =
        #getObjects(CollectableObjects)

    FolderStatus.Text =
        "Variant: " .. variantCount ..
        "\nActive: " .. activeCount ..
        "\nCollectable: " .. collectableCount
end

--==================================================
-- FOLDER DEBUG
--==================================================

local function printFolder(folder, folderName)

    print(
        "========== " ..
        folderName ..
        " =========="
    )

    local objects = folder:GetChildren()

    if #objects == 0 then
        print("EMPTY")
        return
    end

    for _, obj in ipairs(objects) do

        local pos = getPosition(obj)

        if pos then

            print(
                obj.ClassName,
                obj:GetFullName(),
                "| Position:",
                tostring(pos)
            )

        else

            print(
                obj.ClassName,
                obj:GetFullName()
            )
        end
    end
end

-- Initial debug
printFolder(
    ActiveVariantTokenSpawns,
    "ActiveVariantTokenSpawns"
)

printFolder(
    ActiveCollectableObjects,
    "ActiveCollectableObjects"
)

printFolder(
    CollectableObjects,
    "CollectableObjects"
)

--==================================================
-- CHILD ADDED MONITOR
--==================================================

local function setupChildMonitor(folder, folderName)

    folder.ChildAdded:Connect(function(obj)

        log(
            "NEW OBJECT:",
            obj.Name,
            "| Folder:",
            folderName
        )

        task.wait(0.03)

        if CONFIG.Enabled then
            collectObject(
                obj,
                folderName
            )
        end
    end)

    folder.ChildRemoved:Connect(function(obj)

        log(
            "REMOVED:",
            obj.Name,
            "| Folder:",
            folderName
        )
    end)
end

setupChildMonitor(
    ActiveVariantTokenSpawns,
    "ActiveVariantTokenSpawns"
)

setupChildMonitor(
    ActiveCollectableObjects,
    "ActiveCollectableObjects"
)

setupChildMonitor(
    CollectableObjects,
    "CollectableObjects"
)

--==================================================
-- POSITION MONITOR
--==================================================

local positionCache = {}

task.spawn(function()

    while task.wait(CONFIG.PositionCheckInterval) do

        if CONFIG.Enabled then

            local folders = {
                {
                    ActiveVariantTokenSpawns,
                    "ActiveVariantTokenSpawns"
                },

                {
                    ActiveCollectableObjects,
                    "ActiveCollectableObjects"
                },

                {
                    CollectableObjects,
                    "CollectableObjects"
                }
            }

            for _, data in ipairs(folders) do

                local folder = data[1]
                local folderName = data[2]

                for _, obj in ipairs(folder:GetChildren()) do

                    local position = getPosition(obj)

                    if position then

                        local oldPosition =
                            positionCache[obj]

                        if oldPosition then

                            local distance =
                                (position - oldPosition).Magnitude

                            if distance > 1 then

                                log(
                                    "POSITION CHANGED:",
                                    obj.Name,
                                    "| Folder:",
                                    folderName,
                                    "| Distance:",
                                    distance
                                )

                                task.spawn(function()

                                    collectObject(
                                        obj,
                                        folderName
                                    )

                                end)
                            end
                        end

                        positionCache[obj] =
                            position
                    end
                end
            end
        end
    end
end)

--==================================================
-- MAIN SCANNER
--==================================================

task.spawn(function()

    while task.wait(CONFIG.ScanInterval) do

        if CONFIG.Enabled then

            updateCounters()
            scanAndCollect()

        end
    end
end)

--==================================================
-- CLEAN POSITION CACHE
--==================================================

task.spawn(function()

    while task.wait(2) do

        for obj in pairs(positionCache) do

            if not obj
                or not obj.Parent then

                positionCache[obj] = nil
            end
        end

    end
end)

--==================================================
-- ANTI AFK
--==================================================

if CONFIG.AntiAFK then

    Player.Idled:Connect(function()

        if not CONFIG.AntiAFK then
            return
        end

        log("Anti-AFK triggered")

        pcall(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(
                Vector2.new(
                    math.random(200, 800),
                    math.random(200, 600)
                )
            )

        end)

    end)

end

--==================================================
-- ANTI-AFK BACKUP
--==================================================

task.spawn(function()

    while task.wait(45) do

        if CONFIG.AntiAFK
            and CONFIG.Enabled then

            pcall(function()

                VirtualUser:CaptureController()

                VirtualUser:ClickButton2(
                    Vector2.new(
                        math.random(100, 900),
                        math.random(100, 600)
                    )
                )

            end)

            log("Anti-AFK backup pulse")
        end

    end
end)

--==================================================
-- START
--==================================================

Status.Text = "Status: RUNNING"
Status.TextColor3 =
    Color3.fromRGB(100, 255, 100)

log("======================================")
log("INSTANT TOKEN COLLECTOR V5.2 STARTED")
log("======================================")

log(
    "ActiveVariantTokenSpawns:",
    ActiveVariantTokenSpawns:GetFullName()
)

log(
    "ActiveCollectableObjects:",
    ActiveCollectableObjects:GetFullName()
)

log(
    "CollectableObjects:",
    CollectableObjects:GetFullName()
)

updateCounters()
scanAndCollect()
