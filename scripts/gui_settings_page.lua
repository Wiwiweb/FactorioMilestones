local table = require("__flib__.table")
require("presets.presets")
require("scripts.milestones_util")

local function refresh_arrow_buttons(gui_index, settings_flow)
    local arrows_flow = settings_flow.children[gui_index].milestones_arrows_flow
    arrows_flow.clear()

    if gui_index == 1 then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_up", sprite="milestones_arrow_up", style="milestones_small_button", tags={action="milestones_swap_setting", direction=-1}}
    end
    if gui_index == #settings_flow.children then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_down", sprite="milestones_arrow_down", style="milestones_small_button", tags={action="milestones_swap_setting", direction=1}}
    end
end

local function refresh_all_arrow_buttons(settings_flow)
    for i, child in pairs(settings_flow.children) do
        if child.type == "flow" then
            refresh_arrow_buttons(i, settings_flow)
        end
    end
end

local function add_milestone_setting(milestone, settings_flow, gui_index)
    local prototype
    local elem_button

    local milestone_flow = settings_flow.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big", index=gui_index}
    milestone_flow.add{type="sprite", sprite="milestones_icon_"..milestone.type, tooltip={"milestones.type_"..milestone.type}}

    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="item",
            item=milestone.name, tags={action="milestones_change_setting", milestone_type="item"}}
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="fluid",
            fluid=milestone.name, tags={action="milestones_change_setting", milestone_type="fluid"}}
    elseif milestone.type == "technology" then
        prototype = game.technology_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="technology",
            technology=milestone.name, tags={action="milestones_change_setting", milestone_type="technology"}}
    elseif milestone.type == "kill" then
        prototype = game.entity_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="entity",
            entity=milestone.name, tags={action="milestones_change_setting", milestone_type="kill"},
            elem_filters={{filter="entity-with-health"}}}
    end

    if milestone.name ~= nil and prototype == nil then
        milestone_flow.add{type="label", caption={"", "[color=red]", {"milestones.invalid_entry"}, milestone.name, "[/color]"}}
    else
        milestone_flow.add(elem_button)

        local caption = (prototype ~= nil) and prototype.localised_name or ""
        milestone_flow.add{type="label", name="milestones_settings_label", caption=caption}
    end

    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}

    local unique_technology = milestone.type ~= "technology" or (prototype ~= nil and prototype.research_unit_count_formula ~= nil) -- No text field or infinity button for unique technologies

    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, clear_and_focus_on_right_click=true,
        tags={action="milestones_change_setting_quantity"}, style="short_number_textfield", visible=unique_technology, tooltip={"milestones.settings_quantity_tooltip"}}

    local infinity_button = milestone_flow.add({type="sprite-button", sprite="milestones_infinity_icon", tags={action="milestones_settings_infinity_button"}, style="milestones_grey_button", visible=unique_technology,
        tooltip={"milestones.settings_infinity_button_tooltip"}})
    milestone_flow.add({type="textfield", name="milestones_settings_next_textfield", text=milestone.next, style="milestones_very_short_textfield", visible=false,
        clear_and_focus_on_right_click=true, tooltip={"milestones.settings_next_textfield_tooltip"}})
    milestone_flow.add{type="empty-widget", name="milestones_settings_next_spacer", style="milestones_very_short_spacer", visible=true}
    if milestone.next ~= nil then
        toggle_infinity_button(infinity_button)
    end

    milestone_flow.add{type="sprite-button", sprite="utility/trash", style="milestones_trash_button", tags={action="milestones_delete_setting"}}
    milestone_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}

    return milestone_flow
end

function toggle_infinity_button(button_element)
    local textfield_element = button_element.parent.milestones_settings_next_textfield
    local spacer_element = button_element.parent.milestones_settings_next_spacer
    if button_element.style.name == "milestones_selected_grey_button" then
        button_element.style = "milestones_grey_button"
        textfield_element.visible = false
        spacer_element.visible = true
    else
        button_element.style = "milestones_selected_grey_button"
        textfield_element.visible = true
        spacer_element.visible = false
        if textfield_element.text == nil or textfield_element.text == "" then
            textfield_element.text = "x10"
        end
    end
end

local function get_milestones_array_element(flow, allow_empty, player_index)
    if not allow_empty and (flow.milestones_settings_item == nil or flow.milestones_settings_item.elem_value == nil) then
        return nil
    end
    local quantity = tonumber(flow.milestones_settings_quantity.text) or 1
    local next_formula = flow.milestones_settings_next_textfield.text
    if next_formula == "" then next_formula = nil end
    if next_formula ~= nil then
        local operator, _ = parse_next_formula(next_formula)
        if operator == nil then
            game.players[player_index].print({"", {"milestones.message_invalid_next"}, next_formula})
            next_formula = nil
        end
    end
    return {
        type=flow.milestones_settings_item.tags.milestone_type,
        name=flow.milestones_settings_item.elem_value,
        quantity=quantity,
        next=next_formula
    }
end

function get_resulting_milestones_array(player_index)
    local resulting_milestones = {}
    local settings_flow = global.players[player_index].settings_flow
    for _, child in pairs(settings_flow.children) do
        if child.type == "flow" then
            local milestone = get_milestones_array_element(child, false, player_index)
            table.insert(resulting_milestones, milestone)
        end
    end
    return resulting_milestones
end

function fill_settings_flow(settings_flow, milestones)
    for i, milestone in pairs(milestones) do
        local item_flow = add_milestone_setting(milestone, settings_flow, nil)
        if i < #milestones then
            settings_flow.add{type="line"}
        end
    end
    refresh_all_arrow_buttons(settings_flow)
end

function build_settings_page(player)
    local main_frame = global.players[player.index].main_frame
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.settings_title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = false
    main_frame.milestones_titlebar.milestones_close_button.visible = false
    main_frame.milestones_dialog_buttons.visible = true

    local inner_frame = global.players[player.index].inner_frame

    local preset_flow = inner_frame.add{type="flow", name="milestones_preset_flow", direction="horizontal"}
    preset_flow.add{type="label", caption={"milestones.settings_preset"}, style="caption_label"}

    -- Preset dropdown
    local preset_dropdown = preset_flow.add{type="drop-down", name="milestones_preset_dropdown", items=global.valid_preset_names}
    if global.current_preset_name == "Imported" then
        preset_dropdown.caption = {"milestones.settings_imported"}
        preset_dropdown.tags = {action="milestones_change_preset", imported=true}
    else
        local current_preset_index = 1
        for _, value in pairs(global.valid_preset_names) do
            if value == global.current_preset_name then break end
            current_preset_index = current_preset_index + 1
        end
        if current_preset_index > #global.valid_preset_names then -- Preset not found, can happen when removing mods
            current_preset_index = 1
        end
        preset_dropdown.selected_index = current_preset_index
        preset_dropdown.tags = {action="milestones_change_preset", imported=false}
    end

    preset_flow.add{type="sprite-button", name="milestones_import_button", tooltip={"milestones.settings_import"}, sprite="utility/import_slot", style="tool_button",
        tags={action="milestones_open_import"}}
    preset_flow.add{type="sprite-button", name="milestones_export_button", tooltip={"milestones.settings_export"}, sprite="utility/export_slot", style="tool_button",
        tags={action="milestones_open_export"}}

    local settings_scroll = inner_frame.add{type="scroll-pane", name="milestones_settings_scroll"}
    local settings_flow = settings_scroll.add{type="frame", name="milestones_settings_inner_flow", direction="vertical", style="milestones_deep_frame_in_shallow_frame"}
    global.players[player.index].settings_flow = settings_flow
    fill_settings_flow(settings_flow, global.loaded_milestones)

    local buttons_flow = inner_frame.add{type="flow", direction="horizontal"}
    for _, type in pairs({"item", "fluid", "technology", "kill"}) do
        buttons_flow.add{type="button",
            caption={"", "[img=milestones_icon_"..type.."_black] ", {"milestones.settings_add_"..type}},
            tags={action="milestones_add_setting", type=type}}
    end
    global.players[player.index].outer_frame.force_auto_center()
end

function swap_settings(player_index, button_element)
    local index_delta = button_element.tags.direction *2
    gui_index1 = button_element.parent.parent.get_index_in_parent()
    gui_index2 = gui_index1 + index_delta
    gui_index1, gui_index2 = math.min(gui_index1, gui_index2), math.max(gui_index1, gui_index2)
    local settings_flow = global.players[player_index].settings_flow
    local milestone1 = get_milestones_array_element(settings_flow.children[gui_index1], true)
    local milestone2 = get_milestones_array_element(settings_flow.children[gui_index2], true)

    -- index1 is always smaller, destroying and rebuilding in this order works
    settings_flow.children[gui_index2].destroy()
    settings_flow.children[gui_index1].destroy()
    add_milestone_setting(milestone2, settings_flow, gui_index1)
    add_milestone_setting(milestone1, settings_flow, gui_index2)
    refresh_arrow_buttons(gui_index1, settings_flow)
    refresh_arrow_buttons(gui_index2, settings_flow)
end

function delete_setting(player_index, button_element)
    gui_index = button_element.parent.get_index_in_parent()
    button_element.parent.destroy()

    local milestones_flow = global.players[player_index].settings_flow
    if #milestones_flow.children ~= 0 then
        -- If this is the first element, we have to delete the line AFTER the element
        -- The line AFTER will be index 1 once the element is destroyed
        line_gui_index = (gui_index == 1) and 1 or gui_index - 1
        milestones_flow.children[line_gui_index].destroy()
        -- Update arrows of new first or last element
        update_arrows_element_index = (gui_index == 1) and 1 or #milestones_flow.children
        refresh_arrow_buttons(update_arrows_element_index, milestones_flow)
    end
end

function add_setting(player_index, button_element)
    local milestone_type = button_element.tags.type
    local settings_flow = global.players[player_index].settings_flow

    local previous_last_element_index = #settings_flow.children
    local only_element = previous_last_element_index == 0
    local new_element_index = previous_last_element_index + (only_element and 1 or 2) -- No line if we are adding the 1st element

    local milestone = {type=milestone_type, quantity=1}
    if not only_element then
        settings_flow.add{type="line"}
    end
    add_milestone_setting(milestone, settings_flow, new_element_index)
    refresh_arrow_buttons(new_element_index, settings_flow)
    if not only_element then
        refresh_arrow_buttons(previous_last_element_index, settings_flow)
    end

    local inner_frame = global.players[player_index].inner_frame
    inner_frame.milestones_settings_scroll.scroll_to_bottom()
end

function cancel_settings_page(player_index)
    global.players[player_index].inner_frame.clear()
    local player = game.get_player(player_index)
    build_display_page(player)
    global.players[player_index].outer_frame.force_auto_center()

    local outer_frame = global.players[player_index].outer_frame
    local import_export_frame = outer_frame.milestones_settings_import_export
    local inside_frame = import_export_frame.milestones_settings_import_export_inside

    inside_frame.clear()
    import_export_frame.visible = false
end

function confirm_settings_page(player_index)
    local player = game.players[player_index]
    if not player.admin then
        game.players[player_index].print{"milestones.message_settings_permission_denied"}
        return
    end

    local new_milestones = get_resulting_milestones_array(player_index)

    if not table.deep_compare(global.loaded_milestones, new_milestones) then -- If something changed
        local inner_frame = global.players[player_index].inner_frame
        local preset_dropdown = inner_frame.milestones_preset_flow.milestones_preset_dropdown
        if preset_dropdown.tags.imported then
            global.current_preset_name = "Imported"
        else
            global.current_preset_name = preset_dropdown.get_item(preset_dropdown.selected_index)
        end

        global.loaded_milestones = table.deep_copy(new_milestones)

        for force_name, force in pairs(game.forces) do
            local global_force = global.forces[force_name]
            if global_force ~= nil then
                merge_new_milestones(force_name, new_milestones)
                backfill_completion_times(force)
            end
        end

        game.print({"milestones.message_settings_changed"})
    end

    cancel_settings_page(player_index)
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_setting" then
        local prototype
        if event.element.elem_type == "item" then
            prototype = game.item_prototypes[event.element.elem_value]
        elseif event.element.elem_type == "fluid" then
            prototype = game.fluid_prototypes[event.element.elem_value]
        elseif event.element.elem_type == "technology" then
            prototype = game.technology_prototypes[event.element.elem_value]
            local visible_textfield = prototype ~= nil and prototype.research_unit_count_formula ~= nil -- No text field for unique technologies
            event.element.parent.milestones_settings_quantity.visible = visible_textfield
            if not visible_textfield then
                event.element.parent.milestones_settings_quantity.text = "1"
            end
        elseif event.element.elem_type == "entity" then
            prototype = game.entity_prototypes[event.element.elem_value]
        end
        event.element.parent.milestones_settings_label.caption = prototype ~= nil and prototype.localised_name or ""
    end
end)

-- Replaces 0s with 1s in quantity settings
script.on_event(defines.events.on_gui_text_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_setting_quantity" then
        local new_quantity = tonumber(event.text)
        if new_quantity ~= nil and new_quantity < 1 then
            event.element.text = "1"
        end
    end
end)

-- Preset dropdown
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_preset" then
        event.element.tags = {action="milestones_change_preset", imported=false}
        local selected_preset_name = event.element.get_item(event.element.selected_index)
        local settings_flow = global.players[event.player_index].settings_flow
        settings_flow.clear()
        fill_settings_flow(settings_flow, presets[selected_preset_name].milestones)
        global.players[event.player_index].outer_frame.force_auto_center()
    end
end)

function is_settings_page_visible(player_index)
    return global.players[player_index].inner_frame.valid and global.players[player_index].inner_frame.milestones_settings_scroll ~= nil
end
