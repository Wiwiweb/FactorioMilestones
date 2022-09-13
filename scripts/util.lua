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

    local valid_categories = {'item', 'fluid', 'technology', 'kill', 'group', 'alias'}
    for _, milestone in pairs(imported_milestones) do
        if not table_contains(valid_categories, milestone.type) then
            return nil, {"", {"milestones.message_invalid_import_type"}, milestone.type}
        end
        if type(milestone.name) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "name"}
        end
        if milestone.type ~= 'group' then
            local num = tonumber(milestone.quantity)
            if num == nil or num < 1 then
                return nil, {"", {"milestones.message_invalid_import_quantity"}, milestone.quantity}
            end
            if milestone.next ~= nil then
                local operator, _ = parse_next_formula(milestone.next)
                if operator == nil then
                    return nil, {"", {"milestones.message_invalid_import_next"}, milestone.next}
                end
            end
        end
        if milestone.type == 'alias' and type(milestone.equals) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "equals"}
        end
    end

    return imported_milestones, nil
end
