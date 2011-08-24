%% VIKAASA The VIKAASA GUI.
%   VIKAASA stands for VIability Kernel Approximation, Analysis and
%   Simulation Application.
%
%   The VIKAASA graphical user interface (GUI) provides a front-end to the
%   VIKAASA library for computation and analysis of viability kernels with
%   two to four variables.
%
%   Running VIKAASA opens the VIKAASA GUI, or raises the GUI window if VIKAASA
%   is already open (only one instance of the VIKAASA GUI can be open at a
%   time).
%
%   See the VIKAASA manual for more detailed information on using the GUI.
%
% See also: vikaasa_cli, gui, project

%%
%    Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
function varargout = vikaasa(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vikaasa_OpeningFcn, ...
                   'gui_OutputFcn',  @vikaasa_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

%% GUI Opening Function -- executes when GUI is made visible
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vikaasa (see VARARGIN)
function vikaasa_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for vikaasa
    handles.output = hObject;
    handles.interface = mfilename;

    %% Initialise the VIKAASA environment.
    handles.path = pwd;
    run Libs/vk_init.m
    handles.version = vk_version;
    handles.copyright = vk_copyright;
    fprintf('%s\n\n', vk_copyright);

    filename = fullfile(handles.path, 'Projects', 'vikaasa_default.mat');
    fprintf('Loading file: %s\n', filename);
    handles = vk_gui_project_load(hObject, handles, filename);

    set(hObject, 'Name', ['VIKAASA ', handles.version]);
    set(hObject, 'Tag', 'vikaasa');

    % Update handles structure
    guidata(hObject, handles);
end

%% GUI Output Function -- Returns data to the MATLAB Command Window.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function varargout = vikaasa_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

%% Run Algorithm button pressed
% hObject    handle to runalg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function runalg_button_Callback(hObject, eventdata, handles)

    %% Get the project.
    project = handles.project;


    %% Read settings from project.
    K = project.K;
    c = project.c;
    f = vk_diff_make_fn(project);


    %% Create a waitbar, if required.
    if (project.progressbar && ~project.use_parallel)
        wb_message = 'Determining viability kernel ...';
        wb = vk_gui_make_waitbar(wb_message);
        computations = prod(project.discretisation);
        options = vk_options_make(project, f, wb, computations, wb_message);
    else
        if (project.use_parallel)
            warning('Waitbar cannot be displayed when computing in parallel.');
        end
        options = vk_options_make(project, f);
    end


    %% Display debugging information
    if (handles.project.debug)
        % Output the settings to the screen for debugging.
        K
        f
        c
        options
    end


    % Get the current window name.
    name = get(handles.figure1, 'Name');

    % If the name already contains some "- MESSAGE", get rid of it.
    pos = regexp(name, '\s-\s[A-Z\s]+$');
    if (~isempty(pos))
        name = name(1:pos(1)-1);
    end
    set(handles.figure1, 'Name', [name, ' - RUNNING ALGORITHM']);

    % Run the computation.
    cl = fix(clock);
    tic;
    fprintf('RUNNING ALGORITHM\n');
    success = 0; error = 0;
    try
        V = vk_kernel_compute(K, f, c, options);

        if (options.cancel_test_fn())
            message_title = 'Kernel Computation Cancelled';
            message1 = 'Cancelled at ';
            message2 = '';
            fprintf('CANCELLED\n');
        else
            message_title = 'Kernel Computation Completed';
            message1 = 'Finished at ';
            message2 = '';
            fprintf('FINISHED\n');
            success = 1;
        end
    catch exception
        message_title = 'Kernel Computation Error';
        message1 = 'Error at ';
        message2 = ['Error message: ', exception.message];

        fprintf('ERROR: %s\n', exception.message);
        error = 1;
    end

    comp_time = toc;

    % Delete the progress bar, if there was one.
    if (project.progressbar && ~project.use_parallel)
        delete(wb);
    end

    % Save the results into our state structure if successful.
    if (success)
        handles.project.V = V;
        handles.project.comp_time = comp_time;
        handles.project.comp_datetime = ...
            sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

        % If autosave is on, then save the result now.
        if (handles.project.autosave)
            filename = fullfile(handles.path, 'Projects', 'autosave.mat');
            if (vk_project_save(project, filename))
                message2 = ['Auto-Saved to ', filename];
            else
                message2 = ['Failed to auto-save to ', filename];
            end
        else
            message2 = '';
        end

        guidata(hObject, handles);
        set(handles.resultstable, 'Data', vk_kernel_results(handles.project));
    end

    % Remove 'RUNNING ALGORITHM' from the title.
    set(handles.figure1, 'Name', name);

    % Display a message.
    c2 = fix(clock);
    msgbox([message1, ...
        sprintf('%i-%i-%i %i:%i:%i', ...
            c2(1), c2(2), c2(3), c2(4), c2(5), c2(6)), ...
        '.  ', message2], ...
        message_title, 'none', 'modal');

    % If we are debugging, rethrow the error
    if (handles.project.debug && error)
        rethrow(exception);
    end
end

%% Maximum Control Size
% hObject    handle to controlmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controlmax_Callback(hObject, eventdata, handles)
    handles.project.c = str2double(get(hObject, 'String'));
    guidata(hObject, handles);
end

% hObject    handle to controlmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function controlmax_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% Plot button pressed -- display either a full kernel or a sliced kernel
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function plot_button_Callback(hObject, eventdata, handles)
    V = vk_kernel_augment(handles.project);
    K = vk_kernel_augment_constraints(handles.project);
    labels = [handles.project.labels; ...
        handles.project.addnlabels(find(~handles.project.addnignore))];
    colour = handles.project.plotcolour;
    method = handles.project.plottingmethod;
    box = handles.project.drawbox;
    alpha_val = handles.project.alpha;

    if (handles.project.holdfig && isfield(handles, 'current_figure'))
        h = handles.current_figure;
    else
        h = figure(...
            'CloseRequestFcn', ...
            @(h, event) eval('try vk_gui_figure_close(h, event), catch, delete(h), end'), ...
            'WindowButtonMotionFcn', ...
            @(h, event) eval('try vk_gui_figure_focus(h, event), catch, end'));
    end

    % If we are ignoring any variables, elminate them from the slices, and all
    % slice = all values.
    slices = vk_kernel_augment_slices(handles.project);

    if (size(slices, 1) > 0)
        vk_figure_make_slice(V, slices, K, labels, colour, ...
            method, box, alpha_val, h);
    else % Just plot the whole thing.
        vk_figure_make(V, K, labels, colour, method, ...
            box, alpha_val, h);
    end

    handles.current_figure = h;
    guidata(hObject, handles);
end


%% State-space discretisation
% hObject    handle to discretisation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function discretisation_Callback(hObject, eventdata, handles)
    handles.project.discretisation = str2double(get(hObject, 'String'));
    guidata(hObject, handles);
end

% hObject    handle to discretisation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function discretisation_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% File menu -- Load, Save, Save As ...
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function file_menu_Callback(hObject, eventdata, handles)
end

% hObject    handle to load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function load_menu_Callback(hObject, eventdata, handles)
    [filename, pathname] = uigetfile( ...
        {'*.mat', 'All MAT-Files (*.mat)'; ...
            '*.*','All Files (*.*)'}, ...
        'Select MAT file');
    % If "Cancel" is selected then return
    if isequal([filename,pathname],[0,0])
        return
    % Otherwise construct the fullfilename and Check and load the file.
    else
        File = fullfile(pathname,filename);
        handles = vk_gui_project_load(hObject, handles, File);
        guidata(hObject, handles);
    end
end

% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function save_menu_Callback(hObject, eventdata, handles)
    vk_project_save(handles.project, handles.filename);
end

% hObject    handle to saveas_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function saveas_menu_Callback(hObject, eventdata, handles)
    % Allow the user to select the file name to save to
    [filename, pathname] = uiputfile( ...
        {'*.mat';'*.*'}, ...
        'Save as');
    % If 'Cancel' was selected then return
    if isequal([filename,pathname],[0,0])
        return;
    else
        if (~strcmp(filename(end-3:end), '.mat'))
            filename = [filename, '.mat'];
        end

        % Construct the full path and save
        File = fullfile(pathname,filename);
        success = vk_project_save(handles.project, File);

        % If successful, allow the 'save' menu option to work.
        if (success)
            set(handles.save_menu, 'Enable', 'on');
            set(handles.filename_label, 'String', filename);
            handles.filename = File;
            guidata(hObject,handles);
        end
    end
end

% hObject    handle to new_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function new_menu_Callback(hObject, eventdata, handles)
    % Create the new project and save it in the GUI state.
    handles.project = vk_project_new( ...
        'numvars', 2, ...
        'labels', {{'Variable 1'; 'Variable 2'}}, ...
        'symbols', {{'x'; 'y'}}, ...
        'K', [0, 0, 0, 0], ...
        'discretisation', [11; 11], ...
        'diff_eqns', {{'0'; '0'}} ...
    );

    % Update the GUI to display the new project.
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end


%% The 'Variables' table has been edited.
% hObject    handle to vartable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%    Indices: row and column indices of the cell(s) edited
%    PreviousData: previous data for the cell(s) edited
%    EditData: string(s) entered by the user
%    NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%    Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
function vartable_CellEditCallback(hObject, eventdata, handles)
    vardata = get(hObject, 'Data');
    changes = struct(...
        'labels', {vardata(:,1)}, ...
        'symbols', {vardata(:, 2)}, ...
        'K', ...
            reshape(transpose(cell2mat(vardata(:, 3:4))), 1, []), ...
        'discretisation', cell2mat(vardata(:, 5)), ...
        'diff_eqns', {vardata(:, 6)} ...
    );

    handles.project.labels = changes.labels;
    handles.project.symbols = changes.symbols;
    handles.project.K = changes.K;
    handles.project.discretisation = changes.discretisation;
    handles.project.diff_eqns = changes.diff_eqns;

    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end


%% The symbol used to represent the control (usually 'u')
% hObject    handle to controlsymbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controlsymbol_Callback(hObject, eventdata, handles)
    handles.project.controlsymbol = get(hObject, 'String');
    guidata(hObject, handles);
end

% hObject    handle to controlsymbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function controlsymbol_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'draw box' check-box has been clicked
% hObject    handle to drawbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function drawbox_Callback(hObject, eventdata, handles)

    handles.project.drawbox = get(hObject, 'Value');
    guidata(hObject, handles);
end

%% The 'control tolerance' option
% hObject    handle to controltolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controltolerance_Callback(hObject, eventdata, handles)
    handles.project.controltolerance = str2double(get(hObject, 'String'));
    guidata(hObject, handles);
end

% hObject    handle to controltolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function controltolerance_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'custom constraint set function' option
% hObject    handle to custom_exited_fn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function custom_constraint_set_fn_Callback(hObject, eventdata, handles)
    disp('hi');
    handles.project.custom_constraint_set_fn = get(hObject,'String');
    guidata(hObject, handles);
end

% hObject    handle to custom_exited_fn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function custom_constraint_set_fn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% hObject    handle to custom_exited_fn_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function custom_constraint_set_fn_checkbox_Callback(hObject, eventdata, handles)

    handles.project.use_custom_constraint_set_fn = get(hObject,'Value');
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end


%% The stopping tolerance
% hObject    handle to stoppingtolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function stoppingtolerance_Callback(hObject, eventdata, handles)
    handles.project.stoppingtolerance = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to stoppingtolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function stoppingtolerance_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'time discretisation', now actually called 'step size'
% hObject    handle to timediscretisation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function timediscretisation_Callback(hObject, eventdata, handles)
    handles.project.h = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to timediscretisation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function timediscretisation_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'hold on' checkbox.  Used to draw figures over other figures.
% hObject    handle to holdfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function holdfig_Callback(hObject, eventdata, handles)
    handles.project.holdfig = get(hObject, 'Value');
    guidata(hObject, handles);
end


%% The 'plot colour' button.  A coloured button.
% hObject    handle to plotcolour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function plotcolour_Callback(hObject, eventdata, handles)
    handles.project.plotcolour = uisetcolor(handles.project.plotcolour);
    set(hObject, 'BackgroundColor', handles.project.plotcolour);
    guidata(hObject, handles);
end


%% The control algorithm to use for simulation.
% This drop-down is populated from the ControlAlgs and VControlAlgs
% folders.
% hObject    handle to sim_controlalg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_controlalg_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    handles.project.sim_controlalg = contents{get(hObject,'Value')};
    guidata(hObject, handles);
end

% hObject    handle to sim_controlalg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function sim_controlalg_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'Go' button for simulations.
% hObject    handle to sim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_button_Callback(hObject, eventdata, handles)

    %% Get project file
    project = handles.project;

    %% Construct the differential function
    f = vk_diff_make_fn(project);

    %% Construct options, containing progress bar if necessary.
    if (handles.project.progressbar)
        wb_message = 'Running Simulation ...';
        wb = vk_gui_make_waitbar(wb_message);
        options = vk_options_make(handles.project, f, wb, project.sim_iterations, ...
            wb_message);
    else
        options = vk_options_make(handles.project, f);
    end

    %% Add 'RUNNING SIMULATION' to the titlebar
    % Get the current window name.
    name = get(handles.figure1, 'Name');

    % If the name already contains some "- MESSAGE", get rid of it.
    pos = regexp(name, '\s-\s[A-Z\s]+$');
    if (~isempty(pos))
        name = name(1:pos(1)-1);
    end
    set(handles.figure1, 'Name', [name, ' - RUNNING SIMULATION']);

    sim_state = vk_sim_make(project, options);

    %% Delete any waitbars
    if (handles.project.progressbar)
        delete(wb);
    end

    %% Remove 'RUNNING SIMULATION' from titlebar.
    set(handles.figure1, 'Name', name);

    %% If the simulation completed successfully, add it into the project.
    if (sim_state.success)
        handles.project.sim_state = sim_state;
        handles = vk_gui_update_inputs(hObject, handles);
        guidata(hObject, handles);
    end

    %% If debugging is turned on, rethrow any error.
    if (handles.project.debug && isstruct(sim_state.error))
        rethrow(sim_state.error);
    end
end


%% The 'time horizon' for the simulation (used to be called 'iterations')
% hObject    handle to sim_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_iterations_Callback(hObject, eventdata, handles)
    handles.project.sim_iterations = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end


% hObject    handle to sim_iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function sim_iterations_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The number of forward-looking steps employed by optimizing algorithms.
% hObject    handle to steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function steps_Callback(hObject, eventdata, handles)
    handles.project.steps = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function steps_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'debug' checkbox has been clicked
% hObject    handle to debug_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function debug_checkbox_Callback(hObject, eventdata, handles)
    handles.project.debug = get(hObject,'Value');
    guidata(hObject, handles);
end


%% The control algorithm used by the kernel determination routine
% hObject    handle to controlalg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controlalg_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    handles.project.controlalg = contents{get(hObject,'Value')};
    guidata(hObject, handles);
end

% hObject    handle to controlalg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function controlalg_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The plotting method drop-down
% hObject    handle to plottingmethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function plottingmethod_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    handles.project.plottingmethod = contents{get(hObject,'Value')};
    guidata(hObject, handles);
end

function plottingmethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plottingmethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The simulation starting-point cell array
% hObject    handle to sim_start (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%    Indices: row and column indices of the cell(s) edited
%    PreviousData: previous data for the cell(s) edited
%    EditData: string(s) entered by the user
%    NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%    Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
function sim_start_CellEditCallback(hObject, eventdata, handles)
    data = get(hObject, 'Data');
    handles.project.sim_start = cell2mat(data(:,1));

    handles.project.sim_hardupper = find(cell2mat(data(:,2)));
    handles.project.sim_hardlower = find(cell2mat(data(:,3)));

    guidata(hObject, handles);
end


%% The line colour for drawing simulation results
% hObject    handle to sim_linecolour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_linecolour_Callback(hObject, eventdata, handles)
    handles.project.sim_line_colour = ...
        uisetcolor(handles.project.sim_line_colour);
    set(hObject, 'BackgroundColor', ...
        handles.project.sim_line_colour);
    guidata(hObject, handles);
end


%% The line width for drawing simulaton trajectories
% hObject    handle to sim_linewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_linewidth_Callback(hObject, eventdata, handles)
    handles.project.sim_line_width = str2double(get(hObject, 'String'));
    guidata(hObject, handles);
end

% hObject    handle to sim_linewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function sim_linewidth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'time profiles' button' -- draw time profiles for the simulation.
% hObject    handle to sim_timeprofiles_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_timeprofiles_button_Callback(hObject, eventdata, handles)
    if (~isfield(handles.project, 'sim_state'))
        errordlg('Could not create simulation plot, because there is no data present.');
        return;
    end

    % Information from the project
    project = handles.project;

    % Make a figure (or use an existing one)
    if (project.holdfig && isfield(handles, 'current_timeprofile'))
        h = handles.current_timeprofile;
    else
        h = figure(...
            'CloseRequestFcn', ...
            @(h, event) eval('try vk_gui_figure_close(h, event, ''tp''), catch, delete(h), end'), ...
            'WindowButtonMotionFcn', ...
            @(h, event) eval('try vk_gui_figure_focus(h, event, ''tp''), catch, end'), ...
            'Name', 'Time Profiles' ...
            );
    end

    h = vk_figure_timeprofiles_make(project, 'handle', h);
    handles.current_timeprofile = h;
    guidata(hObject, handles);
end


%% The 'show points' checkbox for drawing simulation trajectories.
% hObject    handle to sim_showpoints_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_showpoints_checkbox_Callback(hObject, eventdata, handles)
    handles.project.sim_showpoints = get(hObject,'Value');
    guidata(hObject, handles);
end


%% The 'add to current figure' button for drawing simulations
% hObject    handle to sim_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_plot_button_Callback(hObject, eventdata, handles)
    if (~isfield(handles.project, 'sim_state'))
        errordlg('Could not create simulation plot, because there is no data present.');
        return;
    end

    if (~isfield(handles, 'current_figure'))
        errordlg('Could not create simulation plot, because no figure exists.');
        return;
    end

    h = handles.current_figure;
    figure(h);

    sim_state = vk_sim_augment(handles.project);
    [limits, slices] = vk_figure_data_retrieve(h);

    T = sim_state.T;
    path = sim_state.path;
    if (~isempty(slices))
        slices = sortrows(slices, -1);
        for i = 1:size(slices, 1)
            path = [path(1:slices(i, 1)-1, :); path(slices(i, 1)+1:end, :)];
        end
    end

    limits = vk_plot_path_limits(limits, path);

    viablepath = sim_state.viablepath;
    showpoints = handles.project.sim_showpoints;

    vk_plot_path(T, path, viablepath, showpoints, ...
        handles.project.sim_line_colour, handles.project.sim_line_width);

    vk_figure_data_insert(h, limits, slices);
    axis(limits);
end


%% The 'interactive view' button for creating interactive simulations
% hObject    handle to sim_gui_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_gui_button_Callback(hObject, eventdata, handles)
    % Display settings.
    display_opts = struct(...
        'alpha', handles.project.alpha, ...
        'labels', {[handles.project.labels; ...
            handles.project.addnlabels(find(~handles.project.addnignore))]}, ...
        'colour', handles.project.plotcolour, ...
        'line_colour', handles.project.sim_line_colour, ...
        'line_width', handles.project.sim_line_width, ...
        'method', handles.project.plottingmethod, ...
        'showpoints', handles.project.sim_showpoints, ...
        'slices', vk_kernel_augment_slices(handles.project), ...
        'parent', handles.figure1 ...
    );

    if (isfield(handles.project, 'sim_state'))
        vk_gui_simgui(vk_sim_augment(handles.project), display_opts);
    else
        errordlg('Could not create interactive simulation, because there is no data present.');
    end
end


%% The simulation method -- either 'ode' or 'euler'
% hObject    handle to sim_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_method_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    handles.project.sim_method = contents{get(hObject,'Value')};
    guidata(hObject, handles);
end

% hObject    handle to sim_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function sim_method_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% The 'layers' option for use with satisficing control algorithm
% hObject    handle to layers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function layers_Callback(hObject, eventdata, handles)
    handles.project.layers = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to layers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function layers_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'alpha' option for plotting semi-transparent kernels.
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function alpha_Callback(hObject, eventdata, handles)
    handles.project.alpha = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function alpha_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The 'plot alone' option for drawing simulation results.
% hObject    handle to sim_plotalone_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_plotalone_button_Callback(hObject, eventdata, handles)
    if (~isfield(handles.project, 'sim_state'))
        errordlg('Could not create simulation plot, because there is no data present.');
        return;
    end

    h = figure;

    title(['Simulation starting from ', ...
        num2str(transpose(handles.project.sim_state.path(:,1))), ...
        ' for ', num2str(handles.project.sim_state.T(end)), ...
        ' time intervals']);

    sim_state = vk_sim_augment(handles.project);

    T = sim_state.T;
    path = sim_state.path;

    slices = vk_kernel_augment_slices(handles.project);
    K = vk_kernel_augment_constraints(handles.project);
    labels = [handles.project.labels; ...
        handles.project.addnlabels(find(~handles.project.addnignore))];
    if (~isempty(slices))
        slices = sortrows(slices, -1);
        for i = 1:size(slices, 1)
            path = [path(1:slices(i, 1)-1, :); path(slices(i, 1)+1:end, :)];
            K = [K(1:2*slices(i, 1)-2), ...
                K(2*slices(i, 1)+1:end)];
            labels = [labels(1:slices(i, 1)-1); ...
                labels(slices(i, 1)+1:end)];
        end
    end

    if (handles.project.drawbox)
        limits = vk_plot_box(K);
    else
        limits = K;
    end
    limits = vk_plot_path_limits(limits, path);

    viablepath = sim_state.viablepath;
    showpoints = handles.project.sim_showpoints;

    vk_plot_path(T, path, viablepath, showpoints, ...
        handles.project.sim_line_colour, handles.project.sim_line_width);

    vk_figure_data_insert(h, limits, slices);
    axis(limits);
    grid on;

    xlabel(labels(1, :));
    ylabel(labels(2, :));
    if (length(limits) == 6)
        zlabel(labels(3, :));
        view(3);
    end
end


%% The 'progress bar' checkbox -- for displaying a bar while computing
% hObject    handle to progressbar_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function progressbar_checkbox_Callback(hObject, eventdata, handles)
    handles.project.progressbar = get(hObject,'Value');
    guidata(hObject, handles);
end


%% The 'stop when steady' checkbox for simulations.
% hObject    handle to sim_stopsteady_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function sim_stopsteady_checkbox_Callback(hObject, eventdata, handles)
    handles.project.sim_stopsteady = get(hObject,'Value');
    guidata(hObject, handles);
end


%% The 'default control' -- for use with optimising control algorithms.
% hObject    handle to controldefault_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controldefault_checkbox_Callback(hObject, eventdata, handles)
    handles.project.use_controldefault = get(hObject,'Value');
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end

% hObject    handle to controldefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function controldefault_Callback(hObject, eventdata, handles)
    handles.project.controldefault = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% hObject    handle to controldefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function controldefault_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The use of a custom cost function
% For kernel determination and simulaton as well.
%
% hObject    handle to custom_cost_fn_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function custom_cost_fn_checkbox_Callback(hObject, eventdata, handles)
    handles.project.use_custom_cost_fn = get(hObject,'Value');
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end

% hObject    handle to custom_cost_fn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function custom_cost_fn_Callback(hObject, eventdata, handles)
    handles.project.custom_cost_fn = get(hObject,'String');
    guidata(hObject, handles);
end

% hObject    handle to custom_cost_fn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
function custom_cost_fn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


%% The autosave checkbox for saving kerels automatically on completion.
% hObject    handle to autosave_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function autosave_checkbox_Callback(hObject, eventdata, handles)
    handles.project.autosave = get(hObject,'Value');
    guidata(hObject, handles);
end


%% The tools menu -- various tools
% hObject    handle to tools_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function tools_menu_Callback(hObject, eventdata, handles)
end

% hObject    handle to delete_waitbar_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function delete_waitbar_menu_Callback(hObject, eventdata, handles)
    set(0,'ShowHiddenHandles','on');
    delete(findobj('Tag', 'WaitBar'));
end

% hObject    handle to close_windows_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function close_windows_menu_Callback(hObject, eventdata, handles)
    set(0,'ShowHiddenHandles','on');
    delete(get(0,'Children'));
end

%% The help menu
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function help_menu_Callback(hObject, eventdata, handles)
end

% hObject    handle to vikaasa_manual_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function vikaasa_manual_menu_Callback(hObject, eventdata, handles)
    open Docs/vikaasa_manual.pdf;
end

% hObject    handle to about_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function about_menu_Callback(hObject, eventdata, handles)

    %h = msgbox(['VIKAASA ', handles.version, ' [Copyright??]'], ...
    %    'About VIKASSA', 'help', 'modal');
    %uiwait(h);

    open Docs/html/about_vikaasa.html;
end


% --- Executes on button press in view_coords_button.
function view_coords_button_Callback(hObject, eventdata, handles)
% hObject    handle to view_coords_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    Vcell = [cellstr(handles.project.labels)';
        num2cell(handles.project.V)];
    assignin('base', 'V', Vcell);
    openvar V;

end


% --- Executes on button press in sim_view_coords_button.
function sim_view_coords_button_Callback(hObject, eventdata, handles)
% hObject    handle to sim_view_coords_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    simulation = [...
        cellstr('T'), num2cell(handles.project.sim_state.T)];
    simulation = [simulation; ...
        cellstr(handles.project.labels), num2cell(handles.project.sim_state.path);
        cellstr('Velocity'), num2cell(handles.project.sim_state.normpath)];

    if (size(handles.project.sim_state.controlpath, 2) == size(simulation, 2) - 1)
        simulation = [simulation; ...
            cellstr('Control'), num2cell(handles.project.sim_state.controlpath)];
    end

    assignin('base', 'simulation', simulation);
    openvar simulation;
end


% --- Executes on button press in sim_use_nearest_checkbox.
function sim_use_nearest_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to sim_use_nearest_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.project.sim_use_nearest = get(hObject,'Value');
    guidata(hObject, handles);
end


% --- Executes on button press in controlmax_enforce_checkbox.
function controlmax_enforce_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to controlmax_enforce_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.project.controlenforce = get(hObject,'Value');
    guidata(hObject, handles);
end

% --- Executes on button press in control_bounded_checkbox.
function control_bounded_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to control_bounded_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.project.controlbounded = get(hObject,'Value');
    guidata(hObject, handles);
end


% --- Executes on button press in addvar_button.
function addvar_button_Callback(hObject, eventdata, handles)
% hObject    handle to addvar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    project = handles.project;

    project.labels = [project.labels; {'New Variable'}];
    project.symbols = [project.symbols; {'new'}];
    project.K = [project.K, 0, 1];
    project.discretisation = [project.discretisation; 11];
    project.diff_eqns = [project.diff_eqns; {'0'}];

    project.numvars = project.numvars + 1;
    handles.project = vk_project_sanitise(project);

    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end

% --- Executes on button press in deletevar_button.
function deletevar_button_Callback(hObject, eventdata, handles)
% hObject    handle to deletevar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    project = handles.project;

    if (project.numvars > 2)
        index = find(project.slices(:,1) == project.numvars);
        if (index)
            project.slices = [project.slices(1:index-1,:); project.slices(index+1:end,:)];
        end
        project.numvars = project.numvars - 1;

        handles.project = vk_project_sanitise(project);

        handles = vk_gui_update_inputs(hObject, handles);

        guidata(hObject, handles);
    end
end


% --- Executes when entered data in editable cell(s) in slices.
function slices_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to slices (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%    Indices: row and column indices of the cell(s) edited
%    PreviousData: previous data for the cell(s) edited
%    EditData: string(s) entered by the user
%    NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%    Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

    data = get(hObject, 'Data');
    indices = eventdata.Indices;

    % Check for 'all' columns that got ticked.
    for i = 1:size(indices, 1)
        if (indices(i, 2) == 1 && data{indices(i, 1), 1} == true)
            data{indices(i, 1), 2} = false;
        elseif (indices(i, 2) == 2 && data{indices(i, 1), 2} == true)
            data{indices(i, 1), 1} = false;
        end
    end

    set(hObject, 'Data', data);

    handles.project.slices = vk_kernel_make_slices( ...
        data, handles.project.K, handles.project.discretisation);
    handles.project.slices
    guidata(hObject, handles);
end


% --- Executes on button press in use_parfor_checkbox.
function use_parfor_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_parfor_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.project.use_parallel = get(hObject,'Value');
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end


function parfor_processors_Callback(hObject, eventdata, handles)
% hObject    handle to parfor_processors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.project.parallel_processors = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function parfor_processors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parfor_processors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in deletesim_button.
function deletesim_button_Callback(hObject, eventdata, handles)
% hObject    handle to deletesim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  b = questdlg('Are you sure you want to delete the simulation results?', ...
    'Confirm');

  if (strcmp(b, 'Yes'))
    handles.project = vk_sim_delete_results(handles.project);
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
  end
end

% --- Executes on button press in deleteresults_button.
function deleteresults_button_Callback(hObject, eventdata, handles)
% hObject    handle to deleteresults_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  b = questdlg('Are you sure you want to delete the kernel results?', ...
    'Confirm');

  if (strcmp(b, 'Yes'))
    handles.project = vk_kernel_delete_results(handles.project);
    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
  end
end


% --- Executes on button press in sim_showkernel_checkbox.
function sim_showkernel_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to sim_showkernel_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.project.sim_showkernel = get(hObject,'Value');
    guidata(hObject, handles);
end



function sim_timeprofile_cols_Callback(hObject, eventdata, handles)
% hObject    handle to sim_timeprofile_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.project.sim_timeprofile_cols = str2double(get(hObject,'String'));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function sim_timeprofile_cols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sim_timeprofile_cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in addaddnvar_button.
function addaddnvar_button_Callback(hObject, eventdata, handles)
% hObject    handle to addaddnvar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    project = handles.project;

    project.addnlabels = [project.addnlabels; {'New Variable'}];
    project.addnsymbols = [project.addnsymbols; {'new'}];
    project.addneqns = [project.addneqns; {'0'}];
    project.addnignore = [project.addnignore; 0];

    project.numaddnvars = project.numaddnvars + 1;
    handles.project = vk_project_sanitise(project);

    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end

% --- Executes on button press in deleteaddnvar_button.
function deleteaddnvar_button_Callback(hObject, eventdata, handles)
% hObject    handle to deleteaddnvar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    project = handles.project;

    if (project.numaddnvars > 0)
        index = find(project.slices(:,1) == project.numvars + project.numaddnvars);
        if (index)
            project.slices = [project.slices(1:index-1,:); project.slices(index+1:end,:)];
        end
        project.numaddnvars = project.numaddnvars - 1;
        handles.project = vk_project_sanitise(project);

        handles = vk_gui_update_inputs(hObject, handles);
        guidata(hObject, handles);
    end
end


% --- Executes when entered data in editable cell(s) in addnvartable.
function addnvartable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to addnvartable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
    vardata = get(hObject, 'Data');
    changes = struct( ...
        'addnlabels', {vardata(:,1)}, ...
        'addnsymbols', {vardata(:, 2)}, ...
        'addneqns', {vardata(:, 3)}, ...
        'addnignore', cell2mat(vardata(:, 4)) ...
    );

    handles.project.addnlabels = changes.addnlabels;
    handles.project.addnsymbols = changes.addnsymbols;
    handles.project.addneqns = changes.addneqns;
    handles.project.addnignore = changes.addnignore;

    handles = vk_gui_update_inputs(hObject, handles);
    guidata(hObject, handles);
end
