% VK_ISS_CONSTRAINTS Creates a constraint function suitable for InfSOCSol
%
% SYNOPSIS
%   This function massages VIKAASA's settings into a format that
%   can be fed into InfSOCSol as a constraint function.

%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function [c, ceq] = vk_iss_constraints(u,x,conf)
  h = conf.Options.TimeStep;
  next = x + h * conf.vk_f(x',u')';

  lower = conf.vk_K(1 : 2 : length(conf.vk_K));
  upper = conf.vk_K(2 : 2 : length(conf.vk_K));

  if conf.vk_opts.use_custom_constraint_set_fn
      vars = num2cell(next);
      ccsf = conf.vk_opts.custom_constraint_set_fn(vars{:});
  else
      ccsf = [];
  end

  ceq = [];
  c = [lower - next, next - upper, ccsf];
end
