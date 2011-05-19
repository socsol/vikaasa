%% VK_ERROR Display an error using either ERRORDLG or ERROR
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function vk_error(message)
    if (exist('errordlg'))
        errordlg(message);
    end

    error(message);
end
