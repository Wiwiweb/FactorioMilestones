local function add_milestone_display(table, milestone)
    local milestone_flow = table.add{type="flow", direction="horizontal"}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    end

    if prototype == nil then
        game.print("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        return
    end
    -- game.print(milestone.name)
    -- game.print(prototype)
    milestone_flow.add{type="label", caption=prototype.localised_name}
end

local function build_interface(player)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="milestones_main_frame", caption={"gui.title"}}
    main_frame.style.size = {385, 165}
    main_frame.auto_center = true

    player.opened = main_frame

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="ugg_content_frame"}
    local content_table = content_frame.add{type="table", name="content_table", column_count=2}

    local global_force = global.forces[player.force.name]

    for _, milestone in pairs(global_force.complete_milestones) do
        add_milestone_display(content_table, milestone)
    end

    for _, milestone in pairs(global_force.incomplete_milestones) do
        add_milestone_display(content_table, milestone)
    end
end

local function toggle_interface(player)
    local main_frame = player.gui.screen.milestones_main_frame
    if main_frame == nil then
        build_interface(player)
        player.set_shortcut_toggled("milestones-toggle-gui", true)
    else
        main_frame.destroy()
        player.set_shortcut_toggled("milestones-toggle-gui", false)
    end
end


script.on_event(defines.events.on_gui_click, function(event)

end)

script.on_event(defines.events.on_gui_text_changed, function(event)

end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "milestones-toggle-gui" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
end)

script.on_event("milestones-toggle-gui", function(event)
    local player = game.get_player(event.player_index)
    toggle_interface(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "milestones_main_frame" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
end)
