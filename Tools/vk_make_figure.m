function vk_make_figure(V, constraint_set, labels, colour, method, box, ...
    alpha_val, handle)
% vk_make_figure - This function plots a viability kernel.
%
%  - V: the complete viability kernel.
%  - handle: the handle to display the figure in.
  
  figure_name = 'Viability Kernel';
  
  figure(handle);
  title(figure_name);
  set(handle, 'Name', figure_name);  
  
  xlabel(labels(1, :));
  ylabel(labels(2, :));
  if (size(V, 2) == 2)
      vk_plot_area(V, colour, method, alpha_val);      
  elseif (size(V, 2) == 3)
      zlabel(labels(3, :));
      vk_plot_surface(V, colour, method, alpha_val);
      view(3);
      if (exist('camlight') && exist('lighting'))
          camlight;
          lighting gouraud;
      end
  end
  
  if (box)
      limits = vk_plot_box(constraint_set);
  else
      limits = constraint_set;
  end    
  
  vk_figure_data_insert(handle, limits, []);
  axis(limits);
end
