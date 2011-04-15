%% VK_SAVE Save vk_state to a specified file.
%
% See also: VIKAASA, GUI
function success = vk_save(project, filename)
    try        
        save(filename,'-struct','project');
        success = 1;
    catch exception
        errordlg(['Could not save ', filename, ': ', exception.message]);
        success = 0;
    end
end