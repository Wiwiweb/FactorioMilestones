local function add_milestone_setting(milestone, inner_frame)
    local type_caption
    local prototype
    local elem_button
    if milestone.type == "item" then
        type_caption = {"gui.milestones_type_item"}
        prototype = game.item_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, item=milestone.name, tags={action="milestones_change_setting"}, caption="test"}
    elseif milestone.type == "fluid" then
        type_caption = {"gui.milestones_type_fluid"}
        prototype = game.fluid_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type=milestone.type, fluid=milestone.name, tags={action="milestones_change_setting"}}
    end

    inner_frame.add{type="label", caption=type_caption, style="caption_label"}

    local milestone_flow = inner_frame.add{type="flow", direction="horizontal", style="milestones_label_flow"}
    milestone_flow.add(elem_button)
    milestone_flow.add{type="label", name="milestones_settings_label", caption=prototype.localised_name}
    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}
    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, tags={action="milestones_change_setting_quantity"}, style="short_number_textfield"}
    milestone_flow.add{type="sprite-button", sprite="utility/trash", style="frame_action_button_red"}

    local arrows_flow = milestone_flow.add{type="flow", direction="vertical"}
    arrows_flow.add{type="sprite-button", sprite="milestones_arrow_up", style="milestones_arrow_button"}
    arrows_flow.add{type="sprite-button", sprite="milestones_arrow_down", style="milestones_arrow_button"}

    inner_frame.add{type="line"}
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

    for _, milestone in pairs(global.loaded_milestones) do
        add_milestone_setting(milestone, inner_frame)
    end

    -- TODO "add" buttons

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
