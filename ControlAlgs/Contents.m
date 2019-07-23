% CONTROLALGS Control Algorithms.
%   These are all functions of the form:
%
%   u = F(x, K, delta_fn, controlmax [, OPTIONS])
%
%   - The return value 'u' is a scalar, which should be in the range
%     [-controlmax, controlmax].  It represents the control choice of the
%     algorithm, at x.
%
%   - 'x' is a state-space point -- a column-vector of length, equal to the
%     number of dimensions of the viability problem.  For example, for a 3D
%     problem, x could be: [1; 2; 3].
%
%   - 'K' is a row vector of (min, max) pairs, representing the upper- and
%     lower-bounds of each variable in the state-space. Hence, the length
%     of K is twice the number of variables.  For instance, for a 2D
%     problem, K could be [-1, 1, 1, 3].
%
%   - 'delta_fn' is a function representing the differential equations of
%     the viability problem.  The function takes two inputs: x, u and
%     produces an output, xdot, representing the value of the system of
%     differential equations when evaluated at x, with a control of u
%     applied. .  x and xdot are column vectors of the same
%     length as the number dimensions of the viability problem.  u is a
%     scalar.
%
%   - controlmax represents the maximum absolute magnitude of u allowable.
%
%   - OPTIONS can be specified optionally.  It takes the form either of a
%     structure (as generated by TOOLS/VK_OPTIONS), or of a sequence of
%     ('name', value) pairs.
%
% See also: TOOLS/VK_COMPUTE, TOOLS/VK_OPTIONS, VCONTROLALGS
%
% Files
%   CostMin        - Apply the control that minimises the specified cost function.
%   CostSumMin     - Find the control which minimises the sum of costs
%   ManualControl  - Manually choose control from the command line
%   MaximumControl - Apply maximum control.
%   MinimumControl - Apply minimum control (i.e., -controlmax)
%   NormMin1Step   - Fast 1-step norm-minimising control function
%   ZeroControl    - Apply control of zero