%% VK_DIFF_FN Returns the vector of derivatives for a state-space and control.
%
% SYNOPSIS
%   This function returns a column vector of length $n$ of derivatives.  You
%   don't need to use this function directly.  Instead, call vk_make_diff_fn.
%
% USAGE
%   % Get derivatives:
%   xdot = vk_diff_fn(f, x, u)
%
%   - `f' is a function that takes $n+1$ inputs -- i.e., the set of state
%     variables, plus the vector of controls.
%   - `x' is a column vector of length $n$, giving the state-space
%     representation of the system.
%   - `u' is a column vector of control choices.
%
% EXAMPLES
%   % Make a function (or use vk_make_diff_fn for this):
%   f = @(a,b,c,d) a*b + c*d;
%   fn = @(x,u) vk_diff_fn(f,x,u);
%
% See also: vk_make_diff_fn

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
function xdot = vk_diff_fn(f, x, u)
    args = [num2cell(x); num2cell(u)];
    xdot = f(args{:});
end
