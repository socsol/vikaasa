%% VK_EVAL_CONTROL_FN Returns a handle to a control function from a given string
%   Control functions can two signatures.  Either they take 
function control_fn = vk_eval_control_fn(fn_name, varargin)
    % Test for the existence of the function.  If it does not exist, attempt
    % to display an error.
    if (~exist(fn_name, 'file'))
        vk_error(['The function "', fn_name, '" does not exist.  You will need to specify another control algorithm.']);
    end

    %% Determine the type of the control algorithm
    %   Either: 'ControlAlg' for a normal control algorithm, or 'VControlAlg'
    %   if it is a control algorithm that requires knowledge of the viability
    %   kernel.
    type = '';

    if (exist('file_in_loadpath') == 5)
        %% In Octave, this command exists.
        fileandpath = file_in_loadpath([fn_name, '.m']);
    else
        %% In MATLAB, we use 'which'
        fileandpath = which(fn_name);
    end

    [pathstr, file, ext] = fileparts(fileandpath);
    if (~isempty(findstr(pathstr, 'VControlAlgs')))
        type = 'VControlAlg';
    else
        type = 'ControlAlg';
    end

    % If the function is a VControlAlg, then an info struct needs to have been
    % passed as a second argument.
    if (strcmp(type, 'VControlAlg') && nargin < 2)
        vk_error('This is control algorithm requires knowledge of the viability kernel.  You need to pass an "info" structure to vk_make_control_fn.');
    end

    %% Create the function.
    fn = eval(['@', fn_name]);

    %% Wrap the function if it is a VControlAlg.
    if (strcmp(type, 'VControlAlg'))
        info = varargin{1};
        
        control_fn = @(x, K, f, c, varargin) fn(info, x, K, f, c, varargin{:});
    else
        control_fn = fn;
    end
end
