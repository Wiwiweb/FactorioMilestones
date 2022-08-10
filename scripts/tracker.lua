local core_util = require("__core__/lualib/util.lua")
local misc = require("__flib__.misc")
require("scripts.gui")
require("scripts.milestones_util")

local function print_milestone_reached(force, milestone)
    local human_timestamp = misc.ticks_to_timestring(milestone.completion_tick)
    local sprite_path_prefix = milestone.type == "kill" and "entity" or milestone.type
    local sprite_name = sprite_path_prefix .. "." .. milestone.name
    local localised_name
    if milestone.type == "technology" then
        localised_name = game.technology_prototypes[milestone.name].localised_name
        local level_string = (milestone.quantity == 1 and "" or " Level "..milestone.quantity.." ")
        force.print{"milestones.message_milestone_reached_technology", sprite_name, localised_name, level_string, human_timestamp}
    else
        if milestone.type == "item" then
            if milestone.name == "se-rocket-launch-pad-silo-dummy-result-item" then
                localised_name = "Cargo rocket"
            else
                localised_name = game.item_prototypes[milestone.name].localised_name
            end
        elseif milestone.type == "fluid" then
            localised_name = game.fluid_prototypes[milestone.name].localised_name
        elseif milestone.type == "kill" then
            localised_name = game.entity_prototypes[milestone.name].localised_name
        else
            error("Invalid milestone type! " .. milestone.type)
        end

        local message_type = milestone.type == "kill" and "kill" or "item"
        local postscript
        if milestone.name == "character" then
            postscript = " (haha! 😁)"
        end
        if milestone.quantity == 1 then
            force.print{"", {"milestones.message_milestone_reached_" ..message_type.. "_first", sprite_name, localised_name, human_timestamp}, postscript}
        else
            local print_quantity = milestone.quantity
            if milestone.quantity >= 10000 then
                print_quantity = core_util.format_number(milestone.quantity, true)
            end
            force.print{"", {"milestones.message_milestone_reached_" ..message_type.. "_more", print_quantity, sprite_name, localised_name, human_timestamp}, postscript}
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
            local kill_counts = force.kill_count_statistics.input_counts

            local i = 1
            while i <= #global_force.incomplete_milestones do
                local milestone = global_force.incomplete_milestones[i]
                if milestone.type ~= "technology" and is_production_milestone_reached(milestone, item_counts, fluid_counts, kill_counts) then
                    if milestone.next then
                        local next_milestone = create_next_milestone(force_name, milestone)
                        table.insert(global_force.incomplete_milestones, next_milestone)
                        table.insert(global_force.milestones_by_group[next_milestone.group], next_milestone)
                    end
                    mark_milestone_reached(force, milestone, game.tick, i)
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
    if global_force == nil then return end

    local i = 1
    while i <= #global_force.incomplete_milestones do
        local milestone = global_force.incomplete_milestones[i]
        if is_tech_milestone_reached(milestone, technology_researched) then
            mark_milestone_reached(force, milestone, game.tick, i)
            print_milestone_reached(force, milestone)
            refresh_gui_for_force(force)
        else
            -- I guess you could technically have the same technology in 2 milestones...
            -- so we have to keep iterating
            i = i + 1
        end
    end
end)

