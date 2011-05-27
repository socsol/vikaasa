%% VK_PROJECT_SAVE Save a project to a specified file.
%
% SYNOPSIS
%   Saves a given project to a specified .mat file, ensuring that the file is
%   in MATLAB(R)'s version 7 format (so that it can be read from either Octave
%   or MATLAB(R)).  If the file already exists, it will be overwritten.
%
% USAGE
%   % Save the `project' structure into `filename':
%   vk_project_save(project, filename)
%
% NOTES
%   If saving is not successful, an error will be thrown.
%
% See also: vikaasa, project, vk_project_load

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
