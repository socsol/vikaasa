%% VK_FIGURE_DATA_RETRIEVE Retrieve data previously stored in figure
%
% See also: vk_figure_data_retrieve
%

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
function [limits, slices] = vk_figure_data_retrieve(h)
    ud = get(h, 'UserData');
    limits = ud(1, 2:ud(1,1)+1);
    
    if (size(ud, 1) > 1)
        slices = ud(2:end, 2:ud(2,1)+1);
    else
        slices = [];
    end
end
