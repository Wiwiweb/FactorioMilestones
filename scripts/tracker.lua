local misc = require("__flib__.misc")

milestones = {
    {type="item", name="iron-gear-wheel", quantity=1},
    {type="item", name="iron-gear-wheel", quantity=50},
    {type="item", name="automation-science-pack", quantity=1},
    {type="item", name="logistic-science-pack", quantity=1},
    {type="fluid", name="petroleum", quantity=1},
}

local function print_milestone_reached(force, milestone)
    local human_timestamp = misc.ticks_to_timestring(milestone.completion_tick)
    -- local item_prototype = game.item_prototypes[item]
    -- local human_name = item_prototype.localized_name
    local quantity_string = (milestone.quantity == 1 and "" or milestone.quantity .. " ")
    local rich_text = "[" .. milestone.type .. "=" .. milestone.name .. "]"
    force.print("[font=heading-1]Created the first " .. quantity_string .. rich_text .. " at [color=green]" .. human_timestamp .. "[img=quantity-time][/color]![/font]")
    force.play_sound({path="utility/achievement_unlocked"})
end

local function check_milestone_reached(force, milestone, input_counts, milestone_index)
    if input_counts[milestone.name] and input_counts[milestone.name] >= milestone.quantity then
        milestone.completion_tick = game.tick
        table.insert(global.forces[force.name].complete_milestones, milestone)
        table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
        print_milestone_reached(force, milestone)
    end
end


function track_item_creation(event)
    if event.tick == 0 then -- Skip first tick of the game where all listeners will be called
        return
    end

    for _, force in pairs(game.forces) do
        local global_force = global.forces[force.name]

        if global_force ~= nil and
            force.item_production_statistics.input_counts and 
            next(force.item_production_statistics.input_counts) ~= nil then -- This force has players and production
                
            local item_counts = force.item_production_statistics.input_counts
            local fluid_counts = force.fluid_production_statistics.input_counts

            for i, milestone in ipairs(global_force.incomplete_milestones) do
                if milestone.type == "item" then
                    check_milestone_reached(force, milestone, item_counts, i)
                elseif milestone.type == "fluid" then
                    check_milestone_reached(force, milestone, fluid_counts, i)
                end
            end
        end
    end
end

