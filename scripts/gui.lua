local function build_interface(player)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="milestones_main_frame", caption={"gui.title"}}
    main_frame.style.size = {385, 165}
    main_frame.auto_center = true

    player.opened = main_frame

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="ugg_content_frame"}
    local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal", style="ugg_controls_flow"}
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
