local misc = require("__flib__.misc")
require("milestones_util")

local function get_timestamp(ticks, print_milliseconds)
    if print_milliseconds then
        local remaining_ticks = ticks % 60
        local milliseconds = math.floor((16.66666 * remaining_ticks) + 0.5) -- 16.666666 milliseconds per tick, rounded to int
        return misc.ticks_to_timestring(ticks) .. "." .. string.format("%03d", milliseconds)
    else
        return misc.ticks_to_timestring(ticks)
    end

end

local function add_milestone_item(gui_table, milestone, print_milliseconds)
    local milestone_flow = gui_table.add{type="flow", direction="horizontal", style="milestones_horizontal_flow"}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    elseif milestone.type == "technology" then
        prototype = game.technology_prototypes[milestone.name]
    end

    if prototype == nil then
        log("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        milestone_flow.add{type="label", caption={"", "[color=red]", {"milestones.invalid_entry"}, milestone.name, "[/color]"}}
        return
    end
    
    -- Sprite
    local sprite_path = milestone.type .. "/" .. milestone.name
    local sprite_number
    local tooltip
    if milestone.quantity > 1 then
        sprite_number = milestone.quantity
        tooltip = {"", milestone.quantity, "x ", prototype.localised_name}
    end
    if milestone.type == "technology" then
        local postfix = milestone.quantity == 1 and {"milestones.type_technology"} or "Level "..milestone.quantity
        tooltip = {"", prototype.localised_name, " (", postfix, ")"}
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
    else
        local locale_name = milestone.before and "milestones.completed_before_label" or "milestones.completed_label"
        tooltip = milestone.before and {"milestones.completed_before_tooltip"}
        print_milliseconds = print_milliseconds and not milestone.before
        caption = {"", {locale_name}, "[font=default-bold]", get_timestamp(milestone.completion_tick, print_milliseconds), "[img=quantity-time][/font]"}
    end
    milestone_flow.add{type="label", name="milestones_display_time", caption=caption, tooltip=tooltip}

    -- Optional edit button
    if milestone.before then
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

    milestone_flow.add{type="label", name="milestones_display_time", caption={"milestones.completed_label"}}
    local textfield = milestone_flow.add{type="textfield", name="milestones_edit_time_field", 
        text=get_timestamp(milestone.completion_tick, false), style="short_number_textfield",
        tags={action="milestones.milestones_confirm_edit_time"}}
    textfield.focus()
    milestone_flow.add{type="sprite-button", name="milestones_confirm_edit_time", sprite="utility/check_mark_white", style="milestones_confirm_button", 
        tooltip={"milestones.edit_time_confirm"}, tags={action="milestones_confirm_edit_time"}}
end

local function timestring_to_ticks(timestring)
    local numbers = {}
    for number in string.gmatch(timestring, "%d+") do
        table.insert(numbers, tonumber(number))
    end
    if #numbers == 0 or #numbers > 3 then return nil end
    while #numbers < 3 do
        table.insert(numbers, 1, 0)
    end

    local ticks = 
        numbers[1] * 60*60*60 + -- Hours
        numbers[2] * 60*60 +    -- Minutes
        numbers[3] * 60         -- Seconds
    log("Converted ".. timestring .." to : "..serpent.line(numbers).. " = " .. ticks .. " ticks")
    if ticks <= 0 then return nil end
    if ticks > 10*365*24*60*60*60 then return nil end -- Probably no one has a save longer than 10 years...
    return ticks
end

function confirm_edit_time(player_index, element)
    local force = game.players[player_index].force
    local milestone_flow = element.parent
    local milestone_index = milestone_flow.get_index_in_parent()
    local milestone = global.forces[force.name].complete_milestones[milestone_index]

    local timestring = milestone_flow.milestones_edit_time_field.text
    local completion_tick = timestring_to_ticks(timestring)
    if completion_tick then
        milestone.completion_tick = completion_tick
        milestone.before = nil
    end
    sort_milestones(global.forces[force.name].complete_milestones)
    refresh_gui_for_force(force)
end

function build_display_page(player)
    local main_frame = global.players[player.index].main_frame
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = true
    main_frame.milestones_titlebar.milestones_close_button.visible = true
    main_frame.milestones_dialog_buttons.visible = false

    local inner_frame = global.players[player.index].inner_frame
    local display_scroll = inner_frame.add{type="scroll-pane", name="milestones_display_scroll"}
    -- This tries to keep 3 rows per column, which results in roughly 16:9 shape
    local column_count = math.max(
                            math.min(
                                math.ceil(math.sqrt(#global.loaded_milestones / 3)), 
                                8), 
                            1) 
    local content_table = display_scroll.add{type="table", name="milestones_content_table", column_count=column_count, style="milestones_table_style"}

    local global_force = global.forces[player.force.name]

    local print_milliseconds = settings.global["milestones_check_frequency"].value < 60
    for _, milestone in pairs(global_force.complete_milestones) do
        add_milestone_item(content_table, milestone, print_milliseconds)
    end

    for _, milestone in pairs(global_force.incomplete_milestones) do
        add_milestone_item(content_table, milestone, print_milliseconds)
    end
end

function is_display_page_visible(player_index)
    return global.players[player_index].inner_frame.milestones_display_scroll ~= nil
end
