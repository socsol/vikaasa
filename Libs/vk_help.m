%% VK_HELP Display a help message.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo

cd ..
vk_readme = fileread('README');
if (size(vk_readme, 2) == 1)
    vk_readme = transpose(vk_readme);
end

disp(vk_readme);
