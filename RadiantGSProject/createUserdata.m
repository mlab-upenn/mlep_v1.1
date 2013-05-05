function [userdata] = createUserdata(userdata)

%% CONTROLLER PARAMETERS
controller1.T = 60*60;
controller1.start = 8*3600;
controller1.end = 13*3600;

controller1.rho = [21; 25; 27] / 60;
controller1.ofs = ([0; 21+27; 21] - 36)/ 60;

idx = controller1.ofs < 0; controller1.ofs(idx) = controller1.ofs(idx) + 1;
controller1.t2s = controller1.ofs + controller1.rho > 1;


% Controller 2 from 13:00 to 18:00
controller2.T = 60*60;
controller2.start = 13*3600;
controller2.end = 18*3600;

controller2.rho = [3; 12; 18] / 60;
controller2.ofs = ([0; 3+18; 3] - 8)/ 60;

idx = controller2.ofs < 0; controller2.ofs(idx) = controller2.ofs(idx) + 1;
controller2.t2s = controller2.ofs + controller2.rho > 1;

%% SIMULATION PARAMETERS 
userdata.ctrls = [controller1 controller2];

userdata.HiThres = 24;
userdata.LoThres = 22;

% Time of day to start pre-heating
timeStep = 1;   % time step in minute
userdata.deltaT = timeStep*60;  % time step in seconds
userdata.timeStepsPerHour = 60/timeStep;
userdata.PreheatTime = 5*userdata.timeStepsPerHour;

% Time of day to start and stop control
userdata.startTime = 8*userdata.timeStepsPerHour;
userdata.endTime = 18*userdata.timeStepsPerHour;

% Green scheduling parameters
userdata.nCtrl = length(userdata.ctrls);
for k = 1:userdata.nCtrl
    % Period in number of time steps (not in seconds, minutes...)
    userdata.ctrls(k).gsPeriod = round(userdata.ctrls(k).T / userdata.deltaT);  % ctrls(k).T is in seconds
    userdata.ctrls(k).gsRho = round(userdata.ctrls(k).rho * userdata.ctrls(k).gsPeriod);  % convert rho to time steps
    userdata.ctrls(k).gsOfs = round(userdata.ctrls(k).ofs * userdata.ctrls(k).gsPeriod);  % convert offset to time steps
    userdata.ctrls(k).gsStart = round(userdata.ctrls(k).start / userdata.deltaT);
    userdata.ctrls(k).gsEnd = round(userdata.ctrls(k).end / userdata.deltaT);
end

userdata.gsStep = 0;  % internal time step of the green scheduler
userdata.activeCtrl = 1;
end



