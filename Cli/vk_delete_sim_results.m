%% VK_DELETE_SIM_RESULTS Removes data belonging to the simulation from project
function project = vk_delete_sim_results(project)
    if (isfield(project, 'sim_state'))
        project = rmfield(project, 'sim_state');
    end
end
