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
%   - `exited_on' is matrix of the form described by vk_viable_exited.
%
%   % Specifying options:
%   [u, crashed] = vk_control_bound(x, u, K, f, c, options)
%
%   Here `options' is either a structure created by vk_options, or
%   otherwise a list of 'name', value pairs.
%
% CAVEATS
%   When the `use_custom_constraint_set' option is specified, vk_control_bound
%   will not be able to improve the control choice for real (non-imaginary)
%   violations.  In this case, it simply checks for constraint set violations.
%
% Requires: vk_options, vk_viable_exited
% See also: control, vk_control_enforce, vk_viable

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
        crashed = any(any(~isnan(exited_on)));
        return;
    end


    %% Next, check to see if the point has exited on one step.
    exited_on = vk_viable_exited(next_fn(x, u), K, f, c, options);
    crashed = any(any(~isnan(exited_on)));
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
    crashed = any(any(~isnan(exited_on)));
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
    fn, K, f, c, options)

    zero_fn = options.zero_fn;

    new_u = u;

    %% Check for violations in the complex plane first.
    if (any(~isnan(exited_on(:,2))))
        %% Check for the existence of a boundary control that fixes this.
        if (isreal(fn(x, allowed_max)))
            %% The maximum allowed control eliminates the imaginary part.
            %   In this case, we start from slightly above u, and search
            %   upwards for the value closest to u that solves the problem.
            %
            %   We also adjust the allowed_min, in the hope that the range
            %   between the value we identify and the allowed_max all avoid
            %   the complex numbers.
            for uu = u+options.controltolerance:controltolerance:allowed_max
                if (isreal(fn(x, uu)))
                    new_u = uu;
                    allowed_min = new_u;
                    break;
                end
            end
        elseif (isreal(fn(x,allowed_min)))
            range = allowed_min:controltolerance:u-options.controltolerance;
            for uu = range(end:-1:1)
                if (isreal(fn(x, uu)))
                    new_u = uu;
                    allowed_max = new_u;
                    break;
                end
            end
        end

        %% if we found a new_u above, re-evaluate.
        if (u ~= new_u)
            u = new_u;
            exited_on = vk_viable_exited(fn(x, u), K, f, c, ...
                options);
            crashed = any(any(~isnan(exited_on)));
        end
    end


    %% If there are still complex numbers, or if the first column is zeros, give up.
    if (~crashed || any(~isnan(exited_on(:,2))) || all(exited_on(:,1) == 0))
        return;
    end


    %% In this case, there are only real violations of the rectangular constraint set.
    dims = find(~isnan(exited_on));
    for i = 1:length(dims)
        dim = dims(i);
        upper = sign(exited_on(dim,1)) == 1;

        % Create a function to make equal to zero using the
        % vk_distance_fn helper.
        if (upper)
            need_equal = K(dim*2) - options.controltolerance;
        else
            need_equal = K(dim*2 - 1) + options.controltolerance;
        end
        dist = @(u) vk_distance_fn(@(u) fn(x, u), u, need_equal, dim);

        % We need the signs of the upper and lower values to be
        % different and real; otherwise, we shouldn't use fzero.
        if (sign(dist(allowed_min)) ~= sign(dist(allowed_max)) ...
          && isreal([dist(allowed_min), dist(allowed_max)]))
            new_u = zero_fn(dist, [allowed_min, allowed_max]);
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
        exited_on = vk_viable_exited(fn(x, u), K, f, c, ...
            options);
        crashed = any(any(~isnan(exited_on)));
    end
end

