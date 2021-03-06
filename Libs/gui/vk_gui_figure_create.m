%% VK_GUI_FIGURE_CREATE Create a new GUI-managed figure
%
% SYNOPSIS
%   This function is used by the VIKAASA GUI to keep track of focus events
%   being sent to windows.  It is unlikely that you will need to use it
%   yourself.
%
% See also: vk_gui_figure_focus, vikaasa

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
function h = vk_gui_figure_create(handles)
    if (handles.project.holdfig && isfield(handles, 'current_figure'))
        h = handles.current_figure;
    else
        h = figure(...
            'CloseRequestFcn', ...
            @(h, event) eval('try vk_gui_figure_close(h, event), catch, delete(h), end'), ...
            'WindowButtonMotionFcn', ...
            @(h, event) eval('try vk_gui_figure_focus(h, event), catch, end'));
    end

end
