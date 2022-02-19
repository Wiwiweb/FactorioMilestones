require("scripts.gui_settings_page")

function toggle_import_export_page(player_index, button_element, import)
    if button_element.style.name == "flib_selected_tool_button" then
        close_import_export_page(player_index)
    else
        close_import_export_page(player_index)
        build_import_export_page(player_index, button_element, import)
    end
end

local function milestones_table_to_json(table)
    local json = game.table_to_json(table)

    -- Beautification
    -- Example milestone line:
    -- {"type":"item","name":"se-cargo-rocket-section","quantity":100},

    json = json:gsub("%[{", "[\n  {")
    json = json:gsub("},{", "},\n  {")
    json = json:gsub("\",\"", "\", \"")
    json = json:gsub("}]", "}\n]")
    return json
end

function build_import_export_page(player_index, button_element, import)
    local titlebar_caption = import and {"milestones.settings_import_title"} or {"milestones.settings_export_title"}

    local outer_frame = global.players[player_index].outer_frame
    local import_export_frame = outer_frame.milestones_settings_import_export
    import_export_frame.milestones_settings_import_export_titlebar.milestones_settings_import_export_titlebar_label.caption = titlebar_caption

    local inside_frame = import_export_frame.milestones_settings_import_export_inside
    inside_frame.clear()
    
    local scroll = inside_frame.add{type="scroll-pane", name="milestones_import_export_scroll"}
    local textbox = scroll.add{type="text-box", name="milestones_settings_import_export_textbox", style="milestones_import_export_textbox", horizontal_scroll_policy="dont-show-but-allow-scrolling"}
    if not import then
        textbox.text = milestones_table_to_json(get_resulting_milestones_array(player_index))
        textbox.read_only = true
    end
    
    local button_frame = inside_frame.add{type="flow", direction="horizontal"}
    button_frame.add{type="empty-widget", style="flib_horizontal_pusher"}
    if import then
        button_frame.add{type="button", style="dialog_button", caption={"milestones.settings_import"}, tags={action="milestones_import_settings"}}
    else
        button_frame.add{type="button", style="dialog_button", caption={"gui.close"}, tags={action="milestones_close_import_export"}}
    end
    
    textbox.select_all()
    textbox.focus()
    import_export_frame.visible = true

    button_element.style = "flib_selected_tool_button"
end

function close_import_export_page(player_index)
    local outer_frame = global.players[player_index].outer_frame
    local import_export_frame = outer_frame.milestones_settings_import_export
    local inside_frame = import_export_frame.milestones_settings_import_export_inside

    inside_frame.clear()
    import_export_frame.visible = false

    local button_flow = global.players[player_index].inner_frame.milestones_preset_flow
    button_flow.milestones_import_button.style = "tool_button"
    button_flow.milestones_export_button.style = "tool_button"
end

function import_settings(player_index)
    local import_string = global.players[player_index].outer_frame
                              .milestones_settings_import_export
                              .milestones_settings_import_export_inside
                              .milestones_import_export_scroll
                              .milestones_settings_import_export_textbox.text
    local imported_milestones, error = convert_and_validate_imported_json(import_string)
    if imported_milestones == nil then
        game.players[player_index].print(error)
    else
        local settings_flow = global.players[player_index].settings_flow
        settings_flow.clear()
        fill_settings_flow(settings_flow, imported_milestones)
        local preset_dropdown = global.players[player_index].inner_frame.milestones_preset_flow.milestones_preset_dropdown
        preset_dropdown.caption = {"milestones.settings_imported"}
        preset_dropdown.tags = {action="milestones_change_preset", imported=true} -- For some reason, can't just change a single tag
        close_import_export_page(player_index)
    end
end
