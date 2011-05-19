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
%

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
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
        vk_figure_make_slice(V, project.slices, K, labels, colour, ...
            method, box, alpha_val, h);
    else
        vk_figure_make(V, K, labels, colour, method, ...
            box, alpha_val, h);
    end
end
