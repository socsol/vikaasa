% --- Saves the state variables into the GUI's handle.
function handles = vk_4dgui_set_state(vk_state, hObject, handles)
       
    handles.vk_state = vk_4dgui_state_sanitise(vk_state);    
    guidata(hObject, handles);    
    handles = vk_4dgui_update_inputs(hObject, handles);