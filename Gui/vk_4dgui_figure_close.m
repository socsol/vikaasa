function vk_4dgui_figure_close(h, event, varargin)    
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