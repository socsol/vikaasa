%% VK_GUI_UPDATE_INPUTS Set the GUI inputs to the values recorded in the system state
%
% See also: VIKAASA, GUI
%

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
function handles = vk_gui_update_inputs(hObject, handles)
    project = handles.project;

    %% Update the main variable table
    handles = vk_gui_set_vartable(hObject, handles);

    %% Fill these inputs in with string values from project
    set(handles.controlsymbol, 'String', project.controlsymbol);
    set(handles.controlmax, 'String', ...
        num2str(project.c));
    set(handles.controltolerance, 'String', ...
        num2str(project.controltolerance));
    set(handles.stoppingtolerance, 'String', ...
        num2str(project.stoppingtolerance));
    set(handles.timediscretisation, 'String', ...
        num2str(project.h));

    %% Tick the drawbox option, if necessary.
    set(handles.drawbox, 'Value', project.drawbox);


    %% Set the two results boxes' content, and resize
    set(handles.resultstable, 'Data', vk_kernel_results(project));
    set(handles.sim_resultstable, 'Data', vk_sim_results(project));

    % Change the units of the table to pixels, so that we can calculate the
    % widths.  Has to be changed back to whatever it was afterwards.
    units = get(handles.resultstable, 'Units');
    set(handles.resultstable, 'Units', 'pixels');
    pos = get(handles.resultstable, 'Position');
    set(handles.resultstable, 'Units', units);

    width = pos(3) / 2 - 10;
    set(handles.resultstable, 'ColumnWidth', {width});
    set(handles.sim_resultstable, 'ColumnWidth', {width});


    %% Custom constraint set
    % If the 'use_custom_constraint_set_fn' option is set to true, then we
    % want to enable the input area. Otherwise, we want to disable it.
    if (project.use_custom_constraint_set_fn)
        set(handles.custom_constraint_set_fn_checkbox, 'Value', 1);
        set(handles.custom_constraint_set_fn, 'Enable', 'on');
    else
        set(handles.custom_constraint_set_fn_checkbox, 'Value', 0);
        set(handles.custom_constraint_set_fn, 'Enable', 'off');
    end

    set(handles.custom_constraint_set_fn, 'String', ...
        project.custom_constraint_set_fn);


    %% 'Hold' checkbox
    set(handles.holdfig, 'Value', project.holdfig);


    %% Colour to draw viability kernels.
    set(handles.plotcolour, 'BackgroundColor', project.plotcolour);


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
        if (strcmp(control_algs{i}, project.controlalg))
            set(handles.controlalg, 'Value', i);
            break;
        end
    end


    %% Forward-looking steps.
    set(handles.steps, 'String', project.steps);

    %% Debug
    set(handles.debug_checkbox, 'Value', project.debug);

    %% Plotting method drop-down
    plottingmethods = {'qhull'; 'isosurface'; 'isosurface-smooth'; 'scatter'; 'scatter-x'; 'scatter-+'};
    set(handles.plottingmethod, 'String', char(plottingmethods{:}));

    for i = 1:size(plottingmethods, 1)
        if (strcmp(plottingmethods{i}, project.plottingmethod))
            set(handles.plottingmethod, 'Value', i);
            break;
        end
    end

    %% Simulation options
    set(handles.sim_start, 'RowName', project.symbols);
    sim_start_data = [num2cell(project.sim_start), ...
        num2cell(logical(zeros(project.numvars, 2)))];
    if (length(project.sim_hardupper) > 0)
        sim_start_data(project.sim_hardupper, 2) = ...
            num2cell(logical(ones(length(project.sim_hardupper),1)));
    end

    if (length(project.sim_hardlower) > 0)
    sim_start_data(project.sim_hardlower, 3) = ...
        num2cell(logical(ones(length(project.sim_hardlower),1)));
    end

    set(handles.sim_start, 'Data', sim_start_data);

    set(handles.sim_iterations, 'String', ...
        num2str(project.sim_iterations));

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
        if (strcmp(sim_controlalgs{i}, project.sim_controlalg))
            set(handles.sim_controlalg, 'Value', i);
            break;
        end
    end

    set(handles.alpha, 'String', num2str(project.alpha));

    sim_methods = {'ode', 'euler'};
    set(handles.sim_method, 'String', char(sim_methods));
    for i = 1:2
        if (strcmp(sim_methods{i}, project.sim_method))
            set(handles.sim_method, 'Value', i);
            break;
        end
    end

    set(handles.sim_linecolour, 'BackgroundColor', ...
        project.sim_line_colour);
    set(handles.sim_linewidth, 'String', ...
        num2str(project.sim_line_width));

    set(handles.layers, 'String', project.layers);

    set(handles.progressbar_checkbox, 'Value', ...
        project.progressbar);

    set(handles.sim_showpoints_checkbox, 'Value', ...
        project.sim_showpoints);

    set(handles.sim_stopsteady_checkbox, 'Value', ...
        project.sim_stopsteady);

    set(handles.sim_use_nearest_checkbox, 'Value', ...
        project.sim_use_nearest);

    %% Custom cost function
    set(handles.custom_cost_fn_checkbox, 'Value', ...
        project.use_custom_cost_fn);

    if (project.use_custom_cost_fn)
        set(handles.custom_cost_fn, 'Enable', 'on');
    else
        set(handles.custom_cost_fn, 'Enable', 'off');
    end

    set(handles.custom_cost_fn, 'String', ...
        project.custom_cost_fn);


    %% controldefault
    set(handles.controldefault_checkbox, 'Value', ...
        project.use_controldefault);

    if (project.use_controldefault)
        set(handles.controldefault, 'Enable', 'on');
    else
        set(handles.controldefault, 'Enable', 'off');
    end

    set(handles.controldefault, 'String', ...
        num2str(project.controldefault));


    %% Autosave
    set(handles.autosave_checkbox, 'Value', ...
        project.autosave);


    %% control_enforce
    set(handles.controlmax_enforce_checkbox, 'Value', ...
        project.controlenforce);

    %% control_bounded
    set(handles.control_bounded_checkbox, 'Value', ...
        project.controlbounded);

    %% Slices
    numslicevars = project.numvars + length(find(project.addnignore == false));
    set(handles.slices, 'RowName', ...
        [project.symbols; project.addnsymbols(find(project.addnignore == false))]);
    slice_data = cell(numslicevars, 3);
    slice_data(:, 1:2) = mat2cell( ...
        logical(zeros(numslicevars, 2)), ...
        ones(1, numslicevars), [1 1]);
    slice_data(:, 3) = num2cell(zeros(numslicevars, 1));

    for i = 1:size(project.slices, 1)
        % If the slice relates to one of the additional vars, then we need to
        % check that the element in question isn't ignored.  If it is, we
        % skip/ignore the slice.
        skip = 0;
        if (project.slices(i, 1) <= project.numvars)
            index = project.slices(i, 1);
        elseif (project.addnignore(project.slices(i,1) - project.numvars))
            skip = 1;
        else
            index = project.slices(i, 1) - ...
                length(find(project.addnignore(1:(project.slices(i,1)-project.numvars))));
        end

        if (~skip)
            if (isnan(project.slices(i, 2)))
                slice_data{index, 1} = true;
            else
                slice_data{index, 2} = true;
                slice_data{index, 3} = project.slices(i,2);
            end
        end
    end
    set(handles.slices, 'Data', slice_data);

    %% Parfor
    set(handles.use_parfor_checkbox, 'Value', project.use_parallel);
    set(handles.parfor_processors, 'String', ...
        num2str(project.parallel_processors));
    if (project.use_parallel)
        set(handles.parfor_processors, 'Enable', 'on');
    else
        set(handles.parfor_processors, 'Enable', 'off');
    end

    set(handles.sim_timeprofile_cols, 'String', num2str(project.sim_timeprofile_cols));
end
