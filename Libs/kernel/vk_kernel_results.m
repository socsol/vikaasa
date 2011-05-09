%% VK_KERNEL_RESULTS Returns the results of a kernel approximation
function results = vk_kernel_results(project)

    if (isfield(project, 'comp_datetime'))
        results = {...
                'Computation Begun at', project.comp_datetime; ...
                'Computation Time', vk_timeformat(project.comp_time); ...
                'Viable Points', size(project.V, 1); ...
                'Percentage Viable', 100 * size(project.V, 1) / ...
                    prod(project.discretisation);
        };
    else
        results = {'', 'No results'};
    end
end