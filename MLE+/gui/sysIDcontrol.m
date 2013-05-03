function [eplus_in_curr mlep] = sysIDcontrol(cmd,eplus_out_prev, eplus_in_prev, time, timeStep, mlep)

if strcmp(cmd, 'init')
    for j = 1:size(mlep.data.inputTableData,1)
    	eplus_in_curr.(mlep.data.inputFieldNames{j}) = mlep.data.sysIDinput(j,mlep.data.stepNumber(j));
        mlep.data.stepNumber(j) = mlep.data.stepNumber(j) + 1;
    end
end
 
% ---------------WRITE YOUR CODE---------------
if strcmp(cmd,'normal')
    % ---------------WRITE YOUR CODE---------------
    % Normal mode. This part sets the input
    % Check the input variables fieldnames.
    for j = 1:size(mlep.data.inputTableData,1)
        % Compute inputs, changed every controlSteps minutes
        if mod(timeStep, mlep.data.controlChangeTime(j)) == 0
            eplus_in_curr.(mlep.data.inputFieldNames{j}) = mlep.data.sysIDinput(j,mlep.data.stepNumber(j));
            mlep.data.stepNumber(j) = mlep.data.stepNumber(j) + 1;
        else
            eplus_in_curr.(mlep.data.inputFieldNames{j}) = eplus_in_prev.(mlep.data.inputFieldNames{j})(end);
        end
    end
end
end