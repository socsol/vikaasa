%% VK_CONTROL_WRAP_FN Wrap a control algorithm with bounding code, etc.
%
% SYNOPSIS
%   This function wraps the result of a control choice in up to two
%   functions.  Firstly, if enforcement of the control range is in place,
%   then the outcome of calling the function will be passed through
%   vk_control_enforce to make sure that it lies within the control set $[-c,
%   c]$.  Secondly, if bounding of control choices at the constraint set edge
%   is enabled, then the control choice (or the result from calling
%   vk_control_enforce) is passed through vk_control_bound.
%
% USAGE
%   % Get a handle to a function which is wrapped in one or both of the above
%   % functions, depending on the options structure:
%   fn = vk_control_wrap_fn(control_fn, K, f, c, options);
%   % Call that function on some x, and u:
%   fn(x, u)
%
% Requires: vk_options, vk_control_bound, vk_control_enforce
%
% See also: vk_control_make_fn

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
function fn = vk_control_wrap_fn(control_fn, K, f, c, varargin)

    %% Create options structure
    options = vk_options(K, f, c, varargin{:});

    %% Options we arre concerned with:
    bound_fn = options.bound_fn;
    enforce_fn = options.enforce_fn;
    controlenforce = options.controlenforce;

    if (controlenforce)
        fn = @(x) bound_fn(x, ...
            enforce_fn(control_fn(x, K, f, c, options), c), ...
            K, f, c, options);
    else
        fn = @(x) bound_fn(x, ...
        	control_fn(x, K, f, c, options), K, f, c, options);
    end
end

