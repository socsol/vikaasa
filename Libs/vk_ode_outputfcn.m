%% VK_ODE_OUTPUTFCN Used to make various checks during ODE solver runs.
%
% SYNOPSIS
%   This function is usually fed by vk_options into `ode45' (or
%   similar) so that certain checks can be undertaken while the solver is
%   running.  Currently, those checks are testing to see if a steady state
%   has been acheived and testing to see if the user has issued a cancel
%   command.
%
% USAGE
%   % Standard usage:
%   outputfcn = @(T, Y, flag) VK_ODE_OUTPUTFCN(T, Y, flag, ...
%       report_progress, progress_fn, cancel_test, cancel_test_fn, ...
%       stopsteady, norm_fn, small);
%   odeopts = odeset('OutputFcn', outputfcn);
%   [T, Y] = ode45(odefun, T, Y, odeopts);
%
% See also: TOOLS, TOOLS/VK_OPTIONS, TOOLS/VK_SIMULATE_ODE

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
function status = vk_ode_outputfcn(T, Y, flag, report_progress, ...
    progress_fn, cancel_test, cancel_test_fn, stopsteady, norm_fn, small)

    % Report progress, unless this is the 'init' call.
    if (report_progress && ~strcmp(flag, 'init') && ~isempty(T))
        T_max = round(max(T));
        progress_fn(T_max);
    end

    % Status needs to be 1 when we want to stop.
    if (cancel_test)
        status = cancel_test_fn();
    else
        status = 0; % Don't stop.
    end

    % Check if we should stop on account of having reached a steady state.
    if (stopsteady && ~strcmp(flag, 'init') && ~isempty(T))
        Y1 = Y(1:end-1, :);
        Y2 = Y(2:end, :);
        Ydiff = Y2 - Y1;

        T1 = T(1:end-1);
        T2 = T(2:end);
        Tdiff = T2 - T1;

        for i = 1:length(Tdiff)
            %fprintf('T = %f; N = %f\n', T2(i), ...
            %norm_fn(Ydiff(i, :) / Tdiff(i)));
            if (norm_fn(Ydiff(i, :) / Tdiff(i)) <= small)
                status = 1; % stop
                break;
            else

            end
        end
    end
end
