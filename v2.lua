--==================================================
-- INSTANT TOKEN COLLECTOR V5.2 FIX
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

local ScanDelay = 0.15
local TeleportDelay = 0.08

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

local function GetCharacter()

    Character = Player.Character

    if not Character then
        Character = Player.CharacterAdded:Wait()
    end

    Root = Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Root = Character:WaitForChild(
            "HumanoidRootPart",
            5
        )
    end

    return Root
end

GetCharacter()

Player.CharacterAdded:Connect(function(char)

    Character = char

    Root = char:WaitForChild(
        "HumanoidRootPart",
        5
    )

end)

--==================================================
-- FIND SYSTEMS
--==================================================

local Systems = Find(
    workspace,
    "Systems",
    5
)

if not Systems then

    warn(
        "[TOKEN V5.2] Workspace.Systems NOT FOUND"
    )

    return
end

print(
    "[TOKEN V5.2] Systems:",
    Systems:GetFullName()
)

--==================================================
-- FIND 3 FOLDERS
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

--==================================================
-- PRINT STRUCTURE
--==================================================

print("======================================")
print("TOKEN COLLECTOR V5.2")
print("======================================")

print(
    "ActiveVariantTokenSpawns:",
    ActiveVariantTokenSpawns
        and ActiveVariantTokenSpawns:GetFullName()
        or "NOT FOUND"
)

print(
    "ActiveCollectableObjects:",
    ActiveCollectableObjects
        and ActiveCollectableObjects:GetFullName()
        or "NOT FOUND"
)

print(
    "CollectableObjects:",
    CollectableObjects
        and CollectableObjects:GetFullName()
        or "NOT FOUND"
)

print("======================================")

--==================================================
-- UI
--==================================================

local PlayerGui = Player:WaitForChild(
    "PlayerGui"
)

local OldGui = PlayerGui:FindFirstChild(
    "TokenCollectorV52"
)

if OldGui then
    OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "TokenCollectorV52"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 220)
Main.Position = UDim2.new(
    0.5,
    -150,
    0.5,
    -110
)

Main.BackgroundColor3 =
    Color3.fromRGB(25,25,30)

Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(
    1,
    -45,
    0,
    35
)

Title.Position =
    UDim2.new(0,10,0,3)

Title.BackgroundTransparency = 1

Title.Text =
    "INSTANT TOKEN COLLECTOR V5.2"

Title.TextColor3 =
    Color3.fromRGB(255,255,255)

Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = Main

--==================================================
-- HIDE
--==================================================

local Hide = Instance.new("TextButton")

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

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius =
    UDim.new(0,6)

HideCorner.Parent = Hide

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")

Status.Size =
    UDim2.new(1,-20,0,30)

Status.Position =
    UDim2.new(0,10,0,42)

Status.BackgroundTransparency = 1

Status.Text = "Status: RUNNING"

Status.TextColor3 =
    Color3.fromRGB(100,255,100)

Status.TextSize = 14

Status.Font =
    Enum.Font.GothamBold

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = Main

--==================================================
-- COUNTER
--==================================================

local Counter = Instance.new("TextLabel")

Counter.Size =
    UDim2.new(1,-20,0,65)

Counter.Position =
    UDim2.new(0,10,0,75)

Counter.BackgroundTransparency = 1

Counter.Text =
    "Variant: 0\nActive: 0\nCollectable: 0"

Counter.TextColor3 =
    Color3.fromRGB(200,200,200)

Counter.TextSize = 13

Counter.Font =
    Enum.Font.Gotham

Counter.TextXAlignment =
    Enum.TextXAlignment.Left

Counter.Parent = Main

--==================================================
-- TARGET
--==================================================

local Target = Instance.new("TextLabel")

Target.Size =
    UDim2.new(1,-20,0,25)

Target.Position =
    UDim2.new(0,10,0,138)

Target.BackgroundTransparency = 1

Target.Text =
    "Target: None"

Target.TextColor3 =
    Color3.fromRGB(255,220,100)

Target.TextSize = 12

Target.Font =
    Enum.Font.Gotham

Target.TextXAlignment =
    Enum.TextXAlignment.Left

Target.Parent = Main

--==================================================
-- TOGGLE
--==================================================

local Toggle = Instance.new("TextButton")

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

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius =
    UDim.new(0,7)

ToggleCorner.Parent = Toggle

--==================================================
-- HIDE BUTTON
--==================================================

local Show = Instance.new("TextButton")

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

local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius =
    UDim.new(0,7)

ShowCorner.Parent = Show

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

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position

    end

end)

Title.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not Dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local Delta =
            input.Position - DragStart

        Main.Position = UDim2.new(
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
            "Status: RUNNING"

        Status.TextColor3 =
            Color3.fromRGB(100,255,100)

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

        local Primary =
            obj.PrimaryPart

        if Primary then
            return Primary.Position
        end

        local Part =
            obj:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if Part then
            return Part.Position
        end

    end

    return nil
end

--==================================================
-- TELEPORT
--==================================================

local LastObject = nil
local LastTime = 0

local function TeleportTo(obj, folderName)

    if not Enabled then
        return
    end

    if not obj then
        return
    end

    if not obj.Parent then
        return
    end

    local Position =
        GetPosition(obj)

    if not Position then
        return
    end

    if not Root
        or not Root.Parent then

        GetCharacter()

    end

    if not Root then
        return
    end

    -- chống TP spam cùng object
    if LastObject == obj
        and os.clock() - LastTime < 0.25 then

        return
    end

    LastObject = obj
    LastTime = os.clock()

    Target.Text =
        "Target: " ..
        obj.Name ..
        " [" ..
        folderName ..
        "]"

    print(
        "[V5.2] TP:",
        obj:GetFullName(),
        Position
    )

    pcall(function()

        Root.CFrame =
            CFrame.new(
                Position + Vector3.new(0,2,0)
            )

    end)

    task.wait(TeleportDelay)

end

--==================================================
-- GET OBJECTS
--==================================================

local function GetParts(folder)

    local list = {}

    if not folder then
        return list
    end

    for _, obj in ipairs(
        folder:GetChildren()
    ) do

        if GetPosition(obj) then
            table.insert(list,obj)
        end

    end

    return list
end

--==================================================
-- SCAN
--==================================================

local function ScanFolder(folder, name)

    if not folder then
        return 0
    end

    local objects =
        GetParts(folder)

    for _, obj in ipairs(objects) do

        if not Enabled then
            break
        end

        TeleportTo(
            obj,
            name
        )

    end

    return #objects
end

--==================================================
-- MAIN SCAN
--==================================================

task.spawn(function()

    while task.wait(ScanDelay) do

        if Enabled then

            -- PRIORITY 1
            local VariantCount =
                ScanFolder(
                    ActiveVariantTokenSpawns,
                    "Variant"
                )

            -- PRIORITY 2
            local ActiveCount =
                ScanFolder(
                    ActiveCollectableObjects,
                    "Active"
                )

            -- PRIORITY 3
            local CollectableCount =
                ScanFolder(
                    CollectableObjects,
                    "Collectable"
                )

            Counter.Text =
                "Variant: " ..
                VariantCount ..
                "\nActive: " ..
                ActiveCount ..
                "\nCollectable: " ..
                CollectableCount

        end

    end

end)

--==================================================
-- NEW OBJECT MONITOR
--==================================================

local function MonitorFolder(
    folder,
    folderName
)

    if not folder then
        return
    end

    folder.ChildAdded:Connect(
        function(obj)

            print(
                "[V5.2] NEW:",
                obj:GetFullName()
            )

            task.wait(0.05)

            if Enabled then

                TeleportTo(
                    obj,
                    folderName
                )

            end

        end
    )

end

MonitorFolder(
    ActiveVariantTokenSpawns,
    "Variant"
)

MonitorFolder(
    ActiveCollectableObjects,
    "Active"
)

MonitorFolder(
    CollectableObjects,
    "Collectable"
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
        "[V5.2] Anti-AFK"
    )

end)

--==================================================
-- INITIAL DEBUG
--==================================================

print("======================================")
print("V5.2 READY")
print("======================================")

if ActiveVariantTokenSpawns then
    print(
        "Variant objects:",
        #ActiveVariantTokenSpawns:GetChildren()
    )
else
    warn(
        "ActiveVariantTokenSpawns NOT FOUND"
    )
end

if ActiveCollectableObjects then
    print(
        "Active objects:",
        #ActiveCollectableObjects:GetChildren()
    )
else
    warn(
        "ActiveCollectableObjects NOT FOUND"
    )
end

if CollectableObjects then
    print(
        "Collectable objects:",
        #CollectableObjects:GetChildren()
    )
else
    warn(
        "CollectableObjects NOT FOUND"
    )
end

print("======================================")
