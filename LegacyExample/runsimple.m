% This script simulates a supervisory controller for an HVAC system. The
% controller computes the zone temperature set-point based on the current
% time and the outdoor dry-bulb temperature. The building is simulated by
% EnergyPlus. This simulation is the same as that implemented in
% simple.mdl, but uses plain Matlab code instead of Simulink.
%
% This script illustrates the usage of class mlepProcess in the MLE+
% toolbox for feedback control which involves whole building simulation.
% It has been tested with Matlab R2009b and EnergyPlus 6.0.0.
%
% This example is taken from an example distributed with BCVTB version
% 0.8.0 (https://gaia.lbl.gov/bcvtb).
%
% This script is free software.
%
% (C) 2010-2011 by Truong Nghiem (nghiem@seas.upenn.edu)
%
% CHANGES:
%   2012-04-23  Fix an error with E+ 7.0.0: Matlab must read data from E+
%               before sending any data to E+.
%   2011-07-13  Update to new version of MLE+ which uses mlepInit for
%               system settings.
%   2011-04-28  Update to new version of MLE+ which uses Java for running
%               E+.

%% Create an mlepProcess instance and configure it

ep = mlepProcess;
ep.arguments = {'SmOffPSZ', 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3'};
ep.acceptTimeout = 6000;

VERNUMBER = 2;  % version number of communication protocol (2 for E+ 7.2.0)

%% Start EnergyPlus cosimulation
[status, msg] = ep.start;  

if status ~= 0
    error('Could not start EnergyPlus: %s.', msg);
end

%% The main simulation loop

deltaT = 15*60;  % time step = 15 minutes
kStep = 1;  % current simulation step
MAXSTEPS = 4*24*4+1;  % max simulation time = 4 days

TCRooLow = 22;  % Zone temperature is kept between TCRooLow & TCRooHi
TCRooHi = 26;
TOutLow = 22;  % Low level of outdoor temperature
TOutHi = 24;  % High level of outdoor temperature
ratio = (TCRooHi - TCRooLow)/(TOutHi - TOutLow);

% logdata stores set-points, outdoor temperature, and zone temperature at
% each time step.
logdata = zeros(MAXSTEPS, 4);

while kStep <= MAXSTEPS    
    % Read a data packet from E+
    packet = ep.read;
    if isempty(packet)
        error('Could not read outputs from E+.');
    end
    
    % Parse it to obtain building outputs
    [flag, eptime, outputs] = mlepDecodePacket(packet);
    if flag ~= 0, break; end
        
    % BEGIN Compute next set-points
    dayTime = mod(eptime, 86400);  % time in current day
    if (dayTime >= 6*3600) && (dayTime <= 18*3600)
        % It is day time (6AM-6PM)
        
        % The Heating set-point: day -> 20, night -> 16
        % The cooling set-point is bounded by TCRooLow and TCRooHi
        
        SP = [20, max(TCRooLow, ...
                    min(TCRooHi, TCRooLow + (outputs(1) - TOutLow)*ratio))];
    else
        % The Heating set-point: day -> 20, night -> 16
        % The Cooling set-point: night -> 30
        SP = [16 30];
    end
    % END Compute next set-points
    
    % Write to inputs of E+
    ep.write(mlepEncodeRealData(VERNUMBER, 0, (kStep-1)*deltaT, SP));    

    % Save to logdata
    logdata(kStep, :) = [SP outputs];
    
    kStep = kStep + 1;
end

% Stop EnergyPlus
ep.stop;

disp(['Stopped with flag ' num2str(flag)]);

% Remove unused entries in logdata
kStep = kStep - 1;
if kStep < MAXSTEPS
    logdata((kStep+1):end,:) = [];
end

% Plot results
plot([0:(kStep-1)]'*deltaT/3600, logdata);
legend('Heat SP', 'Cool SP', 'Outdoor', 'Zone');
title('Temperatures');
xlabel('Time (hour)');
ylabel('Temperature (C)');


% ==========FLAGS==============
% Flag	Description
% +1	Simulation reached end time.
% 0	    Normal operation.
% -1	Simulation terminated due to an unspecified error.
% -10	Simulation terminated due to an error during the initialization.
% -20	Simulation terminated due to an error during the time integration.

