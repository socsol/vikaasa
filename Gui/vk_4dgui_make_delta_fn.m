function delta_fn = vk_4dgui_make_delta_fn(hObject, handles)
    % Create inline functions for the differential equations.
    symbols = handles.vk_state.symbols;
    controlsymbol = handles.vk_state.controlsymbol;
    args = mat2cell(symbols,ones(1,size(symbols,1)),size(symbols,2));
    
    diff_eqn_strs = handles.vk_state.diff_eqn;
    
    diff_eqns = cell(size(diff_eqn_strs,1), 1);
    for i = 1:size(diff_eqn_strs,1)
        diff_eqns{i} = inline(diff_eqn_strs(i,:), args{:}, controlsymbol);
    end
    
    % Create the "delta_fn" -- the transition function, based on the
    % differential equations.
    delta_fn = @(x,u) vk_delta_fn(diff_eqns, x, u);
end