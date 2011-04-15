%% MANUALCONTROL Manually choose control from the command line
%   This function allows the user to manually specify control at each
%   position, and also allows the user to test different possible control
%   paths.
%
%   u = MANUALCONTROL(x, constraint_set, delta_fn, controlmax)
%
%   u = MANUALCONTROL(x, constraint_set, delta_fn, controlmax, OPTIONS)
%   where OPTIONS is either a structure created by TOOLS/VK_OPTIONS, or
%   otherwise a series of 'name', value pairs.
%
% See also: TOOLS/VK_OPTIONS
function u = ManualControl(x, constraint_set, delta_fn, controlmax, varargin)

    options = vk_options(constraint_set, delta_fn, controlmax, varargin{:});

    % States
    % ------
    % 1: Main menu
    % 2: Test a control
    % 3: Choose a control
    state = 1; % Start at main menu.
    exit = 0;
    
    % Used to test.
    testcontrol = controlmax;
    testiterations = 1;
    testadjust = 1;
    
    % Used to actually iterate.
    control = controlmax;
    adjust = 1;
    
    fprintf('Current position: %s\n\n', num2str(transpose(x)));
    while (~exit)        
        fprintf('\n');
        switch state
            case 1                                
                fprintf('-----------------------------\n');
                fprintf('          Main Menu\n');
                fprintf('-----------------------------\n');
                fprintf('1. Test a control choice\n');
                fprintf('2. Choose a control\n');
                fprintf('3. Abort\n');
                fprintf('-----------------------------\n');
            case 2
                fprintf('-----------------------------\n');
                fprintf('     Test a control choice\n');
                fprintf('-----------------------------\n');
                fprintf('1. Control to test: %f\n', testcontrol);
                fprintf('2. Number of iterations: %i\n', testiterations);
                fprintf('3. Auto-adjust at boundary: %i\n', testadjust);
                fprintf('4. Go\n');
                fprintf('-----------------------------\n');
            case 3
                fprintf('-----------------------------\n');
                fprintf('       Choose a control\n');
                fprintf('-----------------------------\n');
                fprintf('1. Control choice: %f\n', control);
                fprintf('2. Auto-adjust: %i\n', adjust);
                fprintf('3. Go\n');
                fprintf('-----------------------------\n');
            otherwise
                fprintf('ERROR\n');
        end
        fprintf('\n');
    
        line = '';
        unknown = 0;
        while (strcmp(line, ''))
            line = input('>', 's');
        end
        choice = str2double(line);
        
        switch state            
            case 1 % MAIN MENU
                choice = str2double(line);
                switch choice
                    case 1 % Test a control
                        state = 2;
                    case 2 % Choose a control
                        state = 3;
                    case 3 % Abort
                        exit = 1;
                    otherwise
                        unknown = 1;
                end
            case 2 % TEST A CONTROL
                choice = str2double(line);
                switch choice
                    case 1 % Control to test
                        testcontrol = str2double(input('>>', 's'));
                        if (testcontrol > controlmax ...
                            || testcontrol < -controlmax)
                            fprintf('The control you chose is out of bounds.\n');
                            testcontrol = controlmax;
                        end
                    case 2 % Number of iterations
                        testiterations = round(str2double(input('>>', 's')));
                        if (testiterations < 1)
                            fprintf('The iteration-count must be 1 or greater.\n')
                            testiterations = 1;
                        end
                    case 3 % Auto-adjust
                        testadjust = ~testadjust;
                    case 4 % Go
                        vk_manualcontrol_test(...
                            x, constraint_set, delta_fn, controlmax, options, ...
                            testcontrol, testiterations, testadjust);
                    otherwise
                        unknown = 1;
                end
            case 3 % CHOOSE A CONTROL
            otherwise
                exit = 1;
        end
        
        if (unkown)
            fprintf('Unknown command.\n');
        end
    end
    
    u = control;
end

