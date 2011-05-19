%% VK_CONTROL_ENFORCE Simple function that makes sure that u is in [-c,c]
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function u = vk_control_enforce(u, c)
    if (abs(u) > c)
        u = sign(u)*c;
    end
end

