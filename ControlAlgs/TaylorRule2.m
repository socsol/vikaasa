%% TaylorRule2 Apply the taylor rule.
%   This function chooses a Taylor rule control.
%
%   u = TAYLORRULE(x, constraint_set, delta_fn, controlmax)
%
% See also: CONTROLALGS/MAXIMUMCONTROL, CONTROLALGS/MINIMUMCONTROL
function u = TaylorRule2(x, K, delta_fn, c, varargin)    

    % Whether to bound or not.  If not, then this control algorithm will
    % return values outside of [-c, c]
    bounded = 0;

    % Coefficients on pi and y
    a_pi = 1.5;
    a_y = 0.5;
    
    % Targets.  In steady state pi = i, so they should be the same. y_T = 0
    % because y represents the output gap.
    pi_T = 0;
    i_T = 0;
    y_T = 0;

    % State values are stored in the vector x.  We only take the first
    % three so that this algorithm works in both 3D and 4D.
    y = x(1); pi = x(2); i = x(3);   
        
    % Note that we subtract i, because u = idot \approx i_desired - i
    u = a_pi*(pi - pi_T) + a_y*(y - y_T) - i;
    
    % Bound if the 'bounded' option above is set to 'true'.
    if (bounded)
        if (u > c)
            u = c;
        elseif (u < -c)
            u = -c;
        end
    end
end