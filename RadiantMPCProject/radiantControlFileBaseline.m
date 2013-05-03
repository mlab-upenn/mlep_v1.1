function [eplus_in_curr, userdata] = RadiantControlFileBaseline(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata)
if strcmp(cmd,'init')
    % Initialization mode. This part sets the
    % input parameters for the first time step.
    % ---------------WRITE YOUR CODE---------------
elseif strcmp(cmd,'normal')
    % Regular mode. This part sets the
    % input parameters for the following time steps.
    % ---------------WRITE YOUR CODE---------------
end
