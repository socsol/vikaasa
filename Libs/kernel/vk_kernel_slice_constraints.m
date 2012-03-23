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
function K = vk_kernel_slice_constraints(K, slices)

    % Order slices from largest to smallest dimension.  There is a bug in
    % Octave which causes this to break if there is only one slice.
    if (size(slices, 1) > 1)
        slices = sortrows(slices, -1);
    end

    for i = 1:size(slices, 1)
        K = [K(1:2*slices(i, 1)-2), ...
            K(2*slices(i, 1)+1:end)];
    end
end
