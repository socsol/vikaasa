%% VK_VIEW_KERNEL View the viability kernel contained in the given file.
%   This function opens a project, or takes a project 'state' structure, and
%   displays the kernel contained within it, using the settings contained in
%   the project.
%
% Examples
%   % First, load a project into a structure.
%   proj = load Projects/vikaasa_default.mat;
%   % Change some of the settings:   
%   proj.alpha = 0.4;
%   proj.drawbox = 1;
%   proj.plottingmethod = 'isosurface';
%   % Now, display the kernel:
%   vk_view_kernel(proj);
%
% See also: VIKAASA, SCRIPTS, TOOLS
function vk_view_kernel(input)
    if (ischar(input))
      vk_state = load(input);
    else
      vk_state = input;
    end
    
    V = vk_state.V;
    constraint_set = vk_state.constraint_set;
    labels = vk_state.labels;
    colour = vk_state.plotcolour;
    method = vk_state.plottingmethod;
    box = vk_state.drawbox;
    alpha_val = vk_state.alpha;

    h = figure;

    if (vk_state.numslices > 0)
        slices = vk_4dgui_make_slices(0, struct('vk_state', vk_state));

        vk_make_figure_slice(V, slices, constraint_set, labels, colour, ...
            method, box, alpha_val, h);
    else
        vk_make_figure(V, constraint_set, labels, colour, method, ...
            box, alpha_val, h);
    end
end
