%% VK_SAVE Save vk_state to a specified file.
%
% See also: VIKAASA, GUI
function success = vk_save_project(project, filename)
    try        
        save(filename,'-struct','project', '-v7');
        success = 1;
    catch
        exception = lasterror();
        errordlg(['Could not save ', filename, ': ', exception.message]);
        success = 0;
    end
end