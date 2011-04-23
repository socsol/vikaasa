%% VK_GUI_MAKE_WAITBAR Constructs a waitbar
%
% See also: WAITBAR
function wb = vk_gui_make_waitbar(message)
    wb = waitbar(0, message, 'Name', message, ...
        'CreateCancelBtn', 'setappdata(gcbf, ''cancelling'', 1)', ...
        'Tag', 'WaitBar');
    setappdata(wb, 'cancelling', 0);
end