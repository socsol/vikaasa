%% CONTROL The VIKAASA control algorithm library
%   This library contains functions for working with control algorithms in
%   VIKAASA.
%
% Functions:
%   vk_control_bound          Used to limit control function choices close to
%                             the kernel bounds.  This may lead the control
%                             algorithm to be more successful in some cases.
%
%   vk_control_cost_fn        Used to transform cost functions that take named
%                             parameters into cost functions that accept
%                             vectors, suitable for use with a cost-minimising
%                             control function.
%
%   vk_control_enforce        Used to limit a control function to prevent it
%                             from choosing controls outside of the [-c, c]
%                             range.
%
%   vk_control_make_fn        Used to construct a function handle for a control
%                             algorithm from a string giving the algorithm's
%                             name.
%
%   vk_control_wrap_fn        Returns a function handle wrapped with calls to
%                             vk_control_enforce and/or vk_control_bound.
