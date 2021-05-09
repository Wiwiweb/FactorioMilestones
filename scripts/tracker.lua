local misc = require("__flib__.misc")

milestone_items = {
    ["iron-gear-wheel"]=1,
    ["automation-science-pack"]=1,
    ["logistic-science-pack"]=1
}

function track_item_creation(event)
    if event.tick == 0 then -- Skip first tick of the game where all listeners will be called
        return
    end

    for _, force in pairs(game.forces) do
        if next(force.players) ~= nil and force.item_production_statistics.input_counts and next(force.item_production_statistics.input_counts) ~= nil then -- This force has players and production
            global.milestones[force.name] = global.milestones[force.name] or {}

            local input_counts = force.item_production_statistics.input_counts
            for item, threshold in pairs(milestone_items) do
                if global.milestones[force.name][item] == nil and input_counts[item] and input_counts[item] >= threshold then
                    global.milestones[force.name][item] = game.tick
                    print_milestone_reached(force, item)
                end
            end
        end
    end
end

remote.add_interface("milestones", {
    debug_print_milestones = function()
        game.print(serpent.block(global.milestones))
    end
})

function print_milestone_reached(force, item)
    local human_timestamp = misc.ticks_to_timestring(global.milestones[force.name][item])
    -- local item_prototype = game.item_prototypes[item]
    -- local human_name = item_prototype.localized_name
    local rich_text = "[item=" .. item .. "]"
    force.print("[font=heading-1]Created the first " .. rich_text .. " at [color=green]" .. human_timestamp .. "[/color]![/font]")
    force.play_sound({path="utility/achievement_unlocked"})
end
