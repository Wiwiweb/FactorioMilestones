require("scripts.util")
require("presets.presets")
require("presets.preset_addons")

local function get_delayed_chat_delay()
    local delay = 240
    if settings.global["milestones_check_frequency"].value == delay then -- Avoid on_nth_tick collisions
        return delay + 1
    end
    return delay
end

local function print_chat_delayed(event)
    log("Printing delayed chat")
    if event.tick == 0 then return end
    for _, delayed_chat_message in pairs(global.delayed_chat_messages) do
        game.print(delayed_chat_message)
    end
    global.delayed_chat_messages = {}
    script.on_nth_tick(get_delayed_chat_delay(), nil)
end

function create_delayed_chat()
    script.on_nth_tick(get_delayed_chat_delay(), function(event)
        print_chat_delayed(event)
    end)
end

local function is_preset_valid(preset)
    local forbidden_mods = preset.forbidden_mods or {}
    for _, mod_name in pairs(preset.required_mods) do
        if not game.active_mods[mod_name] then return false end
    end
    for _, mod_name in pairs(forbidden_mods) do
        if game.active_mods[mod_name] then return false end
    end
    return true
end

function load_presets()
    log("Loading presets")
    global.valid_preset_names = {"Empty"}

    local max_nb_mods_matched = -1
    for preset_name, preset in pairs(presets) do
        if is_preset_valid(preset) then
            table.insert(global.valid_preset_names, preset_name)
            if #preset.required_mods > max_nb_mods_matched then
                max_nb_mods_matched = #preset.required_mods
                chosen_preset_name = preset_name
            end
        end
    end
    log("Valid presets found: " .. serpent.line(global.valid_preset_names))

    if global.current_preset_name == nil then
        global.current_preset_name = chosen_preset_name
        log("Auto-detected preset used: " .. global.current_preset_name)
        table.insert(global.delayed_chat_messages, {"milestones.message_loaded_presets", global.current_preset_name})
        global.loaded_milestones = presets[global.current_preset_name].milestones
    end
end

function load_preset_addons()
    log("Loading presets addons")
    log(serpent.block(game.active_mods))
    preset_addons_loaded = {}

    for preset_addon_name, preset_addon in pairs(preset_addons) do
	if preset_addon.build_func then
	    preset_addon.build_func(preset_addon)
	end
        if is_preset_valid(preset_addon) then
            table.insert(preset_addons_loaded, preset_addon_name)
            for _, milestone in ipairs(preset_addon.milestones) do
                table.insert(global.loaded_milestones, milestone)
            end
        end
    end
    log("Preset addons loaded: " .. serpent.line(preset_addons_loaded))

    if #preset_addons_loaded == 1 then
        table.insert(global.delayed_chat_messages, {"milestones.message_loaded_preset_addons_singular", preset_addons_loaded[1]})
    elseif #preset_addons_loaded > 1 then
        table.insert(global.delayed_chat_messages, {"milestones.message_loaded_preset_addons_plural", table.concat(preset_addons_loaded, ", ")})
    end
end

function reload_presets()
    log("Reloading presets")
    local added_presets = {}
    local new_valid_preset_names = {"Empty"}
    for preset_name, preset in pairs(presets) do
        if is_preset_valid(preset) then
            table.insert(new_valid_preset_names, preset_name)
            if not table_contains(global.valid_preset_names, preset_name) then
                table.insert(added_presets, preset_name)
            end
        end
    end
    global.valid_preset_names = new_valid_preset_names
    log("New presets found: " .. serpent.line(added_presets))
    log("New list of valid presets: " .. serpent.line(global.valid_preset_names))
    if #added_presets == 1 then
        table.insert(global.delayed_chat_messages, {"milestones.message_reloaded_presets_singular", added_presets[1]})
    elseif #added_presets > 1 then
        table.insert(global.delayed_chat_messages, {"milestones.message_reloaded_presets_plural", table.concat(added_presets, ", ")})
    end
end
