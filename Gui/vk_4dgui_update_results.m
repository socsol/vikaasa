function handles = vk_4dgui_update_results(hObject, handles)
    vk_state = handles.vk_state;
    
    if (isfield(vk_state, 'comp_datetime'))
        results = {...
                'Computation Begun at', vk_state.comp_datetime; ...
                'Computation Time (s)', vk_state.comp_time; ...
                'Viable Points', size(vk_state.V, 1); ...
                'Percentage Viable', 100 * size(vk_state.V, 1) / ...
                    vk_state.discretisation^vk_state.numvars;
        };
    else
        results = {'', ''};
    end

    handles.vk_state.results = results;
    set(handles.resultstable, 'Data', results);