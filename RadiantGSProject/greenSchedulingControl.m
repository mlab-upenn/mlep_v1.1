function [eplus_in_curr, userdata] = greenSchedulingControl(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata)
if strcmp(cmd,'init')
    % Initialization mode. This part sets the
    % input parameters for the first time step.
    % ---------------WRITE YOUR CODE---------------
    
    userdata = [];
    %% GENERATE ALL NECESSARY CONTORL PARAMETERS
    userdata = createUserdata(userdata);
    % WRITE INPUTS
    eplus_in_curr.rad1 = 1;
    eplus_in_curr.rad2 = 1;
    eplus_in_curr.rad3 = 1;
    
elseif strcmp(cmd,'normal')
    % Regular mode. This part sets the
    % input parameters for the following time steps.
    % ---------------WRITE YOUR CODE---------------
    % Time of Day
    timeOfDay = mod(stepNumber-1, 24*userdata.timeStepsPerHour);
    % Compute control values
    if timeOfDay < userdata.PreheatTime || timeOfDay >= userdata.endTime
        u = [1, 1, 1];
    elseif timeOfDay < userdata.startTime
        u = [1, 1, 1];
        userdata.gsStep = 0;
        userdata.activeCtrl = 1;
    else
        % The main control algorithm
        % Find which controller to use
        if timeOfDay < userdata.ctrls(userdata.activeCtrl).gsStart || timeOfDay >= userdata.ctrls(userdata.activeCtrl).gsEnd
            % Find the active controller
            k = 1;
            while k <= userdata.nCtrl
                if timeOfDay >= userdata.ctrls(k).gsStart && timeOfDay < userdata.ctrls(k).gsEnd
                    break;
                else
                    k = k + 1;
                end
            end
            assert(k <= userdata.nCtrl, 'No active controller at time %d (step %d).', timeOfDay, stepNumber);
            
            fprintf('Switch from controller %d to controller %d at time %d.\n', userdata.activeCtrl, k, timeOfDay);
            userdata.activeCtrl = k;
            userdata.gsStep = 0;
        end
        
        u = (userdata.gsStep >= userdata.ctrls(userdata.activeCtrl).gsOfs) & (userdata.gsStep < userdata.ctrls(userdata.activeCtrl).gsOfs + userdata.ctrls(userdata.activeCtrl).gsRho);
        u(userdata.ctrls(userdata.activeCtrl).t2s) = (userdata.gsStep >= userdata.ctrls(userdata.activeCtrl).gsOfs(userdata.ctrls(userdata.activeCtrl).t2s)) | ...
            (userdata.gsStep < userdata.ctrls(userdata.activeCtrl).gsOfs(userdata.ctrls(userdata.activeCtrl).t2s) + userdata.ctrls(userdata.activeCtrl).gsRho(userdata.ctrls(userdata.activeCtrl).t2s) - userdata.ctrls(userdata.activeCtrl).gsPeriod);
        
        u = u(:)';
        
        userdata.gsStep = userdata.gsStep + 1;
        if userdata.gsStep == userdata.ctrls(userdata.activeCtrl).gsPeriod
            userdata.gsStep = 0;
        end
    end
    
    % WRITE INPUTS
    eplus_in_curr.rad1 = u(1);
    eplus_in_curr.rad2 = u(2);
    eplus_in_curr.rad3 = u(3);
    
end
