%% VK_CONTROL_WRAP_FN Wrap a control algorithm with bounding code, etc.
%   This function wraps the result of a control choice in up to two
%   functions.  Firsltly, if enforcement of the control range is in place,
%   then the outcome of calling the 
function fn = vk_control_wrap_fn(control_fn, K, f, c, varargin)

    %% Create options structure
    options = vk_options(K, f, c, varargin{:});
    
    %% Options we arre concerned with:
    bound_fn = options.bound_fn;
    enforce_fn = options.enforce_fn;
    controlenforce = options.controlenforce;    
          
    if (controlenforce)
        fn = @(x) bound_fn(x, ...
            enforce_fn(control_fn(x, K, f, c, options), c), ...
            K, f, c, options);        
    else      
        fn = @(x) bound_fn(x, ...
        	control_fn(x, K, f, c, options), K, f, c, options);
    end
end

