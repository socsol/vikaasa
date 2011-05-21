%% VK_FIGURE_PLOT_BOX Draw a box around a kernel
%   This function boxes the given figure according to the constraint set.  If
%   there are slices, then these are considered too.
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
function limits = vk_figure_plot_box(K, varargin)

    hold on;

    % Deal with slices by eliminating those constraints from consideration.
    if(~isempty(varargin))
        slices = sortrows(varargin{1}, -1);

        for i = 1:size(slices, 1)
            slice_axis = slices(i, 1);
            K = horzcat(K(1:2*slice_axis-2), ...
                K(2*slice_axis+1:size(K,2)));
        end
    end

    if (length(K) == 4) % 2D case:
        n = 4;
        limits = zeros(1, 4);
        for i = 1:2
            diff = K(2*i) - K(2*i-1);

            limits(2*i-1) = K(2*i-1) - diff/n;
            limits(2*i) = K(2*i) + diff/n;
        end

        % There are 2^2 = 4 corners.  Each corner corresponds to a 2-digit
        % binary number, where a zero in the i-th position means "min", and
        % a one means "max".
        points = zeros(4,2);
        for i = 1:4
            binval = dec2bin(i-1,2);

            for j = 1:2
                if (binval(j) == '0')
                    points(i,j) = K(2*j - 1);
                else
                    points(i,j) = K(2*j);
                end
            end
        end

        % There are 4 lines:
        lines = [...
            1, 2;
            1, 3;
            2, 4;
            3, 4];

        for i = 1:4
            plot(...
                points(lines(i, :), 1), ...
                points(lines(i, :), 2), 'k-');
        end

    elseif (length(K) == 6) % 3D case

        % Make the limits  an n-th of the distance further out, except for
        % the "base" (i.e., lower z), which stays unchanged.
        n = 4; % "4" means add a quarter...
        limits = zeros(1, 6);
        for i = 1:3
            diff = K(2*i) - K(2*i-1);
            if (i == 3)
                limits(2*i-1) = K(2*i-1);
            else
                limits(2*i-1) = K(2*i-1) - diff/n;
            end
            limits(2*i) = K(2*i) + diff/n;
        end

        % There are 2^3 = 8 corners.  Each corner corresponds to a 3-digit
        % binary number, where a zero in the i-th position means "min", and
        % a one means "max".
        points = zeros(8,3);
        for i = 1:8
            binval = dec2bin(i-1,3);

            for j = 1:3
                if (binval(j) == '0')
                    points(i,j) = K(2*j - 1);
                else
                    points(i,j) = K(2*j);
                end
            end
        end

        % There are 12 lines:
        lines = [...
            1, 2;
            1, 3;
            1, 5;
            2, 4;
            2, 6;
            3, 4;
            3, 7;
            4, 8;
            5, 6;
            5, 7;
            6, 8;
            7, 8];

        for i = 1:12
            plot3(...
                points(lines(i, :), 1), ...
                points(lines(i, :), 2), ...
                points(lines(i, :), 3), 'k-');
        end

        % Colour the base "floor" area grey:
        floor = [1,3,7,5,1];
        p = patch(points(floor(:), 1), points(floor(:), 2),...
            points(floor(:), 3), [0.7, 0.7, 0.7]);

        if (exist('alpha'))
            alpha(p, 0.2);
        end
    end
end
