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
gui_Singleton = 0;
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

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes vk_gui_kernel_coordinates wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

    main_handles = guidata(handles.main_hObject);
    set(handles.kernel_coordinates_table, 'ColumnName', [main_handles.project.symbols; {'Show'; 'Phase diagram'; 'Time profile'; 'Copy to simulation'}])

    Vcell = num2cell(main_handles.project.V);
    buttons = cell(size(Vcell, 1), 4);
    for i = 1:size(Vcell, 1)
      for j = 1:4
        buttons{i,j} = 'click';
      end
    end

    set(handles.kernel_coordinates_table, 'Data', [Vcell, buttons]);
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

    data = get(handles.kernel_coordinates_table, 'Data');
    main_handles = guidata(handles.main_hObject);

    % If a 'click' was clicked ...
    if eventdata.Indices(2) - size(data, 2) + 4 > 0
      pos = eventdata.Indices(2) - size(data, 2) + 4

      if pos == 1
          % Show

          % Create a figure, or use the current one.
          h = vk_gui_figure_create(main_handles);
          figure(h);

          [limits, slices] = vk_figure_data_retrieve(h);

          % If the 'limits' are zero, then this must be a new plot.
          if any(size(limits) <= 0)
              slices = vk_kernel_augment_slices(main_handles.project);
              K = main_handles.project.K; 

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

              if (main_handles.project.drawbox)
                  limits = vk_plot_box(K);
              else
                  limits = K;
              end
          end

          vk_plot_point(main_handles.project.V(eventdata.Indices(1), :));
          vk_figure_data_insert(h, limits, slices);

          % We should set the current_figure value here ... but won't it corrupt?
          main_handles.current_figure = h;
          guidata(handles.main_hObject, main_handles);
      elseif pos == 2
          % Phase diagram

          % Create a figure, or use the current one.
          h = vk_gui_figure_create(main_handles);
          figure(h);

          [limits, slices] = vk_figure_data_retrieve(h);

          % If the 'limits' are zero, then this must be a new plot.
          if any(size(limits) <= 0)
              slices = vk_kernel_augment_slices(main_handles.project);
              K = main_handles.project.K; 

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

              if (main_handles.project.drawbox)
                  limits = vk_plot_box(K);
              else
                  limits = K;
              end
          end

          paths = main_handles.project.viable_paths{eventdata.Indices(1)};
          limits = vk_plot_path_limits(limits, paths.path);
          
          % The 'inside' values can't be computed ahead of time.
          viablepath = paths.viablepath;
          distances = vk_kernel_distances(main_handles.project.K, main_handles.project.discretisation);
          V = main_handles.project.V;
          for i = 1:length(paths.T)
              [viablepath(1, i), viablepath(2, i)] = ...
                vk_kernel_inside(paths.path(:,i), V, distances, main_handles.project.layers);
          end

          vk_plot_path(paths.T, paths.path, viablepath, main_handles.project.sim_showpoints, main_handles.project.sim_line_colour, main_handles.project.sim_line_width);

          axis(limits);
          vk_figure_data_insert(h, limits, slices); 

          main_handles.current_figure = h;
          guidata(handles.main_hObject, main_handles);
      elseif pos == 3
          % Time profile
      elseif pos == 4 
          % Copy to simulation
      end
    end
end
