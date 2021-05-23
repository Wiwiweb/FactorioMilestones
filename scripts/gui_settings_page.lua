local table = require("__flib__.table")

local function refresh_arrow_buttons(gui_index, milestones_settings_flow)
    local arrows_flow = milestones_settings_flow.children[gui_index].milestones_arrows_flow
    arrows_flow.clear()

    if gui_index == 1 then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_up", sprite="milestones_arrow_up", style="milestones_arrow_button", tags={action="milestones_swap_setting", direction=-1}}
    end
    if gui_index == #milestones_settings_flow.children then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_down", sprite="milestones_arrow_down", style="milestones_arrow_button", tags={action="milestones_swap_setting", direction=1}}
    end
end

local function refresh_all_arrow_buttons(milestones_settings_flow)
    for i, child in pairs(milestones_settings_flow.children) do
        if child.type == "flow" then
            refresh_arrow_buttons(i, milestones_settings_flow)
        end
    end
end

local function add_milestone_setting(milestone, milestones_settings_flow, gui_index)
    local prototype
    local elem_button
    local sprite

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

    local milestone_flow = milestones_settings_flow.add{type="flow", direction="horizontal", style="milestones_horizontal_flow", index=gui_index}
    milestone_flow.add{type="sprite", sprite="milestones_icon_"..milestone.type, tooltip={"gui.milestones_type_"..milestone.type}}
    milestone_flow.add(elem_button)

    local caption = (prototype ~= nil) and prototype.localised_name or ""
    milestone_flow.add{type="label", name="milestones_settings_label", caption=caption}
    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}

    local visible_textfield = milestone.type ~= "technology" or (prototype ~= nil and prototype.research_unit_count_formula ~= nil) -- No text field for unique technologies
    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, 
        tags={action="milestones_change_setting_quantity"}, style="short_number_textfield", visible=visible_textfield}
    milestone_flow.add{type="sprite-button", sprite="utility/trash", style="frame_action_button_red", tags={action="milestones_delete_setting"}}

    local arrows_flow = milestone_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}

    return milestone_flow
end

local function get_milestones_array_element(flow)
    if flow.milestones_settings_item.elem_value == nil then return nil end
    local quantity = tonumber(flow.milestones_settings_quantity.text) or 1
    return {
        type=flow.milestones_settings_item.elem_type,
        name=flow.milestones_settings_item.elem_value,
        quantity=quantity
    }
end

function get_resulting_milestones_array(player_index)
    local resulting_milestones = {}
    local milestones_settings_flow = global.players[player_index].inner_frame.milestones_settings_inner_flow
    for _, child in pairs(milestones_settings_flow.children) do
        if child.type == "flow" then
            local milestone = get_milestones_array_element(child)
            table.insert(resulting_milestones, milestone)
        end
    end
    game.print(serpent.block(resulting_milestones))
end

function build_settings_page(player)
    local main_frame = global.players[player.index].main_frame
    main_frame.milestones_titlebar.milestones_main_label.caption = {"gui.settings_title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = false
    main_frame.milestones_titlebar.milestones_close_button.visible = false
    main_frame.milestones_dialog_buttons.visible = true

    local inner_frame = global.players[player.index].inner_frame

    local preset_flow = inner_frame.add{type="flow", direction="horizontal"}
    preset_flow.add{type="label", caption="Preset:", style="caption_label"}
    preset_flow.add{type="drop-down", items={"Vanilla", "Space Exploration"}}

    local milestones_settings_flow = inner_frame.add{type="frame", name="milestones_settings_inner_flow", direction="vertical", style="milestones_deep_frame_in_shallow_frame"}
    for i, milestone in pairs(global.loaded_milestones) do
        gui_index = i*2-1 -- Account for `line` elements
        local milestone_item_flow = add_milestone_setting(milestone, milestones_settings_flow, gui_index)
        if i < #global.loaded_milestones then
            milestones_settings_flow.add{type="line"}
        end
    end
    refresh_all_arrow_buttons(milestones_settings_flow)

    local buttons_flow = inner_frame.add{type="flow", direction="horizontal"}
    buttons_flow.add{type="button", caption={"", "[img=milestones_icon_item_black] ", {"gui.milestones_settings_add_item"}},
        tags={action="milestones_add_setting", type="item"}}
    buttons_flow.add{type="button", caption={"", "[img=milestones_icon_fluid_black] ", {"gui.milestones_settings_add_fluid"}},
        tags={action="milestones_add_setting", type="fluid"}}
    buttons_flow.add{type="button", caption={"", "[img=milestones_icon_technology_black] ", {"gui.milestones_settings_add_technology"}},
        tags={action="milestones_add_setting", type="technology"}}
end

function swap_settings(player_index, button_element)
    local index_delta = button_element.tags.direction *2
    gui_index1 = button_element.parent.parent.get_index_in_parent()
    gui_index2 = gui_index1 + index_delta
    gui_index1, gui_index2 = math.min(gui_index1, gui_index2), math.max(gui_index1, gui_index2)
    local inner_frame = global.players[player_index].inner_frame
    local milestones_flow = inner_frame.milestones_settings_inner_flow
    local milestone1 = get_milestones_array_element(milestones_flow.children[gui_index1])
    local milestone2 = get_milestones_array_element(milestones_flow.children[gui_index2])
    
    -- index1 is always smaller, destroying and rebuilding in this order works
    local is_last_element = gui_index2 == #milestones_flow.children
    milestones_flow.children[gui_index2].destroy()
    milestones_flow.children[gui_index1].destroy()
    add_milestone_setting(milestone2, milestones_flow, gui_index1)
    add_milestone_setting(milestone1, milestones_flow, gui_index2)
    refresh_arrow_buttons(gui_index1, milestones_flow)
    refresh_arrow_buttons(gui_index2, milestones_flow)
end

function delete_setting(player_index, button_element)
    gui_index = button_element.parent.get_index_in_parent()
    button_element.parent.destroy()

    local inner_frame = global.players[player_index].inner_frame
    local milestones_flow = inner_frame.milestones_settings_inner_flow
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
    local milestones_type = button_element.tags.type
    local inner_frame = global.players[player_index].inner_frame
    local milestones_settings_flow = inner_frame.milestones_settings_inner_flow

    local previous_last_element_index = #milestones_settings_flow.children
    local new_element_index = #milestones_settings_flow.children + 2
    
    local milestone = {type=milestones_type, quantity=1}
    milestones_settings_flow.add{type="line"}
    add_milestone_setting(milestone, milestones_settings_flow, new_element_index)
    refresh_arrow_buttons(new_element_index, milestones_settings_flow)
    refresh_arrow_buttons(previous_last_element_index, milestones_settings_flow)
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
