%% VK_KERNEL_RUN Run a kernel calculation from a file or structure.
%   This function takes as input a string representing the name of the
%   algorithm to run (either 'inclusion' or 'exclusion') and either a
%   filename containing a project, or a structure representing a
%   project, and runs the viability kernel calculation contained
%   within.  Then, it either returns the result, or saves it into a
%   file.
%
%   vk_kernel_run(ALG, FILENAME) Runs ALG on the project contained in
%   FILENAME, and when complete saves the result back into that file.
%
%   vk_kernel_run(ALG, FILE1, FILE2) Runs the project contained in
%   FILE1, and when complete, saves the result into FILE2.
%
%   proj2 = vk_kernel_run(ALG, PROJ1) Runs the project represented by
%   PROJ1 and returns a new structure.
%
% Examples
%   % Load a file into a structure
%   proj = vk_project_load('Projects/vikaasa_default.mat');
%   % Change some settings.
%   proj.controlalg = 'CostMin';
%   proj.steps = 2;
%   proj.use_controldefault = 1;
%   proj.controldefault = 0;
%   % Re-run the inclusion algorithm.
%   proj = vk_kernel_run('inclusion', proj);
%   % Save the result.
%   vk_project_save(project, 'Projects/newproject.mat');
%
% Requires: vk_diff_make_fn, vk_kernel_compute, vk_options, vk_options_make, vk_project_load
%
% See also: vikaasa_cli

%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function varargout = vk_kernel_run(alg, varargin)
    if (nargin < 2)
        error('You must specify at least two inputs.');
    end

    if ~strcmp(alg,'inclusion') && ~strcmp(alg, 'exclusion')
        error('The algorithm must be either "inclusion" or "exclusion".');
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
    if (project.progressbar)
        options = vk_options(K, f, c, options, ...
            'report_progress', 1, ...
            'progress_fn', @(x) fprintf('\r%6.2f%% done', (x/computations)*100));
    end


    %% determine the control algorithm
    if alg == 'inclusion'
      compute_fn = @vk_kernel_compute;
    else % exclusion
      compute_fn = @vk_iss_kernel_compute;
    end

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
    try
        [V, NV, viable_paths, nonviable_paths] = compute_fn(K, f, c, options);

        if (options.cancel_test_fn())
            fprintf('CANCELLED\n');
        else
            fprintf('FINISHED\n');
            success = 1;
        end
    catch
        exception = lasterror();
        error(exception);
        fprintf('ERROR: %s\n', exception.message);
        err = 1;
    end

    comp_time = toc;

    % Save the results into our state structure if successful.
    if (success)
        project.V = V;
        project.viable_paths = viable_paths;
        project.NV = NV;
        project.nonviable_paths = nonviable_paths;
        project.comp_time = comp_time;
        project.comp_datetime = ...
            sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

        if (nargin > 2)
            % If a separate file was specified, save to that.
            vk_project_save(project, varargin{2});
        elseif (nargout == 0 && ischar(varargin{1}))
            % Otherwise, if no other option was given, save back to the
            % original file.
            vk_project_save(project, varargin{1});
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
