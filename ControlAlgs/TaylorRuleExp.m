%% TAYLORRULEEXP Example of a specific Taylor rule algorithm
%   This function chooses a Taylor rule control.
%
%   u = TAYLORRULE(x, K, f, c)
%
% See also: CONTROLALGS/MAXIMUMCONTROL, CONTROLALGS/MINIMUMCONTROL

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
function u = TaylorRuleExp(x, K, f, c, varargin)

    % Coefficients on pi and y
    a_pi = 1.1;
    a_y = 0.0;

    % Targets.  In steady state pi = i, so they should be the same. y_T = 0
    % because y represents the output gap.
    pi_T = 0.02;
    i_T = 0.02;
    y_T = 0;

    % State values are stored in the vector x.  We only take the first
    % three so that this algorithm works in both 3D and 4D.
    y = x(1); pi = x(2); i = x(3);

    % Note that we subtract i, because u = idot \approx i_desired - i
    u = (i_T - i) + a_pi*(pi - pi_T) + a_y*(y - y_T);
end
