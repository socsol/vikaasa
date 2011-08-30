%% FLTAYLORRULE Example of a specific Taylor rule algorithm
%   This function chooses a Taylor rule control.
%
%   u = FLTaylorRule(x, K, f, c)
%
% See also: MaximumControl, MinimumControl

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
function u = FLTaylorRule(x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    % Coefficients on pi and y
    a_pi = 1.5;
    a_y = 0.5;

    % Targets.  In steady state pi = i, so they should be the same. y_T = 0
    % because y represents the output gap.
    pi_T = 0.02;
    i_T = 0.02;
    y_T = 0;

    % State values are stored in the vector x.  We only take the first
    % three so that this algorithm works in both 3D and 4D.
    y = x(1); pi = x(2); i = x(3);

    % Create a TR function which gives the Taylor choice of i for a given
    % (y,pi) pair.
    TR = @(y,pi) i_T + a_pi*(pi - pi_T) + a_y*(y - y_T);

    % Choose the u that makes interest in the next period equal to the Taylor
    % prescription.
    u = fzero(@(u) FLTaylorRuleHelper(x, u, TR, options), 0);
end

function diff = FLTaylorRuleHelper(x, u, TR, options)
    x2 = options.next_fn(x,u);
    diff = TR(x2(1), x2(2)) - x2(3);
end
