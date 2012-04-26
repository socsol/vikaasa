%% VK_KERNEL_VIEW View the viability kernel contained in the given file.
%
% SYNOPSIS
%   This function opens a project, or takes a project structure, and
%   displays the kernel contained within it, using the settings contained in
%   the project.
%
% USAGE
%   % Viewing a kernel from within a project file:
%   vk_view_kernel('project.mat');
%
%   % Getting a handle to the resulting figure:
%   fig = vk_view_kernel(proj);
%
%   % Specifying an existing figure to plot into:
%   vk_view_kernel('project.mat', fig);
%   % Or:
%   p = vk_project_load('project.mat');
%   vk_view_kernel(p, fig);
%
% EXAMPLES
%   % Loading a project file, changing some settings and plotting the result:
%   % First, load a project into a structure.
%   proj = vk_project_load('Projects/vikaasa_default.mat');
%   % Change some of the settings:
%   proj.alpha = 0.4;
%   proj.drawbox = 1;
%   proj.plottingmethod = 'isosurface';
%   % Now, display the kernel:
%   vk_view_kernel(proj);
%
%   % Loading two different projects, and plotting both kernels into a single
%   % figure:
%   p1 = vk_project_load('project1.mat');
%   p2 = vk_project_load('project2.mat');
%   fig = vk_kernel_view(p1);
%   vk_kernel_view(p2, fig);
%
%   % The same thing again, but all in a single line:
%   vk_kernel_view('project2.mat', ...
%       vk_kernel_view('project1.mat'));
%
% Requires:  vk_figure_make, vk_figure_make_slice, vk_kernel_augment, vk_kernel_augment_constraints, vk_kernel_augment_slices, vk_project_load
%
% See also: vikaasa

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
function fig = vk_kernel_view(input, varargin)
    if (ischar(input))
      project = vk_project_load(input);
    else
      project = input;
    end

    %% Plot into a pre-existing figure if one is specified.
    if (nargin > 1)
        fig = varargin{1};
    else
        fig = figure;
    end

    vk_figure_make(project, fig);
end
