function vk_4dgui_figure_focus(h, event, varargin)    
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