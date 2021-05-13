local data_util = require("__flib__.data-util")
local styles = data.raw["gui-style"].default

styles.milestones_content_frame = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles.milestones_label_flow = {
  type = "horizontal_flow_style",
  parent = "horizontal_flow",
  vertical_align = "center",
  minimal_width = 150,
  horizontal_spacing = 8
}

styles.milestones_table_style = {
  type = "table_style",
  horizontal_spacing = 32
}

data:extend{
    {
        type = "custom-input",
        name = "milestones_toggle_gui",
        key_sequence = "CONTROL + ALT + M",
        order = "a"
    }
}

local shortcut_icon = "__milestones__/graphics/shortcut-icon.png"
data:extend{
  {
    type = "shortcut",
    name = "milestones_toggle_gui",
    icon = data_util.build_sprite(nil, {0,0}, shortcut_icon, 32, 2),
    disabled_icon = data_util.build_sprite(nil, {48,0}, shortcut_icon, 32, 2),
    small_icon = data_util.build_sprite(nil, {0,32}, shortcut_icon, 24, 2),
    disabled_small_icon = data_util.build_sprite(nil, {36,32}, shortcut_icon, 24, 2),
    associated_control_input = "milestones_toggle_gui",
    toggleable = true,
    action = "lua"
  }
}

-- Sprites
local settings_gear = "__milestones__/graphics/settings-gear.png"
data:extend{
  data_util.build_sprite("milestones_settings_black", {0, 0}, settings_gear, 32),
  data_util.build_sprite("milestones_settings_white", {32, 0}, settings_gear, 32),
  data_util.build_sprite("milestones_settings_disabled", {64, 0}, settings_gear, 32),
}
