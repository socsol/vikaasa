%% VK_GUI_PROJECT_LOAD Setup the GUI-related fields after a file is loaded.
%
% SYNOPSIS
%   This function wraps the CLI command, vk_project_load, providing some
%   additional support in the VIKAASA GUI.
%
% Requires:  vk_gui_update_inputs, vk_project_load
%
% See also: gui

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
function handles = vk_gui_project_load(hObject, handles, filename)
    handles.project = vk_project_load(filename);
    handles.filename = filename;
    set(handles.save_menu, 'Enable', 'on');
    set(handles.filename_label, 'String', filename);
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end
