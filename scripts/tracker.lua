local misc = require("__flib__.misc")
require("scripts.gui")

local function print_milestone_reached(force, milestone)
    local human_timestamp = misc.ticks_to_timestring(milestone.completion_tick)
    -- local item_prototype = game.item_prototypes[item]
    -- local human_name = item_prototype.localised_name
    local quantity_string = (milestone.quantity == 1 and "" or milestone.quantity .. " ")
    local rich_text = "[" .. milestone.type .. "=" .. milestone.name .. "]"
    force.print("[font=heading-1]Created the first " .. quantity_string .. rich_text .. " at [color=green]" .. human_timestamp .. "[img=quantity-time][/color]![/font]")
    force.play_sound{path="utility/achievement_unlocked"}
end

local function check_milestone_reached(force, milestone, stats, milestone_index)
    if stats.get_input_count(milestone.name) >= milestone.quantity then

        milestone.completion_tick = game.tick

        table.insert(global.forces[force.name].complete_milestones, milestone)
        table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
        
        print_milestone_reached(force, milestone)
        for _, player in pairs(force.players) do
            refresh_gui(player)
        end
            
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
                
            local item_stats = force.item_production_statistics
            local fluid_stats = force.fluid_production_statistics

            for i, milestone in ipairs(global_force.incomplete_milestones) do
                if milestone.type == "item" then
                    check_milestone_reached(force, milestone, item_stats, i)
                elseif milestone.type == "fluid" then
                    check_milestone_reached(force, milestone, fluid_stats, i)
                end
            end
        end
    end
end

