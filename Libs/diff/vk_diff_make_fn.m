%% VK_DIFF_MAKE_FN Construct a MATLAB function from an array of strings
%   This function returns a function which returns the array of derviatives
%   for a given state-space point (represented as a column vector), and a
%   control choice (represented by a scalar).
%
% See also: CLI
function diff_fn = vk_diff_make_fn(project)
    symbols = project.symbols;
    controlsymbol = project.controlsymbol;
    diff_eqns = cellstr(project.diff_eqns);
    args = cellstr(symbols);
    
    %% Build a string that contains all of the equations
    % With semi-colons separating them
    inline_str = '[';
    for i = 1:size(diff_eqns,1)
        inline_str = [inline_str, diff_eqns{i}];
        if (i < size(diff_eqns,1))
            inline_str = [inline_str, ';'];
        else
            inline_str = [inline_str, ']'];
        end
    end

    %% Create an inline function.
    diff_inline = inline(inline_str, args{:}, controlsymbol);
    
    %% Create the array-based function
    diff_fn = @(x, u) vk_diff_fn(diff_inline, x, u);
end
