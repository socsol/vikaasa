%% ZEROCONTROL Apply control of zero
%   This function chooses a control of zero every time.
%
%   u = ZEROCONTROL(x, constraint_set, delta_fn, controlmax)
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
function u = ZeroControl(x, K, f, c, varargin)    
    u = 0;
end
