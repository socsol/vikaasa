%% VK_HELP Display a help message. Type `vk_help' to see the message.

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

cd ..
vikaasa_readme = fileread('README');
if (size(vikaasa_readme, 2) == 1)
    vikaasa_readme = transpose(vikaasa_readme);
end

disp(vikaasa_readme);