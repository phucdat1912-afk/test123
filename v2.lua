--==================================================
-- INSTANT TOKEN COLLECTOR V5.3
-- SPAWN ONLY VERSION
--
-- CHỈ TP KHI:
-- 1. Object mới xuất hiện
-- 2. Object mới được thêm vào folder
-- 3. Variant token xuất hiện
-- 4. Collectable mới xuất hiện
--
-- KHÔNG TP LIÊN TỤC VÀO OBJECT CŨ
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local Enabled = true
local AntiAFK = true

local TeleportDelay = 0.08
local SpawnDelay = 0.03

--==================================================
-- SAFE FIND
--==================================================

local function Find(parent, name, timeout)

    if not parent then
        return nil
    end

    local obj = parent:FindFirstChild(name)

    if obj then
        return obj
    end

    local start = os.clock()

    while os.clock() - start < (timeout or 3) do

        obj = parent:FindFirstChild(name)

        if obj then
            return obj
        end

        task.wait(0.1)

    end

    return nil
end

--==================================================
-- CHARACTER
--==================================================

local Character
local Root

local function UpdateCharacter()

    Character = Player.Character

    if not Character then
        Character = Player.CharacterAdded:Wait()
    end

    Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not Root then

        Root =
            Character:WaitForChild(
                "HumanoidRootPart",
                5
            )

    end

end

UpdateCharacter()

Player.CharacterAdded:Connect(function(char)

    Character = char

    Root =
        char:WaitForChild(
            "HumanoidRootPart",
            5
        )

end)

--==================================================
-- SYSTEMS
--==================================================

local Systems =
    Find(
        workspace,
        "Systems",
        5
    )

if not Systems then

    warn(
        "[V5.3] Workspace.Systems NOT FOUND"
    )

    return
end

--==================================================
-- FOLDERS
--==================================================

local ActiveVariantTokenSpawns =
    Find(
        Systems,
        "ActiveVariantTokenSpawns",
        3
    )

local ActiveCollectableObjects =
    Find(
        Systems,
        "ActiveCollectableObjects",
        3
    )

local CollectableObjects =
    Find(
        Systems,
        "CollectableObjects",
        3
    )

print("======================================")
print("INSTANT TOKEN COLLECTOR V5.3")
print("======================================")

print(
    "Variant:",
    ActiveVariantTokenSpawns
        and ActiveVariantTokenSpawns:GetFullName()
        or "NOT FOUND"
)

print(
    "Active:",
    ActiveCollectableObjects
        and ActiveCollectableObjects:GetFullName()
        or "NOT FOUND"
)

print(
    "Collectable:",
    CollectableObjects
        and CollectableObjects:GetFullName()
        or "NOT FOUND"
)

print("======================================")

--==================================================
-- UI
--==================================================

local PlayerGui =
    Player:WaitForChild("PlayerGui")

local OldGui =
    PlayerGui:FindFirstChild(
        "TokenCollectorV53"
    )

if OldGui then
    OldGui:Destroy()
end

local Gui =
    Instance.new("ScreenGui")

Gui.Name =
    "TokenCollectorV53"

Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

--==================================================
-- MAIN
--==================================================

local Main =
    Instance.new("Frame")

Main.Size =
    UDim2.new(0,300,0,220)

Main.Position =
    UDim2.new(
        0.5,
        -150,
        0.5,
        -110
    )

Main.BackgroundColor3 =
    Color3.fromRGB(25,25,30)

Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0,10)

MainCorner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(1,-45,0,35)

Title.Position =
    UDim2.new(0,10,0,3)

Title.BackgroundTransparency = 1

Title.Text =
    "TOKEN COLLECTOR V5.3"

Title.TextColor3 =
    Color3.fromRGB(255,255,255)

Title.TextSize = 15
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = Main

--==================================================
-- HIDE
--==================================================

local Hide =
    Instance.new("TextButton")

Hide.Size =
    UDim2.new(0,30,0,28)

Hide.Position =
    UDim2.new(1,-35,0,5)

Hide.Text = "-"

Hide.TextSize = 18

Hide.TextColor3 =
    Color3.fromRGB(255,255,255)

Hide.BackgroundColor3 =
    Color3.fromRGB(50,50,60)

Hide.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.new(1,-20,0,28)

Status.Position =
    UDim2.new(0,10,0,42)

Status.BackgroundTransparency = 1

Status.Text =
    "Status: WAITING FOR SPAWN"

Status.TextColor3 =
    Color3.fromRGB(255,220,100)

Status.TextSize = 13

Status.Font =
    Enum.Font.GothamBold

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = Main

--==================================================
-- TARGET
--==================================================

local Target =
    Instance.new("TextLabel")

Target.Size =
    UDim2.new(1,-20,0,42)

Target.Position =
    UDim2.new(0,10,0,72)

Target.BackgroundTransparency = 1

Target.Text =
    "Target: None"

Target.TextColor3 =
    Color3.fromRGB(210,210,210)

Target.TextSize = 12

Target.Font =
    Enum.Font.Gotham

Target.TextWrapped = true

Target.TextXAlignment =
    Enum.TextXAlignment.Left

Target.Parent = Main

--==================================================
-- COUNTER
--==================================================

local Counter =
    Instance.new("TextLabel")

Counter.Size =
    UDim2.new(1,-20,0,30)

Counter.Position =
    UDim2.new(0,10,0,112)

Counter.BackgroundTransparency = 1

Counter.Text =
    "Waiting..."

Counter.TextColor3 =
    Color3.fromRGB(170,170,180)

Counter.TextSize = 11

Counter.Font =
    Enum.Font.Gotham

Counter.TextXAlignment =
    Enum.TextXAlignment.Left

Counter.Parent = Main

--==================================================
-- TOGGLE
--==================================================

local Toggle =
    Instance.new("TextButton")

Toggle.Size =
    UDim2.new(1,-20,0,35)

Toggle.Position =
    UDim2.new(0,10,1,-45)

Toggle.Text =
    "COLLECTOR: ON"

Toggle.TextColor3 =
    Color3.fromRGB(255,255,255)

Toggle.TextSize = 13

Toggle.Font =
    Enum.Font.GothamBold

Toggle.BackgroundColor3 =
    Color3.fromRGB(40,130,65)

Toggle.Parent = Main

--==================================================
-- SHOW
--==================================================

local Show =
    Instance.new("TextButton")

Show.Size =
    UDim2.new(0,70,0,35)

Show.Position =
    UDim2.new(0,10,0.5,-17)

Show.Text = "TOKEN"

Show.TextColor3 =
    Color3.fromRGB(255,255,255)

Show.TextSize = 11

Show.Font =
    Enum.Font.GothamBold

Show.BackgroundColor3 =
    Color3.fromRGB(25,25,30)

Show.Visible = false

Show.Parent = Gui

Hide.MouseButton1Click:Connect(function()

    Main.Visible = false
    Show.Visible = true

end)

Show.MouseButton1Click:Connect(function()

    Main.Visible = true
    Show.Visible = false

end)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(input)

    if
        input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position

    end

end)

Title.InputEnded:Connect(function(input)

    if
        input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not Dragging then
        return
    end

    if
        input.UserInputType ==
            Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        local Delta =
            input.Position - DragStart

        Main.Position =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )

    end

end)

--==================================================
-- TOGGLE
--==================================================

Toggle.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        Toggle.Text =
            "COLLECTOR: ON"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(40,130,65)

        Status.Text =
            "Status: WAITING FOR SPAWN"

        Status.TextColor3 =
            Color3.fromRGB(255,220,100)

    else

        Toggle.Text =
            "COLLECTOR: OFF"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(130,45,45)

        Status.Text =
            "Status: PAUSED"

        Status.TextColor3 =
            Color3.fromRGB(255,100,100)

    end

end)

--==================================================
-- POSITION
--==================================================

local function GetPosition(obj)

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
            obj:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if part then
            return part.Position
        end

    end

    return nil
end

--==================================================
-- PROCESSED OBJECTS
--==================================================

local Processed = {}

--==================================================
-- COLLECT NEW OBJECT
--==================================================

local function CollectNewObject(
    obj,
    folderName
)

    if not Enabled then
        return
    end

    if not obj then
        return
    end

    if not obj.Parent then
        return
    end

    -- Đã xử lý object này rồi
    if Processed[obj] then
        return
    end

    local Position =
        GetPosition(obj)

    if not Position then

        -- Model có thể chưa load part
        task.wait(0.05)

        Position =
            GetPosition(obj)

        if not Position then
            return
        end
    end

    Processed[obj] = true

    if not Root
        or not Root.Parent then

        UpdateCharacter()

    end

    if not Root then
        return
    end

    print(
        "[V5.3] NEW SPAWN:",
        obj:GetFullName()
    )

    print(
        "[V5.3] POSITION:",
        tostring(Position)
    )

    Target.Text =
        "Target: " ..
        obj.Name ..
        "\n" ..
        folderName

    Status.Text =
        "Status: TELEPORTING"

    Status.TextColor3 =
        Color3.fromRGB(100,255,100)

    pcall(function()

        Root.CFrame =
            CFrame.new(
                Position +
                Vector3.new(0,2,0)
            )

    end)

    task.wait(TeleportDelay)

    Status.Text =
        "Status: WAITING FOR SPAWN"

    Status.TextColor3 =
        Color3.fromRGB(255,220,100)

end

--==================================================
-- MONITOR NEW CHILD
--==================================================

local function MonitorFolder(
    folder,
    folderName
)

    if not folder then

        warn(
            "[V5.3] Folder missing:",
            folderName
        )

        return
    end

    print(
        "[V5.3] Monitoring:",
        folder:GetFullName()
    )

    -- QUAN TRỌNG:
    -- Không xử lý object đã có sẵn.
    -- Chỉ ChildAdded từ thời điểm script chạy.

    folder.ChildAdded:Connect(
        function(obj)

            print(
                "[V5.3] >>> SPAWN DETECTED <<<"
            )

            print(
                "[V5.3]",
                folderName,
                obj.Name
            )

            task.wait(SpawnDelay)

            CollectNewObject(
                obj,
                folderName
            )

        end
    )

end

--==================================================
-- START MONITORS
--==================================================

MonitorFolder(
    ActiveVariantTokenSpawns,
    "ActiveVariantTokenSpawns"
)

MonitorFolder(
    ActiveCollectableObjects,
    "ActiveCollectableObjects"
)

MonitorFolder(
    CollectableObjects,
    "CollectableObjects"
)

--==================================================
-- REMOVE CACHE
--==================================================

local function SetupRemoveMonitor(folder)

    if not folder then
        return
    end

    folder.ChildRemoved:Connect(
        function(obj)

            Processed[obj] = nil

            print(
                "[V5.3] Removed:",
                obj.Name
            )

        end
    )

end

SetupRemoveMonitor(
    ActiveVariantTokenSpawns
)

SetupRemoveMonitor(
    ActiveCollectableObjects
)

SetupRemoveMonitor(
    CollectableObjects
)

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()

    if not AntiAFK then
        return
    end

    pcall(function()

        VirtualUser:CaptureController()

        VirtualUser:ClickButton2(
            Vector2.new(
                math.random(300,700),
                math.random(200,500)
            )
        )

    end)

    print(
        "[V5.3] Anti-AFK"
    )

end)

--==================================================
-- CLEAN CACHE
--==================================================

task.spawn(function()

    while task.wait(5) do

        for obj in pairs(Processed) do

            if not obj
                or not obj.Parent then

                Processed[obj] = nil

            end

        end

    end

end)

--==================================================
-- READY
--==================================================

Status.Text =
    "Status: WAITING FOR SPAWN"

Status.TextColor3 =
    Color3.fromRGB(255,220,100)

Counter.Text =
    "Existing objects ignored"

print("======================================")
print("V5.3 READY")
print("Existing objects will NOT be collected.")
print("Waiting for NEW spawned objects...")
print("======================================")
