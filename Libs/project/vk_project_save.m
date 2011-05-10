%% VK_PROJECT_SAVE Save a project to a specified file.
%
% See also: VIKAASA, GUI
function success = vk_project_save(project, filename)
    try        
        save(filename,'-struct','project', '-v7');
        success = 1;
    catch
        exception = lasterror();
        vk_error(['Could not save ', filename, ': ', exception.message]);
        success = 0;
    end
end
