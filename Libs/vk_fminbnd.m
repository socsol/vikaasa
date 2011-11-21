%% VK_FMINBND A naive (slow) minimisation function.
%
% SYNOPSIS
%   This function is similar to `fminbnd', except that instead of using a
%   golden ratio search, it searches linearly through $[minvar, maxvar]$.
%   `fminbnd' is faster, so this function is generally not used.
%
%   It takes the same arguments as `fminbnd', except that it takes an
%   additional `tolerance' option, which indicates the distance between points
%   polled (i.e. `minvar:tolerance:maxvar' is polled).
%
% USAGE
%   % Find the minimum of x^2 between -1 and 1:
%   min = vk_fminbnd(@(x) x^2, -1, 1, 0.01);
%
% See also: fminbnd

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
function min = vk_fminbnd(fn, minvar, maxvar, tolerance)
  minval = fn(maxvar);
  min = maxvar;
  for i = minvar:tolerance:maxvar
    f = fn(i);
    if (f < minval)
      minval = f;
      min = i;
    end
  end
end
