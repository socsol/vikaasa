%% VK_LSODE_WRAPPER Wrap the `lsode' function so that it works like `ode45'.
%
% SYNOPSIS
%   Because `lsode' does not conform to the functional signature of `ode45', it
%   is necessary to wrap it using this function in order to use it with
%   VIKAASA.
%
% USAGE
%   % Use lsode like you would use ode45:
%   [T, Y] = vk_lsode_wrapper(odefun, [0, time_horizon], x0);
%
% See also: vk_options

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
function [T, Y] = vk_lsode_wrapper(odefun, timespan, x0)
    h = lsode_options('maximum step size');
    T = timespan(1):h:timespan(2);
    Y = lsode(@(x,t) odefun(t,x), x0, T);

    %% ode45 returns the time vector as a column.
    T = transpose(T);
end
