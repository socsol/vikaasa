function u = FisheriesControl(x, K, f, c, varargin)
    %% Extract information from the state-space vector:
    b = x(1);
    e = x(2);

    %% Define our upper and lower bounds for e:
    e_upper = 0.7;
    e_lower = 0.1;

    %% Determine the control to use.
    %   Note that we are calling ZeroControl, MaximumControl and
    %   MinimumControl, purely to demonstrate how you can chain existing
    %   control algorithms into your custom ones.  We coul just as well use
    %   '0', '-c' and 'c' ourselves.
    if (e > 0.7)
        u = MinimumControl(x, K, f, c, varargin{:});
    elseif (e < 0.1)
        u = MaximumControl(x, K, f, c, varargin{:});
    else
        u = ZeroControl(x, K, f, c, varargin{:});
    end
end
