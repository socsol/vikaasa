%% VK_PROJECT_FROM_VARDATA Returns a skeleton project from a cell array
function ret = vk_project_parse_vardata(vardata)
    ret = { ...
        'vardata', {vardata}, ...
        'labels', {vardata(:,1)}, ...
        'symbols', {vardata(:, 2)}, ...
        'K', ...
            reshape(transpose(cell2mat(vardata(:, 3:4))), 1, []), ...
        'discretisation', cell2mat(vardata(:, 5)), ...
        'diff_eqns', {vardata(:, 6)} ...
    };
end
