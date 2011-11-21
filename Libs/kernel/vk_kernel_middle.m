%% VK_KERNEL_MIDDLE Find a point which represents the ``middle'' of the kernel.
%
% SYNOPSIS
%   This function finds the middle of a viability kernel approximation by
%   averaging the points.  Note that the middle may not actually represent a
%   point in the kernel approximation.
%
% USAGE
%   % C will be a vector giving the postion of the middle.
%   C = vk_kernel_middle(V);

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
function C = vk_kernel_middle(V)
  C = sum(V,1)/size(V,1);
end
