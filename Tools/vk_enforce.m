%% VK_ENFORCE Simple function that makes sure that u is in [-c,c]
function u = vk_enforce(u, c)
    if (u > c)
        u = c;
    elseif (u < -c)
        u = -c;
    end
end

