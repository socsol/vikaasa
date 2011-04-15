function [limits, slices] = vk_figure_data_retrieve(h)
    ud = get(h, 'UserData');
    limits = ud(1, 2:ud(1,1)+1);
    
    if (size(ud, 1) > 1)
        slices = ud(2:end, 2:ud(2,1)+1);
    else
        slices = [];
    end
end
