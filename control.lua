require("scripts.tracker")

global.milestones = global.milestones or {}

script.on_nth_tick(120, track_item_creation)
