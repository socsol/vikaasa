%% VK_SIM_START Determine where the starting position is.
%   This function reads a start state out of the given project.  If the project
%   has 'sim_use_nearest' checked, then the nearest 'grid' point (according to
%   the discretisation) is used instead of the given one. 
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
function start = vk_sim_start(project)

    start = project.sim_start;

    if (project.sim_use_nearest)
        for i = 1:project.numvars
            ax = linspace(project.K(2*i-1),project.K(2*i),project.discretisation(i));
            [v,j] = min(abs(ax-start(i)));
            start(i) = ax(j);
        end
    end
end
