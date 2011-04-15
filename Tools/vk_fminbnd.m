function min = vk_fminbnd(fn, minvar, maxvar, tolerance)
  minval = fn(maxvar);
  min = maxvar;
  for i = minvar:tolerance:maxvar
    f = fn(i);
    if (f < minval)
      minval = f;
      min = i;
    end
  end
