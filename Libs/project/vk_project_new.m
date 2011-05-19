%% VK_PROJECT_NEW Creates a new project structure.
%   This function returns a newly initialised project structure.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function project = vk_project_new(varargin)
    project = struct(varargin{:});

    if (~isfield(project, 'numvars'))
        project.numvars = 2;
    end

    project = vk_project_sanitise(project);
end

