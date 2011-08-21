paths = cell2mat(simulation(:, 2:end));

figure
title('Output gap decomposition');
hold on
plot(paths(1,:), -0.2*paths(2, :), ...
    'Color', 'r', 'DisplayName', 'Output gap effect');
plot(paths(1,:), -0.5*(paths(4, :) - paths(3,:)), ...
    'Color', 'g', 'DisplayName', 'Real interest rate effect');
plot(paths(1,:), 0.2*paths(5,:), ...
    'Color', 'k', 'DisplayName', 'Exchange rate effect');
plot(paths(1,:), -0.2*paths(2, :) -0.5*(paths(4, :) - paths(3,:)) + 0.2*paths(5,:), ...
    'Color', 'b', 'DisplayName', 'xdot');
legend show

figure
title('Taylor rule decomposition');
hold on
plot(paths(1,:), 0.5*paths(2, :), ...
    'Color', 'r', 'DisplayName', 'Output gap effect');
plot(paths(1,:), 1.5*(paths(3,:) - 0.02), ...
    'Color', 'g', 'DisplayName', 'Inflation gap effect');
plot(paths(1,:), 0.5*paths(2, :) + 1.5*(paths(3,:) - 0.02), ...
    'Color', 'k', 'DisplayName', 'Combined effect');
plot(paths(1,:), 0.02 + 0.5*paths(2, :) + 1.5*(paths(3,:) - 0.02), ...
    'Color', 'b', 'DisplayName', 'Taylor rule');
legend show


