-- ========================================
--  ██╗     ██╗   ██╗███████╗
--  ██║     ██║   ██║██╔════╝
--  ██║     ██║   ██║███████╗
--  ██║     ██║   ██║╚════██║
--  ███████╗╚██████╔╝███████║
--  ╚══════╝ ╚═════╝ ╚══════╝
--  
--  Lus_Hub - Loader
--  开发者: Shadow
--  版本: v2.0
--  入口: 加载所有模块
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

-- ==================== LusHub 品牌 ====================
local LusHub = {
    Name = "Lus_Hub",
    Developer = "Shadow",
    Version = "2.0",
    BrandSound = 4590662766,
}

function LusHub:LogInfo(msg)
    print("[Lus_Hub] [Info] " .. msg)
end

function LusHub:LogWarning(msg)
    warn("[Lus_Hub] [Warning] " .. msg)
end

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

-- ==================== 创建主窗口 ====================
local Window = Obsidian:CreateWindow({
    Title = "Lus_Hub",
    Footer = Language.Get("developer") .. " | " .. Language.Get("version"),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

-- ==================== Settings Tab (语言切换) ====================
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
local MainModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/allow-make/scripts_luau/main/Main.lua"))()

-- ==================== 初始化模块 ====================
local function InitModule(module, name)
    if module and type(module.Init) == "function" then
        local success, err = pcall(module.Init, LusHub, Window, Obsidian, ESPLib, Language)
        if success then
            LusHub:LogInfo(name .. " module loaded")
        else
            LusHub:LogWarning(name .. " module failed: " .. tostring(err))
        end
    else
        LusHub:LogWarning(name .. " module not found or invalid")
    end
end

InitModule(ESPModule, "ESP")
InitModule(MiscModule, "Misc")
InitModule(AutoRoomsModule, "AutoRooms")
InitModule(MainModule, "Main")

-- ==================== 品牌启动音效 ====================
LusHub:PlaySound(5)

-- ==================== 加载完成通知 ====================
task.wait(1)
LusHub:NotifyInfo("Lus_Hub", Language.Get("loaded") .. " | " .. Language.Get("developer"))

print("[Lus_Hub] Loaded successfully")
