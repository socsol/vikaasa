%% VK_SIM_AUGMENT_PATH Add details about additional variables to a simulation path

%%
%  Copyright 2012 Jacek B. Krawczyk and Alastair Pharo
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
function path = vk_sim_augment_path(path, numvars, numaddnvars, ...
    addnignore, addneqns, symbols)

    path = [path; zeros(numaddnvars, size(path, 2))];

    %% For each non-ignored index, fill in the gaps:
    for i = transpose(find(~addnignore))
        fn = inline(addneqns{i}, symbols{:});
        for col = 1:size(path, 2)
            args = num2cell(path(1:numvars, col));
            path(i+numvars, col) = fn(args{:});
        end
    end

    %% Now remove all the ignored rows in reverse:
    for i = sort(transpose(find(addnignore))+numvars, 'descend')
        path = [path(1:i-1,:); path(i+1:end,:)];
    end
end
