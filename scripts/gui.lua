local misc = require("__flib__.misc")

local function get_timestamp(ticks, print_milliseconds)
    if print_milliseconds then
        local remaining_ticks = ticks % 60
        local milliseconds = math.floor((16.66666 * remaining_ticks) + 0.5) -- 16.666666 milliseconds per tick, rounded to int
        return misc.ticks_to_timestring(ticks) .. "." .. string.format("%03d", milliseconds)
    else
        return misc.ticks_to_timestring(ticks)
    end

end

local function add_milestone_item(table, milestone, print_milliseconds)
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
        caption = {"", {"gui.completed_label"}, " [font=default-bold]", get_timestamp(milestone.completion_tick, print_milliseconds), "[img=quantity-time][/font]"}
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
    local settings_button = titlebar.add{
        type="sprite-button",
        style="frame_action_button",
        sprite="milestones_settings_white", 
        hovered_sprite="milestones_settings_black", 
        clicked_sprite="milestones_settings_black", 
        mouse_button_filter={"left"},
        tooltip = {"gui.milestones_settings_instructions"},
        tags={
            action="milestones_open_settings"
        }
    }
    if not player.permission_group.allows_action(defines.input_action.mod_settings_changed) then
        settings_button.enabled = false
        settings_button.tooltip = {"gui.milestones_settings_disabled"}
        settings_button.sprite = "milestones_settings_disabled"
        settings_button.hovered_sprite = "milestones_settings_disabled"
        settings_button.clicked_sprite = "milestones_settings_disabled"
    end
    titlebar.add{
        type="sprite-button",
        style="frame_action_button",
        mouse_button_filter={"left"},
        sprite="utility/close_white",
        hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",
        tooltip = {"gui.close-instruction"},
        tags={
            action="milestones_close_gui"
        }
    }
    titlebar.drag_target = main_frame

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="milestones_content_frame"}
    local content_table = content_frame.add{type="table", name="content_table", column_count=2, style="milestones_table_style"}

    local global_force = global.forces[player.force.name]

    local print_milliseconds = settings.global["milestones_check_frequency"].value < 60
    for _, milestone in pairs(global_force.complete_milestones) do
        add_milestone_item(content_table, milestone, print_milliseconds)
    end

    for _, milestone in pairs(global_force.incomplete_milestones) do
        add_milestone_item(content_table, milestone, print_milliseconds)
    end
end

local function build_gui(player)
    build_interface(player)
    player.set_shortcut_toggled("milestones_toggle_gui", true)
end

local function close_gui(player)
    local main_frame = player.gui.screen.milestones_main_frame
    main_frame.destroy()
    player.set_shortcut_toggled("milestones_toggle_gui", false)
end

local function toggle_interface(player)
    if main_frame == nil then
        build_gui(player)
    else
        close_gui(player)
    end
end

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "milestones_main_frame" then
        local player = game.get_player(event.player_index)
        close_gui(player)
    end
end)

-- Quickbar shortcut
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "milestones_toggle_gui" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
end)

-- Keyboard shortcut
script.on_event("milestones_toggle_gui", function(event)
    local player = game.get_player(event.player_index)
    toggle_interface(player)
end)


script.on_event(defines.events.on_gui_click, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_close_gui" then
        local player = game.get_player(event.player_index)
        close_gui(player)
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)

end)