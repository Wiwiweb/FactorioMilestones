On_milestone_reached_event = nil -- global

local interface = {}

function interface.get_on_milestone_reached_event()
	if not On_milestone_reached_event then On_milestone_reached_event = script.generate_event_name() end
	return On_milestone_reached_event
end

remote.add_interface("milestones", interface)
