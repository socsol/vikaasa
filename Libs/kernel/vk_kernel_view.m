%% VK_KERNEL_VIEW View the viability kernel contained in the given file.
%   This function opens a project, or takes a project 'state' structure, and
%   displays the kernel contained within it, using the settings contained in
%   the project.
%
% Examples
%   % First, load a project into a structure.
%   proj = vk_project_load('Projects/vikaasa_default.mat');
%   % Change some of the settings:
%   proj.alpha = 0.4;
%   proj.drawbox = 1;
%   proj.plottingmethod = 'isosurface';
%   % Now, display the kernel:
%   vk_view_kernel(proj);
%
% See also: VIKAASA, SCRIPTS, TOOLS
function vk_kernel_view(input)
    if (ischar(input))
      project = vk_project_load(input);
    else
      project = input;
    end

    V = project.V;
    K = project.K;
    labels = project.labels;
    colour = project.plotcolour;
    method = project.plottingmethod;
    box = project.drawbox;
    alpha_val = project.alpha;

    h = figure;

    if (size(project.slices,1) > 0)
        vk_make_figure_slice(V, project.slices, K, labels, colour, ...
            method, box, alpha_val, h);
    else
        vk_make_figure(V, K, labels, colour, method, ...
            box, alpha_val, h);
    end
end
