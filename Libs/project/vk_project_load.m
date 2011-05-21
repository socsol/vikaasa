%% VK_PROJECT_LOAD Loads a file and returns a project structure
%   Performs checks to see if the file is in the old format.  If it is,
%   then it is converted.
%

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function project = vk_project_load(File)
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
                project.V = vk_kernel_convert( ...
                  {contents.xax, contents.yax, contents.zax, contents.qax}, ...
                  contents.dispgrid);
            else
                %% 3D case
                project.K = [...
                    contents.xmin, contents.xmax, ...
                    contents.ymin, contents.ymax, ...
                    contents.zmin, contents.zmax];
                project.V = vk_kernel_convert( ...
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
