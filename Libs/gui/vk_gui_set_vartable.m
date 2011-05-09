%% VK_GUI_SET_VARTABLE Update the vartable to reflect the project
%
% See also: VIKAASA
function handles = vk_gui_set_vartable(hObject, handles)
    project = handles.project;

    vartable = cell(project.numvars, 6);

    vartable(:, 1) = project.labels;
    vartable(:, 2) = project.symbols;
    vartable(:, 5) = num2cell(project.discretisation);
    vartable(:, 6) = project.diff_eqns;

    for i = 1:project.numvars
        vartable(i, 3:4) = num2cell(project.K(2*i-1:2*i));
    end

    set(handles.vartable, 'Data', vartable);
end
