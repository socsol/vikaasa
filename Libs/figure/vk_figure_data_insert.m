%% VK_FIGURE_DATA_INSERT Add data into a figure handle.
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
function vk_figure_data_insert(h, limits, slices)
    % Create a rectangular set of cells.
    data = {...
        size(limits, 2), limits, [];
        size(slices, 2)*ones(size(slices, 1), 1), slices, []};

    if (size(slices, 1) > 0)
        % Pad the cells.
        diff = size(limits, 2) - size(slices, 2);
        if (diff > 0)
            data{2, 3} = zeros(size(slices, 1), diff);
        elseif (diff < 0)
            data{1, 3} = zeros(1, -diff);
        end
    end

    % This augmented form is used because of a bug in Octave.
    set(h, 'UserData', vertcat(...
        cell2mat([data(1,1), data(1,2), data(1,3)]), ...
        cell2mat([data(2,1), data(2,2), data(2,3)])));
  end
