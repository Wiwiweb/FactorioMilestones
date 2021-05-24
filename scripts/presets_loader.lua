require("presets")

local function is_preset_valid(preset)
    for _, mod_name in pairs(preset.required_mods) do
        if not game.active_mods[mod_name] then return false end
    end
    return true
end

function load_presets()
    global.valid_presets = {}
    global.current_preset = {}

    local max_nb_mods_matched = -1
    for _, preset in pairs(presets) do
        if is_preset_valid(preset) then
            table.insert(global.valid_presets, preset)
            if #preset.required_mods > max_nb_mods_matched then
                max_nb_mods_matched = #preset.required_mods
                global.current_preset = preset
            end
        end
    end
    game.print{"", {"milestones.message_loaded_presets"}, global.current_preset.name}
end

function reload_presets()
    local added_presets = {}
    local new_valid_presets = {}
    for preset_key, preset in pairs(presets) do
        if is_preset_valid(preset) then
            table.insert(new_valid_presets, preset)
            if global.valid_presets[preset_key] == nil then
                table.insert(added_presets, preset.name)
            end
        end
    end
    if #added_presets == 1 then
        game.print{"message_reloaded_presets_singular", added_presets[1].name}
    elseif #added_presets > 1 then
        game.print{"message_reloaded_presets_plural", table.concat(added_presets, ", ")}
    end
end