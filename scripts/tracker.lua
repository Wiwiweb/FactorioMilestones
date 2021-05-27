local misc = require("__flib__.misc")
require("scripts.gui")

local function print_milestone_reached(force, milestone)
    local human_timestamp = misc.ticks_to_timestring(milestone.completion_tick)
    local sprite_name = milestone.type .. "." .. milestone.name
    local localised_name
    if milestone.type == "technology" then
        localised_name = game.technology_prototypes[milestone.name].localised_name
        local level_string = (milestone.quantity == 1 and "" or " level "..milestone.quantity.." ")
        force.print{"milestones.message_milestone_reached_technology", sprite_name, localised_name, level_string, human_timestamp}
    else
        if milestone.type == "item" then
            localised_name = game.item_prototypes[milestone.name].localised_name
        elseif milestone.type == "fluid" then
            localised_name = game.fluid_prototypes[milestone.name].localised_name
        end
        if milestone.quantity == 1 then
            force.print{"milestones.message_milestone_reached_item_first", sprite_name, localised_name, human_timestamp}
        else
            force.print{"milestones.message_milestone_reached_item_more", milestone.quantity, sprite_name, localised_name, human_timestamp}
        end
    end
    force.play_sound{path="utility/achievement_unlocked"}
end

local function check_milestone_reached(force, milestone, stats, milestone_index)
    local input_count = stats.input_counts[milestone.name]
    if input_count ~= nil and input_count >= milestone.quantity then

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

