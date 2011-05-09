%% Helper function that formatting seconds into something human readable.
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
