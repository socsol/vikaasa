%% VK_SIM_RESULTS Returns the results a simulation in a cell array
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
