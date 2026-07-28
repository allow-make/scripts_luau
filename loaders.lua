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
--  注册所有 UI API，供其他模块使用
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

-- ========================================
--  LusHub 全局 API (注册给所有模块)
-- ========================================
_G.LusHub = {
    Name = "Lus_Hub",
    Developer = "Shadow",
    Version = "2.0",
    BrandSound = 4590662766,
    
    -- UI API
    Obsidian = Obsidian,
    ESPLib = ESPLib,
    Language = Language,
    Window = nil,
    
    -- 通知 API
    NotifyInfo = function(title, desc)
        Obsidian:Notify({
            Title = title or Language.Get("information"),
            Description = desc,
            Time = 5,
        })
    end,
    
    NotifyWarning = function(desc)
        Obsidian:Notify({
            Title = Language.Get("warning"),
            Description = desc,
            Time = 6,
        })
    end,
    
    -- 音效 API
    PlaySound = function(volume)
        pcall(function()
            local Sound = Instance.new("Sound", game:GetService("SoundService"))
            Sound.SoundId = "rbxassetid://4590662766"
            Sound.Volume = volume or 5
            Sound.PlayOnRemove = true
            Sound:Destroy()
        end)
    end,
    
    -- 日志 API
    LogInfo = function(msg)
        print("[Lus_Hub] [Info] " .. msg)
    end,
    
    LogWarning = function(msg)
        warn("[Lus_Hub] [Warning] " .. msg)
    end,
    
    -- 安全执行 API
    Try = function(func, errorMsg)
        local success, result = pcall(func)
        if not success then
            _G.LusHub:NotifyWarning(errorMsg or tostring(result))
            _G.LusHub:LogWarning(errorMsg or tostring(result))
            return nil
        end
        return result
    end,
}

local LusHub = _G.LusHub

-- ==================== 创建主窗口 ====================
local Window = Obsidian:CreateWindow({
    Title = "Lus_Hub",
    Footer = LusHub.Developer .. " | " .. LusHub.Version,
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

LusHub.Window = Window

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
        LusHub:NotifyInfo(Language.Get("information"), "Language changed to: " .. Value)
    end
})

-- ==================== 加载后端模块 ====================
local function LoadModule(url, name)
    local success, module = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and module and type(module.Init) == "function" then
        local ok, err = pcall(module.Init, LusHub)
        if ok then
            LusHub:LogInfo(name .. " module loaded")
        else
            LusHub:LogWarning(name .. " module failed: " .. tostring(err))
        end
    else
        LusHub:LogWarning(name .. " module not found")
    end
end

LoadModule("https://raw.githubusercontent.com/allow-make/scripts_luau/main/ESP.lua", "ESP")
LoadModule("https://raw.githubusercontent.com/allow-make/scripts_luau/main/Main.lua", "Main")
LoadModule("https://raw.githubusercontent.com/allow-make/scripts_luau/main/Misc.lua", "Misc")
LoadModule("https://raw.githubusercontent.com/allow-make/scripts_luau/main/AutoRooms.lua", "AutoRooms")

-- ==================== 品牌启动音效 ====================
LusHub:PlaySound(5)

-- ==================== 加载完成通知 ====================
task.wait(1)
LusHub:NotifyInfo("Lus_Hub", Language.Get("loaded") .. " | " .. Language.Get("developer"))

print("[Lus_Hub] Loaded successfully")
