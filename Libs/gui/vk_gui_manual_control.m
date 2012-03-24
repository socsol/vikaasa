%%
%  Copyright 2012 Jacek B. Krawczyk and Alastair Pharo
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
function varargout = vk_gui_manual_control(varargin)
% VK_GUI_MANUAL_CONTROL MATLAB code for vk_gui_manual_control.fig
%      VK_GUI_MANUAL_CONTROL, by itself, creates a new VK_GUI_MANUAL_CONTROL or raises the existing
%      singleton*.
%
%      H = VK_GUI_MANUAL_CONTROL returns the handle to a new VK_GUI_MANUAL_CONTROL or the handle to
%      the existing singleton*.
%
%      VK_GUI_MANUAL_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VK_GUI_MANUAL_CONTROL.M with the given input arguments.
%
%      VK_GUI_MANUAL_CONTROL('Property','Value',...) creates a new VK_GUI_MANUAL_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vk_gui_manual_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vk_gui_manual_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vk_gui_manual_control

% Last Modified by GUIDE v2.5 18-Mar-2012 19:01:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vk_gui_manual_control_OpeningFcn, ...
                   'gui_OutputFcn',  @vk_gui_manual_control_OutputFcn, ...
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

% --- Executes just before vk_gui_manual_control is made visible.
function vk_gui_manual_control_OpeningFcn(hObject, eventdata, handles, varargin)
  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to vk_gui_manual_control (see VARARGIN)

  % Choose default command line output for vk_gui_manual_control
  handles.output = hObject;

  % Store the main hObject ... use it to retrieve the main window's handles.
  handles.main_hObject = varargin{1};
  main_handles = guidata(handles.main_hObject);
  project = main_handles.project;

  % The general parameters of the manual simulation:
  handles.T = 0:project.h:project.sim_iterations;

  % Set the variable names
  set(handles.controls_table, 'RowName', project.controlsymbols);
  symbols = [project.symbols; project.addnsymbols(find(~project.addnignore))];
  set(handles.variables_table, 'RowName', symbols);

  % Set the time axis
  set(handles.controls_table, 'ColumnName', num2cell(handles.T));
  set(handles.variables_table, 'ColumnName', num2cell(handles.T));
  set(handles.velocity_table, 'ColumnName', num2cell(handles.T));

  % Create a set of empty data cells
  handles.path = zeros( ...
    length(project.symbols) + length(project.addnsymbols(find(~project.addnignore))), ...
    length(handles.T));
  handles.controlpath = zeros(length(project.controlsymbols), length(handles.T));
  handles.normpath = zeros(1, length(handles.T));

  set(handles.controls_table, 'Data', handles.controlpath);
  set(handles.variables_table, 'Data', handles.path);
  set(handles.velocity_table, 'Data', handles.normpath);

  % Make the control table editable.
  set(handles.controls_table, 'ColumnEditable', logical(ones(1, length(handles.T))));

  % Check for an existing simulation path.  If it exists, use it for the
  % initial values.
  if isfield(project, 'sim_state')
      controls = get(handles.controls_table, 'Data');
      if size(project.sim_state.controlpath, 1) == size(controls, 1)
          len = min(length(handles.T), size(project.sim_state.controlpath, 2));
          controls(:,1:len) = project.sim_state.controlpath(:,1:len);
      end
      set(handles.controls_table, 'Data', controls);
  end

  % Update handles structure
  guidata(hObject, handles);

  vk_gui_manual_control_update(hObject, handles, 0);


  % UIWAIT makes vk_gui_manual_control wait for user response (see UIRESUME)
  % uiwait(handles.manual_control);
end

%% Updates the variables section.
function vk_gui_manual_control_update(hObject, handles, start)
    path = get(handles.variables_table, 'Data');
    controlpath = get(handles.controls_table, 'Data');
    normpath = handles.normpath;

    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    f = vk_diff_make_fn(project); 
    options = vk_options_make(project, f);
    next_fn = options.next_fn;
    norm_fn = options.norm_fn;

    % Special case when start = 0, we have to get the start state from the main
    % window, and set up the normpath.
    if (start == 0)
        project.sim_start
        path(:,1) = vk_sim_augment_path(project.sim_start, project.numvars, project.numaddnvars, project.addnignore, project.addneqns, project.symbols);

        start = 1;
    end

    % First, update the dynamic equations
    for i = start:length(handles.T) - 1
        path(1:project.numvars, i+1) = next_fn( ...
            path(1:project.numvars, i), ...
            controlpath(:, i));
        normpath(i) = norm_fn(f( ...
            path(1:project.numvars, i), ...
            controlpath(:, i)));
    end
    normpath(end) = norm_fn(f( ...
        path(1:project.numvars, end), ...
        controlpath(:, end)));


    % Now update the additional vars
    path(:,start+1:length(handles.T)) = vk_sim_augment_path( ...
        path(1:project.numvars,start+1:length(handles.T)), ...
        project.numvars, project.numaddnvars, project.addnignore, ...
        project.addneqns, project.symbols);

    set(handles.variables_table, 'Data', path);
    set(handles.velocity_table, 'Data', normpath);

    handles.path = path;
    handles.normpath = normpath; 
    handles.controlpath = controlpath;
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = vk_gui_manual_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in copytosim_button.
function copytosim_button_Callback(hObject, eventdata, handles)
% hObject    handle to copytosim_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    main_handles.project.sim_start = handles.path(1:project.numvars, 1);
    main_handles.project.sim_state = vk_gui_manual_control_simulation( ...
        project, handles.T, handles.path, ...
        handles.controlpath, handles.normpath);
    guidata(handles.main_hObject, main_handles);
end

% --- Executes on button press in phasediagram_button.
function phasediagram_button_Callback(hObject, eventdata, handles)
% hObject    handle to phasediagram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    % Create a figure, or use the current one.
    h = vk_gui_figure_create(main_handles);
    figure(h);

    [limits, slices] = vk_figure_data_retrieve(h);

    if any(size(limits) <= 0)
      slices = vk_kernel_augment_slices(project);

      K = vk_kernel_slice_constraints( ...
          vk_kernel_augment_constraints(project), ...
          slices);
      if (~any(length(K) == [4,6]))
          errordlg('Phase diagram can only be drawn for 2 or 3 dimensions.');
          return;
      end

      labels = vk_kernel_slice_text( ...
          vk_kernel_augment_labels(project), ...
          slices);

      if (main_handles.project.drawbox)
          limits = vk_plot_box(K);
      else
          limits = K;
      end

      xlabel(labels{1});
      ylabel(labels{2});
      if length(limits) == 6
        view(3);
        zlabel(labels{3});
      end

      hold on;
      grid on;
    end

    % Create the path variable
    path = vk_kernel_slice_path(handles.path, slices);
    limits = vk_plot_path_limits(limits, path);

    viablepath = vk_gui_manual_control_viablepath(handles.path(1:project.numvars,:), ...
        handles.normpath, project);
    
    vk_plot_path(handles.T, path, viablepath, project.sim_showpoints, ...
        project.sim_line_colour, project.sim_line_width);

    vk_figure_data_insert(h, limits, slices);
    axis(limits);

    main_handles.current_figure = h;
    guidata(handles.main_hObject, main_handles);
end

% --- Executes on button press in timeprofiles_button.
function timeprofiles_button_Callback(hObject, eventdata, handles)
% hObject    handle to timeprofiles_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    simulation = vk_gui_manual_control_simulation(project, handles.T, handles.path, ...
        handles.controlpath, handles.normpath);

    h = vk_gui_timeprofile_create(main_handles);
    h = vk_figure_timeprofiles_make(project, ...
        'handle', h, ...
        'simulation', simulation);

    main_handles.current_timeprofile = h;
    guidata(handles.main_hObject, main_handles);
end

% --- Executes on button press in clearcontrols_button.
function clearcontrols_button_Callback(hObject, eventdata, handles)
% hObject    handle to clearcontrols_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.controlpath = zeros(size(handles.controlpath));
    set(handles.controls_table, 'Data', handles.controlpath);
    guidata(hObject, handles);
end


% --- Executes when entered data in editable cell(s) in controls_table.
function controls_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to controls_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

    vk_gui_manual_control_update(hObject, handles, eventdata.Indices(2));
end

function viablepath = vk_gui_manual_control_viablepath(path, normpath, project)
    viablepath = zeros(5, size(path,2));

    V = project.V;
    K = project.K;
    discretisation = project.discretisation;
    layers = project.layers;
    c = project.c;

    f = vk_diff_make_fn(project);
    options = vk_options_make(project, f);

    distances = vk_kernel_distances(K, discretisation);

    for i = 1:size(path,2)
        x = path(:, i);

        %% Record viability, etc. at this point
        [viablepath(1, i), viablepath(2, i)] = vk_kernel_inside(x, V, ...
            distances, layers);
        exited_on = vk_viable_exited(x, K, f, c, options);
        viablepath(3, i) = any(~isnan(exited_on(:,1)));
        viablepath(4, i) = any(~isnan(exited_on(:,2)));

        %% Record velocity and steadyness
        viablepath(5, i) = normpath(i) <= options.small;
    end
end

function simulation = vk_gui_manual_control_simulation(project, T, path, controlpath, normpath)
    % Use vk_options make to construct options.
    f = vk_diff_make_fn(project);
    options = vk_options_make(project, f);

    % We don't need the augmented path in this function.
    path = path(1:project.numvars, :);

    comp_time = 0;
    cl = fix(clock);
    comp_datetime = ...
        sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

    % Make a mock simulation
    simulation = struct( ...
        'T', T, ...
        'path', path, ...
        'normpath', normpath, ...
        'controlpath', controlpath, ...
        'viablepath', vk_gui_manual_control_viablepath(path, normpath, project), ...
        'distances', vk_kernel_distances(project.K, project.discretisation), ...
        'V', project.V, ...
        'K', project.K, ...
        'c', project.c, ...
        'small', options.small, ...
        'layers', project.layers, ...
        'time_horizon', T(end), ...
        'comp_time', comp_time, ...
        'comp_datetime', comp_datetime);
end
