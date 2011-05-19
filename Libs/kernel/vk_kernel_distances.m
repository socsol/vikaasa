%% VK_KERNEL_DISTANCES Calculate distances between points in each dimension
%   Using a given rectangular constraint set and discretisation.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function distances = vk_kernel_distances(K, discretisation)
    distances = zeros(1, length(K)/2);
    for i = 1:length(K)/2
        distances(i) = (K(2*i) - K(2*i - 1)) ...
            / (discretisation(i)-1);
    end
end
