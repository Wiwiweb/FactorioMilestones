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
    local milestone_flow = table.add{type="flow", direction="horizontal", style="milestones_horizontal_flow"}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    end

    if prototype == nil then
        log("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        milestone_flow.add{type="label", caption={"", "[color=red]", {"milestones.invalid_entry"}, milestone.name, "[/color]"}}
        return
    end
    
    local sprite_path = milestone.type .. "/" .. milestone.name
    local sprite_number = nil
    local tooltip = prototype.localised_name
    if milestone.quantity > 1 then
        sprite_number = milestone.quantity
        tooltip = {"", milestone.quantity, "x ", prototype.localised_name}
    end
    local caption
    if milestone.completion_tick == nil then
        caption = {"", "[color=100,100,100]", {"milestones.incomplete_label"}, "[/color]"}
    else
        caption = {"", {"milestones.completed_label"}, " [font=default-bold]", get_timestamp(milestone.completion_tick, print_milliseconds), "[img=quantity-time][/font]"}
    end
    
    milestone_flow.add{type="sprite-button", sprite=sprite_path, number=sprite_number, tooltip=tooltip, style="transparent_slot"}
    milestone_flow.add{type="label", caption=caption}
end

function build_display_page(player)
    local main_frame = global.players[player.index].main_frame
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = true
    main_frame.milestones_titlebar.milestones_close_button.visible = true
    main_frame.milestones_dialog_buttons.visible = false

    local inner_frame = global.players[player.index].inner_frame
    local content_table = inner_frame.add{type="table", name="milestones_content_table", column_count=2, style="milestones_table_style"}

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
    return global.players[player_index].inner_frame.milestones_content_table ~= nil
end
