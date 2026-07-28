-- ========================================
--  ██╗     ██╗   ██╗███████╗
--  ██║     ██║   ██║██╔════╝
--  ██║     ██║   ██║███████╗
--  ██║     ██║   ██║╚════██║
--  ███████╗╚██████╔╝███████║
--  ╚══════╝ ╚═════╝ ╚══════╝
--  
--  Lus_Hub - Doors 综合辅助
--  开发者: Shadow
--  版本: v2.0
--  单文件完整版 (仅依赖 ObsidianUI)
-- ========================================

-- ==================== 加载 ObsidianUI ====================
local Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

if not Obsidian then
    warn("[Lus_Hub] Failed to load ObsidianUI")
    return
end

-- ==================== 内置 ESP 库 (mstudio45) ====================
-- 完整内嵌，不依赖外部加载
local ESPLib = {}
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    local camera = workspace.CurrentCamera
    local character = nil
    local rootPart = nil

    local function GetPivot(inst)
        if inst.ClassName == "Bone" then return inst.TransformedWorldCFrame
        elseif inst.ClassName == "Attachment" then return inst.WorldCFrame
        elseif inst.ClassName == "Camera" then return inst.CFrame
        else return inst:GetPivot() end
    end

    local function FindPrimaryPart(inst)
        if not inst then return nil end
        return (inst:IsA("Model") and inst.PrimaryPart)
            or inst:FindFirstChildWhichIsA("BasePart")
            or inst:FindFirstChildWhichIsA("UnionOperation")
            or inst
    end

    local function DistanceFrom(inst, from)
        if not (inst and from) then return 9e9 end
        local pos1 = typeof(inst) == "Instance" and GetPivot(inst).Position or inst
        local pos2 = typeof(from) == "Instance" and GetPivot(from).Position or from
        return (pos2 - pos1).Magnitude
    end

    local MainGUI = Instance.new("ScreenGui")
    MainGUI.Parent = CoreGui
    MainGUI.Name = "LusHub_ESP"
    MainGUI.ResetOnSpawn = false

    local StorageFolder = Instance.new("Folder", game)
    StorageFolder.Name = "LusHub_ESP_Storage"

    ESPLib.Objects = {}
    ESPLib.GlobalConfig = {
        Highlighters = true,
        Billboards = true,
        Distance = true,
        Tracers = false,
        Arrows = true,
        Rainbow = false,
        Font = Enum.Font.Gotham,
    }
    ESPLib.RainbowHue = 0
    ESPLib.RainbowColor = Color3.new(1, 1, 1)

    function ESPLib:Add(settings)
        if not settings or not settings.Model then return nil end

        local espData = {
            Index = tostring(math.random(100000, 999999)),
            Settings = table.clone(settings),
            Deleted = false,
            Hidden = false,
        }

        espData.Settings.Name = settings.Name or settings.Model.Name
        espData.Settings.Color = settings.Color or Color3.new(1, 1, 1)
        espData.Settings.MaxDistance = settings.MaxDistance or 5000
        espData.Settings.FillTransparency = settings.FillTransparency or 0.65
        espData.Settings.OutlineTransparency = settings.OutlineTransparency or 0
        espData.Settings.FillColor = settings.FillColor or Color3.new(1, 1, 1)
        espData.Settings.OutlineColor = settings.OutlineColor or Color3.new(1, 1, 1)
        espData.Settings.TextSize = settings.TextSize or 16
        espData.Settings.StudsOffset = settings.StudsOffset or Vector3.new(0, 3, 0)
        espData.Settings.Visible = (settings.Visible ~= false)

        local billboard = Instance.new("BillboardGui")
        billboard.Name = espData.Index
        billboard.Parent = MainGUI
        billboard.Adornee = settings.Model
        billboard.StudsOffset = espData.Settings.StudsOffset
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.Enabled = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = espData.Settings.Name
        textLabel.TextColor3 = espData.Settings.Color
        textLabel.TextSize = espData.Settings.TextSize
        textLabel.Font = ESPLib.GlobalConfig.Font
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.Parent = billboard

        local highlighter = Instance.new("Highlight")
        highlighter.Name = espData.Index
        highlighter.Parent = MainGUI
        highlighter.Adornee = settings.Model
        highlighter.FillColor = espData.Settings.FillColor
        highlighter.OutlineColor = espData.Settings.OutlineColor
        highlighter.FillTransparency = espData.Settings.FillTransparency
        highlighter.OutlineTransparency = espData.Settings.OutlineTransparency

        local tracer = nil
        if settings.Tracer and settings.Tracer.Enabled then
            local path2d = Instance.new("Path2D")
            path2d.Parent = MainGUI
            path2d.Color3 = settings.Tracer.Color or Color3.new(1, 0, 0)
            path2d.Thickness = settings.Tracer.Thickness or 2
            path2d.Transparency = settings.Tracer.Transparency or 0
            tracer = path2d
        end

        local arrow = nil
        if settings.Arrow and settings.Arrow.Enabled then
            local img = Instance.new("ImageLabel")
            img.Parent = MainGUI
            img.Size = UDim2.new(0, 48, 0, 48)
            img.SizeConstraint = Enum.SizeConstraint.RelativeYY
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.BackgroundTransparency = 1
            img.BorderSizePixel = 0
            img.Image = "http://www.roblox.com/asset/?id=16368985219"
            img.ImageColor3 = settings.Arrow.Color or Color3.new(1, 1, 1)
            img.Visible = false
            arrow = img
        end

        local function UpdateESP()
            if espData.Deleted then return end
            if not espData.Settings.Visible then
                billboard.Enabled = false
                highlighter.Adornee = nil
                highlighter.Parent = StorageFolder
                if tracer then tracer.Visible = false end
                if arrow then arrow.Visible = false end
                return
            end

            local modelRoot = FindPrimaryPart(settings.Model)
            if not modelRoot then return end

            local dist = DistanceFrom(modelRoot, rootPart or camera)
            if dist > espData.Settings.MaxDistance then
                billboard.Enabled = false
                highlighter.Adornee = nil
                highlighter.Parent = StorageFolder
                if tracer then tracer.Visible = false end
                if arrow then arrow.Visible = false end
                return
            end

            billboard.Enabled = ESPLib.GlobalConfig.Billboards
            highlighter.Adornee = ESPLib.GlobalConfig.Highlighters and settings.Model or nil
            highlighter.Parent = ESPLib.GlobalConfig.Highlighters and MainGUI or StorageFolder

            if ESPLib.GlobalConfig.Rainbow then
                local color = ESPLib.RainbowColor
                textLabel.TextColor3 = color
                highlighter.FillColor = color
                highlighter.OutlineColor = color
                if tracer then tracer.Color3 = color end
                if arrow then arrow.ImageColor3 = color end
            else
                textLabel.TextColor3 = espData.Settings.Color
                highlighter.FillColor = espData.Settings.FillColor
                highlighter.OutlineColor = espData.Settings.OutlineColor
                if tracer then tracer.Color3 = espData.Settings.Tracer and espData.Settings.Tracer.Color or Color3.new(1, 0, 0) end
                if arrow then arrow.ImageColor3 = espData.Settings.Arrow and espData.Settings.Arrow.Color or Color3.new(1, 1, 1) end
            end

            if ESPLib.GlobalConfig.Distance then
                textLabel.Text = string.format("%s\n[%dm]", espData.Settings.Name, math.floor(dist))
            else
                textLabel.Text = espData.Settings.Name
            end

            -- Tracer
            if tracer then
                tracer.Visible = ESPLib.GlobalConfig.Tracers and espData.Settings.Tracer and espData.Settings.Tracer.Enabled or false
                if tracer.Visible and camera then
                    local screenPos = camera:WorldToViewportPoint(modelRoot.Position)
                    local from = espData.Settings.Tracer and espData.Settings.Tracer.From or "Bottom"
                    local viewSize = camera.ViewportSize
                    local fromPos
                    if from == "Top" then
                        fromPos = Vector2.new(viewSize.X / 2, 0)
                    elseif from == "Center" then
                        fromPos = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                    elseif from == "Mouse" then
                        local mouse = UserInputService:GetMouseLocation()
                        fromPos = Vector2.new(mouse.X, mouse.Y)
                    else
                        fromPos = Vector2.new(viewSize.X / 2, viewSize.Y)
                    end
                    tracer:SetControlPoints({
                        Path2DControlPoint.new(UDim2.fromOffset(fromPos.X, fromPos.Y)),
                        Path2DControlPoint.new(UDim2.fromOffset(screenPos.X, screenPos.Y))
                    })
                end
            end

            -- Arrow
            if arrow then
                local screenPos = camera:WorldToViewportPoint(modelRoot.Position)
                arrow.Visible = ESPLib.GlobalConfig.Arrows and espData.Settings.Arrow and espData.Settings.Arrow.Enabled and screenPos.Z <= 0
                if arrow.Visible then
                    local viewSize = camera.ViewportSize
                    local center = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                    local dir = Vector2.new(screenPos.X, screenPos.Y) - center
                    local angle = math.deg(math.atan2(dir.Y, dir.X)) + 90
                    local offset = (espData.Settings.Arrow.CenterOffset or 300) * 0.001 * viewSize.Y
                    arrow.Rotation = angle + 180
                    arrow.Position = UDim2.new(0, center.X + offset * math.cos(math.atan2(dir.Y, dir.X)), 0, center.Y + offset * math.sin(math.atan2(dir.Y, dir.X)))
                end
            end
        end

        espData.Update = UpdateESP
        table.insert(ESPLib.Objects, espData)

        return {
            Destroy = function()
                espData.Deleted = true
                billboard:Destroy()
                highlighter:Destroy()
                if tracer then tracer:Destroy() end
                if arrow then arrow:Destroy() end
            end,
            Show = function()
                espData.Settings.Visible = true
            end,
            Hide = function()
                espData.Settings.Visible = false
            end,
            Update = UpdateESP,
            Settings = espData.Settings,
        }
    end

    -- 更新循环
    RunService.RenderStepped:Connect(function()
        ESPLib.RainbowHue = (ESPLib.RainbowHue + 0.002) % 1
        ESPLib.RainbowColor = Color3.fromHSV(ESPLib.RainbowHue, 0.8, 1)

        character = Players.LocalPlayer.Character
        if character then
            rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        end
        camera = workspace.CurrentCamera

        for _, esp in pairs(ESPLib.Objects) do
            pcall(esp.Update)
        end
    end)

    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        camera = workspace.CurrentCamera
    end)
end

-- ==================== 语言表 (内嵌) ====================
local Language = {
    Current = "zh",
    zh = {
        loading = "Lus_Hub 加载中...",
        loaded = "Lus_Hub 加载完成",
        developer = "开发者: Shadow",
        version = "版本: v2.0",
        information = "信息",
        warning = "警告",
        settings = "设置",
        esp = "视觉",
        main = "主控",
        misc = "杂项",
        language = "语言",
        language_zh = "中文",
        language_en = "English",
        global_control = "全局控制",
        enable_esp = "启用 ESP",
        show_distance = "显示距离",
        rainbow_mode = "彩虹模式",
        item_highlight = "物品高亮",
        door = "门",
        key = "钥匙",
        gold = "金块",
        items = "物品",
        books = "书本",
        breaker = "开关",
        lever = "杠杆",
        hiding_spot = "隐藏点",
        entity_highlight = "实体高亮",
        monster_esp = "怪物 ESP",
        player_esp = "玩家 ESP",
        color = "颜色",
        base_features = "基础功能",
        noclip = "穿墙模式",
        speed = "速度修改",
        teleport = "传送",
        utilities = "实用功能",
        entity_alert = "怪物刷新提醒",
        fullbright = "全亮",
        anti_afk = "反 AFK",
        fps_unlocker = "FPS 解锁",
        fov = "视野调整",
        third_person = "第三人称",
        volume_control = "音量控制",
        auto_rooms = "自动 Rooms",
        auto_rooms_desc = "自动寻路 + 躲柜 + 通关",
        anti_rush = "Anti-Rush",
        anti_ambush = "Anti-Ambush",
        anti_a60 = "Anti-A-60",
        anti_a120 = "Anti-A-120",
        room = "房间",
        milestone = "里程碑达成",
        entity_detected = "检测到实体",
        rush = "Rush 出现了，请找柜子躲起来。",
        ambush = "Ambush 出现了，请找柜子躲起来。",
        ["a-60"] = "A-60 出现了，请找柜子躲起来。",
        ["a-120"] = "A-120 出现了，请找柜子躲起来。",
        room_milestone = "你已通过第 %d 扇门，继续前进！",
        room_1000 = "你已到达第 1000 扇门。现在你可以离开 Rooms 了。感谢使用 Lus Hub。",
        extensions = "扩展",
        extension_features = "扩展功能",
        select_extension = "选择扩展",
        select_extension_hint = "请从左侧选择要加载的扩展",
        refresh_extensions = "刷新扩展列表",
        extensions_refreshed = "扩展列表已刷新",
        file_not_found = "文件未找到",
        read_failed = "读取失败",
        compile_error = "编译错误",
        load_error = "加载错误",
        execution_error = "执行错误",
        extension_loaded = "扩展已加载",
        no_extensions = "没有找到扩展",
        no_lua_files = "没有找到 .lua 文件",
        place_files_in = "请将 .lua 文件放入: ",
    },
    en = {
        loading = "Lus_Hub loading...",
        loaded = "Lus_Hub loaded",
        developer = "Developer: Shadow",
        version = "Version: v2.0",
        information = "Information",
        warning = "Warning",
        settings = "Settings",
        esp = "ESP",
        main = "Main",
        misc = "Misc",
        language = "Language",
        language_zh = "中文",
        language_en = "English",
        global_control = "Global Control",
        enable_esp = "Enable ESP",
        show_distance = "Show Distance",
        rainbow_mode = "Rainbow Mode",
        item_highlight = "Item Highlight",
        door = "Door",
        key = "Key",
        gold = "Gold",
        items = "Items",
        books = "Books",
        breaker = "Breaker",
        lever = "Lever",
        hiding_spot = "Hiding Spot",
        entity_highlight = "Entity Highlight",
        monster_esp = "Monster ESP",
        player_esp = "Player ESP",
        color = "Color",
        base_features = "Base Features",
        noclip = "Noclip",
        speed = "Speed",
        teleport = "Teleport",
        utilities = "Utilities",
        entity_alert = "Entity Alert",
        fullbright = "Fullbright",
        anti_afk = "Anti-AFK",
        fps_unlocker = "FPS Unlocker",
        fov = "FOV",
        third_person = "Third Person",
        volume_control = "Volume Control",
        auto_rooms = "Auto Rooms",
        auto_rooms_desc = "Auto Pathfind + Hide + Complete",
        anti_rush = "Anti-Rush",
        anti_ambush = "Anti-Ambush",
        anti_a60 = "Anti-A-60",
        anti_a120 = "Anti-A-120",
        room = "Room",
        milestone = "Milestone Reached",
        entity_detected = "Entity Detected",
        rush = "Rush generated. Please find a cabinet to hide in.",
        ambush = "Ambush generated. Please find a cabinet to hide in.",
        ["a-60"] = "A-60 generated. Please find a cabinet to hide in.",
        ["a-120"] = "A-120 generated. Please find a cabinet to hide in.",
        room_milestone = "You have passed room %d. Keep going!",
        room_1000 = "You have arrived at the door of Room 1000. You can now leave the rooms. Thank you for using Lus Hub.",
        extensions = "Extensions",
        extension_features = "Extension Features",
        select_extension = "Select Extension",
        select_extension_hint = "Select an extension from the left panel",
        refresh_extensions = "Refresh Extensions",
        extensions_refreshed = "Extensions refreshed",
        file_not_found = "File not found",
        read_failed = "Read failed",
        compile_error = "Compile error",
        load_error = "Load error",
        execution_error = "Execution error",
        extension_loaded = "Extension loaded",
        no_extensions = "No extensions found",
        no_lua_files = "No .lua files found",
        place_files_in = "Place .lua files in: ",
    }
}

function Language.Get(key, ...)
    local lang = Language[Language.Current] or Language.zh
    local text = lang[key] or key
    if select("#", ...) > 0 then
        return string.format(text, ...)
    end
    return text
end

function Language.Set(lang)
    if Language[lang] then
        Language.Current = lang
        return true
    end
    return false
end

-- ==================== LusHub 品牌 ====================
local LusHub = {
    Name = "Lus_Hub",
    Developer = "Shadow",
    Version = "2.0",
    BrandSound = 4590662766,
}

function LusHub:NotifyInfo(title, desc)
    Obsidian:Notify({
        Title = title or Language.Get("information"),
        Description = desc,
        Time = 5,
    })
end

function LusHub:NotifyWarning(desc)
    Obsidian:Notify({
        Title = Language.Get("warning"),
        Description = desc,
        Time = 6,
    })
end

function LusHub:PlaySound(volume)
    pcall(function()
        local Sound = Instance.new("Sound", game:GetService("SoundService"))
        Sound.SoundId = "rbxassetid://4590662766"
        Sound.Volume = volume or 5
        Sound.PlayOnRemove = true
        Sound:Destroy()
    end)
end

function LusHub:LogInfo(msg)
    print("[Lus_Hub] [Info] " .. msg)
end

function LusHub:LogWarning(msg)
    warn("[Lus_Hub] [Warning] " .. msg)
end

-- ==================== 创建 UI ====================
local Window = Obsidian:CreateWindow({
    Title = "Lus_Hub",
    Footer = LusHub.Developer .. " | " .. LusHub.Version,
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

-- ========================================
--  Settings Tab
-- ========================================
local SettingsTab = Window:AddTab(Language.Get("settings"), "settings")
local SettingsGroup = SettingsTab:AddLeftGroupbox(Language.Get("language"))

SettingsGroup:AddDropdown("LanguageSelect", {
    Text = Language.Get("language"),
    Values = {Language.Get("language_zh"), Language.Get("language_en")},
    Default = Language.Current == "zh" and 1 or 2,
    Callback = function(Value)
        if Value == Language.Get("language_zh") then
            Language.Set("zh")
        else
            Language.Set("en")
        end
        LusHub:NotifyInfo(Language.Get("information"), "Language changed to: " .. Value)
    end
})

-- ========================================
--  ESP Tab
-- ========================================
local ESPTab = Window:AddTab(Language.Get("esp"), "eye")

local GlobalGroup = ESPTab:AddLeftGroupbox(Language.Get("global_control"))

GlobalGroup:AddToggle("ESPEnabled", {
    Text = Language.Get("enable_esp"),
    Default = true,
    Callback = function(Value)
        ESPLib.GlobalConfig.Highlighters = Value
        ESPLib.GlobalConfig.Billboards = Value
    end
})

GlobalGroup:AddToggle("ShowDistance", {
    Text = Language.Get("show_distance"),
    Default = true,
    Callback = function(Value)
        ESPLib.GlobalConfig.Distance = Value
    end
})

GlobalGroup:AddToggle("RainbowMode", {
    Text = Language.Get("rainbow_mode"),
    Default = false,
    Callback = function(Value)
        ESPLib.GlobalConfig.Rainbow = Value
    end
})

local ItemGroup = ESPTab:AddLeftGroupbox(Language.Get("item_highlight"))

local itemConfigs = {
    {key = "Door", name = Language.Get("door"), color = Color3.fromRGB(0, 255, 255)},
    {key = "Key", name = Language.Get("key"), color = Color3.fromRGB(0, 255, 0)},
    {key = "Gold", name = Language.Get("gold"), color = Color3.fromRGB(255, 204, 0)},
    {key = "Items", name = Language.Get("items"), color = Color3.fromRGB(0, 0, 255)},
    {key = "Books", name = Language.Get("books"), color = Color3.fromRGB(0, 255, 0)},
    {key = "Breaker", name = Language.Get("breaker"), color = Color3.fromRGB(255, 255, 0)},
    {key = "Lever", name = Language.Get("lever"), color = Color3.fromRGB(0, 255, 0)},
    {key = "HidingSpot", name = Language.Get("hiding_spot"), color = Color3.fromRGB(0, 200, 100)},
}

for _, cfg in ipairs(itemConfigs) do
    local toggle = ItemGroup:AddToggle(cfg.key, {
        Text = cfg.name,
        Default = true,
        Callback = function(Value) print(cfg.key .. " ESP:", Value) end
    })
    toggle:AddColorPicker(cfg.key .. "Color", {
        Default = cfg.color,
        Title = cfg.name .. " " .. Language.Get("color"),
        Callback = function(Value) print(cfg.key .. " color updated") end
    })
end

local EntityGroup = ESPTab:AddRightGroupbox(Language.Get("entity_highlight"))

EntityGroup:AddToggle("MonsterESP", {
    Text = Language.Get("monster_esp"),
    Default = true,
    Callback = function(Value) print("Monster ESP:", Value) end
})

EntityGroup:AddToggle("PlayerESP", {
    Text = Language.Get("player_esp"),
    Default = true,
    Callback = function(Value) print("Player ESP:", Value) end
})

-- 怪物扫描 + ESP
local MONSTERS = {"Rush", "Ambush", "Seek", "Figure", "A-60", "A-120", "Dupe", "Eyes", "Screech", "Halt", "Dread", "Giggle", "Lookman"}
local MonsterESPObjects = {}
local AlertCooldown = {}

local function ScanMonsters()
    for _, name in pairs(MONSTERS) do
        local entity = workspace:FindFirstChild(name)
        if entity then
            if not MonsterESPObjects[name] then
                MonsterESPObjects[name] = ESPLib:Add({
                    Name = "⚠ " .. name,
                    Model = entity,
                    Color = Color3.fromRGB(255, 0, 0),
                    ESPType = "Highlight",
                    FillColor = Color3.fromRGB(255, 0, 0),
                    FillTransparency = 0.4,
                    OutlineColor = Color3.fromRGB(255, 0, 0),
                    OutlineTransparency = 0.2,
                    MaxDistance = 200,
                    Tracer = { Enabled = true, Color = Color3.fromRGB(255, 0, 0), Thickness = 2, Transparency = 0.3, From = "Bottom" },
                    Visible = true,
                })
                if not AlertCooldown[name] or tick() - AlertCooldown[name] > 5 then
                    AlertCooldown[name] = tick()
                    local key = name:lower()
                    local msg = Language.Get(key) or ("%s generated. Be careful."):format(name)
                    LusHub:NotifyInfo(Language.Get("entity_detected"), msg)
                    LusHub:PlaySound(3)
                end
            end
        else
            if MonsterESPObjects[name] then
                pcall(function() MonsterESPObjects[name]:Destroy() end)
                MonsterESPObjects[name] = nil
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(ScanMonsters)
    end
end)

-- ========================================
--  Main Tab
-- ========================================
local MainTab = Window:AddTab(Language.Get("main"), "settings")

local BaseGroup = MainTab:AddLeftGroupbox(Language.Get("base_features"))

local NoclipToggle = BaseGroup:AddToggle("Noclip", {
    Text = Language.Get("noclip"),
    Default = false,
    Callback = function(Value) print("Noclip:", Value) end
})
NoclipToggle:AddKeyPicker("NoclipKeybind", {
    Default = "N",
    Mode = "Toggle",
    Text = Language.Get("noclip"),
    SyncToggleState = true,
})

local SpeedToggle = BaseGroup:AddToggle("Speed", {
    Text = Language.Get("speed"),
    Default = false,
    Callback = function(Value) print("Speed:", Value) end
})
SpeedToggle:AddSlider("SpeedValue", {
    Text = "Speed",
    Default = 25,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(Value) print("Speed value:", Value) end
})

BaseGroup:AddToggle("Teleport", {
    Text = Language.Get("teleport"),
    Default = false,
    Callback = function(Value) print("Teleport:", Value) end
})

local UtilGroup = MainTab:AddRightGroupbox(Language.Get("utilities"))

UtilGroup:AddToggle("EntityAlert", {
    Text = Language.Get("entity_alert"),
    Default = true,
    Callback = function(Value) print("Entity Alert:", Value) end
})

UtilGroup:AddToggle("Fullbright", {
    Text = Language.Get("fullbright"),
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
        else
            game:GetService("Lighting").Brightness = 0.5
            game:GetService("Lighting").Ambient = Color3.fromRGB(127, 127, 127)
        end
    end
})

UtilGroup:AddToggle("AntiAFK", {
    Text = Language.Get("anti_afk"),
    Default = true,
    Callback = function(Value)
        if Value then
            local GC = getconnections or get_signal_cons
            if GC then
                for _, conn in pairs(GC(game.Players.LocalPlayer.Idled)) do
                    if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
                end
            end
        end
    end
})

UtilGroup:AddToggle("FPSUnlocker", {
    Text = Language.Get("fps_unlocker"),
    Default = false,
    Callback = function(Value)
        if Value then settings().Rendering.QualityLevel = 1 else settings().Rendering.QualityLevel = 0 end
    end
})

local FOVToggle = UtilGroup:AddToggle("FOV", {
    Text = Language.Get("fov"),
    Default = false,
    Callback = function(Value) print("FOV:", Value) end
})
FOVToggle:AddSlider("FOVValue", {
    Text = "FOV",
    Default = 90,
    Min = 60,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = Value
        end
    end
})

UtilGroup:AddToggle("ThirdPerson", {
    Text = Language.Get("third_person"),
    Default = false,
    Callback = function(Value) print("Third Person:", Value) end
})

UtilGroup:AddSlider("VolumeControl", {
    Text = Language.Get("volume_control"),
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        game:GetService("SoundService").Volume = Value / 100
    end
})

-- ========================================
--  Misc Tab
-- ========================================
local MiscTab = Window:AddTab(Language.Get("misc"), "box")

local AutoGroup = MiscTab:AddLeftGroupbox(Language.Get("auto_rooms"))

AutoGroup:AddToggle("AutoRooms", {
    Text = Language.Get("auto_rooms_desc"),
    Default = true,
    Callback = function(Value) print("Auto Rooms:", Value) end
})

AutoGroup:AddDivider()

local AntiGroup = MiscTab:AddLeftGroupbox("Anti-Monster")

AntiGroup:AddToggle("AntiRush", {
    Text = Language.Get("anti_rush"),
    Default = false,
    Callback = function(Value) print("Anti-Rush:", Value) end
})

AntiGroup:AddToggle("AntiAmbush", {
    Text = Language.Get("anti_ambush"),
    Default = false,
    Callback = function(Value) print("Anti-Ambush:", Value) end
})

AntiGroup:AddToggle("AntiA60", {
    Text = Language.Get("anti_a60"),
    Default = false,
    Callback = function(Value) print("Anti-A-60:", Value) end
})

AntiGroup:AddToggle("AntiA120", {
    Text = Language.Get("anti_a120"),
    Default = false,
    Callback = function(Value) print("Anti-A-120:", Value) end
})

-- 扩展系统
local ExtensionListGroup = MiscTab:AddRightGroupbox(Language.Get("extensions"))
local ExtensionTabbox = MiscTab:AddRightTabbox(Language.Get("extension_features"))

local DefaultExtTab = ExtensionTabbox:AddTab(Language.Get("select_extension"))
DefaultExtTab:AddLabel(Language.Get("select_extension_hint"))

local ExtensionButtons = {}

local function LoadExtension(fileName)
    local path = "LusHub_Delta/" .. fileName
    if not isfile(path) then
        LusHub:NotifyWarning(Language.Get("file_not_found") .. ": " .. fileName)
        return
    end
    local source = readfile(path)
    if not source then
        LusHub:NotifyWarning(Language.Get("read_failed") .. ": " .. fileName)
        return
    end
    local func, err = loadstring(source)
    if not func then
        LusHub:NotifyWarning(Language.Get("compile_error") .. ": " .. err)
        return
    end
    local tabName = fileName:gsub("%.lua$", "")
    local extTab = ExtensionTabbox:AddTab(tabName)
    local api = {
        Tab = extTab,
        Window = Window,
        Obsidian = Obsidian,
        ESPLib = ESPLib,
        LusHub = LusHub,
        Language = Language,
        FileName = fileName,
    }
    local success, result = pcall(func, api)
    if not success then
        extTab:AddLabel(Language.Get("load_error") .. ": " .. tostring(result))
        LusHub:NotifyWarning(Language.Get("execution_error") .. ": " .. fileName)
        return
    end
    LusHub:NotifyInfo(Language.Get("extension_loaded"), fileName)
    LusHub:PlaySound(3)
end

local function RefreshExtensionList()
    for _, btn in pairs(ExtensionButtons) do
        pcall(function() btn:Destroy() end)
    end
    ExtensionButtons = {}
    local folderPath = "LusHub_Delta/"
    if not isfolder(folderPath) then
        makefolder(folderPath)
        ExtensionListGroup:AddLabel(Language.Get("no_extensions"))
        return
    end
    local files = listfiles(folderPath)
    local hasFiles = false
    for _, filePath in ipairs(files) do
        if filePath:match("%.lua$") then
            hasFiles = true
            local fileName = filePath:gsub(folderPath, "")
            local displayName = fileName:gsub("%.lua$", "")
            local btn = ExtensionListGroup:AddButton({
                Text = displayName,
                Func = function() LoadExtension(fileName) end
            })
            table.insert(ExtensionButtons, btn)
        end
    end
    if not hasFiles then
        ExtensionListGroup:AddLabel(Language.Get("no_lua_files"))
        ExtensionListGroup:AddLabel(Language.Get("place_files_in") .. folderPath)
    end
end

ExtensionListGroup:AddButton({
    Text = Language.Get("refresh_extensions"),
    Func = function()
        RefreshExtensionList()
        LusHub:NotifyInfo(Language.Get("extensions_refreshed"), "")
        LusHub:PlaySound(3)
    end
})

RefreshExtensionList()

-- ========================================
--  AutoRooms 核心逻辑 (内嵌)
-- ========================================
local function StartAutoRooms()
    if game.PlaceId ~= 6839171747 or game.ReplicatedStorage.GameData.Floor.Value ~= "Rooms" then
        LusHub:LogInfo("AutoRooms: Not in Rooms mode")
        return
    end

    if workspace:FindFirstChild("PathFindPartsFolder") then
        LusHub:NotifyWarning("AutoRooms - Pathfinding parts already exist")
        return
    end

    local PathfindingService = game:GetService("PathfindingService")
    local LocalPlayer = game.Players.LocalPlayer
    local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
    local RunService = game:GetService("RunService")

    local PathFolder = Instance.new("Folder", workspace)
    PathFolder.Name = "PathFindPartsFolder"

    -- 反 AFK
    local GC = getconnections or get_signal_cons
    if GC then
        for _, conn in pairs(GC(LocalPlayer.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end

    -- 移除 A90
    pcall(function()
        local modules = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules
        if modules:FindFirstChild("A90") then
            modules.A90.Name = "lol"
        end
    end)

    local function GetDistance(p1, p2) return (p1 - p2).Magnitude end

    local function SortByDistance(objects, ref)
        table.sort(objects, function(a, b)
            return GetDistance(a.Position, ref) < GetDistance(b.Position, ref)
        end)
        return objects
    end

    local function FindLocker()
        local char = LocalPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
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
        return SortByDistance(lockers, root.Position)[1]
    end

    local function GetTarget()
        local entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
        if entity then
            local main = entity:FindFirstChild("Main")
            if main and main.Position.Y > -4 then
                return FindLocker()
            end
        end
        return workspace.CurrentRooms[LatestRoom.Value].Door.Door
    end

    local function ComputePath(dest)
        local char = LocalPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local path = PathfindingService:CreatePath({
            AgentRadius = 1, AgentHeight = 5, AgentCanJump = false,
            WaypointSpacing = 2, AgentMaxSlope = 45
        })
        pcall(function() path:ComputeAsync(root.Position, dest.Position) end)
        if path.Status == Enum.PathStatus.Complete then
            return path:GetWaypoints()
        end
        return nil
    end

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

    local function FollowPath(waypoints)
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        for _, wp in pairs(waypoints) do
            if root.Anchored == false then
                hum:MoveTo(wp.Position)
                hum.MoveToFinished:Wait()
            end
        end
    end

    local function SetupMovement()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        local col = char:FindFirstChild("Collision")
        if root then root.CanCollide = false end
        if col then
            col.CanCollide = false
            col.Size = Vector3.new(8, col.Size.Y, 8)
        end
        if hum then hum.WalkSpeed = 25 end
    end

    local LastMilestone = 0

    LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        local current = math.clamp(LatestRoom.Value, 1, 1000)
        if current % 100 == 0 and current ~= LastMilestone and current < 1000 then
            LastMilestone = current
            LusHub:NotifyInfo(Language.Get("milestone"), Language.Get("room_milestone", current))
            LusHub:PlaySound(3)
        end
        if current == 1000 then
            LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
            PathFolder:ClearAllChildren()
            LusHub:PlaySound(5)
            LusHub:NotifyInfo(Language.Get("milestone"), Language.Get("room_1000"))
        end
    end)

    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        SetupMovement()
        local target = GetTarget()
        if target then
            local waypoints = ComputePath(target)
            if waypoints then
                RenderPath(waypoints)
                FollowPath(waypoints)
            end
        end
    end)

    LusHub:LogInfo("AutoRooms loaded")
end

-- ========================================
--  启动 AutoRooms (不阻塞主线程)
-- ========================================
task.spawn(StartAutoRooms)

-- ========================================
--  品牌启动
-- ========================================
LusHub:PlaySound(5)
task.wait(1)
LusHub:NotifyInfo("Lus_Hub", Language.Get("loaded") .. " | " .. Language.Get("developer"))

print("========================================")
print("  Lus_Hub loaded successfully")
print("  Developer: Shadow")
print("  Version: 2.0")
print("  Toggle UI: RightControl")
print("========================================")
