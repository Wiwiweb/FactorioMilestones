local misc = require("__flib__.misc")
require("scripts.gui")

local function print_milestone_reached(force, milestone)
    log("print_milestone_reached")
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

local function mark_milestone_reached(force, milestone, milestone_index)
    milestone.completion_tick = game.tick
    table.insert(global.forces[force.name].complete_milestones, milestone)
    table.remove(global.forces[force.name].incomplete_milestones, milestone_index)
end

local function is_production_milestone_reached(force, milestone, item_count, fluid_count)
    local type_count = milestone.type == "item" and item_count or fluid_count
    local milestone_count = type_count[milestone.name]
    if milestone_count ~= nil and milestone_count >= milestone.quantity then
        return true
    end
    return false
end

local function is_tech_milestone_reached(force, milestone, technology_researched)
    log("milestone: " .. serpent.line(milestone))
    log("technology_researched: " .. technology_researched.name .." - ".. technology_researched.level)
    local level_needed = milestone.quantity == 1 and 1 or (milestone.quantity + 1) -- +1 because the level we get is the current researchable level, not the researched level
    if milestone.type == "technology" and
       technology_researched.name == milestone.name and
       technology_researched.level >= level_needed then
        return true
    end
    return false
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

            for i, milestone in ipairs(global_force.incomplete_milestones) do
                if is_production_milestone_reached(force, milestone, item_counts, fluid_counts) then
                    mark_milestone_reached(force, milestone, i)
                    print_milestone_reached(force, milestone)
                    refresh_gui_for_force(force)
                end
            end
        end
    end
end

script.on_event(defines.events.on_research_finished, function(event)
    local technology_researched = event.research
    local force = event.research.force
    local global_force = global.forces[force.name]
    for i, milestone in ipairs(global_force.incomplete_milestones) do
        if is_tech_milestone_reached(force, milestone, technology_researched) then
            mark_milestone_reached(force, milestone, i)
            print_milestone_reached(force, milestone)
            refresh_gui_for_force(force)
        end
    end
end)

