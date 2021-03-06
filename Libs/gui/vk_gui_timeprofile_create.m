%% VK_GUI_TIMEPROFILE_CREATE Constructs a figure handle for plotting time profiles in
%
% SYNOPSIS
%   This function is used by the VIKAASA GUI to keep track of focus events
%   being sent to windows.  It is unlikely that you will need to use it
%   yourself.
%
% See also: vikaasa

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
function h = vk_gui_timeprofile_create(handles)
    % Make a figure (or use an existing one)
    if (handles.project.holdfig && isfield(handles, 'current_timeprofile'))
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
end
