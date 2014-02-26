% VK_ISS_VIABLE_STOP Determine whether vk_viable should stop
%
% SYNOPSIS
%   This function is used by vk_viable when run under the exclusion
%   algorithm, to determine when to stop.
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
function [viable, stop] = vk_iss_viable_stop(l, x, u, K, f, c, options)

  %% Options of interest
  maxloops = options.maxloops;

  %% Default return values
  viable = false;
  stop = false;

  %% If we get to maxloops in the exclusion algorithm, it indicates viability.
  if (l == maxloops)
    viable = true;
    stop = true;
  end

end