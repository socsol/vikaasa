%% VK_CONTROL_ENFORCE Simple function that makes sure that u is in $[-c,c]$
%
% SYNOPSIS
%   This function is used by VIKAASA to filter control choices that are outside
%   of the permitted $[-c, c]$ range.  This is done by clipping control choices
%   outside of this range to the nearest value.
%
% USAGE
%   % Make sure $u \in [-c, c]$.
%   u = vk_control_enforce(u, c)
%
% See also: vk_control_bound

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
function uenf = vk_control_enforce(u, c)
    uenf = u;
    for i = 1:length(u)
        if (abs(u(i)) > c(i))
            uenf(i) = sign(u(i))*c(i);
        end
    end
end

