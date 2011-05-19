%% VK_SIM_DELETE_RESULTS Removes data belonging to the simulation from project
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function project = vk_sim_DELETE_results(project)
    if (isfield(project, 'sim_state'))
        project = rmfield(project, 'sim_state');
    end
end
