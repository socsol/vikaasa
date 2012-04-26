% VK_VIABLE Determine the viability of a point in the state space
%
% SYNOPSIS
%   The algorithm attempts to bring the system to a near-steady state by
%   applying a bounded control.
%
%   The function returns one or two values.  The second value is a
%   structure that gives information about how the point was determined
%   viable or non-viable.
%
% EXAMPLES
%   % Standard usage:
%   isviable = vk_viable(x, K, f, c);
%
%   % With an options structure created by vk_options:
%   isviable = vk_viable(x, K, f, c, options);
%
%   % Returning additional information:
%   [isviable, paths] = vk_viable(x, K, f, c, options);
%
% Requires: vk_control_wrap_fn, vk_options, vk_viable_exited
%
% See also: ControlAlgs, vk_kernel_compute

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
function varargout = vk_viable(x, K, f, c, varargin)

    %% Construct options
    options = vk_options(K, f, c, varargin{:});


    %% Options of interest
    numvars = options.numvars;
    maxloops = options.maxloops;
    cancel_test = options.cancel_test;
    small = options.small;

    norm_fn = options.norm_fn;
    next_fn = options.next_fn;
    cancel_test_fn = options.cancel_test_fn;


    %% Construct a control function
    % This control function will be bounded by the bound_fn, so that it
    % does not unnecessarily choose any control that causes an immediate
    % crash.  The bound_fn also returns non-viability of the point.
    control_fn = vk_control_wrap_fn(options.control_fn, K, f, c, options);

    %% Construct a fallback control function
    fallback_fn = vk_control_wrap_fn(@ZeroControl, K, f, c, options);

    %% Can additionall return the path taken in determining viability
    if (nargout > 1)
        recordpath = true;

        % This is will be filled with column vectors.  However, we will
        % transpose it before returning.
        path = zeros(numvars, maxloops);

        controlpath = zeros(options.numcontrols, maxloops);
        normpath = zeros(1, maxloops);
        viablepath = zeros(5, maxloops);
    else
        recordpath = false;
    end


    %% Check if we pretest x for viability
    % If we do, and the point turns out to be non-viable, we set maxloops
    % to 0 to skip the main loop.
    if (options.use_custom_constraint_set_fn)
        exited_on = vk_viable_exited(x, K, f, c, options);
        if (any(any(~isnan(exited_on))))
            viable = false;
            maxloops = 0;
            path(:, 1) = x;
        end
    end


    %% The main loop
    for l = 1:maxloops

        %% Record the position.
        if (recordpath)
            path(:, l) = x;
        end

        %% Find control for point x
        try
            [u, crashed, exited_on] = control_fn(x);
        catch
            ex = lasterror();
            warning(['Error using control algorithm at point ', ...
                mat2str(transpose(x)), ...
                ' falling back on ZeroControl.']);
            [u, crashed, exited_on] = fallback_fn(x);
        end

        %% Record the new control.
        if (recordpath)
            controlpath(:,l) = u;
            viablepath(3, l) = any(~isnan(exited_on(:,1)));
            viablepath(4, l) = any(~isnan(exited_on(:,2)));

            %% Record velocity and steadyness
            norm_val = norm_fn(f(x, u));
            steady = norm_val <= small;
            viablepath(5, l) = steady;
            normpath(l) = norm_val;
        end

        %% Check stopping criteria
        % Either, the algorithm has decided that the point is or isn't
        % viable, the maximum number of loops has been reached, or the user
        % has intervened.
        if (crashed || (cancel_test && cancel_test_fn()))
            viable = false;
            break;
        elseif (l == maxloops)
            fprintf('Maxloops exceeded\n');
            viable = false;
            break;
        elseif (recordpath && steady) || (norm_fn(f(x, u)) <= small)
            viable = true;
            break;
        end

        %% Update x for next iteration.
        x = next_fn(x, u);
    end


    %% Return the viability of the point.
    varargout{1} = viable;

    %% Potentially return extra info too, if requested.
    if (nargout > 1)
        h = options.h;

        paths = struct;
        paths.T = 0:h:h*(l-1);
        paths.path = path(:, 1:l);
        paths.normpath = normpath(1:l);
        paths.controlpath = controlpath(:, 1:l);
        paths.viablepath = viablepath(:, 1:l);

        if (viable == false)
            paths.exited_on = exited_on;
        end

        varargout{2} = paths;
    end
end
