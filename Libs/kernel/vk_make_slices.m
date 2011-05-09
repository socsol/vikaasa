%% VK_MAKE_SLICES Construct a slice array from a cell array
%   
function slices = vk_make_slices(data, K, discretisation)      
    
    slices = [];

    distances = vk_make_distances(K, discretisation);
    
    %% Loop through rows of data
    % There will be one row in data for each variable.
    for i = 1:size(data, 1)     
        if (data{i,1})
            % If the first element is checked, then that dimension is
            % sliced for all values, essentially eliminating it from
            % consideration.
            slices = [slices; i, NaN, NaN];
        elseif (data{i,2})
            % If the second element is checked, then that dimension is
            % sliced at a particular value. 
            % The third element is the 'distance', which tells the slicer how far to either side of the slice value 
            slices = [slices; i, data{i, 3}, distances(i)];
        end
    end
end
