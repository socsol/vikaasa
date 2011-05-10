%% VK_CELLFUN_PARFOR An implementation of CELLFUN that uses PARFOR
%   This is a MATLAB equivalent of parcellfun for GNU Octave.
%
% See also: CELLFUN, PARCELLFUN, PARFOR
function varargout = vk_cellfun_parfor(numprocs, fun, varargin)

    if (nargin < 3)
        error('There must be at least one cell as input');        
    end
    
    
    %% nret gives the number of return values to work with.
    if (nargout(fun) >= 1)
        nret = nargout(fun);
    else
        nret = nargout;
    end
    

    %% Work out what inputs are cell arrays.
    cells = cell(1, length(varargin));
    for i = 1:length(varargin)
        if (~iscell(varargin{i}))
            break;
        end
        
        cells{i} = varargin{i};
    end    
    
    %% Any remaining inputs should be name:value pairs.    
    if (i < length(varargin))
        cells = cells(1:i-1);
        options = struct(varargin{i:end});
    else
        options = struct();
    end
        
    %% Check that all the cell arrays have the same size (if there's more than one).
    if (length(cells) > 1)
        chksize = size(cells{1});
        checks = cellfun(@(x) all(size(x) == chksize), cells(2:end));
        if (~all(checks))
            error('All cell arrays must have the same dimensions.');
        end
    end
       
    %% Create the return cell array.
    varargout = cell(nret,1);
    for v = 1:nret
        if (~isfield(options, 'UniformOutput') || options.UniformOutput)
            varargout{v} = zeros(size(cells{1}));
        else
            varargout{v} = cell(size(cells{1}));
        end
    end
    
    %% Construct argument arrays for each function call.
    args = cell(length(cells{1}),length(cells));
    for i = 1:length(cells{1})                       
        for j = 1:length(cells)
            c = cells{j};
            args(i,j) = c(i);
        end
    end
    
    %% Start the pool
    matlabpool(numprocs);
        
    %% Make the function calls in parallel.
    try
        ret = cell(size(cells{1}));
        parfor i = 1:length(cells{1})
            r = cell(1, nret);
            [r{:}] = fun(args{i,:});
            ret{i} = r;
        end
    catch exception
        matlabpool close;
        rethrow(exception); 
    end
    
    %% Close the pool
    matlabpool close;

    %% Distribute the function call results (not in parallel).
    for i = 1:length(cells{1})        
        r = ret{i};
        for v = 1:nret            
            if (~isfield(options, 'UniformOutput') || options.UniformOutput)            
                % Retrieve the v-th return array
                arr = varargout{v};
                % Update the i-th element
                arr(i) = r{v};
                % Set the v-th array to reflect the update
                varargout{v} = arr;
            else
                % Retrieve the v-th return cell
                c = varargout{v};
                % Update the i-th element
                c{i} = r{v};
                % Set the v-th cell to reflect the update
                varargout{v} = c;
            end
        end
    end
end

