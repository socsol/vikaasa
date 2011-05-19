%% VK_FIGURE_DATA_RETRIEVE Retrieve data previously stored in figure
%
% See also: vk_figure_data_retrieve
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function [limits, slices] = vk_figure_data_retrieve(h)
    ud = get(h, 'UserData');
    limits = ud(1, 2:ud(1,1)+1);
    
    if (size(ud, 1) > 1)
        slices = ud(2:end, 2:ud(2,1)+1);
    else
        slices = [];
    end
end
