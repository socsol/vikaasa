%% VK_NEW_PROJECT Creates a new project structure.
%   This function returns a newly initialised project structure.
function project = vk_new_project(varargin)
    project = struct(varargin{:});

    if (~isfield(project, 'numvars'))
        project.numvars = 2;
    end

    project = vk_project_sanitise(project);
end

