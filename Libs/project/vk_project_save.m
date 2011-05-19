%% VK_PROJECT_SAVE Save a project to a specified file.
%   Saves a given project to a specified .MAT file, ensuring that the file is
%   in MATLAB's version 7 format (so that it can be read from either Octave or
%   MATLAB).  If the file already exists, it will be overwritten.
%
%   VK_PROJECT_SAVE(PROJECT, FILENAME)
%
%   If saving is not successful, an error will be thrown.
%
% See also: VIKAASA, PROJECT VK_PROJECT_LOAD
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
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
