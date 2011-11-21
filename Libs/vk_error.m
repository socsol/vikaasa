%% VK_ERROR Display an error using either `errordlg' or `error'.
%
% SYNOPSIS
%   This function is used by VIKAASA to display error messages differently,
%   depending on the capabilities of the platform.
%
%   It will attempt to display an error window, using `errordlg', and then also
%   throw a real error.  This means that unless this function is called inside
%   of a `try .. catch' block, it will halt computation.
%
% USAGE
%   % Throw an error.
%   vk_error('An error occurred');
%
% See also: error, errordlg

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
function vk_error(message)
    if (exist('errordlg'))
        errordlg(message);
    end

    error(message);
end
