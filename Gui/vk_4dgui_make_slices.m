function slices = vk_4dgui_make_slices(hObject, handles)
    
    constraint_set = handles.vk_state.constraint_set;
    discretisation = handles.vk_state.discretisation;
    
    slices = [];
    
    if (handles.vk_state.numslices > 0)
        % The first slice always gets done.
        slice1 = handles.vk_state.slice1;
        slice1plane = handles.vk_state.slice1plane(slice1);

        distance1 = (constraint_set(slice1 * 2) ...
            - constraint_set(slice1 * 2 - 1)) / discretisation;

        % Slices is an n x 3 matrix.   Each row specifies a slice.
        slices = [slice1, slice1plane, distance1];

        if (handles.vk_state.numslices == 2)
            slice2 = handles.vk_state.slice2;
            slice2plane = handles.vk_state.slice2plane(slice2);

            distance2 = (constraint_set(slice2 * 2) ...
                - constraint_set(slice2 * 2 - 1)) / discretisation;

            slices = vertcat(slices, [slice2, slice2plane, distance2]);
        end
    end
end