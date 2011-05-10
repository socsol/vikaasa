%% VK_GUI_LOAD_PROJECT Setup the GUI-related fields after a file is loaded.
%   This function wraps the CLI command, VK_LOAD_PROJECT.
%
% See also: CLI, GUI, VK_LOAD_PROJECT
function handles = vk_gui_load_project(hObject, handles, filename)
    handles.project = vk_load_project(filename);
    handles.filename = filename;
    set(handles.save_menu, 'Enable', 'on');
    set(handles.filename_label, 'String', filename);
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end