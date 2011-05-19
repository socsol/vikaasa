%% VK_GUI_SET_VARTABLE Update the vartable to reflect the project
%
% See also: VIKAASA
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
function handles = vk_gui_set_vartable(hObject, handles)
    project = handles.project;

    vartable = cell(project.numvars, 6);

    vartable(:, 1) = project.labels;
    vartable(:, 2) = project.symbols;
    vartable(:, 5) = num2cell(project.discretisation);
    vartable(:, 6) = project.diff_eqns;

    for i = 1:project.numvars
        vartable(i, 3:4) = num2cell(project.K(2*i-1:2*i));
    end

    set(handles.vartable, 'Data', vartable);
end
