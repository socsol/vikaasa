%% ZEROCONTROL Apply control of zero
%   This function chooses a control of zero every time.
%
%   u = ZEROCONTROL(x, constraint_set, delta_fn, controlmax)
%
% See also: CONTROLALGS/MAXIMUMCONTROL, CONTROLALGS/MINIMUMCONTROL
function u = ZeroControl(x, constraint_set, delta_fn, controlmax, varargin)    
    u = 0;
end