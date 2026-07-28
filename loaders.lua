-- ========================================
--  Lus_Hub - Loader
--  开发者: Shadow
--  版本: v2.0
-- ========================================

print("[Lus_Hub] Starting...")

-- ==================== 加载语言表 ====================
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/allow-make/scripts_luau/main/Language.lua"))()

-- ==================== 加载 UI ====================
local Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- ==================== 显示 Loading ====================
Obsidian:Notify({
    Title = "Lus_Hub",
    Description = Language.Get("loading"),
    Time = 3,
})

-- ==================== 加载 ESP 库 ====================
local ESPLib = getgenv().mstudio45_ESP
if not ESPLib then
    warn("[Lus_Hub] ESP library not loaded")
    Obsidian:Notify({
        Title = Language.Get("warning"),
        Description = "ESP library not loaded",
        Time = 5,
    })
    return
end

-- ==================== 创建主窗口 ====================
local Window = Obsidian:CreateWindow({
    Title = "Lus_Hub",
    Footer = Language.Get("developer") .. " | " .. Language.Get("version"),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

-- ==================== 创建设置 Tab (语言切换) ====================
local SettingsTab = Window:AddTab("Settings", "settings")
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
        Obsidian:Notify({
            Title = Language.Get("information"),
            Description = "Language changed to: " .. Value,
            Time = 3,
        })
    end
})

-- ==================== 加载后端模块 ====================
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/allow-make/scripts_luau/main/ESP.lua"))()
local MiscModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/allow-make/scripts_luau/main/Misc.lua"))()
local AutoRoomsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/allow-make/scripts_luau/main/AutoRooms.lua"))()

-- ==================== 初始化模块 ====================
if ESPModule then
    ESPModule.Init(LusHub, Window, Obsidian, ESPLib, Language)
end

if MiscModule then
    MiscModule.Init(LusHub, Window, Obsidian, ESPLib, Language)
end

if AutoRoomsModule then
    AutoRoomsModule.Init(LusHub, Language)
end

-- ==================== 品牌启动音效 ====================
local function PlaySound(soundId, volume)
    pcall(function()
        local Sound = Instance.new("Sound", game:GetService("SoundService"))
        Sound.SoundId = "rbxassetid://" .. tostring(soundId or 4590662766)
        Sound.Volume = volume or 5
        Sound.PlayOnRemove = true
        Sound:Destroy()
    end)
end

PlaySound(4590662766, 5)

-- ==================== 加载完成通知 ====================
task.wait(1)
Obsidian:Notify({
    Title = "Lus_Hub",
    Description = Language.Get("loaded") .. " | " .. Language.Get("developer"),
    Time = 4,
})

print("[Lus_Hub] Loaded successfully")
