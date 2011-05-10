%% MAXIMUMCONTROL Apply maximum control.
%   This control rule simply returns the maximum control, regardless of
%   position, etc.
%
%   u = MAXIMUMCONTROL(x, constraint_set, delta_fn, controlmax)
%
% See also: CONTROLALGS/MINIMUMCONTROL, CONTROLALGS/ZEROCONTROL,
%   TOOLS/VK_VIABLE
function u = MaximumControl(x, constraint_set, delta_fn, controlmax, ...
    varargin)

    u = controlmax;
end