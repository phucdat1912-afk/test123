--==================================================
-- INSTANT TOKEN COLLECTOR V5.4
-- POSITION CHANGE DETECTOR
--
-- STRUCTURE:
-- Workspace.Systems.ActiveVariantTokenSpawns
-- Workspace.Systems.ActiveCollectableObjects
-- Workspace.Systems.CollectableObjects
--
-- LOGIC:
-- 1. Ignore objects already existing when script starts
-- 2. Detect NEW objects
-- 3. Detect reused objects moving to a NEW position
-- 4. TP ONCE per new position
-- 5. Do NOT TP repeatedly to the same position
-- 6. Variant has highest priority
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

local PositionThreshold = 3
local TeleportDelay = 0.08
local CheckDelay = 0.10

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

    while os.clock() - start < timeout do

        obj = parent:FindFirstChild(name)

        if obj then
            return obj
        end

        task.wait(0.1)
    end

    return nil
end

--==================================================
-- SYSTEMS
--==================================================

local Systems = Find(
    workspace,
    "Systems",
    5
)

if not Systems then
    warn("[V5.4] Workspace.Systems NOT FOUND")
    return
end

local VariantFolder = Find(
    Systems,
    "ActiveVariantTokenSpawns",
    3
)

local ActiveFolder = Find(
    Systems,
    "ActiveCollectableObjects",
    3
)

local CollectableFolder = Find(
    Systems,
    "CollectableObjects",
    3
)

print("======================================")
print("INSTANT TOKEN COLLECTOR V5.4")
print("======================================")

print(
    "Variant:",
    VariantFolder and VariantFolder:GetFullName()
        or "NOT FOUND"
)

print(
    "Active:",
    ActiveFolder and ActiveFolder:GetFullName()
        or "NOT FOUND"
)

print(
    "Collectable:",
    CollectableFolder and CollectableFolder:GetFullName()
        or "NOT FOUND"
)

print("======================================")

--==================================================
-- CHARACTER
--==================================================

local Character
local Root

local function RefreshCharacter()

    Character = Player.Character

    if not Character then
        return false
    end

    Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    return Root ~= nil
end

RefreshCharacter()

Player.CharacterAdded:Connect(function(char)

    Character = char

    Root =
        char:WaitForChild(
            "HumanoidRootPart",
            5
        )

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
-- UI
--==================================================

local PlayerGui =
    Player:WaitForChild("PlayerGui")

local Old =
    PlayerGui:FindFirstChild(
        "TokenCollectorV54"
    )

if Old then
    Old:Destroy()
end

local Gui =
    Instance.new("ScreenGui")

Gui.Name =
    "TokenCollectorV54"

Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main =
    Instance.new("Frame")

Main.Size =
    UDim2.new(0,310,0,235)

Main.Position =
    UDim2.new(
        0.5,
        -155,
        0.5,
        -117
    )

Main.BackgroundColor3 =
    Color3.fromRGB(25,25,30)

Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner =
    Instance.new("UICorner")

Corner.CornerRadius =
    UDim.new(0,10)

Corner.Parent = Main

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
    "INSTANT TOKEN COLLECTOR V5.4"

Title.TextColor3 =
    Color3.fromRGB(255,255,255)

Title.TextSize = 14

Title.Font =
    Enum.Font.GothamBold

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
-- STATUS
--==================================================

local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.new(1,-20,0,30)

Status.Position =
    UDim2.new(0,10,0,43)

Status.BackgroundTransparency = 1

Status.Text =
    "WAITING FOR NEW POSITION"

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
    UDim2.new(1,-20,0,45)

Target.Position =
    UDim2.new(0,10,0,75)

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
-- INFO
--==================================================

local Info =
    Instance.new("TextLabel")

Info.Size =
    UDim2.new(1,-20,0,30)

Info.Position =
    UDim2.new(0,10,0,122)

Info.BackgroundTransparency = 1

Info.Text =
    "Waiting..."

Info.TextColor3 =
    Color3.fromRGB(170,170,180)

Info.TextSize = 11

Info.Font =
    Enum.Font.Gotham

Info.TextXAlignment =
    Enum.TextXAlignment.Left

Info.Parent = Main

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

Toggle.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        Toggle.Text =
            "COLLECTOR: ON"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(40,130,65)

        Status.Text =
            "WAITING FOR NEW POSITION"

        Status.TextColor3 =
            Color3.fromRGB(255,220,100)

    else

        Toggle.Text =
            "COLLECTOR: OFF"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(130,45,45)

        Status.Text =
            "PAUSED"

        Status.TextColor3 =
            Color3.fromRGB(255,100,100)

    end
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
-- POSITION CACHE
--==================================================

local ObjectState = {}

-- ObjectState[obj] = {
--     position = Vector3,
--     lastCollected = Vector3,
--     initialized = true
-- }

--==================================================
-- QUEUE
--==================================================

local Queue = {}
local QueueKeys = {}

local function QueueObject(
    obj,
    folderName,
    position
)

    if not obj then
        return
    end

    if QueueKeys[obj] then
        return
    end

    QueueKeys[obj] = true

    table.insert(
        Queue,
        {
            object = obj,
            folder = folderName,
            position = position
        }
    )

end

--==================================================
-- PROCESS QUEUE
--==================================================

task.spawn(function()

    while task.wait(0.02) do

        if not Enabled then
            continue
        end

        local item =
            table.remove(
                Queue,
                1
            )

        if not item then
            continue
        end

        QueueKeys[item.object] = nil

        local obj = item.object

        if not obj
            or not obj.Parent then

            continue
        end

        local position =
            GetPosition(obj)

        if not position then
            continue
        end

        if not Root
            or not Root.Parent then

            RefreshCharacter()

        end

        if not Root then
            continue
        end

        -- Kiểm tra lần cuối:
        -- nếu vị trí đã thay đổi trước khi xử lý
        -- thì dùng vị trí mới nhất.

        local state =
            ObjectState[obj]

        if state
            and state.lastCollected then

            local distance =
                (
                    position -
                    state.lastCollected
                ).Magnitude

            if distance <
                PositionThreshold then

                continue
            end
        end

        --==========================================
        -- TELEPORT
        --==========================================

        Status.Text =
            "TELEPORTING"

        Status.TextColor3 =
            Color3.fromRGB(
                100,
                255,
                100
            )

        Target.Text =
            "Target: " ..
            obj.Name ..
            "\n" ..
            item.folder

        Info.Text =
            "Position: " ..
            tostring(position)

        print(
            "[V5.4] TP ->",
            obj:GetFullName(),
            "|",
            tostring(position)
        )

        pcall(function()

            Root.CFrame =
                CFrame.new(
                    position +
                    Vector3.new(0,2,0)
                )

        end)

        --==========================================
        -- LOCK THIS POSITION
        --==========================================

        ObjectState[obj] = ObjectState[obj] or {}

        ObjectState[obj].lastCollected =
            position

        task.wait(TeleportDelay)

        Status.Text =
            "WAITING FOR NEW POSITION"

        Status.TextColor3 =
            Color3.fromRGB(
                255,
                220,
                100
            )

    end
end)

--==================================================
-- INITIALIZE EXISTING OBJECTS
--
-- QUAN TRỌNG:
-- Object đã tồn tại khi execute sẽ KHÔNG bị TP.
-- Chỉ lưu position làm mốc.
--==================================================

local function InitializeFolder(
    folder,
    folderName
)

    if not folder then
        return 0
    end

    local count = 0

    for _, obj in ipairs(
        folder:GetChildren()
    ) do

        local position =
            GetPosition(obj)

        if position then

            ObjectState[obj] = {
                position = position,
                lastCollected = position,
                initialized = true
            }

            count += 1

        end
    end

    print(
        "[V5.4] Initialized",
        folderName,
        count,
        "existing objects"
    )

    return count
end

InitializeFolder(
    VariantFolder,
    "ActiveVariantTokenSpawns"
)

InitializeFolder(
    ActiveFolder,
    "ActiveCollectableObjects"
)

InitializeFolder(
    CollectableFolder,
    "CollectableObjects"
)

--==================================================
-- DETECT NEW / MOVED
--==================================================

local function MonitorFolder(
    folder,
    folderName,
    priority
)

    if not folder then
        warn(
            "[V5.4] Missing folder:",
            folderName
        )
        return
    end

    --==============================================
    -- NEW OBJECT
    --==============================================

    folder.ChildAdded:Connect(
        function(obj)

            task.wait(0.03)

            local position =
                GetPosition(obj)

            if not position then
                return
            end

            print(
                "[V5.4] NEW OBJECT:",
                obj:GetFullName(),
                "|",
                tostring(position)
            )

            ObjectState[obj] = {
                position = position,
                lastCollected = nil,
                initialized = false
            }

            QueueObject(
                obj,
                folderName,
                position
            )

        end
    )

    --==============================================
    -- REMOVED
    --==============================================

    folder.ChildRemoved:Connect(
        function(obj)

            ObjectState[obj] = nil
            QueueKeys[obj] = nil

            print(
                "[V5.4] REMOVED:",
                obj.Name
            )

        end
    )

end

--==================================================
-- START MONITORS
--==================================================

MonitorFolder(
    VariantFolder,
    "ActiveVariantTokenSpawns",
    1
)

MonitorFolder(
    ActiveFolder,
    "ActiveCollectableObjects",
    2
)

MonitorFolder(
    CollectableFolder,
    "CollectableObjects",
    3
)

--==================================================
-- POSITION MONITOR
--==================================================

task.spawn(function()

    while task.wait(CheckDelay) do

        if not Enabled then
            continue
        end

        --==========================================
        -- PRIORITY 1
        -- VARIANT
        --==========================================

        if VariantFolder then

            for _, obj in ipairs(
                VariantFolder:GetChildren()
            ) do

                local position =
                    GetPosition(obj)

                if position then

                    local state =
                        ObjectState[obj]

                    if not state then

                        ObjectState[obj] = {
                            position = position,
                            lastCollected = nil
                        }

                        QueueObject(
                            obj,
                            "ActiveVariantTokenSpawns",
                            position
                        )

                    else

                        local old =
                            state.position

                        if old then

                            local moved =
                                (
                                    position -
                                    old
                                ).Magnitude

                            if moved >=
                                PositionThreshold then

                                state.position =
                                    position

                                -- Chỉ queue nếu đây
                                -- thực sự là vị trí mới.

                                if
                                    not state.lastCollected
                                    or
                                    (
                                        position -
                                        state.lastCollected
                                    ).Magnitude >=
                                    PositionThreshold
                                then

                                    QueueObject(
                                        obj,
                                        "ActiveVariantTokenSpawns",
                                        position
                                    )

                                end
                            end
                        end
                    end
                end
            end
        end

        --==========================================
        -- PRIORITY 2
        -- ACTIVE
        --==========================================

        if ActiveFolder then

            for _, obj in ipairs(
                ActiveFolder:GetChildren()
            ) do

                local position =
                    GetPosition(obj)

                if position then

                    local state =
                        ObjectState[obj]

                    if not state then

                        ObjectState[obj] = {
                            position = position,
                            lastCollected = nil
                        }

                        QueueObject(
                            obj,
                            "ActiveCollectableObjects",
                            position
                        )

                    else

                        local old =
                            state.position

                        if old then

                            local moved =
                                (
                                    position -
                                    old
                                ).Magnitude

                            if moved >=
                                PositionThreshold then

                                state.position =
                                    position

                                if
                                    not state.lastCollected
                                    or
                                    (
                                        position -
                                        state.lastCollected
                                    ).Magnitude >=
                                    PositionThreshold
                                then

                                    QueueObject(
                                        obj,
                                        "ActiveCollectableObjects",
                                        position
                                    )

                                end
                            end
                        end
                    end
                end
            end
        end

        --==========================================
        -- PRIORITY 3
        -- COLLECTABLE
        --==========================================

        if CollectableFolder then

            for _, obj in ipairs(
                CollectableFolder:GetChildren()
            ) do

                local position =
                    GetPosition(obj)

                if position then

                    local state =
                        ObjectState[obj]

                    if not state then

                        ObjectState[obj] = {
                            position = position,
                            lastCollected = nil
                        }

                        QueueObject(
                            obj,
                            "CollectableObjects",
                            position
                        )

                    else

                        local old =
                            state.position

                        if old then

                            local moved =
                                (
                                    position -
                                    old
                                ).Magnitude

                            if moved >=
                                PositionThreshold then

                                state.position =
                                    position

                                if
                                    not state.lastCollected
                                    or
                                    (
                                        position -
                                        state.lastCollected
                                    ).Magnitude >=
                                    PositionThreshold
                                then

                                    QueueObject(
                                        obj,
                                        "CollectableObjects",
                                        position
                                    )

                                end
                            end
                        end
                    end
                end
            end
        end

    end
end)

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
        "[V5.4] Anti-AFK"
    )

end)

--==================================================
-- CACHE CLEANUP
--==================================================

task.spawn(function()

    while task.wait(5) do

        for obj in pairs(ObjectState) do

            if not obj
                or not obj.Parent then

                ObjectState[obj] = nil
                QueueKeys[obj] = nil

            end

        end

    end

end)

--==================================================
-- READY
--==================================================

Info.Text =
    "Existing objects ignored"

print("======================================")
print("V5.4 READY")
print("======================================")
print("Existing objects: IGNORED")
print("New object: DETECTED")
print("Position change: DETECTED")
print("Same position: LOCKED")
print("======================================")
