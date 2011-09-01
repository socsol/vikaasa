%% VK_GUI_FIGURE_CLOSE Catch close events in the VIKAASA GUI
%
% SYNOPSIS
%   This function is used by the VIKAASA GUI to keep track of close events
%   being sent to windows.  It is unlikely that you will need to use it
%   yourself.
%
% USAGE
%   % Close a figure.
%   vk_gui_figure_close(h, event);
%
%   % Close a timeprofile figure.
%   vk_gui_figure_close(h, event, 'tp');
%
% See also: vk_gui_figure_focus, vikaasa

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
function vk_gui_figure_close(h, event, varargin)
    hObject = findobj('Tag', 'vikaasa');
    handles = guidata(hObject);

    if (nargin == 3 && strcmp(varargin{1}, 'tp'))
        name = 'current_timeprofile';
    else
        name = 'current_figure';
    end

    if (isfield(handles, name) && handles.(name) == h)
        handles = rmfield(handles, name);
    end

    guidata(hObject, handles);
    delete(h);
end
