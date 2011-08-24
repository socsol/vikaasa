%% VK_KERNEL_AUGMENT_SLICES Augment the list of slices, and remove any ignored
%
% SYNOPSIS
%   Where additional values are specified, make sure that any that are set
%   to 'ignore' are not included in the list of slices, and then add
%   'all' slices for them, so that they will be eliminated.
%
% USAGE
%   % Augment the slices, store the result in slices, using data from p:
%   slices = vk_kernel_augment_slices(p);
%
% See also: vk_kernel_augment, vk_kernel_augment_constraints

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%`
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function slices = vk_kernel_augment_slices(project)

    slices = project.slices;
    ignore = transpose(find(project.addnignore))+project.numvars;
    if (~isempty(ignore))
        %% If an ignored variable is in the list of slices, remove it.
        %   We need to remove all the ignored slices before decrementing, below.
        for i = ignore
            sliceindex = find(slices(:,1) == i);
            if (~isempty(sliceindex))
                slices = [slices(1:sliceindex-1, :); slices(sliceindex+1, :)];
            end
        end

        for i = ignore
            % If there are any slices at indexes greater than an ignored one,
            % decrement them.
            decrementindices = find(slices(:,1) > i);
            if (~isempty(decrementindices))
                slices(decrementindices,1) = slices(decrementindices) - 1;
            end
        end
    end
end
