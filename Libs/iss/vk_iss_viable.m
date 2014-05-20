function v = vk_iss_viable(u, x, t, conf)
  lower = conf.vk_K(1 : 2 : length(conf.vk_K));
  upper = conf.vk_K(2 : 2 : length(conf.vk_K));

  if conf.vk_opts.use_custom_constraint_set_fn
      vars = num2cell(x);
      ccsf = conf.vk_opts.custom_constraint_set_fn(vars{:});
  else
      ccsf = [];
  end

  % eps is used because of rounding issues.
  c = [lower - x - eps(x), x - upper - eps(x), ccsf];
  v = any(c > 0);
end