%% VK_TIMEFORMAT Helper function that formats seconds into something human readable.
%
% SYNOPSIS
%   Given some number of seconds, this function returns a string containing a
%   number, and a unit (one of 'seconds', 'minutes', 'hours' or 'days').  The
%   unit will be accurate to one decimal place.  The decision concerning which
%   units to use is made by choosing the smallest possible, such that the unit
%   is greater than one.
%
% USAGE
%   % Displays '60 seconds'
%   vk_timeformat(60)
%
%   % Displays '1 minutes'
%   vk_timeformat(61)

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
function formatted = vk_timeformat(seconds)
    if (seconds > 22896000)
        formatted = 'unknown time';
        return;
    elseif (seconds > 86400)
        denom = 86400;
        desc = ' days';
    elseif (seconds > 3600)
        denom = 3600;
        desc = ' hours';
    elseif (seconds > 60)
        denom = 60;
        desc = ' minutes';
    else
        denom = 1;
        desc = ' seconds';
    end

    formatted = sprintf('%.1f %s', seconds/denom, desc);
end
