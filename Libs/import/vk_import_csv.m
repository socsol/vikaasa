%% VK_IMPORT_CSV Imports a CSV file containing a viability kernel into VIKAASA.
%
% SYNOPSIS
%   Given some filename containing row-wise listing of the discrete coordinates of a viability kernel, VIKAASA will attempt to read in the file, creating a matrix like the ones used by VIKAASA.  This matrix is then either added to an existing project if one is specified, or otherwise returned in a vanilla project.

%%
%  Copyright 2012 Jacek B. Krawczyk and Alastair Pharo
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
function project = vk_import_csv(filename, varargin)
  try
    csv = csvread(filename);
  catch
    % Try reading all but the first row if there is an error.
    csv = csvread(filename, 1, 0);
  end

  if nargin > 1
    % Attach it to the existing project.
    project = varargin{1};
    project.V = csv;
    project = vk_project_sanitise(project);
  else
    % Return a bare-bones project.
    project = vk_project_new('V', csv, 'numfields', size(csv, 2));
  end
end
