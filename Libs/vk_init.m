%% VK_INIT Initialise the VIKAASA environment

%% Info
vk_version = '0.10.1';
vk_copyright = 'Copyright (C) 2011 Jacek B. Krawczyk and Alastair Pharo';

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
