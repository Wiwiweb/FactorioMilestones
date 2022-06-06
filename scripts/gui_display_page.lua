local misc = require("__flib__.misc")
require("scripts.milestones_util")

local function get_timestamp(ticks, print_milliseconds)
    if print_milliseconds then
        local remaining_ticks = ticks % 60
        local milliseconds = math.floor((16.66666 * remaining_ticks) + 0.5) -- 16.666666 milliseconds per tick, rounded to int
        return misc.ticks_to_timestring(ticks) .. "." .. string.format("%03d", milliseconds)
    else
        return misc.ticks_to_timestring(ticks)
    end

end

local function add_milestone_item(gui_table, milestone, print_milliseconds, compact_list)
    local milestone_flow = gui_table.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big"}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    elseif milestone.type == "technology" then
        prototype = game.technology_prototypes[milestone.name]
    elseif milestone.type == "kill" then
        prototype = game.entity_prototypes[milestone.name]
    end

    if prototype == nil then
        log("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        milestone_flow.add{type="label", caption={"", "[color=red]", {"milestones.invalid_entry"}, milestone.name, "[/color]"}}
        return
    end

    -- Sprite
    local sprite_path_prefix = milestone.type == "kill" and "entity" or milestone.type
    local sprite_path = sprite_path_prefix .. "/" .. milestone.name
    local sprite_number
    local tooltip
    if milestone.quantity > 1 then
        sprite_number = milestone.quantity
        tooltip = {"", milestone.quantity, "x ", prototype.localised_name}
    end
    if milestone.type == "technology" then
        local postfix = milestone.quantity == 1 and {"milestones.type_technology"} or "Level "..milestone.quantity
        tooltip = {"", prototype.localised_name, " (", postfix, ")"}
    elseif milestone.type == "kill" then
        local prefix = milestone.quantity == 1 and "" or milestone.quantity .."x "
        tooltip = {"", prefix, prototype.localised_name, " (", {"milestones.type_kill"}, ")"}
    else
        local prefix = milestone.quantity == 1 and "" or milestone.quantity .."x "
        tooltip = {"", prefix, prototype.localised_name}
    end
    milestone_flow.add{type="sprite-button", sprite=sprite_path, number=sprite_number, tooltip=tooltip, style="transparent_slot"}

    -- Item name
    local caption
    local tooltip
    if milestone.completion_tick == nil then
        caption = {"", "[color=100,100,100]", {"milestones.incomplete_label"}, "[/color]"}
    elseif milestone.lower_bound_tick == nil then
        local label_name
        if compact_list then
            label_name = ""
        elseif milestone.type == "kill" then
            label_name = {"milestones.killed_label"}
        elseif milestone.type == "technology" then
            label_name = {"milestones.researched_label"}
        else
            label_name = {"milestones.completed_label"}
        end
        caption = {"", label_name, "[font=default-bold]", get_timestamp(milestone.completion_tick, print_milliseconds), "[img=quantity-time][/font]"}
    else
        tooltip = {"milestones.completed_before_tooltip"}
        caption = "[font=default-bold]" ..get_timestamp(milestone.lower_bound_tick, false).. "[img=quantity-time][/font] - " ..
                  "[font=default-bold]" ..get_timestamp(milestone.completion_tick, false).. "[img=quantity-time][/font]"
    end
    milestone_flow.add{type="label", name="milestones_display_time", caption=caption, tooltip=tooltip}

    -- Optional edit button
    if milestone.lower_bound_tick then
        milestone_flow.add{type="sprite-button", name="milestones_edit_time", sprite="utility/rename_icon_small_white", style="milestones_small_button", 
            tooltip={"milestones.edit_time_tooltip"}, tags={action="milestones_edit_time"}}
    end
end

function enable_edit_time(player_index, element)
    local force = game.players[player_index].force
    local milestone_flow = element.parent
    local milestone_index = milestone_flow.get_index_in_parent()
    local milestone = global.forces[force.name].complete_milestones[milestone_index]

    milestone_flow.milestones_display_time.destroy()
    milestone_flow.milestones_edit_time.destroy()

    local edit_time_dropdown_index, edit_time_default_value = get_default_unit_for_time_bucket(milestone.lower_bound_tick, milestone.completion_tick)
    local textfield = milestone_flow.add{type="textfield", name="milestones_edit_time_field",
        text=string.format("%.1f", edit_time_default_value), numeric=true, allow_decimal=true,
        tags={action="milestones_confirm_edit_time_textfield"}, style="milestones_small_textfield"}
    textfield.focus()
    textfield.select_all()

    milestone_flow.add{type="drop-down", name="milestones_edit_time_dropdown",
    items={{"milestones.edit_time_minutes"}, {"milestones.edit_time_hours"}, {"milestones.edit_time_days"}, {"milestones.edit_time_exact_time"}},
    selected_index=edit_time_dropdown_index, style="milestones_small_dropdown", tags={action="milestones_edit_time_dropdown"}}

    milestone_flow.add{type="sprite-button", name="milestones_confirm_edit_time", sprite="utility/check_mark_white", style="milestones_confirm_button",
        tooltip={"milestones.edit_time_confirm"}, tags={action="milestones_confirm_edit_time"}}
end

local function parse_exact_time_to_ticks(time_string)
    local time_parts = {}
    for part in string.gmatch(time_string, "[^:]+") do
        local number = tonumber(part)
        if not number or number < 0 then return nil end
        table.insert(time_parts, number)
    end
    if #time_parts == 3 then
        return time_parts[1]*60*60*60 + time_parts[2]*60*60 + time_parts[3]*60
    elseif #time_parts == 2 then
        return time_parts[1]*60*60 + time_parts[2]*60
    else
        return nil
    end
end

local function get_ticks_from_quantity_and_unit(quantity, unit)
    if unit == 1 then -- minutes
        return quantity * 60*60
    elseif unit == 2 then -- hours
        return quantity * 60*60*60
    elseif unit == 3 then -- days
        return quantity * 24*60*60*60
    end
end

local function get_quantity_from_ticks_and_unit(ticks, unit)
    if unit == 1 then -- minutes
        return ticks / (60*60)
    elseif unit == 2 then -- hours
        return ticks / (60*60*60)
    elseif unit == 3 then -- days
        return ticks / (24*60*60*60)
    end
end

function get_default_unit_for_time_bucket(lower_bound_tick, upper_bound_tick)
    local lower_bound_ticks_ago = game.tick - lower_bound_tick - 10*60*60 -- Add 10 minutes leeway to avoid bumping something to the next unit 1 tick after we calculate it
    local upper_bound_ticks_ago = game.tick - upper_bound_tick

    local default_unit_index
    if lower_bound_ticks_ago <= 1*60*60*60 then -- 1 hour ago
        default_unit_index = 1 -- minutes
    elseif lower_bound_ticks_ago < 50*60*60*60 then -- 50 hours ago
        default_unit_index = 2 -- hours
    else -- More than 50 hours ago
        default_unit_index = 3 -- days
    end
    return default_unit_index, get_quantity_from_ticks_and_unit(upper_bound_ticks_ago, default_unit_index)
end

function confirm_edit_time(player_index, element)
    local force = game.players[player_index].force
    local milestone_flow = element.parent
    local milestone_index = milestone_flow.get_index_in_parent()
    local milestone = global.forces[force.name].complete_milestones[milestone_index]

    local time_quantity = milestone_flow.milestones_edit_time_field.text
    local time_unit = milestone_flow.milestones_edit_time_dropdown.selected_index
    if time_quantity ~= nil then
        local completion_tick
        if time_unit == 4 then -- Exact time
            completion_tick = parse_exact_time_to_ticks(time_quantity)
        else
            local nb_ticks_ago = get_ticks_from_quantity_and_unit(time_quantity, time_unit)
            local absolute_ticks = math.max(0, game.tick - nb_ticks_ago)
            completion_tick = ceil_to_nearest_minute(absolute_ticks)
        end
        if completion_tick then -- Could still be nil in case of parse error
            milestone.completion_tick = completion_tick
            milestone.lower_bound_tick = nil
            sort_milestones(global.forces[force.name].completed_milestones)
            sort_milestones(global.forces[force.name].milestones_by_group[milestone.group])
        end
    end

    refresh_gui_for_force(force)
end

function edit_time_dropdown_changed(event)
    -- Update the default value shown in the textfield
    local dropdown = event.element
    local milestone_flow = dropdown.parent
    local textfield = milestone_flow.milestones_edit_time_field

    local player = game.get_player(event.player_index)
    local milestone_index = milestone_flow.get_index_in_parent()
    local milestone = global.forces[player.force.name].complete_milestones[milestone_index]

    if dropdown.selected_index == 4 then -- Exact time
        textfield.numeric = false
        textfield.text = misc.ticks_to_timestring(milestone.completion_tick)
    else
        local upper_bound_ticks_ago = game.tick - milestone.completion_tick
        local quantity = get_quantity_from_ticks_and_unit(upper_bound_ticks_ago, dropdown.selected_index)
        textfield.numeric = true
        textfield.text = string.format("%.1f", quantity)
    end
end


function build_display_page(player)
    local main_frame = get_main_frame(player.index)
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = true
    main_frame.milestones_titlebar.milestones_close_button.visible = true
    main_frame.milestones_dialog_buttons.visible = false

    local inner_frame = get_inner_frame(player.index)
    inner_frame.clear() -- Just in case the GUI didn't close through close_gui
    local display_scroll = inner_frame.add{type="scroll-pane", name="milestones_display_scroll"}
    -- This tries to keep 3 rows per column, which results in roughly 16:9 shape
    -- TODO: Account for groups or not?
    local column_count = math.max(
                            math.min(
                                math.ceil(math.sqrt(#global.loaded_milestones / 3)),
                                8),
                            1)

    local global_force = global.forces[player.force.name]

    local print_milliseconds = settings.global["milestones_check_frequency"].value < 60
    local compact_list = settings.get_player_settings(player)["milestones_compact_list"].value
    local view_by_group = settings.get_player_settings(player)["milestones_list_by_group"].value
    if view_by_group then
        for group_name, group_milestones in pairs(global_force.milestones_by_group) do
            display_scroll.add{type="label", caption=group_name, style="caption_label"}
            local group_table = display_scroll.add{type="table", column_count=column_count, style="milestones_table_style"}
            for _, milestone in pairs(group_milestones) do
                add_milestone_item(group_table, milestone, print_milliseconds, compact_list)
            end
            display_scroll.add{type="line"}
        end
        display_scroll.children[#display_scroll.children].destroy() -- Remove last line
    else
        local content_table = display_scroll.add{type="table", column_count=column_count, style="milestones_table_style"}
        for _, milestone in pairs(global_force.complete_milestones) do
            add_milestone_item(content_table, milestone, print_milliseconds, compact_list)
        end

        for _, milestone in pairs(global_force.incomplete_milestones) do
            add_milestone_item(content_table, milestone, print_milliseconds, compact_list)
        end
    end
end

function is_display_page_visible(player_index)
    return get_inner_frame(player_index).milestones_display_scroll ~= nil
end
