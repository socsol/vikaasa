% TOOLS The VIKAASA
%
% See also: VIKAASA
%
% Files
%   vk_compare                        - Returns the difference in elements between two kernels, as a pair
%   vk_compare_files                  - 
%   vk_compute                        - This function computes the viability kernel of the problem represented
%   vk_compute_recursive              - This is a recursive function that iterates over all the given axes and
%   vk_compute_redo3d29jul            - vk_compute_redo3d29jul.m -- function for computing viability kernel.
%   vk_compute_redo3d29jul_new        - vk_compute_redo3d29jul.m -- function for computing viability kernel.
%   vk_compute_redo4d28aug            - vk_compute_redo4d28aug.m -- Mark's 4D viability kernel calculation
%   vk_compute_redo4d28aug_new        - vk_compute_redo4d28aug.m -- Mark's 4D viability kernel calculation
%   vk_convert                        - vk_convert(axes, dispgrid)
%   vk_cornersoln                     - Bound 
%   vk_cost_fn                        - compose cost functions of x, xdot 
%   vk_delta_fn                       - 
%   vk_distance_fn                    - Helper function that works out the distance of one element of our
%   vk_eval_fn                        - 
%   vk_exited                         - This function returns a list of axes on which the point has violated
%   vk_figure_data_insert             - Create a rectangular set of cells.
%   vk_figure_data_retrieve           - 
%   vk_first                          - 
%   vk_fminbnd                        - 
%   vk_inkernel                       - Whether the point x is within the (assumed convex) viability kernel V.
%   vk_load_redo3d29jul               - vk_load_redo3d29jul.m
%   vk_make_figure                    - vk_make_figure - This function plots a viability kernel.
%   vk_make_figure_slice              - vk_make_figure_slice - This function slices a viability kernel any number
%   vk_make_simulation                - This function creates a simulation object, which can be used to view the
%   vk_neighbours                     - We go through the kernel, looking for all points that are leq than
%   vk_ode_outputfcn                  - Report progress, unless this is the 'init' call.
%   vk_options                        - Create an options structure for use with VIKAASA toolbox.
%   vk_plot_area                      - vk_plot_area.m -- plots a 2D filled (yellow) area.
%   vk_plot_box                       - This function boxes the given figure according to the constraint set.  If
%   vk_plot_path                      - 
%   vk_plot_path_limits               - 
%   vk_plot_surface                   - vk_plot_surface.m
%   vk_simulate_euler                 - Create a simulation using the Euler method.
%   vk_simulate_ode                   - Create a simulation using ODE method.
%   vk_slice                          - vk_slice.m
%   vk_viable                         - Determines viability of a point.
%   vk_viable_ode                     - Determines viability of a point.
%   vk_viable_redo3d29jul             - 
%   vk_viable_redo4d28aug             - 
%   vk_viable_redo4d28aug_interactive - 
%   vk_wnorm                          - 
