%% VK_CONTROL_COST_FN compose cost functions of x, xdot 
%   This function is needed by certain cost-minimising control functions in
%   order to be able to minimise using an un-named vector of variables, instead
%   of a tuple.
%
%   cfn = VK_CONTROL_COST_FN(cost_fn, x, xdot)
%
%   cost_fn would be a function like: @(x,y,z,xdot,ydot,zdot) <function of
%   those vars>, whereas cfn will instead by a function of two variables: x and
%   xdot.
%
% See also: CONTROL, VK_CONTROL_EVAL_FN
%

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
function cost = vk_control_cost_fn(cost_fn, x, xdot)
    vars = num2cell([x;xdot]);
    cost = cost_fn(vars{:});
end
