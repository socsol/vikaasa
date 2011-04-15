%% MINIMUMCONTROL Apply minimum control (i.e., -controlmax)
%   This function returns the largest negative control available,
%   regardless of size.
%
%   u = MINIMUMCONTROL(x, constraint_set, delta_fn, controlmax)
%
% See also: CONTROLALGS/MAXIMUMCONTROL, CONTROLALGS/ZEROCONTROL,
%   TOOLS/VK_VIABLE
function u = MinimumControl(x, constraint_set, delta_fn, controlmax, ...
    varargin)
    
    u = -controlmax;
end