%% VK_GUI_PROJECT_LOAD Setup the GUI-related fields after a file is loaded.
%   This function wraps the CLI command, VK_PROJECT_LOAD.
%
% See also: CLI, GUI, VK_LOAD_PROJECT
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function handles = vk_gui_project_load(hObject, handles, filename)
    handles.project = vk_project_load(filename);
    handles.filename = filename;
    set(handles.save_menu, 'Enable', 'on');
    set(handles.filename_label, 'String', filename);
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end
