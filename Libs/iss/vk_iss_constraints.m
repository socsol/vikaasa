%% This function needs to return hopefully negative numbers
function [c, ceq] = vk_iss_constraints(u,x,h,conf)
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
