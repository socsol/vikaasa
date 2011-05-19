%% VK_TIMEFORMAT Helper function that formats seconds into something human readable.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function formatted = vk_timeformat(seconds)
    if (seconds > 22896000)
        formatted = 'unknown time';
        return;
    elseif (seconds > 86400)
        denom = 86400;
        desc = ' days';
    elseif (seconds > 3600)
        denom = 3600;
        desc = ' hours';
    elseif (seconds > 60)
        denom = 60;
        desc = ' minutes';
    else
        denom = 1;
        desc = ' seconds';
    end

    formatted = sprintf('%.1f %s', seconds/denom, desc);
end
