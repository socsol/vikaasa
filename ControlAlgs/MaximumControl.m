%% MAXIMUMCONTROL Apply maximum control.
%
% SYNOPSIS
%   This control rule simply returns the maximum control, regardless of
%   position, etc.
%
% USAGE
%   % Standard usage
%   u = MaximumControl(x, K, f, c);
%
%   % With options
%   u = MaximumControl(x, K, f, c, options);
%  
% See also: MinimumControl, ZeroControl, vk_viable

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
function u = MaximumControl(x, K, f, c, varargin)
    u = c;
end
