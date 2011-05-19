%% VK_KERNEL_DELETE_RESULTS Delete the results of a kernel approximation from the project
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function project = vk_kernel_delete_results(project)
    project = rmfield(project, {'V', 'comp_datetime', 'comp_time'});
end
