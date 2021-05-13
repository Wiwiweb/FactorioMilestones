local misc = require("__flib__.misc")

local function add_milestone_item(table, milestone)
    local milestone_flow = table.add{type="flow", direction="horizontal", style="milestones_label_flow"}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    end

    if prototype == nil then
        game.print("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        milestone_flow.add{type="label", caption="Invalid: " .. milestone.name}
        return
    end
    -- game.print(milestone.name)
    -- game.print(prototype)
    local sprite_path = milestone.type .. "/" .. milestone.name
    local sprite_number = nil
    local tooltip = prototype.localised_name
    if milestone.quantity > 1 then
        sprite_number = milestone.quantity
        tooltip = {"", milestone.quantity, "x ", prototype.localised_name}
    end
    local caption
    if milestone.completion_tick == nil then
        caption = {"", "[color=100,100,100]", {"gui.incomplete_label"}, "[/color]"}
    else
        caption = {"", {"gui.completed_label"}, " [font=default-bold]", misc.ticks_to_timestring(milestone.completion_tick), "[img=quantity-time][/font]"}
    end
    
    milestone_flow.add{type="sprite-button", sprite=sprite_path, number=sprite_number, tooltip=tooltip, style="transparent_slot"}
    milestone_flow.add{type="label", caption=caption}
end

local function build_interface(player)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="milestones_main_frame", direction="vertical"}
    player.opened = main_frame
    main_frame.force_auto_center()

    local titlebar = main_frame.add{type="flow", style="flib_titlebar_flow", direction="horizontal"}
    titlebar.add{
        type = "label",
        style = "frame_title",
        style_mods = {left_margin = 4},
        caption = {"gui.title"},
        ignored_by_interaction = true
    }
    titlebar.add{type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true}
    titlebar.add{
        type="sprite-button",
        style="frame_action_button",
        sprite="milestones_settings_white", 
        hovered_sprite="milestones_settings_black", 
        clicked_sprite="milestones_settings_black", 
        disabled_sprite="milestones_settings_disabled",
        mouse_button_filter={"left"},
        tooltip = {"gui.settings-instruction"}
    }
    titlebar.add{
        type="sprite-button",
        style="frame_action_button",
        mouse_button_filter={"left"},
        sprite="utility/close_white",
        hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",
        tooltip = {"gui.close-instruction"}
    }
    titlebar.drag_target = main_frame

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="milestones_content_frame"}
    local content_table = content_frame.add{type="table", name="content_table", column_count=2, style="milestones_table_style"}

    local global_force = global.forces[player.force.name]

    for _, milestone in pairs(global_force.complete_milestones) do
        add_milestone_item(content_table, milestone)
    end

    for _, milestone in pairs(global_force.incomplete_milestones) do
        add_milestone_item(content_table, milestone)
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
