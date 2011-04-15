%% VK_SAVE_PROJECT Saves a project to a file.
function vk_save_project(proj, filename)
    save(filename, '-struct', 'proj', '-v7');
end
