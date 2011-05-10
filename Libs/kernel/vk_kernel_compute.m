%% VK_KERNEL_COMPUTE Compute a viability kernel using CELLFUN or PARCELLFUN
%   This function takes a constraint set, an array of differential
%   equations, and a maximum absolute control magnitude, and attempts to
%   compute an approximate viability kernel, by dividing the state-space
%   into a discretised set of points (according to the 'discretisation'
%   option specified in OPTIONS), and calling a viability-determination
%   algorithm (usually TOOLS/VK_VIABLE) against each point.  The default
%   discretisation is 10, which is thought to give a fairly good initial
%   indication.  Thus, for a 2D problem, VK_KERNEL_COMPUTE needs to make
%
%   In addition to the three arguments that this function accepts,
%   additional options can be passed in either as ('name', value) pairs, or
%   as a structure generated by TOOLS/VK_OPTIONS (See TOOLS/VK_OPTIONS for
%   a list of available options).
%
%   VK_KERNEL_COMPUTE makes use of CELLFUN by splitting the problem space into
%   discretisation-many sub-problems, which are then passed into CELLFUN.
%   This is useful because in GNU Octave  PARCELLFUN can be used as a
%   drop-in replacement for CELLFUN to simultaneously consider the
%   viability of multiple points, using parallel processing.  Which of
%   these functions is called can be altered by changing the 'cell_fn'
%   option (see TOOLS/VK_OPTIONS).
%
%   Standard way of calling:
%   V = VK_KERNEL_COMPUTE(K, diff_fn, c)
%
%       - K is the constraint set, a row vector twice as long as the number
%         of variables,
%
%   Passing in an options structure, constructed by VK_OPTIONS:
%   V = VK_KERNEL_COMPUTE(K, diff_fn, c, OPTIONS)
%
%   Using the default options, except for some specified here:
%   V = vk_compute(K, diff_fn, c, ...
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
%   Using an options structure, and modifying some parameters:
%   V = VK_KERNEL_COMPUTE(K, diff_fn, c, OPTIONS, ...
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
% Examples
%   % Compute a simple viability kernel
%   K = [0, 1, 0, 1]    % Two dimensions, each with the same upper and
%                       % lower bounds.
%   diff_fn = @(x, u) [1/2*x(1) + x(2)*u; u];
%   V = VK_KERNEL_COMPUTE(K, diff_fn, 0.001);
%
%   % Compute the same kernel with a higher discretisation
%   V = VK_KERNEL_COMPUTE(K, diff_fn, 0.001, 'discretisation', [50, 50]);
%
%   % Compute the same kernel again, but this time using PARCELLFUN
%   V = VK_KERNEL_COMPUTE(K, diff_fn, 0.001, ...
%       'discretisation, [50, 50], ...
%       'cell_fn', @(varargin) parcellfun(2, varargin{:}, 'UniformOutput', false));
%
% See also: CELLFUN, PARCELLFUN, TOOLS, OPTIONS/VK_OPTIONS, VIABLE/VK_VIABLE,
%   VIKAASA
function V = vk_kernel_compute(K, diff_fn, c, varargin)

    %% Build options.
    options = vk_options(K, diff_fn, c, varargin{:});

    %% These are the options that we are interested in.
    numvars = options.numvars;
    discretisation = options.discretisation;

    %% Create vectors of points for each dimension
    %   LINSPACE is used to accomplish this.  Discretisation in each dimension
    %   is potentially different.
    ax = cell(numvars, 1)
    for i = 1:numvars
        ax{i} = linspace(K(2*i - 1), ...
            K(2*i), discretisation(i));
    end

    %% Create a function for use with CELLFUN
    %   This function wraps the VK_KERNEL_COMPUTE_RECURSIVE helper function
    %   prepopulating all variables except for 'start' and 'posn'.  See
    %   VK_KERNEL_COMPUTE_RECURSIVE, below.
    fn = @(start, posn) vk_kernel_compute_recursive(...
        zeros(prod(discretisation(2:end)), numvars), start, 0, posn, ...
        ax(2:end), K, diff_fn, c, ...
        options);

    %% Create a cell of 'starts'.
    %   These are used by progress feedback functions to tell how far along the
    %   algorithm is.
    start_cells = cell(1, discretisation(1));
    for i = 1:discretisation(1)
        start_cells{i} = (i - 1) * (prod(discretisation(2:end));
    end

    %% Call CELLFUN or PARCELLFUN
    [V_cells,cnt_cells] = options.cell_fn(fn, start_cells, num2cell(ax{1}));


    %% Build the viability kernel from the results of the CELLFUN call
    V = zeros(sum(cell2mat(cnt_cells)), numvars);
    c = 0;
    for i = 1:discretisation(1)
        V(c+1:c+cnt_cells{i}, :) = V_cells{i}(1:cnt_cells{i},:);
        c = c + cnt_cells{i};
    end
end


%% VK_KERNEL_COMPUTE_RECURSIVE Recursive helper function for VK_KERNEL_COMPUTE
%   This is a recursive function that takes  calls a viability function on each
%   one.  It returns an untrucated list of viable points, along with a counter
%   of how many points in the list are viable (hence it is easy to truncate
%   this list as needed).
%
%
%
%   - 'start' indicates how many computations will have been undertaken
%     by the time that the sub-problem in question is called (assuming
%     that computation is not occuring in parallel).  This is used to
%     display progress information during computation.
%
%   - 'posn' is a (possibly partially constructed) point to consider.  In those
%     cases where posn is not fully constructed, points are taken from the ax
%     variable to produce points.
function [V, cnt] = vk_kernel_compute_recursive(V, start, cnt, posn, ax, ...
    K, diff_fn, c, options)

    cancel_test = options.cancel_test;
    discretisation = options.discretisaton;

    % More than one axis still under consideration -- call
    % vk_kernel_compute_recursive on the subset of points.
    if (length(ax) > 1)
        curr_ax = ax{1};
        for i = 1:length(curr_ax)
            if (cancel_test && options.cancel_test_fn())
                break;
            end

            s = start + (i-1) * prod(discretisation(length(posn)+2:end));
            [V,cnt] = vk_kernel_compute_recursive(V, s, cnt, ...
                [posn, curr_ax(i)], ax(2:end), K, diff_fn, c, options);
        end
    else % Only one axis remaining -- call options.viable_fn on each point.
        curr_ax = ax{1};
        for i = 1:length(curr_ax)
            if (cancel_test && options.cancel_test_fn())
                break;
            end

            x = transpose(horzcat(posn, curr_ax(i)));

            if (options.debug)
                disp(start + i);
                disp(transpose(x));
            end

            if (options.report_progress)
                options.progress_fn(start + i);
            end

            viable = options.viable_fn(x, K, f, c, options);

            if (viable)
                cnt = cnt + 1;
                V(cnt, :) = [posn, curr_ax(i)];
            end
        end
    end
end
