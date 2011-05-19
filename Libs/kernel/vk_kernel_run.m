%% VK_KERNEL_RUN Run a kernel calculation from a file or structure.
%   This function takes as input either a filename containing a project, or a
%   structure representing a project, and runs the viability kernel calculation
%   contained within.  Then, it either returns the result, or saves it into a
%   file.
%
%   VK_KERNEL_RUN(FILENAME)  Runs the project contained in FILENAME, and when
%   complete saves the result back into that file.
%
%   VK_KERNEL_RUN(FILE1, FILE2) Runs the project contained in FILE1, and when
%   complete, saves the result into FILE2.
%
%   PROJ2 = VK_KERNEL_RUN(PROJ1) Runs the project represented by PROJ1 and
%   returns a new structure.
%
% Examples
%   % Load a file into a structure
%   proj = vk_project_load('Projects/vikaasa_default.mat');
%   % Change some settings.
%   proj.controlalg = 'CostMin';
%   proj.steps = 2;
%   proj.use_controldefault = 1;
%   proj.controldefault = 0;
%   % Re-run the kernel.
%   proj = vk_kernel_run(proj);
%   % Save the result.
%   vk_project_save(project, 'Projects/newproject.mat');
%
% See also: VIKAASA_CLI, KERNEL, PROJECT, VK_KERNEL_COMPUTE
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function varargout = vk_kernel_run(varargin)
    if (nargin == 0)
        error('You must specify at least one input.');
    end

    if (ischar(varargin{1}))
        project = vk_project_load(varargin{1});
    else
        project = varargin{1};
    end

    %% Read settings from project.
    K = project.K;
    c = project.c;
    f = vk_diff_make_fn(project);
    
    %% Create options.
    options = vk_options_make(project, f);
    computations = prod(project.discretisation);
    options = vk_options(K, f, c, options, ...
        'report_progress', 1, ...
        'progress_fn', @(x) fprintf('\r%6.2f%% done', (x/computations)*100));

    %% Display debugging information
    if (project.debug)
        % Output the settings to the screen for debugging.
        K
        f
        c
        options        
    end

    % Run the computation.
    cl = fix(clock);
    tic;    
    fprintf('RUNNING ALGORITHM\n');
    success = 0; err = 0;
    %try
        V = vk_kernel_compute(K, f, c, options);
        
        if (options.cancel_test_fn())            
            fprintf('CANCELLED\n');
        else            
            fprintf('FINISHED\n');
            success = 1;
        end        
    %catch
    %    exception = lasterror();
    %    error(exception);
    %    fprintf('ERROR: %s\n', exception.message);
    %    err = 1;
    %end
    
    comp_time = toc;
    
    % Save the results into our state structure if successful.
    if (success)
        project.V = V;
        project.comp_time = comp_time;
        project.comp_datetime = ...
            sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

        if (nargin > 1)
            % If a separate file was specified, save to that.
            save(varargin{2}, '-struct', 'project');
        elseif (nargout == 0 && ischar(varargin{1}))
            % Otherwise, if no other option was given, save back to the
            % original file. 
            save(varargin{1}, '-struct', 'project');
        end

        % If a return is expected, give back the structure.
        if (nargout > 0)
            varargout{1} = project;
        end
    end
   
    % If we are debugging, rethrow the error
    if (project.debug && err)
        rethrow(exception);
    end
end
