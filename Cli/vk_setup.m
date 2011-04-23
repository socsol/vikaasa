%% VK_SETUP A script to set paths and 
cd ..
addpath(...
  pwd, ...
  fullfile(pwd, 'Gui'), ...
  fullfile(pwd, 'Tools'), ...
  fullfile(pwd, 'Scripts'), ...
  fullfile(pwd, 'ControlAlgs'), ...
  fullfile(pwd, 'VControlAlgs'));

disp('Commands');
disp('--------');
disp('');
disp('vk_view_kernel FILENAME -- Plot the kernel in FILENAME, according to the settings therein.');
disp('proj = vk_run FILENAME -- Compute the kernel in FILENAME');

% For use with bleeding-edge Octave.  Not in use for now.
%if (exist('graphics_toolkit'))
%    graphics_toolkit fltk;
%end
