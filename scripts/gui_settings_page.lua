local function add_milestone_setting(milestone, containing_frame, first_element, last_element)
    local type_caption
    local prototype
    local elem_button

    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, item=milestone.name, tags={action="milestones_change_setting"}}
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, fluid=milestone.name, tags={action="milestones_change_setting"}}
    end

    local milestone_flow = containing_frame.add{type="flow", direction="horizontal", style="milestones_label_flow"}
    milestone_flow.add{type="sprite", sprite="milestones_icon_"..milestone.type, tooltip={"gui.milestones_type_"..milestone.type}}
    milestone_flow.add(elem_button)
    milestone_flow.add{type="label", name="milestones_settings_label", caption=prototype.localised_name}
    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}
    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, tags={action="milestones_change_setting_quantity"}, style="short_number_textfield"}
    milestone_flow.add{type="sprite-button", sprite="utility/trash", style="frame_action_button_red"}

    local arrows_flow = milestone_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}
    if first_element then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_up", sprite="milestones_arrow_up", style="milestones_arrow_button"}
    end
    if last_element then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"} 
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_down", sprite="milestones_arrow_down", style="milestones_arrow_button"}
    end

    return milestone_flow
end

local function get_milestones_array_element(flow)
    local quantity = tonumber(flow.milestones_settings_quantity.text) or 1
    return {
        type=flow.milestones_settings_item.elem_type,
        name=flow.milestones_settings_item.elem_value,
        quantity=quantity
    }
end

function get_resulting_milestones_array(player_index)
    local resulting_milestones = {}
    local flows = global.players[player_index].inner_frame.children
    for _, child in pairs(flows) do
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
    -- inner_frame.add{type="line"}

    local milestones_settings_flow = inner_frame.add{type="frame", direction="vertical", style="milestones_deep_frame_in_shallow_frame"}
    for i, milestone in pairs(global.loaded_milestones) do
        local milestone_item_flow = add_milestone_setting(milestone, milestones_settings_flow, i == 1, i == #global.loaded_milestones)
        if i < #global.loaded_milestones then
            milestones_settings_flow.add{type="line"}
        end
    end

    local buttons_flow = inner_frame.add{type="flow", direction="horizontal"}
    buttons_flow.add{type="button", caption={"", "[item=iron-gear-wheel] ", {"gui.milestones_settings_add_item"}}}
    buttons_flow.add{type="button", caption={"", "[fluid=water] ", {"gui.milestones_settings_add_fluid"}}}

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
