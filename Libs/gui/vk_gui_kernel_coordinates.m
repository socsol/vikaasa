%% VK_GUI_KERNEL_COORDINATES A GUI window for viewing kernel coordinates
%
% SYNOPSIS
%   This function is used by the VIKAASA GUI to view kernel
%   coordinates in a tabular display.  It can be accessed via the
%   ``Viable points'' button in the main window.
%
% See also: vikaasa

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
function varargout = vk_gui_kernel_coordinates(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vk_gui_kernel_coordinates_OpeningFcn, ...
                   'gui_OutputFcn',  @vk_gui_kernel_coordinates_OutputFcn, ...
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

% --- Executes just before vk_gui_kernel_coordinates is made visible.
function vk_gui_kernel_coordinates_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to vk_gui_kernel_coordinates (see VARARGIN)

    % Choose default command line output for vk_gui_kernel_coordinates
    handles.output = hObject;

    % The main 'handles' object is passed in on creation.
    handles.main_hObject = varargin{1};
    handles.V = varargin{2};
    handles.viable_paths = varargin{3};

    set(hObject, 'Name', varargin{4});

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes vk_gui_kernel_coordinates wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

    main_handles = guidata(handles.main_hObject);

    opts = {'Show'; 'Phase diagram'; 'Time profile'; 'Copy to simulation'};

    set(handles.kernel_coordinates_table, 'ColumnName', [main_handles.project.symbols; 'Steps'; opts])

    Vcell = num2cell(handles.V);
    buttons = cell(size(Vcell, 1), 4);
    steps = cell(size(Vcell, 1), 1);
    for i = 1:size(Vcell, 1)
      if (isfield(main_handles.project, 'viable_paths'))
          paths = handles.viable_paths{i};
          steps{i} = size(paths.path,2);
      end
      for j = 1:4
          buttons(i,1:4) = opts;
      end
    end

    set(handles.kernel_coordinates_table, 'Data', [Vcell, steps, buttons]);
end

% --- Outputs from this function are returned to the command line.
function varargout = vk_gui_kernel_coordinates_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes when selected cell(s) is changed in kernel_coordinates_table.
function kernel_coordinates_table_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to kernel_coordinates_table (see GCBO)
    % eventdata  structure with the following fields (see UITABLE)
    %	Indices: row and column indices of the cell(s) currently selected
    % handles    structure with handles and user data (see GUIDATA)

    % Get the index of the button pressed.
    data = get(handles.kernel_coordinates_table, 'Data');
    pos = eventdata.Indices(2) - size(data, 2) + 4;

    % If a non-interactive item is selected, do nothing.
    if pos <= 0
      return;
    end

    if pos == 1
        % Show
        vk_gui_kernel_coordinates_show(hObject, handles, eventdata.Indices(1));
    elseif pos == 2
        % Phase diagram
        vk_gui_kernel_coordinates_phasediagram(hObject, handles, eventdata.Indices(1));
    elseif pos == 3
        % Time profile
        vk_gui_kernel_coordinates_timeprofiles(hObject, handles, eventdata.Indices(1));
    elseif pos == 4
        % Copy to simulation
        vk_gui_kernel_coordinates_copy(hObject, handles, eventdata.Indices(1));
    end
end

%% Show point
function vk_gui_kernel_coordinates_show(hObject, handles, index)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    % Create a figure, or use the current one.
    h = vk_gui_figure_create(main_handles);
    figure(h);

    % Get the existing figure, if there is one.
    [limits, slices] = vk_figure_data_retrieve(h);

    % If the 'limits' are zero, then this must be a new plot.
    if any(size(limits) <= 0)
        slices = vk_kernel_augment_slices(project);

        K = vk_kernel_slice_constraints( ...
            vk_kernel_augment_constraints(project), ...
            slices);
        if (~any(length(K) == [4,6]))
            errordlg('Points can only be drawn for 2 or 3 dimensions.');
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

    x = vk_kernel_slice_path( ...
        vk_sim_augment_path(transpose(handles.V(index, :)), project.numvars, ...
            project.numaddnvars, project.addnignore, project.addneqns, ...
            project.symbols), slices);

    vk_plot_point(x, project.plotcolour);
    vk_figure_data_insert(h, limits, slices);
    axis(limits);

    main_handles.current_figure = h;
    guidata(handles.main_hObject, main_handles);
end

%% Phase diagram
function vk_gui_kernel_coordinates_phasediagram(hObject, handles, index)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    % Create a figure, or use the current one.
    h = vk_gui_figure_create(main_handles);
    figure(h);

    [limits, slices] = vk_figure_data_retrieve(h);

    % If the 'limits' are zero, then this must be a new plot.
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
    end

    % get the path information.
    paths = handles.viable_paths{index};

    path = vk_kernel_slice_path( ...
        vk_sim_augment_path(paths.path, project.numvars, project.numaddnvars, ...
            project.addnignore, project.addneqns, project.symbols), slices);

    limits = vk_plot_path_limits(limits, path);

    viablepath = vk_gui_kernel_coordinates_viablepath_extend( ...
        paths.viablepath, paths.path, paths.T, project.V, project.K, ...
        project.discretisation, project.layers);

    vk_plot_path(paths.T, path, viablepath, project.sim_showpoints, ...
        project.sim_line_colour, project.sim_line_width);

    grid on;
    axis(limits);
    vk_figure_data_insert(h, limits, slices);

    main_handles.current_figure = h;
    guidata(handles.main_hObject, main_handles);
end

%% Time profiles
function vk_gui_kernel_coordinates_timeprofiles(hObject, handles, index)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    simulation = vk_gui_kernel_coordinates_simulation(project, handles.viable_paths{index});

    h = vk_gui_timeprofile_create(main_handles);
    h = vk_figure_timeprofiles_make(project, ...
        'handle', h, ...
        'simulation', simulation);

    main_handles.current_timeprofile = h;
    guidata(handles.main_hObject, main_handles);
end

%% Copy to simulation
function vk_gui_kernel_coordinates_copy(hObject, handles, index)
    main_handles = guidata(handles.main_hObject);
    project = main_handles.project;

    main_handles.project.sim_start = transpose(handles.V(index, :));
    main_handles.project.sim_state = vk_gui_kernel_coordinates_simulation(project, handles.viable_paths{index});
    main_handles = vk_gui_update_inputs(handles.main_hObject, main_handles);
    guidata(handles.main_hObject, main_handles);
end

function viablepath = vk_gui_kernel_coordinates_viablepath_extend( ...
    viablepath, path, T, V, K, discretisation, layers)

    % The 'inside' values can't be computed ahead of time.
    distances = vk_kernel_distances(K, discretisation);
    for i = 1:length(T)
        [viablepath(1, i), viablepath(2, i)] = ...
            vk_kernel_inside(path(:,i), V, distances, layers);
    end
end

function simulation = vk_gui_kernel_coordinates_simulation(project, simulation)
    % Use vk_options make to construct options.
    f = vk_diff_make_fn(project);
    options = vk_options_make(project, f);

    % Make a mock simulation
    simulation.distances = vk_kernel_distances(project.K, project.discretisation);
    simulation.V = project.V;

    % Extend the viablepath info
    simulation.viablepath = vk_gui_kernel_coordinates_viablepath_extend( ...
        simulation.viablepath, simulation.path, simulation.T, project.V, project.K, ...
        project.discretisation, project.layers);

    simulation.K = project.K;
    simulation.small = options.small;
    simulation.layers = project.layers;
    simulation.time_horizon = simulation.T(end);
    simulation.c = project.c;
    simulation.small = options.small;
    simulation.comp_time = project.comp_time;
    simulation.comp_datetime = project.comp_datetime;
end
