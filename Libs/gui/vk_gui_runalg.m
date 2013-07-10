%% VK_GUI_RUNALG Run a kernel computation algorithm from the gui
function vk_gui_runalg(compute_fn, hObject, eventdata, handles)

    %% Get the project.
    project = handles.project;


    %% Read settings from project.
    K = project.K;
    c = project.c;
    f = vk_diff_make_fn(project);


    %% Create a waitbar, if required.
    if (project.progressbar && ~project.use_parallel)
        wb_message = 'Determining viability kernel ...';
        wb = vk_gui_make_waitbar(wb_message);
        computations = prod(project.discretisation);
        options = vk_options_make(project, f, wb, computations, wb_message);
    else
        if (project.use_parallel)
            warning('Waitbar cannot be displayed when computing in parallel.');
            computations = prod(project.discretisation);
            progress_opts = {@(x) fprintf('%6.2f%% done\n', (x/computations)*100)};
        else
            progress_opts = {};
        end
        options = vk_options_make(project, f, progress_opts{:});
    end


    %% Display debugging information
    if (handles.project.debug)
        % Output the settings to the screen for debugging.
        K
        f
        c
        options
    end


    % Get the current window name.
    name = get(handles.figure1, 'Name');

    % If the name already contains some "- MESSAGE", get rid of it.
    pos = regexp(name, '\s-\s[A-Z\s]+$');
    if (~isempty(pos))
        name = name(1:pos(1)-1);
    end
    set(handles.figure1, 'Name', [name, ' - RUNNING ALGORITHM']);

    % Run the computation.
    cl = fix(clock);
    tic;
    fprintf('RUNNING ALGORITHM\n');
    success = 0; error = 0;
    try
        [V, NV, viable_paths, nonviable_paths] = compute_fn(K, f, c, options);

        if (options.cancel_test_fn())
            message_title = 'Kernel Computation Cancelled';
            message1 = 'Cancelled at ';
            message2 = '';
            fprintf('CANCELLED\n');
        else
            message_title = 'Kernel Computation Completed';
            message1 = 'Finished at ';
            message2 = '';
            fprintf('FINISHED\n');
            success = 1;
        end
    catch exception
        message_title = 'Kernel Computation Error';
        message1 = 'Error at ';
        message2 = ['Error message: ', exception.message];

        fprintf('ERROR: %s\n', exception.message);
        error = 1;
    end

    comp_time = toc;

    % Delete the progress bar, if there was one.
    if (project.progressbar && ~project.use_parallel)
        delete(wb);
    end

    % Save the results into our state structure if successful.
    if (success)
        handles.project.V = V;
        handles.project.viable_paths = viable_paths;
        handles.project.NV = NV;
        handles.project.nonviable_paths = nonviable_paths;
        handles.project.comp_time = comp_time;
        handles.project.comp_datetime = ...
            sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

        % If autosave is on, then save the result now.
        if (handles.project.autosave)
            filename = fullfile(handles.path, 'Projects', 'autosave.mat');
            if (vk_project_save(project, filename))
                message2 = ['Auto-Saved to ', filename];
            else
                message2 = ['Failed to auto-save to ', filename];
            end
        else
            message2 = '';
        end

        guidata(hObject, handles);
        set(handles.resultstable, 'Data', vk_kernel_results(handles.project));
    end

    % Remove 'RUNNING ALGORITHM' from the title.
    set(handles.figure1, 'Name', name);

    % Display a message.
    c2 = fix(clock);
    msgbox([message1, ...
        sprintf('%i-%i-%i %i:%i:%i', ...
            c2(1), c2(2), c2(3), c2(4), c2(5), c2(6)), ...
        '.  ', message2], ...
        message_title, 'none', 'modal');

    % If we are debugging, rethrow the error
    if (handles.project.debug && error)
        rethrow(exception);
    end
end