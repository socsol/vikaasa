%% VK_SIM_RESULTS Returns the results a simulation in a cell array
function results = vk_sim_results(project)
    if (isfield(project, 'sim_state') ...
            && isfield(project.sim_state, 'comp_datetime'))
        results = {...
                'Computation Begun at', project.sim_state.comp_datetime; ...
                'Computation Time', vk_timeformat(project.sim_state.comp_time); ...
                'Number of points', size(project.sim_state.path, 2); ...
                'Lowest velocity', min(project.sim_state.normpath); ...
                'Average velocity', mean(project.sim_state.normpath); ...
        };
    else
        results = {'', 'No results'};
    end
end
