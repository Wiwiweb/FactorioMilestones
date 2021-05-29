require("presets")

local function get_delayed_chat_delay()
    local delay = 240
    if settings.global["milestones_check_frequency"].value == delay then -- Avoid on_nth_tick collisions
        return delay + 1
    end
    return delay
end

local function print_chat_delayed(event)
    if event.tick == 0 then return end
    game.print(global.delayed_chat_message)
    global.delayed_chat_message = nil
    script.on_nth_tick(get_delayed_chat_delay(), nil)
end

function create_delayed_chat()
    script.on_nth_tick(get_delayed_chat_delay(), function(event)
        print_chat_delayed(event)
    end)
end

local function is_preset_valid(preset)
    for _, mod_name in pairs(preset.required_mods) do
        if not game.active_mods[mod_name] then return false end
    end
    return true
end

function load_presets()
    log("Loading presets")
    global.valid_preset_names = {}

    local max_nb_mods_matched = -1
    for preset_name, preset in pairs(presets) do
        if is_preset_valid(preset) then
            table.insert(global.valid_preset_names, preset_name)
            if #preset.required_mods > max_nb_mods_matched then
                max_nb_mods_matched = #preset.required_mods
                global.current_preset_name = preset_name
            end
        end
    end
    log("Valid presets found: " .. serpent.line(global.valid_preset_names))
    log("Auto-detected preset used: " .. global.current_preset_name)

    global.delayed_chat_message = {"milestones.message_loaded_presets", global.current_preset_name}
    global.loaded_milestones = presets[global.current_preset_name].milestones
end

local function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

function reload_presets()
    log("Reloading presets")
    local added_presets = {}
    local new_valid_preset_names = {}
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
        global.delayed_chat_message = {"milestones.message_reloaded_presets_singular", added_presets[1]}
    elseif #added_presets > 1 then
        global.delayed_chat_message = {"milestones.message_reloaded_presets_plural", table.concat(added_presets, ", ")}
    end
end

script.on_configuration_changed(function(event)
    if next(event.mod_changes) ~= nil and event.mod_changes["milestones"] == nil then
        reload_presets()
    end

    -- We also do this here because for some reason on_nth_tick sometimes doesn't work in on_init
    -- I don't know why
    if global.delayed_chat_message ~= nil then
        create_delayed_chat()
    end
end)
