%% VK_FMINBND
%   A naive (slow) minimisation function.  Better to use the real fminbnd.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
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
