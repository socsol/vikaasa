%% VK_LOAD_PROJECT Load a project file and return it as a struct.
%   This function takes a project file, santitises it and returns the resulting
%   struct.
function proj = vk_load_project(filename)
    proj = vk_4dgui_state_sanitise(load(filename));
end
