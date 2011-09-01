%% VK_DIFF_MAKE_FN Construct a MATLAB function from an array of strings
%
% SYNOPSIS
%   This function returns a function which returns the array of derviatives
%   for a given state-space point (represented as a column vector), and a
%   control choice (represented by a scalar).
%
% USAGE
%   % Given some project, create a function:
%   diff_fn = vk_diff_make_fn(project)
%
% Requires: vk_diff_fn

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
function diff_fn = vk_diff_make_fn(project)
    symbols = project.symbols;
    controlsymbol = project.controlsymbol;
    diff_eqns = cellstr(project.diff_eqns);
    args = cellstr(symbols);

    %% Build a string that contains all of the equations
    % With semi-colons separating them
    inline_str = '[';
    for i = 1:size(diff_eqns,1)
        inline_str = [inline_str, diff_eqns{i}];
        if (i < size(diff_eqns,1))
            inline_str = [inline_str, ';'];
        else
            inline_str = [inline_str, ']'];
        end
    end

    %% Create an inline function.
    diff_inline = inline(inline_str, args{:}, controlsymbol);

    %% Create the array-based function
    diff_fn = @(x, u) vk_diff_fn(diff_inline, x, u);
end
