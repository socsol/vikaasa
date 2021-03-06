%% MINIMUMCONTROL Apply minimum control (i.e., $-c$)
%
% SYNOPSIS
%   This function returns the largest negative control available,
%   regardless of size.
%
% USAGE
%   % Standard usage:
%   u = MinimumControl(x, K, f, c);
%
%   % With additional options
%   u = MinimumControl(x, K, f, c, options);
%
% See also: MaximumControl, ZeroControl, vk_viable

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
function u = MinimumControl(x, K, f, c, varargin)
    u = -c;
end
