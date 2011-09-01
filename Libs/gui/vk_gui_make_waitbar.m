%% VK_GUI_MAKE_WAITBAR Constructs a waitbar
%
% SYNOPSIS
%   This function constructs a progress bar.  Used by the VIKAASA GUI to
%   display the progress of viability kernel computations, and of simulations;
%   and to capture cancel events.
%
% USAGE
%   % Create a handle to a waitbar called 'wb'
%   wb = vk_gui_make_waitbar('Please wait');
%
% See also: waitbar

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
function wb = vk_gui_make_waitbar(message)
    wb = waitbar(0, message, 'Name', message, ...
        'CreateCancelBtn', 'setappdata(gcbf, ''cancelling'', 1)', ...
        'Tag', 'WaitBar');
    setappdata(wb, 'cancelling', 0);
end
