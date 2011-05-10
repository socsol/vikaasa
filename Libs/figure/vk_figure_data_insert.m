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
