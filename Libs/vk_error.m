%% VK_ERROR Display an error using either ERRORDLG or ERROR
function vk_error(message)
    if (exist('errordlg'))
        errordlg(message);
    end

    error(message);
end
