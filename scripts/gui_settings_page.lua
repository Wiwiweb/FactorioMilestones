function build_settings_page(player)
    local main_frame = global.players[player.index].main_frame
    main_frame.milestones_titlebar.milestones_main_label.caption = {"gui.settings_title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = false
    main_frame.milestones_titlebar.milestones_close_button.visible = false
    main_frame.milestones_dialog_buttons.visible = true

    local inner_frame = global.players[player.index].inner_frame
    local content_table = inner_frame.add{type="table", name="milestones_content_table", column_count=2, style="milestones_table_style"}

    -- local global_force = global.forces[player.force.name]

    content_table.add{type="label", caption="Settings!"}

end
