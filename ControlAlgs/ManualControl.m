%% MANUALCONTROL Manually choose control from the command line
%
% SYNOPSIS
%   This function allows the user to manually specify control at each
%   position, and also allows the user to test different possible control
%   paths.
%
% USAGE
%   % Standard usage:
%   u = ManualControl(x, K, f, c)
%
%   % With an options structure attached:
%   u = ManualControl(x, K, f, c, options)
%
%   `options' is either a structure created by vk_options, or otherwise a
%   series of 'name', value pairs.
%
% See also: vk_options

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
function u = ManualControl(x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    disp('Current position:');
    disp(transpose(x));

    if (~isempty(vk_viable_exited(x, K, f, c, options)))
        disp('- Outside the constraint set');
    else
        disp('- Inside the constraint set');
    end
    fprintf('\n');

    u = input('Enter control choice >> ');
end
