%% VK_RUN Run a kernel calculation from a file or structure.
%   This function takes as input either a filename containing a project, or a
%   structure representing a project, and runs the viability kernel calculation
%   contained within.  Then, it either returns the result, or saves it into a
%   file.
%
%   VK_RUN(FILENAME)  Runs the project contained in FILENAME, and when complete
%   saves the result back into that file.
%
%   VK_RUN(FILE1, FILE2) Runs the project contained in FILE1, and when complete,
%   saves the result into FILE2.
%
%   PROJ2 = VK_RUN(PROJ1) Runs the project represented by PROJ1 and returns a
%   new structure.
%
% Examples
%   % Load a file into a structure
%   proj = load('Projects/vikaasa_default.mat');
%   % Change some settings.
%   proj.controlalg = 'CostMin';
%   proj.steps = 2;
%   proj.use_controldefault = 1;
%   proj.controldefault = 0;
%   % Re-run the kernel.
%   proj = vk_run(proj);
%   % Save the result.
%   save('Projects/newproject.mat', '-struct', 'proj');
%
% See also: VIKAASA, TOOLS, SCRIPTS, VK_VIEW_KERNEL
function varargout = vk_run(varargin)
    if (nargin == 0)
        error('You must specify at least one input.');
    end

    if (ischar(varargin{1}))
        vk_state = load(varargin{1});
    else
        vk_state = varargin{1};
    end

    %% Read settings from vk_state.
    constraint_set = vk_state.constraint_set;
    controlmax = vk_state.controlmax;
    delta_fn = vk_4dgui_make_delta_fn(0, struct('vk_state', vk_state));
    
    %% Create options.
    options = vk_4dgui_make_options(0, struct('vk_state', vk_state), delta_fn);
    computations = vk_state.discretisation ...
        ^ (length(vk_state.constraint_set) / 2);
    options = vk_options(constraint_set, delta_fn, controlmax, options, ...
        'report_progress', 1, ...
        'progress_fn', @(x) fprintf('%6.2f%% done\r', (x/computations)*100));

    %% Use parcellfun if available.
    if (exist('parcellfun'))
        cell_fn = @(varargin) parcellfun(2, varargin{:}, 'UniformOutput', false);
        options = vk_options(constraint_set, delta_fn, controlmax, options, ...
            'cell_fn', cell_fn);
    end

    %% Display debugging information
    if (vk_state.debug)
        % Output the settings to the screen for debugging.
        constraint_set
        delta_fn
        controlmax
        options        
    end

    % Run the computation.
    c = fix(clock);
    tic;    
    fprintf('RUNNING ALGORITHM\n');
    success = 0; err = 0;
    try
        V = vk_compute(constraint_set, delta_fn, controlmax, options);
        
        if (options.cancel_test_fn())            
            fprintf('CANCELLED\n');
        else            
            fprintf('FINISHED\n');
            success = 1;
        end        
    catch
        exception = lasterror();
        fprintf('ERROR: %s\n', exception.message);
        err = 1;
    end
    
    comp_time = toc;
    
    % Save the results into our state structure if successful.
    if (success)
        vk_state.V = V;
        vk_state.comp_time = comp_time;
        vk_state.comp_datetime = ...
            sprintf('%i-%i-%i %i:%i:%i', c(1), c(2), c(3), c(4), c(5), c(6));

        if (nargin > 1)
            % If a separate file was specified, save to that.
            save(varargin{2}, '-struct', 'vk_state');
        elseif (nargout == 0 && isschar(varargin{1}))
            % Otherwise, if no other option was given, save back to the
            % original file. 
            save(varargin{1}, '-struct', 'vk_state');
        end

        % If a return is expected, give back the structure.
        if (nargout > 0)
            varargout{1} = vk_state;
        end
    end
   
    % If we are debugging, rethrow the error
    if (vk_state.debug && err)
        rethrow(exception);
    end
end
