function project = vk_sim_timeprofiles_from(project, start)
  project.sim_start = start;
  project.sim_state = vk_sim_make(project);
  vk_figure_timeprofiles_make(project);
end
