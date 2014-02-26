% VK_VIABLE_STOP Determine whether vk_viable should stop
%
% SYNOPSIS
%   This function is used by vk_viable to determine whether to
%   stop, and whether the point should be considered viable or
%   not.  It can be overridden in vk_options.
%
%   Note that this function does not need to test for
%   constraint-set violation, as this is done in vk_viable already.
%
% See also: vk_viable, vk_options

%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
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
function [viable, stop] = vk_viable_stop(l, x, u, K, f, c, options)

  %% Options of interest
  maxloops = options.maxloops;
  small = options.small;
  norm_fn = options.norm_fn;

  %% Default return values
  viable = [];
  stop = false;

  %% Check to see if maxloops was exceeded
  if (l == maxloops)
    fprintf('Maxloops exceeded\n');
    viable = false;
    stop = true;
  elseif norm_fn(f(x, u)) <= small
    viable = true;
    stop = true;
  end

end