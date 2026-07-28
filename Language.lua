-- ========================================
--  Lus_Hub - 语言表
--  支持: 中文 / English
-- ========================================

local Language = {
    -- 当前语言: "zh" 或 "en"
    Current = "zh",
    
    -- ========== 中文 ==========
    zh = {
        -- 通用
        loading = "Lus_Hub 加载中...",
        loaded = "Lus_Hub 加载完成",
        developer = "开发者: Shadow",
        version = "版本: v2.0",
        
        -- 通知标题
        information = "信息",
        warning = "警告",
        error = "错误",
        entity_detected = "检测到实体",
        milestone = "里程碑达成",
        
        -- 怪物提醒
        rush = "Rush 出现了，请找柜子躲起来。",
        ambush = "Ambush 出现了，请找柜子躲起来。",
        a60 = "A-60 出现了，请找柜子躲起来。",
        a120 = "A-120 出现了，请找柜子躲起来。",
        screech = "Screech 出现了，找到它并面对它。",
        eyes = "Eyes 出现了，不要看它。",
        lookman = "Lookman 出现了，不要看它。",
        halt = "Halt 将在下一个房间出现。",
        seek = "Seek 将在下一个房间出现。",
        figure = "Figure 将在下一个房间出现。",
        default_entity = "检测到实体，请小心。",
        
        -- 里程碑
        room_milestone = "你已通过第 %d 扇门，继续前进！",
        room_1000 = "你已到达第 1000 扇门。现在你可以离开 Rooms 了。感谢使用 Lus Hub。",
        
        -- 设置
        language = "语言",
        language_zh = "中文",
        language_en = "English",
    },
    
    -- ========== English ==========
    en = {
        loading = "Lus_Hub loading...",
        loaded = "Lus_Hub loaded",
        developer = "Developer: Shadow",
        version = "Version: v2.0",
        
        information = "Information",
        warning = "Warning",
        error = "Error",
        entity_detected = "Entity Detected",
        milestone = "Milestone Reached",
        
        rush = "Rush generated. Please find a cabinet to hide in.",
        ambush = "Ambush generated. Please find a cabinet to hide in.",
        a60 = "A-60 generated. Please find a cabinet to hide in.",
        a120 = "A-120 generated. Please find a cabinet to hide in.",
        screech = "Screech generated. Please find it and face it.",
        eyes = "Eyes generated. Don't look at him.",
        lookman = "Lookman generated. Don't look at him.",
        halt = "Halt will be generated in the next room.",
        seek = "Seek will be generated in the next room.",
        figure = "Figure will be generated in the next room.",
        default_entity = "Entity generated. Be careful.",
        
        room_milestone = "You have passed room %d. Keep going!",
        room_1000 = "You have arrived at the door of Room 1000. You can now leave the rooms. Thank you for using Lus Hub.",
        
        language = "Language",
        language_zh = "中文",
        language_en = "English",
    },
}

-- ========================================
--  获取文本
-- ========================================
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

return Language
