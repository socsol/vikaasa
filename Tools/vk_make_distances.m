%% VK_MAKE_DISTANCES Calculate distances between points in each dimension
%   Using a given rectangular constraint set and discretisation.
function distances = vk_make_distances(K, discretisation)
    distances = zeros(1, length(K)/2);
    for i = 1:length(K)/2
        distances(i) = (K(2*i) - K(2*i - 1)) ...
            / (discretisation-1);
    end
end
