%% VK_INIT Initialise the VIKAASA environment
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo

%% Info
vk_version = '0.10.3';
vk_copyright = fileread('../NOTICE');
if (size(vk_copyright, 2) == 1)
    vk_copyright = transpose(vk_copyright);
end

%% Paths
cd ..
addpath(...
  pwd, ...
  fullfile(pwd, 'Libs'), ...
  fullfile(pwd, 'ControlAlgs'), ...
  fullfile(pwd, 'VControlAlgs'));

libs = dir(fullfile(pwd, 'Libs'));
for i = 1:length(libs)
    if (libs(i).isdir && ~strcmp(libs(i).name(1), '.'))
        addpath(fullfile(pwd, 'Libs', libs(i).name));
    end
end
