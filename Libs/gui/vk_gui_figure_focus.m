%% VK_GUI_FIGURE_FOCUS Catch focus events in the VIKAASA GUI.
%
% SYNOPSIS
%   This function is used by the VIKAASA GUI to keep track of focus events
%   being sent to windows.  It is unlikely that you will need to use it
%   yourself.
%
% USAGE
%   % Adjust internal VIKAASA GUI settings when a window is focussed.
%   vk_gui_figure_focus(h, event);
%
%   % The same, for a time profile.
%   vk_gui_figure_focus(h, event, 'tp');
%
% See also: vk_gui_figure_close, vikaasa

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
function vk_gui_figure_focus(h, event, varargin)
    hObject = findobj('Tag', 'vikaasa');
    handles = guidata(hObject);

    if (nargin == 3 && strcmp(varargin{1}, 'tp'))
        name = 'current_timeprofile';
    else
        name = 'current_figure';
    end

    if (~isempty(handles))
        handles.(name) = h;
        guidata(hObject, handles);
    end
end
