%% VK_CONTROL_BOUND Bound a control choice to prevent the system from crashing, where possible
%
% SYNOPSIS
%   This function takes a state-space point and a control choice, and
%   checks to see if that control choice will cause the system to exit the
%   constraint set in zero, one or two steps.
%
%   Zero steps means that the point is already outside the constraint set.
%
%   One step means that after applying `u', the system violates the
%   constraint set.
%
%   Two steps makes use of the `controldefault' option.  This is only
%   checked if the `use_controldefault' is specified.  In this case, the
%   uncontrolled system will crash in the next step.
%
%   If vk_control_bound is not able to prevent a crash, it will attempt to
%   minimise the number of variables that crash.
%
% USAGE
%   % Simple usage:
%   u = vk_control_bound(x, u, K, f, c)
%
%   See vk_kernel_compute for information on the format of the input
%   parameters.
%
%   The return value will be the bounded version of the u specified in the
%   input list.  Where potential violations were detected that were
%   salvagable, the new u will differ from the original one.
%
%   % Getting more informaton:
%   [u, crashed] = vk_control_bound(x, u, K, f, c)
%   [u, crashed, exited_on] = vk_control_bound(x, u, K, f, c)
%
%   - `crashed' is a boolean value that indicates whether a crash occurred
%     despite any efforts to avoid one.
%
%   - `exited_on' is a row-vector of integers indicating the dimensions that
%     the system crashed on.  See vk_viable_exited for more information on
%     this.
%
%   % Specifying options:
%   [u, crashed] = vk_control_bound(x, u, K, f, c, options)
%
%   Here `options' is either a structure created by vk_options, or
%   otherwise a list of 'name', value pairs.
%
% CAVEATS
%   When the `use_custom_constraint_set' option is specified, vk_control_bound
%   will not be able to improve the control choice.  In this case, it simply
%   checks for constraint set violations.
%
% See also: control, vk_control_enforce, vk_viable_exited, vk_options, vk_viable

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
function [u, crashed, exited_on] = vk_control_bound(x, u, K, f, c, varargin)

    %% Create options structure
    options = vk_options(K, f, c, varargin{:});


    %% Options that we care about
    use_controldefault = options.use_controldefault;
    controldefault = options.controldefault;
    controlbounded = options.controlbounded;
    next_fn = options.next_fn;

    % We update these as we go.
    allowed_min = -c;
    allowed_max = c;


    %% If we are not interested in bounding, then return for zero steps
    if (~controlbounded)
        exited_on = vk_viable_exited(x, K, f, c, options);
        crashed = ~isempty(exited_on);
        return;
    end


    %% Next, check to see if the point has exited on one step.
    exited_on = vk_viable_exited(next_fn(x, u), K, f, c, options);
    crashed = ~isempty(exited_on);
    if (crashed)
        fn = @(x, u) next_fn(x, u);
        [u, crashed, exited_on, allowed_min, allowed_max] = ...
            vk_newcontrol(x, u, crashed, exited_on, allowed_min, ...
            allowed_max, fn, K, f, c, options);

        %% If we have still crashed, then give up.
        if (crashed)
            return;
        end
    end


    %% If we are not using the controldefault, we are done.
    if (~use_controldefault)
        return;
    end


    %% Next check to see if we exit on two steps.
    exited_on = vk_viable_exited(next_fn(next_fn(x, u), controldefault), K, ...
        f, c, options);
    crashed = ~isempty(exited_on);
    if (crashed)
        fn = @(x, u) next_fn(next_fn(x, u), controldefault);
        [u, crashed, exited_on] = vk_newcontrol(x, u, crashed, ...
            exited_on, allowed_min, allowed_max, fn, K, f, ...
            c, options);
    end
end


%% Helper function that works out the distance of one element of our function.
function dist = vk_distance_fn(fn, u, need_equal, elt)
    val = fn(u);
    dist = need_equal - val(elt);
end


%% Helper function to try to determine new control
function [u, crashed, exited_on, allowed_min, allowed_max] = ...
    vk_newcontrol(x, u, crashed, exited_on, allowed_min, allowed_max, ...
    next_fn, K, f, c, options)

    zero_fn = options.zero_fn;

    new_u = u;

    %% If zero is amongst the crash elements then give up.
    if (any(exited_on == 0))
        return;
    end


    %% Consider the each crashed element.
    for i = 1:length(exited_on)
        % A negative value means the lower bound.
        upper = sign(exited_on(i)) == 1;
        dim = abs(exited_on(i));

        % Create a function to make equal to zero using the
        % vk_distance_fn helper.
        if (upper)
            need_equal = K(dim*2) - options.controltolerance;
        else
            need_equal = K(dim*2 - 1) + options.controltolerance;
        end
        f = @(u) vk_distance_fn(@(u) next_fn(x, u), u, need_equal, dim);

        % We need the signs of the upper and lower values to be
        % different; otherwise, we shouldn't use fzero.
        if (sign(f(allowed_min)) ~= sign(f(allowed_max)))
            new_u = zero_fn(f, [allowed_min, allowed_max]);
        else
            continue; % Try the next dimension.
        end

        % Check the sign of our new control, and shrink the allowed
        % bounds accordingly.  This means that over successive attempts
        % to bound, we don't select larger variables than we did
        % before.
        if (sign(new_u) == 0)
            % This isn't quite correct, but we are unable to work out
            % whether zero is a lower or upper bound.
            allowed_min = 0;
            allowed_max = 0;
        elseif (sign(new_u) == -1)
            allowed_min = new_u;
        else % positive
            allowed_max = new_u;
        end
    end


    %% If anything new was computed, recalculate.
    if (new_u ~= u)
        u = new_u;
        exited_on = vk_viable_exited(next_fn(x, u), K, f, c, ...
            options);
        crashed = ~isempty(exited_on);
    end
end

