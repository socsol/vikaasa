%% VK_LOAD_PROJECT Loads a file and returns a project structure
%   Performs checks to see if the file is in the old format.  If it is,
%   then it is converted.
function project = vk_load_project(File)
    if (exist(File,'file') == 2)
        
        %% Load the file if it exists.
        contents = load(File);
        
        if (isfield(contents, 'dispgrid'))
            %% Old file
            fprintf('Old file detected -- converting.\n');
            project = struct(...
              'labels', char('output gap', 'inflation', 'interest rate', 'exchange rate'), ...
              'symbols', char('x', 'y', 'z', 'q'), ...
              'discretisation', contents.discret*ones(4, 1) ...
            );
            
            if (ndims(contents.dispgrid) == 4)
                %% 4D Case
                project.K = [ ...
                    contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax, ...
                    contents.qmin, contents.qmax];
                project.diff_eqns = char(contents.fnx, contents.fny, 'u', contents.fnq); 
                project.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax, contents.qax}, ...
                  contents.dispgrid);
            else 
                %% 3D case
                project.K = [...
                    contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax];
                project.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax}, ...
                  contents.dispgrid);
                project.diff_eqns = char(contents.fnx, contents.fny, 'u');
            end                                        
        else
            %% New file
            project = contents;
        end
           
        %% Repair any problems with the file.
        project = vk_project_sanitise(project);
    else
        vk_error(['Could not find file: ', File]);
    end
end