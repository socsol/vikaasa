function deltav = vk_delta_fn(diff_eqns, v, u)
  numvars = size(diff_eqns,1);
  deltav = zeros(numvars,1);
  args = num2cell(v);
  for i = 1:numvars
    deltav(i) = diff_eqns{i}(args{:}, u);
  end