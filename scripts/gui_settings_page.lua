local function add_milestone_setting(milestone, inner_frame)
    local type_caption
    local prototype
    local elem_button
    if milestone.type == "item" then
        type_caption = {"gui.milestones_type_item"}
        prototype = game.item_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", elem_type=milestone.type, item=milestone.name, tags={action="milestones_change_setting"}}
    elseif milestone.type == "fluid" then
        type_caption = {"gui.milestones_type_fluid"}
        prototype = game.fluid_prototypes[milestone.name]
        elem_button = {type="choose-elem-button", elem_type=milestone.type, fluid=milestone.name, tags={action="milestones_change_setting"}}
    end

    inner_frame.add{type="label", caption=type_caption}

    local milestone_flow = inner_frame.add{type="flow", direction="horizontal", style="milestones_label_flow"}
    milestone_flow.add(elem_button)
    milestone_flow.add{type="label", name="milestones_settings_label", caption=prototype.localised_name}

    inner_frame.add{type="line"}
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
