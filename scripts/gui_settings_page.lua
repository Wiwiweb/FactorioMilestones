local table = require("__flib__.table")
require("presets")
require("milestones_util")

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
    local sprite

    local milestone_flow = settings_flow.add{type="flow", direction="horizontal", style="milestones_horizontal_flow", index=gui_index}
    milestone_flow.add{type="sprite", sprite="milestones_icon_"..milestone.type, tooltip={"milestones.type_"..milestone.type}}
    
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, item=milestone.name, tags={action="milestones_change_setting"}}
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, fluid=milestone.name, tags={action="milestones_change_setting"}}
    elseif milestone.type == "technology" then
        prototype = game.technology_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, technology=milestone.name, tags={action="milestones_change_setting"}}
    end

    if milestone.name ~= nil and prototype == nil then
        milestone_flow.add{type="label", caption={"", "[color=red]", {"milestones.invalid_entry"}, milestone.name, "[/color]"}}
    else
        milestone_flow.add(elem_button)
        
        local caption = (prototype ~= nil) and prototype.localised_name or ""
        milestone_flow.add{type="label", name="milestones_settings_label", caption=caption}
    end

    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}
    
    local visible_textfield = milestone.type ~= "technology" or (prototype ~= nil and prototype.research_unit_count_formula ~= nil) -- No text field for unique technologies
    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, clear_and_focus_on_right_click=true, 
        tags={action="milestones_change_setting_quantity"}, style="short_number_textfield", visible=visible_textfield}

    milestone_flow.add{type="sprite-button", sprite="utility/trash", style="milestones_trash_button", tags={action="milestones_delete_setting"}}
    local arrows_flow = milestone_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}

    return milestone_flow
end

local function get_milestones_array_element(flow, allow_empty)
    if flow.milestones_settings_item.elem_value == nil and not allow_empty then return nil end
    local quantity = tonumber(flow.milestones_settings_quantity.text) or 1
    return {
        type=flow.milestones_settings_item.elem_type,
        name=flow.milestones_settings_item.elem_value,
        quantity=quantity
    }
end

local function get_resulting_milestones_array(player_index)
    local resulting_milestones = {}
    local settings_flow = global.players[player_index].settings_flow
    for _, child in pairs(settings_flow.children) do
        if child.type == "flow" then
            local milestone = get_milestones_array_element(child, false)
            table.insert(resulting_milestones, milestone)
        end
    end
    return resulting_milestones
end

local function fill_settings_flow(settings_flow, milestones)
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
    preset_flow.add{type="label", caption="Preset:", style="caption_label"}

    -- Preset dropdown
    local current_preset_index = 1
    for _, value in pairs(global.valid_preset_names) do
        if value == global.current_preset_name then break end
        current_preset_index = current_preset_index + 1
    end
    preset_flow.add{type="drop-down", name="milestones_preset_dropdown", items=global.valid_preset_names, selected_index=current_preset_index, tags={action="milestones_change_preset"}}

    local settings_scroll = inner_frame.add{type="scroll-pane", name="milestones_settings_scroll"}
    local settings_flow = settings_scroll.add{type="frame", name="milestones_settings_inner_flow", direction="vertical", style="milestones_deep_frame_in_shallow_frame"}
    global.players[player.index].settings_flow = settings_flow
    fill_settings_flow(settings_flow, global.loaded_milestones)
    
    local buttons_flow = inner_frame.add{type="flow", direction="horizontal"}
    for _, type in pairs({"item", "fluid", "technology"}) do
        buttons_flow.add{type="button", 
            caption={"", "[img=milestones_icon_"..type.."_black] ", {"milestones.settings_add_"..type}},
            tags={action="milestones_add_setting", type=type}}
    end
    main_frame.force_auto_center()
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
    local is_last_element = gui_index2 == #settings_flow.children
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
    global.players[player_index].main_frame.force_auto_center()
end

function confirm_settings_page(player_index)
    local permission_group = game.players[player_index].permission_group
    if permission_group == nil or not permission_group.allows_action(defines.input_action.mod_settings_changed) then
        game.players[player_index].print{"milestones.message_settings_permission_denied"}
        return
    end

    local new_milestones = get_resulting_milestones_array(player_index)

    if not table.deep_compare(global.loaded_milestones, new_milestones) then -- If something changed
        local inner_frame = global.players[player_index].inner_frame
        local preset_dropdown = inner_frame.milestones_preset_flow.milestones_preset_dropdown
        global.current_preset_name = preset_dropdown.get_item(preset_dropdown.selected_index)
        
        global.loaded_milestones = new_milestones
        
        for _, force in pairs(game.forces) do
            local global_force = global.forces[force.name]
            if global_force ~= nil then
                merge_new_milestones(global_force, new_milestones)
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
        end
        event.element.parent.milestones_settings_label.caption = prototype.localised_name
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
        local selected_preset_name = event.element.get_item(event.element.selected_index)
        local settings_flow = global.players[event.player_index].settings_flow
        settings_flow.clear()
        fill_settings_flow(settings_flow, presets[selected_preset_name].milestones)
        global.players[event.player_index].main_frame.force_auto_center()
    end
end)

function is_settings_page_visible(player_index)
    return global.players[player_index].inner_frame.milestones_settings_scroll ~= nil
end
