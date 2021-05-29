local misc = require("__flib__.misc")
require("gui")
require("milestones_util")

local function print_milestone_reached(force, milestone)
    local human_timestamp = misc.ticks_to_timestring(milestone.completion_tick)
    local sprite_name = milestone.type .. "." .. milestone.name
    local localised_name
    if milestone.type == "technology" then
        localised_name = game.technology_prototypes[milestone.name].localised_name
        local level_string = (milestone.quantity == 1 and "" or " Level "..milestone.quantity.." ")
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

function track_item_creation(event)
    if event.tick == 0 then -- Skip first tick of the game where all listeners will be called
        return
    end

    for force_name, global_force in pairs(global.forces) do
        local force = game.forces[force_name]
        if force.item_production_statistics.input_counts and 
        next(force.item_production_statistics.input_counts) ~= nil then -- This force has players and production
            
            local item_counts = force.item_production_statistics.input_counts
            local fluid_counts = force.fluid_production_statistics.input_counts
            local tick = game.tick
            
            local incomplete_milestones = global_force.incomplete_milestones
            local i = 1
            while i <= #incomplete_milestones do
                local milestone = incomplete_milestones[i]
                if is_production_milestone_reached(force, milestone, item_counts, fluid_counts) then
                    mark_milestone_reached(force, milestone, tick, i)
                    print_milestone_reached(force, milestone)
                    refresh_gui_for_force(force)
                else
                    -- When a milestone is reached, incomplete_milestones loses an element
                    -- so we only increment when a milestone is not reached
                    i = i + 1 
                end
            end
        end
    end
end

script.on_event(defines.events.on_research_finished, function(event)
    local technology_researched = event.research
    local force = event.research.force
    local global_force = global.forces[force.name]

    local incomplete_milestones = global_force.incomplete_milestones
    local i = 1
    while i <= #incomplete_milestones do
        local milestone = incomplete_milestones[i]
        if is_tech_milestone_reached(force, milestone, technology_researched) then
            mark_milestone_reached(force, milestone, tick, i)
            print_milestone_reached(force, milestone)
            refresh_gui_for_force(force)
        else
            -- I guess you could technically have the same technology in 2 milestones...
            -- so we have to keep iterating
            i = i + 1 
        end
    end
end)

