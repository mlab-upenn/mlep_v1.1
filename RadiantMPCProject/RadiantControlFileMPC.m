function [eplus_in_curr, userdata] = RadiantControlFileMPC(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata)
%% USERDATA
%	userdata.plant

%% MANIPULATED VARIABLES INPUTS 
%     'ZONE 1 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%     'ZONE 2 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%     'ZONE 3 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%% MEASURED DISTURBANCES
%    'WEST ZONE Zone Total Internal Total Heat Gain Rate'
%    'EAST ZONE Zone Total Internal Total Heat Gain Rate'
%    'NORTH ZONE Zone Total Internal Total Heat Gain Rate'
%    'WEST ZONE Zone Transmitted Solar'
%    'ZN001:FLR001 Surface Inside Face Temperature'
%    'Environment Outdoor Dry Bulb'
%% OUTPUTS
%     'WEST ZONE Zone Mean Air Temperature'
%     'EAST ZONE Zone Mean Air Temperature'
%     'NORTH ZONE Zone Mean Air Temperature'

% ---------------WRITE YOUR CODE---------------
if strcmp(cmd,'init')
    % Initialization mode. This part sets the
    % input parameters for the first time step.
    
    %% Set MPC object
    userdata = setUpMPC(userdata);
    
    %% MEASURED DISTURBANCES px6
    userdata.v(:,1) = eplus_out_prev.outTemp(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,2) = eplus_out_prev.txSolar(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,3) = eplus_out_prev.floorTemp(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,4) = eplus_out_prev.heat1(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,5) = eplus_out_prev.heat2(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,6) = eplus_out_prev.heat3(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    %userdata = getPredictedValues(userdata,stepNumber);
    
    %% MEASURED OUTPUTS
    y(1) = eplus_out_prev.temp1(end);
    y(2) = eplus_out_prev.temp2(end);
    y(3) = eplus_out_prev.temp3(end);
    
    %% INIT X
    userdata.x.Plant = userdata.mpcobj.Model.Plant.c\y';
    
    %% REFERENCE TEMP
    %userdata.r = eplus_out_prev.heatSP(end)*ones(1,3);
    
    %% GENERATE INPUT 
    [input Info] = mpcmove(userdata.mpcobj,userdata.x,y,userdata.r,userdata.v);
    input = input';
    
    %% TRANSFORM POWER TO SET POINT
    % WEST - EAST - NORTH
    tsp = (y+input.*userdata.range./userdata.maxPow)-userdata.range/2;
    
    userdata.tsp(stepNumber,:) = tsp;
    userdata.input(stepNumber,:) = input;
    userdata.cost(stepNumber) = Info.Cost;
    userdata.slack(stepNumber) = Info.Slack;
    
    %% FEEDBACK
    eplus_in_curr.tsp1 = userdata.tsp(stepNumber,1);
    eplus_in_curr.tsp2 = userdata.tsp(stepNumber,2);
    eplus_in_curr.tsp3 = userdata.tsp(stepNumber,3);
elseif strcmp(cmd,'normal')
    % ---------------WRITE YOUR CODE---------------
    %% MEASURED OUTPUTS 
    y(1) = eplus_out_prev.temp1(end);
    y(2) = eplus_out_prev.temp2(end);
    y(3) = eplus_out_prev.temp3(end);
    
    %% MEASURED DISTURBANCES px6
    userdata.v(:,1) = eplus_out_prev.outTemp(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,2) = eplus_out_prev.txSolar(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,3) = eplus_out_prev.floorTemp(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,4) = eplus_out_prev.heat1(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,5) = eplus_out_prev.heat2(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    userdata.v(:,6) = eplus_out_prev.heat3(end)*ones(userdata.mpcobj.PredictionHorizon-1,1);
    %userdata = getPredictedValues(userdata,stepNumber);
    
    %% REFERENCE TEMP
    %userdata.r = eplus_out_prev.heatSP(end)*ones(1,3);
        
    %% GENERATE INPUT MPC
    if mod(stepNumber,userdata.Ts) == 1
        [input Info] = mpcmove(userdata.mpcobj,userdata.x,y,userdata.r,userdata.v);
        input = input';
        userdata.input = input;
        %% TRANSFORM POWER TO SET POINT
        % WEST - EAST - NORTH
        tsp = (y+userdata.input.*userdata.range./userdata.maxPow)-userdata.range/2;
        userdata.tsp(stepNumber,:) = tsp;
        userdata.cost(stepNumber) = Info.Cost;
        userdata.slack(stepNumber) = Info.Slack;
        if strcmp(Info.QPCode,'infeasible')
            disp('infeasible');
        end
        
    else
        %% TRANSFORM POWER TO SET POINT
        % WEST - EAST - NORTH
        tsp = (y+userdata.input.*userdata.range./userdata.maxPow)-userdata.range/2;
        userdata.tsp(stepNumber,:) = tsp;
        userdata.cost(stepNumber) = userdata.cost(stepNumber-1);
        userdata.slack(stepNumber) = userdata.slack(stepNumber-1);
    end
        
    %% FEEDBACK
    eplus_in_curr.tsp1 = userdata.tsp(stepNumber,1);
    eplus_in_curr.tsp2 = userdata.tsp(stepNumber,2);
    eplus_in_curr.tsp3 = userdata.tsp(stepNumber,3);
end
end
