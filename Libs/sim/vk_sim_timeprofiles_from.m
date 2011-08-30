%% VK_SIM_TIMEPROFILES_FROM Create a simulation and view its time profile
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
function project = vk_sim_timeprofiles_from(project, start)
  project.sim_start = start;
  project.sim_state = vk_sim_make(project);
  vk_figure_timeprofiles_make(project);
end
