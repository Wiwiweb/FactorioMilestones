local data_util = require("__flib__.data-util")
local styles = data.raw["gui-style"].default

styles["ugg_content_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["ugg_controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}

data:extend({
    {
        type = "custom-input",
        name = "milestones-toggle-gui",
        key_sequence = "CONTROL + ALT + M",
        order = "a"
    }
})

local shortcut_icon = "__milestones__/graphics/shortcut-icon.png"
data:extend{
  {
    type = "shortcut",
    name = "milestones-toggle-gui",
    icon = data_util.build_sprite(nil, {0,0}, shortcut_icon, 32, 2),
    disabled_icon = data_util.build_sprite(nil, {48,0}, shortcut_icon, 32, 2),
    small_icon = data_util.build_sprite(nil, {0,32}, shortcut_icon, 24, 2),
    disabled_small_icon = data_util.build_sprite(nil, {36,32}, shortcut_icon, 24, 2),
    associated_control_input = "milestones-toggle-gui",
    toggleable = true,
    action = "lua"
  }
}