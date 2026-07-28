-- ========================================
--  Lus_Hub - 语言表
--  支持: 中文 / English
-- ========================================

local Language = {
    Current = "zh",
    
    zh = {
        -- ===== 通用 =====
        loading = "Lus_Hub 加载中...",
        loaded = "Lus_Hub 加载完成",
        developer = "开发者: Shadow",
        version = "版本: v2.0",
        information = "信息",
        warning = "警告",
        error = "错误",
        entity_detected = "检测到实体",
        milestone = "里程碑达成",
        
        -- ===== 怪物提醒 =====
        rush = "Rush 出现了，请找柜子躲起来。",
        ambush = "Ambush 出现了，请找柜子躲起来。",
        ["a-60"] = "A-60 出现了，请找柜子躲起来。",
        ["a-120"] = "A-120 出现了，请找柜子躲起来。",
        screech = "Screech 出现了，找到它并面对它。",
        eyes = "Eyes 出现了，不要看它。",
        lookman = "Lookman 出现了，不要看它。",
        halt = "Halt 将在下一个房间出现。",
        seek = "Seek 将在下一个房间出现。",
        figure = "Figure 将在下一个房间出现。",
        default_entity = "检测到实体，请小心。",
        
        -- ===== 里程碑 =====
        room_milestone = "你已通过第 %d 扇门，继续前进！",
        room_1000 = "你已到达第 1000 扇门。现在你可以离开 Rooms 了。感谢使用 Lus Hub。",
        
        -- ===== 设置 =====
        language = "语言",
        language_zh = "中文",
        language_en = "English",
        
        -- ===== ESP 标签 =====
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
        
        -- ===== Misc 标签 =====
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
        
        -- ===== Main 标签 =====
        base_features = "基础功能",
        noclip = "穿墙模式",
        speed = "速度修改",
        teleport = "玩家传送",
        utilities = "实用功能",
        entity_alert = "怪物刷新提醒",
        fullbright = "全亮",
        anti_afk = "反 AFK",
        fps_unlocker = "FPS 解锁",
        fov = "视野调整",
        third_person = "第三人称",
        custom_cursor = "自定义光标",
        volume_control = "音量控制",
        
        -- ===== AutoRooms =====
        auto_rooms = "自动 Rooms",
        auto_rooms_desc = "自动寻路 + 躲柜 + 通关",
        room_display = "房间显示",
        room = "房间",
    },
    
    en = {
        -- ===== General =====
        loading = "Lus_Hub loading...",
        loaded = "Lus_Hub loaded",
        developer = "Developer: Shadow",
        version = "Version: v2.0",
        information = "Information",
        warning = "Warning",
        error = "Error",
        entity_detected = "Entity Detected",
        milestone = "Milestone Reached",
        
        -- ===== Monster Messages =====
        rush = "Rush generated. Please find a cabinet to hide in.",
        ambush = "Ambush generated. Please find a cabinet to hide in.",
        ["a-60"] = "A-60 generated. Please find a cabinet to hide in.",
        ["a-120"] = "A-120 generated. Please find a cabinet to hide in.",
        screech = "Screech generated. Please find it and face it.",
        eyes = "Eyes generated. Don't look at him.",
        lookman = "Lookman generated. Don't look at him.",
        halt = "Halt will be generated in the next room.",
        seek = "Seek will be generated in the next room.",
        figure = "Figure will be generated in the next room.",
        default_entity = "Entity generated. Be careful.",
        
        -- ===== Milestones =====
        room_milestone = "You have passed room %d. Keep going!",
        room_1000 = "You have arrived at the door of Room 1000. You can now leave the rooms. Thank you for using Lus Hub.",
        
        -- ===== Settings =====
        language = "Language",
        language_zh = "中文",
        language_en = "English",
        
        -- ===== ESP Labels =====
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
        
        -- ===== Misc Labels =====
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
        
        -- ===== Main Labels =====
        base_features = "Base Features",
        noclip = "Noclip",
        speed = "Speed Modifier",
        teleport = "Teleport",
        utilities = "Utilities",
        entity_alert = "Entity Spawn Alert",
        fullbright = "Fullbright",
        anti_afk = "Anti-AFK",
        fps_unlocker = "FPS Unlocker",
        fov = "FOV Modifier",
        third_person = "Third Person",
        custom_cursor = "Custom Cursor",
        volume_control = "Volume Control",
        
        -- ===== AutoRooms =====
        auto_rooms = "Auto Rooms",
        auto_rooms_desc = "Auto Pathfind + Hide + Complete",
        room_display = "Room Display",
        room = "Room",
    },
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

return Language
