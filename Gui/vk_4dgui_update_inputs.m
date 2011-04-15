%% VK_4DGUI_UPDATE_INPUTS Set the GUI inputs to the values recorded in the system state
%
% See also: VIKAASA, GUI
function handles = vk_4dgui_update_inputs(hObject, handles)
    set(handles.vartable, 'Data', handles.vk_state.vardata);

    %% Fill these inputs in with string values from vk_state
    set(handles.controlsymbol, 'String', handles.vk_state.controlsymbol);
    set(handles.controlmax, 'String', ...
        num2str(handles.vk_state.controlmax));
    set(handles.discretisation, 'String', ...
        num2str(handles.vk_state.discretisation));
    set(handles.controltolerance, 'String', ...
        num2str(handles.vk_state.controltolerance));
    set(handles.stoppingtolerance, 'String', ...
        num2str(handles.vk_state.stoppingtolerance));
    set(handles.timediscretisation, 'String', ...
        num2str(handles.vk_state.timediscretisation));

    %% Depending on the number of slice, enable or disable accordingly.
    if (handles.vk_state.numslices == 0)
        set(handles.sliceradio0, 'Value', 1);
        set(handles.sliceradio1, 'Value', 0);
        set(handles.sliceradio2, 'Value', 0);
        set(handles.slice1var, 'Enable', 'off');
        set(handles.slice1val, 'Enable', 'off');
        set(handles.slice2var, 'Enable', 'off');
        set(handles.slice2val, 'Enable', 'off');
    elseif (handles.vk_state.numslices == 1)
        set(handles.sliceradio0, 'Value', 0);
        set(handles.sliceradio1, 'Value', 1);
        set(handles.sliceradio2, 'Value', 0);
        set(handles.slice1var, 'Enable', 'on');
        set(handles.slice1val, 'Enable', 'on');
        set(handles.slice2var, 'Enable', 'off');
        set(handles.slice2val, 'Enable', 'off');
    else
        set(handles.sliceradio0, 'Value', 0);
        set(handles.sliceradio1, 'Value', 0);
        set(handles.sliceradio2, 'Value', 1);
        set(handles.slice1var, 'Enable', 'on');
        set(handles.slice1val, 'Enable', 'on');
        set(handles.slice2var, 'Enable', 'on');
        set(handles.slice2val, 'Enable', 'on');
    end

    %% Depending on the number of dimensions, disable some slice options
    % Need at least one slice for > 3 dimensions
    if (handles.vk_state.numvars < 3)
        set(handles.sliceradio0, 'Enable', 'on');
        set(handles.sliceradio1, 'Enable', 'off');
        set(handles.sliceradio2, 'Enable', 'off');
    elseif (handles.vk_state.numvars > 3)
        set(handles.sliceradio0, 'Enable', 'off');
        set(handles.sliceradio1, 'Enable', 'on');
        set(handles.sliceradio2, 'Enable', 'on');
    elseif (handles.vk_state.numvars == 3) % Can't do two slices for 3D
        set(handles.sliceradio0, 'Enable', 'on');
        set(handles.sliceradio1, 'Enable', 'on');
        set(handles.sliceradio2, 'Enable', 'off');
    end               

    %% Set the elements in the slice list to be the variable labels.
    set(handles.slice1var, 'String', handles.vk_state.labels);
    set(handles.slice1var, 'Value', handles.vk_state.slice1);
    set(handles.slice2var, 'String', handles.vk_state.labels);
    set(handles.slice2var, 'Value', handles.vk_state.slice2);
    set(handles.slice1val, 'String', ...
        num2str(handles.vk_state.slice1plane(handles.vk_state.slice1)));
    set(handles.slice2val, 'String', ...
        num2str(handles.vk_state.slice2plane(handles.vk_state.slice2)));

    %% Tick the drawbox option, if necessary.
    set(handles.drawbox, 'Value', handles.vk_state.drawbox);
    
    
    %% Set the two results boxes' content, and resize
    handles = vk_4dgui_update_results(hObject, handles);   
    handles = vk_4dgui_update_sim_results(hObject, handles);
            
    % Change the units of the table to pixels, so that we can calculate the
    % widths.  Has to be changed back to whatever it was afterwards.
    units = get(handles.resultstable, 'Units');
    set(handles.resultstable, 'Units', 'pixels');    
    pos = get(handles.resultstable, 'Position');
    set(handles.resultstable, 'Units', units);    
    
    width = pos(3) / 2 - 3;
    set(handles.resultstable, 'ColumnWidth', {width});
    set(handles.sim_resultstable, 'ColumnWidth', {width});
    
    
    %% Custom constraint set
    % If the 'use_custom_constraint_set_fn' option is set to true, then we
    % want to enable the input area. Otherwise, we want to disable it.
    if (handles.vk_state.use_custom_constraint_set_fn)
        set(handles.custom_constraint_set_fn_checkbox, 'Value', 1);
        set(handles.custom_constraint_set_fn, 'Enable', 'on');
    else
        set(handles.custom_constraint_set_fn_checkbox, 'Value', 0);
        set(handles.custom_constraint_set_fn, 'Enable', 'off');
    end
            
    set(handles.custom_constraint_set_fn, 'String', ...
        handles.vk_state.custom_constraint_set_fn);
    
    
    %% 'Hold' checkbox
    set(handles.holdfig, 'Value', handles.vk_state.holdfig);
    
    
    %% Colour to draw viability kernels.
    set(handles.plotcolour, 'BackgroundColor', handles.vk_state.plotcolour);
    
    
    %% Control algorithm drop-down
    % Make a list of available control algorithms (M-files in the
    % control_algs folder).
    mfile_list = dir(fullfile(handles.path, 'ControlAlgs', '*.m'));
    mfile_list = mfile_list(find(~cellfun(@isempty,{mfile_list(:).date})));
    mfile_list = mfile_list(find(~cellfun(@(x) strcmp(x, 'Contents.m'), ...
        {mfile_list(:).name})));
    control_algs = {mfile_list(:).name};    
    control_algs = cellfun(@(x) x(1:end-2), control_algs, ...
        'UniformOutput', 0);
    
    handles.control_algs = control_algs;
    set(handles.controlalg, 'String', char(control_algs{:}));
    
    for i = 1:length(control_algs)
        if (strcmp(control_algs{i}, handles.vk_state.controlalg))
            set(handles.controlalg, 'Value', i);
            break;
        end
    end
    
    
    %% Forward-looking steps.
    set(handles.steps, 'String', handles.vk_state.steps);
    
    %% Debug
    set(handles.debug_checkbox, 'Value', handles.vk_state.debug);
    
    %% Plotting method drop-down
    plottingmethods = {'qhull'; 'isosurface'; 'isosurface-smooth'; 'scatter'};
    set(handles.plottingmethod, 'String', char(plottingmethods{:}));
    
    for i = 1:size(plottingmethods, 1)
        if (strcmp(plottingmethods{i}, handles.vk_state.plottingmethod))
            set(handles.plottingmethod, 'Value', i);
            break;
        end
    end
        
    %% Simulation options
    set(handles.sim_start, 'RowName', handles.vk_state.vardata(:, 2));
    set(handles.sim_start, 'Data', num2cell(handles.vk_state.sim_start));
    
    set(handles.sim_iterations, 'String', ...
        num2str(handles.vk_state.sim_iterations));
    
    mfile_list = dir(fullfile(handles.path, 'VControlAlgs', '*.m'));
    mfile_list = mfile_list(find(~cellfun(@isempty,{mfile_list(:).date})));
    mfile_list = mfile_list(find(~cellfun(@(x) strcmp(x, 'Contents.m'), ...
        {mfile_list(:).name})));
    vcontrol_algs = {mfile_list(:).name};    
    vcontrol_algs = cellfun(@(x) x(1:end-2), vcontrol_algs, ...
        'UniformOutput', 0);
    
    handles.vcontrol_algs = vcontrol_algs;
    sim_controlalgs = [control_algs, vcontrol_algs];
    set(handles.sim_controlalg, 'String', ...
        char(sim_controlalgs));
            
    for i = 1:length(sim_controlalgs)
        if (strcmp(sim_controlalgs{i}, handles.vk_state.sim_controlalg))
            set(handles.sim_controlalg, 'Value', i);
            break;
        end
    end
    
    set(handles.alpha, 'String', num2str(handles.vk_state.alpha));
    
    sim_methods = {'ode', 'euler'};
    set(handles.sim_method, 'String', char(sim_methods));
    for i = 1:2
        if (strcmp(sim_methods{i}, handles.vk_state.sim_method))
            set(handles.sim_method, 'Value', i);
            break;
        end
    end
    
    set(handles.sim_linecolour, 'BackgroundColor', ...
        handles.vk_state.sim_line_colour);
    set(handles.sim_linewidth, 'String', ...
        num2str(handles.vk_state.sim_line_width));
    
    set(handles.layers, 'String', handles.vk_state.layers);
    
    set(handles.progressbar_checkbox, 'Value', ...
        handles.vk_state.progressbar);
    
    set(handles.sim_showpoints_checkbox, 'Value', ...
        handles.vk_state.sim_showpoints);
    
    set(handles.sim_stopsteady_checkbox, 'Value', ...
        handles.vk_state.sim_stopsteady);
    
    
    %% Custom cost function
    set(handles.custom_cost_fn_checkbox, 'Value', ...
        handles.vk_state.use_custom_cost_fn);
    
    if (handles.vk_state.use_custom_cost_fn)
        set(handles.custom_cost_fn, 'Enable', 'on');
    else
        set(handles.custom_cost_fn, 'Enable', 'off');
    end
    
    set(handles.custom_cost_fn, 'String', ...
        handles.vk_state.custom_cost_fn);
    
    
    %% controldefault
    set(handles.controldefault_checkbox, 'Value', ...
        handles.vk_state.use_controldefault);
    
    if (handles.vk_state.use_controldefault)
        set(handles.controldefault, 'Enable', 'on');
    else
        set(handles.controldefault, 'Enable', 'off');
    end
        
    set(handles.controldefault, 'String', ...
        num2str(handles.vk_state.controldefault));
    
    
    %% Autosave
    set(handles.autosave_checkbox, 'Value', ...
        handles.vk_state.autosave);
end