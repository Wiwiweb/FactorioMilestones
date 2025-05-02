local table = require("__flib__.table")
require("presets.presets")
require("scripts.milestones_util")

local function refresh_arrow_buttons(gui_index, settings_flow)
    local arrows_flow = settings_flow.children[gui_index].milestones_arrows_flow
    arrows_flow.clear()

    if gui_index == 1 then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"}
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_up", sprite="milestones_arrow_up", style="milestones_small_button",
        tooltip={"milestones.settings_arrow_tooltip"}, tags={action="milestones_swap_setting", direction=-1}}
    end
    if gui_index == #settings_flow.children then
        arrows_flow.add{type="empty-widget", style="milestones_empty_button"}
    else
        arrows_flow.add{type="sprite-button", name="milestones_arrow_down", sprite="milestones_arrow_down", style="milestones_small_button",
        tooltip={"milestones.settings_arrow_tooltip"}, tags={action="milestones_swap_setting", direction=1}}
    end
end

local function refresh_all_arrow_buttons(settings_flow)
    for i, child in pairs(settings_flow.children) do
        if child.type == "flow" then
            refresh_arrow_buttons(i, settings_flow)
        end
    end
end

local function add_group(settings_flow, default_name, gui_index)
    local group_flow = settings_flow.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big_settings", index=gui_index}
    group_flow.add{type="sprite", sprite="milestones_icon_group", tooltip={"milestones.type_group"}}
    group_flow.add{type="label", name="milestones_settings_label", caption={"", {"milestones.type_group"}, ":"}}
    group_flow.add{type="textfield", name="milestones_settings_group_name", text=default_name, clear_and_focus_on_right_click=true}

    group_flow.add{type="empty-widget", style="flib_horizontal_pusher"}

    group_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}
    group_flow.add{type="checkbox", name="milestones_settings_checkbox", state=false,
        tooltip={"milestones.settings_checkbox_tooltip"}, tags={action="milestones_select_setting"}}
    return group_flow
end


local function add_milestone_setting(milestone, settings_flow, gui_index)
    local prototype
    local elem_button

    local common_type
    if milestone.type == "item_consumption" then
        common_type = "item"
    elseif milestone.type == "fluid_consumption" then
        common_type = "fluid"
    else
        common_type = milestone.type
    end

    local milestone_flow = settings_flow.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big_settings", index=gui_index}
    milestone_flow.add{type="sprite", sprite="milestones_icon_"..common_type, tooltip={"milestones.type_"..common_type}}

    if milestone.hidden then
        milestone_flow.tags = {hidden= true}
    end

    -- Note: This works even with the quality mod disabled
    local default_selection_quality = milestone.quality or "normal" -- Default to "normal" because "any" isn't possible yet
    if prototypes.quality[default_selection_quality] == nil then
        default_selection_quality = "normal"
    end

    if milestone.type == "item" or milestone.type == "item_consumption" then
        prototype = prototypes.item[milestone.name]
        local default_selection = nil
        if prototype ~= nil then default_selection = milestone.name end
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="item-with-quality",
            ["item-with-quality"]={name=default_selection, quality=default_selection_quality},
            tags={action="milestones_change_setting", milestone_type=milestone.type}}
    elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
        prototype = prototypes.fluid[milestone.name]
        local default_selection = nil
        if prototype ~= nil then default_selection = milestone.name end
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="fluid",
            fluid=default_selection, tags={action="milestones_change_setting", milestone_type=milestone.type}}
    elseif milestone.type == "technology" then
        prototype = prototypes.technology[milestone.name]
        local default_selection = nil
        if prototype ~= nil then default_selection = milestone.name end
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="technology",
            technology=default_selection, tags={action="milestones_change_setting", milestone_type="technology"}}
    elseif milestone.type == "kill" then
        prototype = prototypes.entity[milestone.name]
        local default_selection = nil
        if prototype ~= nil then default_selection = milestone.name end
        elem_button = {type="choose-elem-button", name="milestones_settings_item", elem_type="entity-with-quality",
            ["entity-with-quality"]={name=default_selection, quality=default_selection_quality},
            tags={action="milestones_change_setting", milestone_type=milestone.type},
            elem_filters={{filter="entity-with-health"}}}
    end

    milestone_flow.add(elem_button)
    local caption
    if milestone.name ~= nil and (prototype == nil or milestone.quality and prototypes.quality[milestone.quality] == nil) then
        caption = {"", "[color=red]", {"milestones.invalid_entry"}, " " .. milestone.name .. " " .. (milestone.quality or ""), "[/color]"}
    else
        if prototype ~= nil then
            if milestone.quality ~= nil then
                caption = {"", prototype.localised_name, " (", {"quality-name."..milestone.quality}, ")"}
            else
                caption = prototype.localised_name
            end
        else
            caption = ""
        end
    end
    milestone_flow.add{type="label", name="milestones_settings_label", caption=caption}

    milestone_flow.add{type="empty-widget", style="flib_horizontal_pusher"}

    local unique_technology = milestone.type ~= "technology" or (prototype ~= nil and prototype.research_unit_count_formula ~= nil) -- No text field or infinity button for unique technologies

    milestone_flow.add{type="textfield", name="milestones_settings_quantity", text=milestone.quantity, numeric=true, clear_and_focus_on_right_click=true,
        tags={action="milestones_change_setting_quantity"}, style="short_number_textfield", visible=unique_technology, tooltip={"milestones.settings_quantity_tooltip"}}

    local infinity_button = milestone_flow.add({type="sprite-button", sprite="milestones_infinity_icon", tags={action="milestones_settings_infinity_button"}, style="milestones_grey_button", visible=unique_technology,
        tooltip={"milestones.settings_infinity_button_tooltip"}})
    milestone_flow.add({type="textfield", name="milestones_settings_next_textfield", text=milestone.next, style="milestones_very_short_textfield", visible=false,
        clear_and_focus_on_right_click=true, tooltip={"milestones.settings_next_textfield_tooltip"}})
    milestone_flow.add{type="empty-widget", name="milestones_settings_next_spacer", style="milestones_very_short_spacer", visible=true}
    if milestone.next ~= nil then
        toggle_infinity_button(infinity_button)
    end

    milestone_flow.add{type="flow", name="milestones_arrows_flow", direction="vertical"}
    milestone_flow.add{type="checkbox", name="milestones_settings_checkbox", state=false,
        tooltip={"milestones.settings_checkbox_tooltip"}, tags={action="milestones_select_setting"}}
    return milestone_flow
end

local function add_alias_setting(milestone, settings_flow, gui_index)
    local milestone_flow = settings_flow.add({type="flow", direction="horizontal", style="milestones_horizontal_flow_big_settings", index=gui_index})
    local caption = {"", {"milestones.settings_alias"}, ": ", milestone.name, " = ", milestone.quantity, "x ", milestone.equals}
    milestone_flow.add({type="label", name="milestones_settings_alias_label", caption=caption, tags={name=milestone.name, equals=milestone.equals, quantity=milestone.quantity}})

    milestone_flow.add({type="empty-widget", style="flib_horizontal_pusher"})

    milestone_flow.add({type="flow", name="milestones_arrows_flow", direction="vertical"})
    milestone_flow.add{type="checkbox", name="milestones_settings_checkbox", state=false,
        tooltip={"milestones.settings_checkbox_tooltip"}, tags={action="milestones_select_setting"}}
end

local function add_settings_element_from_json_item(settings_element, settings_flow, gui_index)
    if settings_element.type == "group" then
        return add_group(settings_flow, settings_element.name, gui_index)
    elseif settings_element.type == "alias" then
        return add_alias_setting(settings_element, settings_flow, gui_index)
    else
        return add_milestone_setting(settings_element, settings_flow, gui_index)
    end
end

function toggle_infinity_button(button_element)
    local textfield_element = button_element.parent.milestones_settings_next_textfield
    local spacer_element = button_element.parent.milestones_settings_next_spacer
    if button_element.style.name == "milestones_selected_grey_button" then
        button_element.style = "milestones_grey_button"
        textfield_element.visible = false
        spacer_element.visible = true
    else
        button_element.style = "milestones_selected_grey_button"
        textfield_element.visible = true
        spacer_element.visible = false
        if textfield_element.text == nil or textfield_element.text == "" then
            textfield_element.text = "x10"
        end
    end
end

local function get_milestones_array_element(flow, allow_empty, player_index)
    if not allow_empty
       and (flow.milestones_settings_item == nil or flow.milestones_settings_item.elem_value == nil)
       and (flow.milestones_settings_group_name == nil or flow.milestones_settings_group_name.text == nil)
       and flow.milestones_settings_alias_label == nil then
        return nil
    end
    if flow.milestones_settings_group_name then
        return {type="group", name=flow.milestones_settings_group_name.text}
    elseif flow.milestones_settings_alias_label then
        return {type="alias", name=flow.milestones_settings_alias_label.tags.name, equals=flow.milestones_settings_alias_label.tags.equals, quantity=flow.milestones_settings_alias_label.tags.quantity}
    end

    local quantity = tonumber(flow.milestones_settings_quantity.text) or 1
    local next_formula = flow.milestones_settings_next_textfield.text
    if not flow.milestones_settings_next_textfield.visible or next_formula == "" then next_formula = nil end
    if next_formula ~= nil then
        local operator, _ = parse_next_formula(next_formula)
        if operator == nil then
            game.players[player_index].print({"", {"milestones.message_invalid_next"}, next_formula})
            next_formula = nil
        end
    end

    local hidden = flow.tags.hidden
    if not hidden or hidden == "" then hidden = nil end

    local milestone_name
    local quality
    if flow.milestones_settings_item.elem_type == "item-with-quality" or flow.milestones_settings_item.elem_type == "entity-with-quality" then
        milestone_name = flow.milestones_settings_item.elem_value.name
        quality = flow.milestones_settings_item.elem_value.quality
        if quality == "normal" then quality = nil end -- For now consider a "normal" selection to be an "any" selection. Until we can get a choose-elem-button that can select "any".
    else
        milestone_name = flow.milestones_settings_item.elem_value
    end

    return {
        type=flow.milestones_settings_item.tags.milestone_type,
        name=milestone_name,
        quantity=quantity,
        quality=quality,
        next=next_formula,
        hidden=hidden
    }
end

function get_resulting_milestones_array(player_index)
    local resulting_milestones = {}
    local settings_flow = storage.players[player_index].settings_flow
    for _, child in pairs(settings_flow.children) do
        if child.type == "flow" then
            local milestone = get_milestones_array_element(child, false, player_index)
            table.insert(resulting_milestones, milestone)
        end
    end
    return resulting_milestones
end

function fill_settings_flow(settings_flow, milestones)
    for i, milestone in pairs(milestones) do
        add_settings_element_from_json_item(milestone, settings_flow, nil)
        if i < #milestones then
            settings_flow.add{type="line"}
        end
    end
    refresh_all_arrow_buttons(settings_flow)
end

local function is_preset_modified(current_milestones, preset_name)
    return presets[preset_name] ~= nil
        and not table.deep_compare(current_milestones, presets[preset_name].milestones)
end

function build_settings_page(player)
    local main_frame = get_main_frame(player.index)
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.settings_title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = false
    main_frame.milestones_titlebar.milestones_close_button.visible = false
    main_frame.milestones_dialog_buttons.visible = true

    local inner_frame = get_inner_frame(player.index)
    local settings_outer_flow = inner_frame.add{type="flow", name="milestones_settings_outer_flow", direction="vertical", style="milestones_settings_outer_flow"}

    local preset_flow = settings_outer_flow.add{type="flow", name="milestones_preset_flow", direction="horizontal", style="milestones_horizontal_flow_center"}

    -- Preset dropdown
    preset_flow.add{type="label", caption={"milestones.settings_preset"}, style="caption_label"}
    local preset_dropdown = preset_flow.add{type="drop-down", name="milestones_preset_dropdown", items=storage.valid_preset_names}
    if storage.current_preset_name == "Imported" then
        preset_dropdown.caption = {"milestones.settings_imported"}
        preset_dropdown.tags = {action="milestones_change_preset", imported=true}
    else
        local current_preset_index = table_get_index(storage.valid_preset_names, storage.current_preset_name) or 1
        preset_dropdown.selected_index = current_preset_index
        preset_dropdown.tags = {action="milestones_change_preset", imported=false}
        if is_preset_modified(storage.loaded_milestones, storage.current_preset_name) then
            preset_dropdown.caption = {"", storage.current_preset_name, " ", {"milestones.settings_preset_modified"}}
        end
    end

    preset_flow.add{type="button", caption={"milestones.settings_reset_preset"}, tooltip={"milestones.settings_reset_preset_tooltip"}, style="milestones_stretchable_button",
        tags={action="milestones_reset_preset"}}
    preset_flow.add{type="sprite-button", name="milestones_import_button", tooltip={"milestones.settings_import"}, sprite="utility/import_slot", style="tool_button",
        tags={action="milestones_open_import"}}
    preset_flow.add{type="sprite-button", name="milestones_export_button", tooltip={"milestones.settings_export"}, sprite="utility/export_slot", style="tool_button",
        tags={action="milestones_open_export"}}


    local settings_scroll = settings_outer_flow.add{type="scroll-pane", name="milestones_settings_scroll", style="milestones_settings_scroll"}
    local settings_flow = settings_scroll.add{type="frame", name="milestones_settings_inner_flow", direction="vertical", style="milestones_deep_frame_in_shallow_frame"}
    storage.players[player.index].settings_flow = settings_flow
    storage.players[player.index].settings_selection_indexes = {}
    fill_settings_flow(settings_flow, storage.loaded_milestones)

    local buttons_flow = settings_outer_flow.add{type="flow", name="milestones_button_flow", direction="horizontal"}
    for _, type in pairs({"group", "item", "fluid", "technology", "kill"}) do
        local tooltip = type == "group" and {"milestones.settings_add_group"} or {"milestones.settings_add_tooltip", {"milestones.type_"..type}}
        buttons_flow.add{type="button", enabled=false, tooltip=tooltip,
            caption={"", "[img=milestones_icon_"..type.."_black] ", {"milestones.settings_add_something", {"milestones.type_"..type}}},
            tags={action="milestones_add_setting", type=type}}
    end
    settings_outer_flow.add{type="button", name="milestones_delete_settings_button",
        enabled=false, style="red_button", tooltip={"milestones.settings_delete_tooltip"},
        caption={"", "[img=utility/trash] ", {"gui.delete"}},
        tags={action="milestones_delete_settings"}}
    get_outer_frame(player.index).force_auto_center()
end

local function update_checkbox_states(settings_flow, settings_selection_indexes)
    local nb_children = #settings_flow.children
    for i = 1, nb_children, 2 do -- 2, because we skip line separators
        settings_flow.children[i].milestones_settings_checkbox.state = settings_selection_indexes[i] or false
    end
end

local function update_buttons_enabled_state(settings_outer_flow, settings_selection_indexes)
    local is_anything_selected = table_size(settings_selection_indexes) > 0
    local add_enabled = is_anything_selected or #settings_outer_flow.milestones_settings_scroll.milestones_settings_inner_flow.children == 0
    for _, button in pairs(settings_outer_flow.milestones_button_flow.children) do
        button.enabled = add_enabled
    end
    settings_outer_flow.milestones_delete_settings_button.enabled = is_anything_selected
end

function select_setting(event)
    local storage_player = storage.players[event.player_index]
    local checkbox_element = event.element
    local index = checkbox_element.parent.get_index_in_parent()

    if checkbox_element.state then -- The element state was already flipped at this point
        if event.shift and table_size(storage_player.settings_selection_indexes) > 0 then
            -- Shift-selection, update the range, update selections
            local first_selected
            local last_selected
            for i, checked in pairs(storage_player.settings_selection_indexes) do
                if checked then
                    if not first_selected then first_selected = i end
                    last_selected = i
                end
            end
            if index < first_selected then
                for i = index, first_selected - 2, 2 do
                    storage_player.settings_selection_indexes[i] = true
                end
            elseif index > last_selected then
                for i = last_selected + 2, index, 2 do
                    storage_player.settings_selection_indexes[i] = true
                end
            else
                storage_player.settings_selection_indexes[index] = true
            end
        elseif event.control then
            -- Additive selection
            storage_player.settings_selection_indexes[index] = true
        else
            -- Normal selection, deselect all others
            storage_player.settings_selection_indexes = {}
            storage_player.settings_selection_indexes[index] = true
        end
    else
        storage_player.settings_selection_indexes[index] = nil
    end
    update_checkbox_states(storage_player.settings_flow, storage_player.settings_selection_indexes)
    update_buttons_enabled_state(storage_player.settings_flow.parent.parent, storage_player.settings_selection_indexes)
end

function swap_settings(player_index, event)
    local index_delta = event.element.tags.direction *2 -- *2 because of separation lines
    if event.shift then
        index_delta = index_delta * 5
    end
    local settings_flow = storage.players[player_index].settings_flow

    gui_index1 = event.element.parent.parent.get_index_in_parent()
    gui_index2 = gui_index1 + index_delta
    gui_index1, gui_index2 = math.min(gui_index1, gui_index2), math.max(gui_index1, gui_index2) -- Now index1 is always the first element
    gui_index1 = math.max(gui_index1, 1) -- Don't go beyond first element
    gui_index2 = math.min(gui_index2, #settings_flow.children) -- Don't go beyond the last element

    settings_flow.swap_children(gui_index1, gui_index2)

    -- Swap selection
    local storage_player = storage.players[event.player_index]
    storage_player.settings_selection_indexes[gui_index1], storage_player.settings_selection_indexes[gui_index2] = storage_player.settings_selection_indexes[gui_index2], storage_player.settings_selection_indexes[gui_index1]

    refresh_arrow_buttons(gui_index1, settings_flow)
    refresh_arrow_buttons(gui_index2, settings_flow)
end

function delete_selected_settings(player_index)
    local storage_player = storage.players[player_index]
    local settings_flow = storage_player.settings_flow
    local inverted_indexes = {}
    for gui_index, _ in pairs(storage_player.settings_selection_indexes) do
        table.insert(inverted_indexes, 1, gui_index)
    end
    for _, gui_index in pairs(inverted_indexes) do
        settings_flow.children[gui_index].destroy()
        if #settings_flow.children > 0 then
            -- If this is the first element, we have to delete the line AFTER the element
            -- The line AFTER will be index 1 once the element is destroyed
            local line_gui_index = (gui_index == 1) and 1 or gui_index - 1
            settings_flow.children[line_gui_index].destroy()
        end
    end
    -- Update arrows of the potentially new first and last element
    if #settings_flow.children >= 1 then
        refresh_arrow_buttons(1, settings_flow)
    end
    if #settings_flow.children >= 2 then
        refresh_arrow_buttons(#settings_flow.children, settings_flow)
    end

    storage_player.settings_selection_indexes = {}
    update_buttons_enabled_state(storage_player.settings_flow.parent.parent, storage_player.settings_selection_indexes)
end

function add_setting(player_index, button_element)
    local storage_player = storage.players[player_index]
    local settings_flow = storage_player.settings_flow
    local milestone_type = button_element.tags.type

    -- Find last selected element
    local last_selected_element_index = 0
    for i = #settings_flow.children, 1, -2 do
        if storage_player.settings_selection_indexes[i] then
            last_selected_element_index = i
            break
        end
    end
    local only_element = last_selected_element_index == 0
    local insert_at_index = last_selected_element_index + 1

    if not only_element then
        settings_flow.add({type="line", index = insert_at_index})
        insert_at_index = insert_at_index + 1
    end

    local new_flow
    if milestone_type == "group" then
        local group_name = "Group " -- Can't localize default textfield values
        local group_digit = 1
        for i = last_selected_element_index, 1, -1 do
            local child = settings_flow.children[i]
            if child.type == "flow" and child.milestones_settings_group_name then
                local previous_group_name = child.milestones_settings_group_name.text
                local previous_name_digit = string.match(previous_group_name, "(%d+)$")
                if previous_name_digit then
                    previous_name_digit = tonumber(previous_name_digit)
                    group_digit = previous_name_digit + 1
                end
                break
            end
        end
        group_name = group_name .. group_digit
        new_flow = add_group(settings_flow, group_name, insert_at_index)
        new_flow.milestones_settings_group_name.focus()
        new_flow.milestones_settings_group_name.select_all()
    else
        local milestone = {type=milestone_type, quantity=1}
        new_flow = add_milestone_setting(milestone, settings_flow, insert_at_index)
    end
    refresh_arrow_buttons(insert_at_index, settings_flow)

    if only_element then
        update_buttons_enabled_state(settings_flow.parent.parent, storage_player.settings_selection_indexes)
    else
        refresh_arrow_buttons(last_selected_element_index, settings_flow)
    end

    local inner_frame = get_inner_frame(player_index)
    inner_frame.milestones_settings_outer_flow.milestones_settings_scroll.scroll_to_element(new_flow)
end

function cancel_settings_page(player_index)
    get_inner_frame(player_index).clear()
    local player = game.get_player(player_index)
    build_display_page(player)

    local outer_frame = get_outer_frame(player_index)
    local import_export_frame = outer_frame.milestones_settings_import_export
    local inside_frame = import_export_frame.milestones_settings_import_export_inside

    outer_frame.force_auto_center()
    inside_frame.clear()
    import_export_frame.visible = false
end

function confirm_settings_page(player_index)
    local player = game.players[player_index]
    if not player.admin then
        game.players[player_index].print{"milestones.message_settings_permission_denied"}
        return
    end

    local new_loaded_milestones = get_resulting_milestones_array(player_index)

    if not table.deep_compare(storage.loaded_milestones, new_loaded_milestones) then -- If something changed
        local inner_frame = get_inner_frame(player_index)
        local preset_dropdown = inner_frame.milestones_settings_outer_flow.milestones_preset_flow.milestones_preset_dropdown
        if preset_dropdown.tags.imported then
            storage.current_preset_name = "Imported"
        else
            storage.current_preset_name = preset_dropdown.get_item(preset_dropdown.selected_index)
        end

        storage.loaded_milestones = table.deep_copy(new_loaded_milestones)
        initialize_alias_table()

        local backfilled_anything = false
        for force_name, force in pairs(game.forces) do
            local storage_force = storage.forces[force_name]
            if storage_force ~= nil then
                merge_new_milestones(force_name, new_loaded_milestones)
                backfilled_anything = backfill_completion_times(force)
            end
        end
        local main_message = {"milestones.message_settings_changed"}
        if game.is_multiplayer() then
            main_message = game.print({"milestones.message_settings_changed_multiplayer", player.name})
        end
        local full_message = {"", main_message}
        if backfilled_anything then
            table.insert(full_message, " ")
            table.insert(full_message, {"milestones.message_settings_backfilled"})
        end
        game.print(full_message)
    end

    cancel_settings_page(player_index)
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_setting" then
        local prototype
        local quality
        if event.element.elem_value then
            if event.element.elem_type == "item-with-quality" then
                prototype = prototypes.item[event.element.elem_value.name]
                quality = event.element.elem_value.quality
                if quality == "normal" then quality = nil end -- For now consider a "normal" selection to be an "any" selection. Until we can get a choose-elem-button that can select "any".
            elseif event.element.elem_type == "fluid" then
                prototype = prototypes.fluid[event.element.elem_value]
            elseif event.element.elem_type == "technology" then
                prototype = prototypes.technology[event.element.elem_value]
                local visible_textfield = prototype ~= nil and prototype.research_unit_count_formula ~= nil -- No text field for unique technologies
                event.element.parent.milestones_settings_quantity.visible = visible_textfield
                if not visible_textfield then
                    event.element.parent.milestones_settings_quantity.text = "1"
                end
            elseif event.element.elem_type == "entity-with-quality" then
                prototype = prototypes.entity[event.element.elem_value.name]
                quality = event.element.elem_value.quality
                if quality == "normal" then quality = nil end -- For now consider a "normal" selection to be an "any" selection. Until we can get a choose-elem-button that can select "any".
            end
        end
        local caption = ""
        if prototype ~= nil then
            if quality ~= nil then
                caption = {"", prototype.localised_name, " (", {"quality-name."..quality}, ")"}
            else
                caption = prototype.localised_name
            end
        end
        event.element.parent.milestones_settings_label.caption = caption
    end
end)

-- Replaces 0s with 1s in quantity settings
script.on_event(defines.events.on_gui_text_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_setting_quantity" then
        local new_quantity = tonumber(event.text)
        if new_quantity ~= nil and new_quantity < 1 then
            event.element.text = "1"
        end
    end
end)

function preset_dropdown_changed(event)
    event.element.tags = {action="milestones_change_preset", imported=false}
    local selected_preset_name = event.element.get_item(event.element.selected_index)
    local preset_milestones = {}
    if presets[selected_preset_name] then
        preset_milestones = presets[selected_preset_name].milestones
    end
    switch_to_milestones_set(preset_milestones, event.player_index)
end

function reset_preset(player_index)
    -- Preset
    local chosen_preset_name = get_auto_detected_preset_name()
    local new_milestones = table.deep_copy(presets[chosen_preset_name].milestones)

    -- Preset addons
    for _preset_addon_name, preset_addon in pairs(preset_addons) do
        if is_preset_mods_enabled(preset_addon) then
            for _, milestone in pairs(preset_addon.milestones) do
                table.insert(new_milestones, milestone)
            end
        end
    end

    local preset_dropdown = get_inner_frame(player_index).milestones_settings_outer_flow.milestones_preset_flow.milestones_preset_dropdown
    local current_preset_index = table_get_index(storage.valid_preset_names, chosen_preset_name) or 1
    preset_dropdown.selected_index = current_preset_index
    preset_dropdown.tags = {action="milestones_change_preset", imported=false}

    switch_to_milestones_set(new_milestones, player_index)

     -- Can be modified or not depending on addons
    if is_preset_modified(new_milestones, chosen_preset_name) then
        preset_dropdown.caption = {"", chosen_preset_name, " ", {"milestones.settings_preset_modified"}}
    end
end

function switch_to_milestones_set(milestones_set, player_index)
    local storage_player = storage.players[player_index]
    local settings_flow = storage_player.settings_flow
    settings_flow.clear()
    if next(milestones_set) then
        fill_settings_flow(settings_flow, milestones_set)
        get_outer_frame(player_index).force_auto_center()
    end
    storage_player.settings_selection_indexes = {}
    update_buttons_enabled_state(settings_flow.parent.parent, storage_player.settings_selection_indexes)
end

function is_settings_page_visible(player_index)
    return get_inner_frame(player_index).milestones_settings_outer_flow ~= nil
end
