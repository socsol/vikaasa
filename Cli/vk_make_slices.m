%% VK_MAKE_SLICES Construct a slice array from a cell array
%   
function slices = vk_make_slices(data, K, discretisation)      
    
    slices = [];
    
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
            slices = [slices; i, data{i, 3}, ...
                (K(i*2) - K(i*2 - 1)) / (discretisation + 1)];
        end
    end
end