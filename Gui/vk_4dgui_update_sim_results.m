function handles = vk_4dgui_update_sim_results(hObject, handles)

    vk_state = handles.vk_state;    
    if (isfield(vk_state, 'sim_state') ...
            && isfield(vk_state.sim_state, 'comp_datetime'))    
        results = {...
                'Computation Begun at', vk_state.sim_state.comp_datetime; ...
                'Computation Time (s)', vk_state.sim_state.comp_time; ...
                'Number of points', size(vk_state.sim_state.path, 2);            
        };
    else
        results = {'', ''};
    end

    handles.vk_state.sim_state.results = results;
    set(handles.sim_resultstable, 'Data', results);