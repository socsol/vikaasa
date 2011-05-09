%% VK_CONTROL_ENFORCE Simple function that makes sure that u is in [-c,c]
function u = vk_control_enforce(u, c)
    if (abs(u) > c)
        u = sign(u)*c;
    end
end

