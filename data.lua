local data_util = require("__flib__.data-util")
local styles = data.raw["gui-style"].default

styles.milestones_inner_frame = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on",
    vertical_flow_style = {
      type = "vertical_flow_style",
      horizontal_align = "center",
      vertical_spacing = 8,
    }
}

styles.milestones_deep_frame_in_shallow_frame = {
  type = "frame_style",
  parent = "deep_frame_in_shallow_frame",
  left_padding = 8,
  right_padding = 8,
  top_padding = 4,
  bottom_padding = 4,
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

styles.milestones_arrow_button = {
  type = "button_style",
  parent = "frame_button",
  width = 16,
  height = 16
}

styles.milestones_empty_button = {
  type = "empty_widget_style",
  width = 16,
  height = 16
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
local arrows = "__milestones__/graphics/arrows.png"
local item_icons = "__milestones__/graphics/item-icons.png"
data:extend{
  data_util.build_sprite("milestones_settings_black", {0, 0}, settings_gear, 32),
  data_util.build_sprite("milestones_settings_white", {32, 0}, settings_gear, 32),
  data_util.build_sprite("milestones_settings_disabled", {64, 0}, settings_gear, 32),
  data_util.build_sprite("milestones_arrow_up", {0, 0}, arrows, 16),
  data_util.build_sprite("milestones_arrow_down", {16, 0}, arrows, 16),
  data_util.build_sprite("milestones_icon_item", {0, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_fluid", {16, 0}, item_icons, 16),
}
