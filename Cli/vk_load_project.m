%% VK_LOAD_PROJECT Loads a file and returns a project structure
%   Performs checks to see if the file is in the old format.  If it is,
%   then it is converted.
function project = vk_load_project(File)        
    if exist(File,'file') == 2
        
        %% Load the file if it exists.
        contents = load(File);
        
        if (isfield(contents, 'dispgrid'))
            %% Old file
            fprintf('Old file detected -- converting.\n');
            project = struct;
                        
            project.vardata = { ...
                'output gap', 'x', contents.xmin, contents.xmax, contents.fnx; ...
                'inflation', 'y', contents.ymin, contents.ymax, contents.fny; ...                
                'interest rate', 'z', contents.zmin, contents.zmax, 'u'};
            
            
            if (ndims(contents.dispgrid) == 4)
                %% 4D Case
                project.vardata = vertcat( ...
                    project.vardata, ...
                    {'exchange rate', 'q', contents.qmin, contents.qmax, contents.fnq} ...
                );
                project.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax, contents.qax}, ...
                  contents.dispgrid);
                project.diff_eqn = char(contents.fnx, contents.fny, contents.fnq);
                project.constraint_set = [contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax, ...
                    contents.qmin, contents.qmax];
                project.symbols = char('x', 'y', 'z', 'q');
                project.labels = char('output gap', 'inflation', ...
                    'interest rate', 'exchange rate');
                project.slice1plane = [-0.012, 0.017, 0.0245, 0];
                project.slice2plane = [-0.012, 0.017, 0.0245, 0];
            else 
                %% 3D case
                project.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax}, ...
                  contents.dispgrid);
                project.diff_eqn = char(contents.fnx, contents.fny);
                project.constraint_set = [contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax];
                project.symbols = char('x', 'y', 'z');
                project.labels = char('output gap', 'inflation', ...
                    'interest rate');
                project.slice1plane = [-0.012, 0.017, 0.0245];
                project.slice2plane = [-0.012, 0.017, 0.0245];
            end                                        

            project.controlmax = 0.005;
            project.numslices = 1;
            project.slice1 = 1;
            project.slice2 = 2;

            project.discretisation = contents.discret;
        else
            %% New file
            project = contents;
        end
           
        %% Repair any problems with the file.
        project = vk_project_sanitise(project);
    else
        errordlg(['Could not find file: ', File]);
    end
end