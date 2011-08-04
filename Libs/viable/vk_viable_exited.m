%% VK_VIABLE_EXITED Indicate whether a point has exited the constraint set.
%
% SYNOPSIS
%   This function returns a $n \times 2$ matrix, where $n$ is the number of
%   dimensions in the problem, the first column gives the direction of any real
%   violation of the constriant set for that dimension (or `NaN' if there was
%   no real violation), and the second column gives the direction of any
%   imaginary violation (or `NaN' if there was no imaginary violation).
%
%   Because VIKAASA only deals with real-valued problems, any complex value at
%   all is considered a violation -- that is, the only imaginary value for
%   which there is no violation is `0*i'.
%
%   In each case, if the number is negative, the lower bound has been violated;
%   if the number is positive, the upper bound is violated.  The actual value
%   gives the distance from the lower or upper bound respectively (or zero for
%   the complex dimension).
%
%   It is also possible for this function to return zeros in the first column.
%   Zero means that a custom constraint set function was used, in which case it
%   is impossible to know which axis the (real) violation occurred on.
%
% USAGE
%   % Standard usage:
%   exited_on = vk_viable_exited(x, K, f, c);
%
%   % With optional params:
%   exited_on = vk_viable_exited(x, K, f, c, options);
%
%   `exited_on' is a $n \times 2$ matrix of numbers.  Each number is either
%   zero, or it represents an axis.  If the number is negative, then that
%   indicates that the lower bound was violated.  If it's positive then the
%   upper bound was violated.
%
%   % Checking how many constraints were violated:
%   exited_on = vk_viable_exited(x, K, f, c);
%   violated = any(any(~isnan(exited_on)));
%   count = sum(sum(~isnan(exited_on)));
%
%   % Checking whether a custom constraint set violation occured:
%   exited_on = vk_viable_exited(x, K, f, c);
%   ccsf = all(exited_on(:,1) == 0);
%
% Requires: vk_options
% See also: viable, vk_viable, vk_control_bound

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
function exited_on = vk_viable_exited(x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    % This makes an nx2 array of NaNs.
    exited_on = zeros(length(x), 2);
    exited_on = arrayfun(@(n) NaN, exited_on);

    % First, check for complex numbers:
    for i = 1:length(x)
      if (~isreal(x(i)))
        exited_on(i,2) = imag(x(i));
      else
        exited_on(i,2) = NaN;
      end
    end

    % If we use the custom constraint set, check that first. If that
    % returns false, then give up.
    if (options.use_custom_constraint_set_fn)
        vars = num2cell(x);
        if (~options.custom_constraint_set_fn(vars{:}))
            exited_on(:,1) = zeros(length(x), 1);
            return;
        end
    end

    for i = 1:length(x)
        if (x(i) < K(2*i  - 1))
            exited_on(i,1) = x(i) - K(2*i  - 1); % < 0
        elseif (x(i) > K(2*i))
            exited_on(i,1) = x(i) - K(2*i); % > 0
        end
    end
end
