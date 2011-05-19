%% VK_GUI_FIGURE_FOCUS Catch focus events in the VIKAASA GUI
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
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
