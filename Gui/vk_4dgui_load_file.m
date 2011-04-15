% --- This function is for loading a file into the new interface.
function handles = vk_4dgui_load_file(hObject, handles, File)        
    if exist(File,'file') == 2
        contents = load(File);
        
        if (isfield(contents, 'dispgrid'))
            fprintf('Old file detected -- converting.\n');
            vk_state = struct;
                        
            vk_state.vardata = { ...
                'output gap', 'x', contents.xmin, contents.xmax, contents.fnx; ...
                'inflation', 'y', contents.ymin, contents.ymax, contents.fny; ...                
                'interest rate', 'z', contents.zmin, contents.zmax, 'u'};
            
            % 4D Case
            if (ndims(contents.dispgrid) == 4)
                vk_state.vardata = vertcat( ...
                    vk_state.vardata, ...
                    {'exchange rate', 'q', contents.qmin, contents.qmax, contents.fnq} ...
                );
                vk_state.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax, contents.qax}, ...
                  contents.dispgrid);
                vk_state.diff_eqn = char(contents.fnx, contents.fny, contents.fnq);
                vk_state.constraint_set = [contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax, ...
                    contents.qmin, contents.qmax];
                vk_state.symbols = char('x', 'y', 'z', 'q');
                vk_state.labels = char('output gap', 'inflation', ...
                    'interest rate', 'exchange rate');
                vk_state.slice1plane = [-0.012, 0.017, 0.0245, 0];
                vk_state.slice2plane = [-0.012, 0.017, 0.0245, 0];
            else % 3D case
                vk_state.V = vk_convert( ...
                  {contents.xax, contents.yax, contents.zax}, ...
                  contents.dispgrid);
                vk_state.diff_eqn = char(contents.fnx, contents.fny);
                vk_state.constraint_set = [contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax];
                vk_state.symbols = char('x', 'y', 'z');
                vk_state.labels = char('output gap', 'inflation', ...
                    'interest rate');
                vk_state.slice1plane = [-0.012, 0.017, 0.0245];
                vk_state.slice2plane = [-0.012, 0.017, 0.0245];
            end                                        

            vk_state.controlmax = 0.005;
            vk_state.numslices = 1;
            vk_state.slice1 = 1;
            vk_state.slice2 = 2;

            vk_state.discretisation = contents.discret;
                        
            handles = vk_4dgui_set_state(vk_state, hObject, handles);
        else
            handles = vk_4dgui_set_state(contents, hObject, handles);
        end
                        
        handles.filename = File;
        set(handles.save_menu, 'Enable', 'on');
        [unused, filename, fileext, unused] = fileparts(File);
        set(handles.filename_label, 'String', [filename, fileext]);
        guidata(hObject, handles);        
    else
        errordlg(['Could not find file: ', File]);
    end