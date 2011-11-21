%% VK_GUI_SET_VARTABLE Update the `vartable' to reflect the project
%
% SYNOPSIS
%   The `vartable' is the table of variables in VIKAASA that contains the main
%   dynamic variables.   This function inserts information into that table (and
%   into the addnvartable too) from a given project.  You don't need to use it
%   yourself.
%
% USAGE
%   % The project should be in 'handles.project'.
%   handles = vk_gui_set_vartable(hObject, handles);
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
function handles = vk_gui_set_vartable(hObject, handles)
    project = handles.project;

    %% Populate vartable
    vartable = cell(project.numvars, 6);

    vartable(:, 1) = project.labels;
    vartable(:, 2) = project.symbols;
    vartable(:, 5) = num2cell(project.discretisation);
    vartable(:, 6) = project.diff_eqns;

    for i = 1:project.numvars
        vartable(i, 3:4) = num2cell(project.K(2*i-1:2*i));
    end

    set(handles.vartable, 'Data', vartable);

    %% Populate addnvartable
    addnvartable = cell(project.numaddnvars, 4);
    if (project.numaddnvars > 0)
      addnvartable(:, 1) = project.addnlabels;
      addnvartable(:, 2) = project.addnsymbols;
      addnvartable(:, 3) = project.addneqns;
      addnvartable(:, 4) = num2cell(logical(project.addnignore));
    end
    set(handles.addnvartable, 'Data', addnvartable);

    %% Populate the controlvartable
    controlvartable = cell(project.numcontrols, 3);
    if (project.numcontrols > 0)
      controlvartable(:, 1) = project.controllabels;
      controlvartable(:, 2) = project.controlsymbols;
      controlvartable(:, 3) = num2cell(project.c);
    end
    set(handles.controlvartable, 'Data', controlvartable);
end
