function [eplus_in_curr userdata] = sysIDcontrol(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata)

% ---------------WRITE YOUR CODE---------------
if strcmp(cmd,'init')
    % Set Inputs
    eplus_in_curr.rad1 = 0;
    eplus_in_curr.rad2 = 0;
    eplus_in_curr.rad3 = 0;
end
if strcmp(cmd,'normal')
    % ---------------WRITE YOUR CODE---------------
    % Normal mode. This part sets the input
    controlSteps = 30;  % change inputs every such minutes
    startHour = 5*2;  % in control steps
    changed = 0;
     
    % Compute inputs, changed every controlSteps minutes
    if mod(stepNumber, controlSteps) == 1
        curRadiants = userdata.inputs(1 + fix((stepNumber-1)/controlSteps), :);
        changed = 1;
    end
    
    % Set Inputs
    if changed
        eplus_in_curr.rad1 = curRadiants(1);
        eplus_in_curr.rad2 = curRadiants(2);
        eplus_in_curr.rad3 = curRadiants(3);
    else
        eplus_in_curr.rad1 = eplus_in_prev.rad1(end);
        eplus_in_curr.rad2 = eplus_in_prev.rad2(end);
        eplus_in_curr.rad3 = eplus_in_prev.rad3(end);
    end
end
end
