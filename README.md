VIKAASA
=======

About
-----

VIKAASA provides a library of functions for GNU Octave or MATLAB(R)
for working with viability kernels, as well as a graphical user
interface for MATLAB(R).  For more information, see the manual.


Download
--------

A zip of the latest version of VIKAASA can be downloaded from
[the website][site].

[site]: http://socsol.github.io/vikaasa/


Starting VIKAASA
----------------

To launch VIKAASA run either `vikaasa` (for the GUI) or `vikaasa_cli`
(to initialise the library) from within MATLAB(R) or Octave.


Command-line examples
---------------------

~~~ matlab
% Loading a VIKAASA project:
project = vk_project_load('filename.mat');

% Projects are just structs, so you can alter them easily.
% To alter the discretisation of next kernel to run, and enable
% parallel processing:
proj.discretisation = [10; 12];
proj.use_parallel = 1;

% Compute a kernel using these settings, and store the result in a
% new project:
project2 = vk_kernel_run(project);

% View the kernel (according to the settings in the project):
vk_kernel_view(project2);

% Saving the project to a file:
vk_project_save(project2, 'filename.mat');
~~~


See also
--------

[The VIKAASA manual][manual] should be considered the most
authoritative document.  It should have been included with this
program.

Type `help <subject>` for any VIKAASA command from within Octave or
MATLAB(R), as well as any of the following:

`Libs`, `control`, `diff`, `figure`, `gui`, `kernel`, `options`,
`project`, `sim`, `test`, `viable`

VIKAASA depends on [InfSOCSol][iss] for some functionality.

[manual]: http://socsol.github.io/vikaasa/vikaasa_manual.pdf
[iss]: https://github.com/socsol/infsocsol


Copyright and licence
---------------------

Copyright 2019 Jacek B. Krawczyk and Alastair Pharo

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.
