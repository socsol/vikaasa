%% VK_GUI_SIMGUI GUI for interactive view of simulations
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
function varargout = vk_gui_simgui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vk_gui_simgui_OpeningFcn, ...
                   'gui_OutputFcn',  @vk_gui_simgui_OutputFcn, ...
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


% --- Executes just before vk_gui_simgui is made visible.
function vk_gui_simgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vk_gui_simgui (see VARARGIN)

    % Choose default command line output for vk_gui_simgui
    handles.output = hObject;

    handles.sim_state = varargin{1};
    handles.display_opts = varargin{2};

    set(handles.timer, 'Min', 1);
    set(handles.timer, 'Max', length(handles.sim_state.T));
    set(handles.timer, 'Value', length(handles.sim_state.T));
    set(handles.timer, 'SliderStep', ...
        [1/length(handles.sim_state.T), ...
        1/handles.sim_state.time_horizon]);

    handles = vk_gui_simgui_setup(hObject, handles);
    handles = vk_gui_simgui_drawstep(length(handles.sim_state.T), ...
        hObject, handles, handles.plotspace);

    set(hObject, 'Name', ['Simulation starting from [', ...
        num2str(transpose(handles.sim_state.path(:,1))), '] for ', ...
        num2str(handles.sim_state.T(end)), ' time intervals']);

    set(handles.showpoints_checkbox, 'Value', ...
        handles.display_opts.showpoints);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes vk_gui_simgui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = vk_gui_simgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;
end


% --- Executes on slider movement.
function timer_Callback(hObject, eventdata, handles)
% hObject    handle to timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    i = round(get(hObject,'Value'));
    handles = vk_gui_simgui_drawstep(i, hObject, handles, handles.plotspace);
end


% --- Executes during object creation, after setting all properties.
function timer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end


% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Stop people from navigating away
    set(handles.figure1, 'WindowStyle', 'modal');

    % Stop indicator.  Set to zero initially.
    set(hObject, 'UserData', 0);

    % Replace 'play' with 'stop', and change the callback.
    set(hObject, 'String', 'Stop');
    set(hObject, 'Callback', ...
        @(hObject, eventdata) set(hObject, 'UserData', 1));

    if (get(handles.timer, 'Value') == get(handles.timer, 'Max'))
        start = 1;
    else
        start = round(get(handles.timer, 'Value'));
    end

    T = handles.sim_state.T;

    for i = start:length(T)
        handles = vk_gui_simgui_drawstep(i, hObject, handles, handles.plotspace);
        % Make the timer match.
        set(handles.timer, 'Value', i);
        refresh;
        pause(0.5);
        if (strcmp(get(handles.figure1, 'BeingDeleted'), 'on') ...
                || get(hObject, 'UserData') == 1)
            break;
        end
    end

    % Return to normal.
    set(hObject, 'String', 'Play');
    set(hObject, 'Callback', @(hObject,eventdata) ...
        vk_gui_simgui('play_button_Callback', ...
        hObject,eventdata,guidata(hObject)));
    set(handles.figure1, 'WindowStyle', 'normal');
end


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


function handles = vk_gui_simgui_drawstep(i, hObject, handles, handle, varargin)

    V = handles.sim_state.V;
    K = handles.sim_state.K;
    labels = handles.display_opts.labels;
    colour = handles.display_opts.colour;
    alpha_val = handles.display_opts.alpha;
    method = handles.display_opts.method;
    line_colour = handles.display_opts.line_colour;
    line_width = handles.display_opts.line_width;

    path = handles.sim_state.path;
    viablepath = handles.sim_state.viablepath;

    set(handles.figure1, 'CurrentAxes', handle);
    cla(handle);

    % If there are slices, we must line them up with the point.
    slices = handles.display_opts.slices;
    if (~isempty(slices))
        for j = 1:size(slices, 1)
            if (~isnan(slices(j,2)))
                slices(j, 2) = path(slices(j, 1), i);
            end
        end

        V = vk_kernel_slice(V, slices);
    end

    if (length(K) / 2 - size(slices, 1) == 2)
        vk_figure_plot_area(V, colour, method, alpha_val);
    elseif (length(K) / 2 - size(slices, 1) == 3)
        vk_figure_plot_surface(V, colour, method, alpha_val);
        camlight;
        lighting gouraud;
    end

    % Add a title and name
    T = handles.sim_state.T;
    figure_name = ['t=', num2str(T(i))];

    if (~isempty(slices))
        for j = 1:size(slices, 1)
            figure_name = [figure_name, ', ', ...
                deblank(labels(slices(j, 1), :)), '=', ...
                num2str(path(slices(j, 1), i))];
        end

        slices = sortrows(slices, -1);
        for j = 1:size(slices, 1)
            slice_axis = slices(j, 1);
            path = [...
                path(1:slice_axis - 1, :);
                path((slice_axis + 1):end, :)];

            K = horzcat(K(1:2*slice_axis-2), ...
                K(2*slice_axis+1:size(K,2)));
        end
    end

    showpoints = handles.display_opts.showpoints;
    vk_figure_plot_path(T, path(:, 1:i), viablepath(:, 1:i), showpoints, ...
        line_colour, line_width);

    limits = vk_figure_plot_box(K);
    limits = vk_figure_plot_path_limits(limits, path);

    axis(limits);
    title(figure_name);
    guidata(hObject, handles);

    if (nargin == 5)
        h = varargin{5};
        vk_figure_data_insert(h, limits, slices);
    end
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    plotspace = handles.plotspace;
    slider = handles.timer;
    pbutton = handles.play_button;
    fbutton = handles.tofig_button;
    checkbox = handles.showpoints_checkbox;

    % New size of the window.
    units = get(hObject, 'Units');
    set(hObject, 'Units', 'points');
    pos = get(hObject, 'Position');
    width = pos(3);
    height = pos(4);
    set(hObject, 'Units', units);

    % The button and slider need about 70pt at the bottom.  The rest should
    % be given to the plotspace.
    units = get(plotspace, 'Units');
    set(plotspace, 'Units', 'points');
    set(plotspace, 'Position', [50, 70+20, width-100, height-70-40]);
    set(plotspace, 'Units', units);

    % The buttons should be repositioned to the far-right.
    units = get(pbutton, 'Units');
    set(pbutton, 'Units', 'points');
    set(fbutton, 'Units', 'points');
    pbuttonpos = get(pbutton, 'Position');
    fbuttonpos = get(fbutton, 'Position');
    set(handles.play_button, 'Position', ...
        [width - pbuttonpos(3) - fbuttonpos(3) - 15-5, pbuttonpos(2:4)]);
    set(handles.tofig_button, 'Position', ...
        [width - fbuttonpos(3) - 15, pbuttonpos(2:4)]);
    set(pbutton, 'Units', units);
    set(fbutton, 'Units', units);

    % The checkbox should be positioned on the left -- do nothing.
%     units = get(checkbox, 'Units');
%     set(checkbox, 'Units', 'points');
%     checkboxpos = get(checkbox, 'Position');
%     set(checkbox, 'Position', [50, 70+20, width-100, height-70-40]);
%     set(checkbox, 'Units', units);

    % The slider should be widened.
    units = get(slider, 'Units');
    set(slider, 'Units', 'points');
    sliderpos = get(slider, 'Position');
    set(handles.timer, 'Position', ...
        [sliderpos(1:2), width-20, sliderpos(4)]);
    set(slider, 'Units', units);
end


% --- Executes on button press in tofig_button.
function tofig_button_Callback(hObject, eventdata, handles)
% hObject    handle to tofig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        parenthandles = guidata(handles.display_opts.parent);

        % Create a figure unconditionally.
        h = figure(...
            'CloseRequestFcn', ...
            @(h, event) eval('try vk_4dgui_figure_close(h, event), catch, delete(h), end'), ...
            'WindowButtonMotionFcn', ...
            @(h, event) eval('try vk_4dgui_figure_focus(h, event), catch, end'));

        % Insert data into figure.
        ax = get(h, 'CurrentAxes');
        i = round(get(handles.timer,'Value'));
        handles = vk_gui_simgui_drawstep(i, hObject, handles, ax, h);
        guidata(hObject, handles);

    catch exception
        warning(exception.message);
        h = figure;
        ax = get(h, 'CurrentAxes');
        i = round(get(handles.timer,'Value'));
        handles = vk_gui_simgui_drawstep(i, hObject, handles, ax);
        guidata(hObject, handles);
    end
end


% --- Executes on button press in showpoints_checkbox.
function showpoints_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to showpoints_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showpoints_checkbox
    handles.display_opts.showpoints = get(hObject,'Value');
    guidata(hObject, handles);

    i = round(get(handles.timer,'Value'));
    handles = vk_gui_simgui_drawstep(i, hObject, handles, handles.plotspace);
end


function handles = vk_gui_simgui_setup(hObject, handles)
    h = handles.plotspace;
    set(handles.figure1, 'CurrentAxes', h);
    hold on;

    path = handles.sim_state.path;

    slices = handles.display_opts.slices;
    K = handles.sim_state.K;
    labels = handles.display_opts.labels;
    if (~isempty(slices))
        slices = sortrows(slices, -1);
        for i = 1:size(slices, 1)
            path = [path(1:slices(i, 1)-1, :); path(slices(i, 1)+1:end, :)];
            K = [K(1:2*slices(i, 1)-2), ...
                K(2*slices(i, 1)+1:end)];
            labels = [labels(1:slices(i, 1)-1, :); ...
                labels(slices(i, 1)+1:end, :)];
        end
    end

    limits = vk_figure_plot_box(K);
    limits = vk_figure_plot_path_limits(limits, path);
    axis(limits);
    grid on;

    xlabel(labels{1});
    ylabel(labels{2});

    if (length(K) == 6)
        zlabel(labels{3});
        view(3);
    end
end


% --- Executes during object creation, after setting all properties.
function showpoints_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showpoints_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
