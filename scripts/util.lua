function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

function convert_and_validate_imported_json(import_string)
    local imported_milestones = game.json_to_table(import_string)

    if imported_milestones == nil then
        return nil, {"milestones.message_invalid_import_json"}
    end

    local valid_categories = {'item', 'fluid', 'technology'}
    for _, milestone in pairs(imported_milestones) do
        if not table_contains(valid_categories, milestone.type) then
            return nil, {"", {"milestones.message_invalid_import_type"}, milestone.type}
        end
        local num = tonumber(milestone.quantity)
        if num == nil or num < 1 then
            return nil, {"", {"milestones.message_invalid_import_quantity"}, milestone.quantity}
        end
    end

    return imported_milestones, nil
end
