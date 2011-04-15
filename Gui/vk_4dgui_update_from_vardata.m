% --- Sets the drop-downs to match the labels, and sets some other system
% variables so that they match the vardata array.
function handles = vk_4dgui_update_from_vardata(vardata, hObject, handles)
    ret = vk_4dgui_state_from_vardata(vardata);
    settings = struct(ret{:});
    
    set(handles.slice1var, 'String', settings.labels);
    set(handles.slice2var, 'String', settings.labels);
            
    handles.vk_state.vardata = vardata;
    handles.vk_state.labels = settings.labels;
    handles.vk_state.symbols = settings.symbols;
    handles.vk_state.constraint_set = settings.constraint_set;
    handles.vk_state.diff_eqn = settings.diff_eqn;
    
    handles = vk_4dgui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end