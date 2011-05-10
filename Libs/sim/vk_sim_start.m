%% VK_SIM_START Determine where the starting position is.
%   This function reads a start state out of the given project.  If the project
%   has 'sim_use_nearest' checked, then the nearest 'grid' point (according to
%   the discretisation) is used instead of the given one. 
function start = vk_sim_start(project)

    start = project.sim_start

    if (project.sim_use_nearest)
        for i = 1:project.numvars
            ax = linspace(project.K(2*i-1),project.K(2*i),project.discretisation(i));
            [v,j] = min(abs(ax-start(i)));
            start(i) = ax(j)
        end
    end
end
