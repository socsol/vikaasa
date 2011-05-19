%% VK_FIGURE_MAKE Plots a viability kernel.
%
%   VK_FIGURE_MAKE(V, K, labels, colour, method, box, alpha_val, handle)
%
%   - V: The complete viability kernel.
%   - K: The constraint set
%   - labels: Labels for the axes
%   - colour: The colour to draw th kernel
%   - method: The method for drawing the kernel
%   - box: Whether or not to draw a box around the kernel
%   - alpha_val: The degree of transparency
%   - handle: the handle to display the figure in.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function vk_figure_make(V, K, labels, colour, method, box, ...
    alpha_val, handle)
  
  figure_name = 'Viability Kernel';
  
  figure(handle);
  title(figure_name);
  set(handle, 'Name', figure_name);  
  
  xlabel(labels{1});
  ylabel(labels{2});
  if (size(V, 2) == 2)
      vk_figure_plot_area(V, colour, method, alpha_val);      
  elseif (size(V, 2) == 3)
      zlabel(labels{3});
      vk_figure_plot_surface(V, colour, method, alpha_val);
      view(3);
  end
  
  if (box)
      limits = vk_figure_plot_box(K);
  else
      limits = K;
  end    
  
  vk_figure_data_insert(handle, limits, []);
  axis(limits);
end
