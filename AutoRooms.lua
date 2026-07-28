-- ========================================
--  Lus_Hub - AutoRooms 后端
--  逻辑: 寻路 + 躲柜 + 通关
--  房间显示: 改用黑曜石 UI 通知
-- ========================================

local AutoRoomsModule = {}

function AutoRoomsModule.Init(LusHub)
    local Language = LusHub.Language
    local Obsidian = LusHub.Obsidian

    -- ========================================
    --  环境检测
    -- ========================================
    local function IsRoomsMode()
        return game.PlaceId == 6839171747 
            and game.ReplicatedStorage.GameData.Floor.Value == "Rooms"
    end

    if not IsRoomsMode() then
        LusHub:LogInfo("AutoRooms: Not in Rooms mode, skipping")
        return
    end

    if workspace:FindFirstChild("PathFindPartsFolder") then
        LusHub:NotifyWarning("AutoRooms - Pathfinding parts already exist")
        return
    end

    -- ========================================
    --  核心服务
    -- ========================================
    local Services = {
        Pathfinding = game:GetService("PathfindingService"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
    }

    local LocalPlayer = Services.Players.LocalPlayer
    local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom

    -- ========================================
    --  路径可视化
    -- ========================================
    local PathFolder = Instance.new("Folder", workspace)
    PathFolder.Name = "PathFindPartsFolder"

    -- ========================================
    --  反 AFK
    -- ========================================
    local function DisableAFK()
        local connections = getconnections or get_signal_cons
        if connections then
            for _, conn in pairs(connections(LocalPlayer.Idled)) do
                if conn.Disable then
                    conn:Disable()
                elseif conn.Disconnect then
                    conn:Disconnect()
                end
            end
        end
    end
    DisableAFK()

    -- ========================================
    --  移除 A90
    -- ========================================
    local function RemoveA90()
        pcall(function()
            local modules = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules
            local a90 = modules:FindFirstChild("A90")
            if a90 then
                a90.Name = "lol"
            end
        end)
    end
    RemoveA90()

    -- ========================================
    --  工具函数
    -- ========================================
    local function GetDistance(pos1, pos2)
        return (pos1 - pos2).Magnitude
    end

    local function SortByDistance(objects, reference)
        table.sort(objects, function(a, b)
            return GetDistance(a.Position, reference) < GetDistance(b.Position, reference)
        end)
        return objects
    end

    -- ========================================
    --  找柜子
    -- ========================================
    local function FindNearestLocker()
        local character = LocalPlayer.Character
        if not character then return nil end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        local lockers = {}
        local rooms = workspace:FindFirstChild("CurrentRooms")
        if not rooms then return nil end

        for _, obj in pairs(rooms:GetDescendants()) do
            if obj.Name == "Rooms_Locker" then
                local door = obj:FindFirstChild("Door")
                local hidden = obj:FindFirstChild("HiddenPlayer")
                if door and hidden and not hidden.Value and door.Position.Y > -3 then
                    table.insert(lockers, door)
                end
            end
        end

        if #lockers == 0 then return nil end
        local sorted = SortByDistance(lockers, root.Position)
        return sorted[1]
    end

    -- ========================================
    --  目标选择
    -- ========================================
    local function GetTarget()
        local entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
        if entity then
            local main = entity:FindFirstChild("Main")
            if main and main.Position.Y > -4 then
                return FindNearestLocker()
            end
        end
        return workspace.CurrentRooms[LatestRoom.Value].Door.Door
    end

    -- ========================================
    --  路径计算
    -- ========================================
    local function CalculatePath(destination)
        local character = LocalPlayer.Character
        if not character then return nil end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        local path = Services.Pathfinding:CreatePath({
            AgentRadius = 1,
            AgentHeight = 5,
            AgentCanJump = false,
            WaypointSpacing = 2,
            AgentMaxSlope = 45
        })

        local success = pcall(function()
            path:ComputeAsync(root.Position, destination.Position)
        end)

        if not success then return nil end

        if path.Status == Enum.PathStatus.Complete then
            return path:GetWaypoints()
        end
        return nil
    end

    -- ========================================
    --  路径渲染
    -- ========================================
    local function RenderPath(waypoints)
        PathFolder:ClearAllChildren()
        for _, wp in pairs(waypoints) do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Position = wp.Position
            part.Shape = "Cylinder"
            part.Rotation = Vector3.new(0, 0, 90)
            part.Material = "Neon"
            part.BrickColor = BrickColor.new("Bright green")
            part.Anchored = true
            part.CanCollide = false
            part.Parent = PathFolder
        end
    end

    -- ========================================
    --  路径跟随
    -- ========================================
    local function FollowPath(waypoints)
        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end

        for _, wp in pairs(waypoints) do
            if root.Anchored == false then
                humanoid:MoveTo(wp.Position)
                humanoid.MoveToFinished:Wait()
            end
        end
    end

    -- ========================================
    --  移动控制
    -- ========================================
    local function SetupMovement()
        local character = LocalPlayer.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local collision = character:FindFirstChild("Collision")

        if root then
            root.CanCollide = false
        end

        if collision then
            collision.CanCollide = false
            collision.Size = Vector3.new(8, collision.Size.Y, 8)
        end

        if humanoid then
            humanoid.WalkSpeed = 25
        end
    end

    -- ========================================
    --  房间里程碑 (使用黑曜石通知)
    -- ========================================
    local LastMilestone = 0

    local function CheckMilestone(room)
        if room % 100 == 0 and room ~= LastMilestone and room < 1000 then
            LastMilestone = room
            LusHub:NotifyInfo(
                Language.Get("milestone"),
                Language.Get("room_milestone", room)
            )
            LusHub:PlaySound(3)
        end

        if room == 1000 then
            LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
            PathFolder:ClearAllChildren()
            LusHub:PlaySound(5)
            LusHub:NotifyInfo(
                Language.Get("milestone"),
                Language.Get("room_1000")
            )
        end
    end

    -- ========================================
    --  房间监听
    -- ========================================
    LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        local current = math.clamp(LatestRoom.Value, 1, 1000)
        CheckMilestone(current)
    end)

    -- ========================================
    --  主循环
    -- ========================================
    Services.RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end

        SetupMovement()

        local destination = GetTarget()
        if destination then
            local waypoints = CalculatePath(destination)
            if waypoints then
                RenderPath(waypoints)
                FollowPath(waypoints)
            end
        end
    end)

    LusHub:LogInfo("AutoRooms loaded")
end

return AutoRoomsModule
