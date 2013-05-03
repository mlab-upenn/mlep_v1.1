function [time loginput logdata] = mlepRunTemplate(data)
% template - Script to launch energy plus co-simulation
% Syntax:  [time loginput logdata] = template(data)
%
% Inputs:
%   data {data.MLEPSETTING, Sdata.timeStep, data.runPeriod,
%   data.sim_inputs}
%
% Outputs:
%   time
%   loginput
%   logdata
%
% Example:
%   [time loginput logdata] = template(data)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTIONNAME1,  OTHER_FUNCTIONNAME2

% Author: WILLY BERNAL
% UNIVERSITY OF PENNSYLVANIA
% email address: willyg@seas.upenn.edu
% Website: http://mlab.seas.upenn.edu/
% May 2012; Last revision: 12-May-2012

%------------- BEGIN CODE --------------
%mlepInit;

%% Create an mlepProcess instance and configure it
ep = mlepProcess;
% Remove .idf .epw
indexIdf = strfind(data.data.idfFullPath, '.idf');
indexEpw = strfind(data.data.weatherFile, '.epw');
ep.arguments = {data.data.idfFullPath(1:indexIdf(1)-1), data.data.weatherFile(1:indexEpw(1)-1)};
%ep.arguments = {'/Users/willyg/Documents/MATLAB/MLE+/Example/SmOffPSZ', 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3'};
ep.acceptTimeout = 6000;
VERNUMBER = 2;  % version number of communication protocol (2 for E+ 6.0.0)


%% Start EnergyPlus cosimulation
%cd(data.data.projectPath) % Change to project directory
[status, msg] = ep.start;

if status ~= 0
    error('Could not start EnergyPlus: %s.', msg);
end

%% The main simulation loop
% READ timestep from file
% READ simulation time from file
deltaT = data.data.timeStep*60;   % time step = 15 minutes
kStep = 1;  % current simulation step
MAXSTEPS = data.data.runPeriod*24*60/data.data.timeStep;  % max simulation time = 4 days

% logdata stores set-points, outdoor temperature, and zone temperature at
% each time step.
logdata = zeros(MAXSTEPS, size(data.data.outputTableData,1));
loginput = zeros(MAXSTEPS, size(data.data.inputTableData,1));
mlepInputVector = struct;
mlepOutputVector = struct;
for i = 1:size(data.data.inputTableData,1)
    mlepInputVector.(data.data.inputTableData{i,end}) = zeros(1,MAXSTEPS);
end
for i = 1:size(data.data.outputTableData,1)
    mlepOutputVector.(data.data.outputTableData{i,end}) = zeros(1,MAXSTEPS);
end
time = (0:(MAXSTEPS-1))'*deltaT/3600;

% Remove .m in control file name
index_m = strfind(data.data.controlFileName, '.m');
data.data.controlFunctionName = data.data.controlFileName(1:index_m(1)-1);
% Create Handle
data.data.funcHandle = str2func(data.data.controlFunctionName);

%%
mlepIn = [];
while kStep <= MAXSTEPS
    % Read a data packet from E+
    packet = ep.read;
    if isempty(packet)
        error('Could not read outputs from E+.');
    end
    
    % Parse it to obtain building outputs
    [flag, eptime, outputs] = mlepDecodePacket(packet);
    if flag ~= 0, break; end
    
    % Save to logdata
    logdata(kStep, :) = outputs;
    for i = 1:size(data.data.outputTableData,1)
        mlepOutputVector.(data.data.outputTableData{i,end})(kStep) = outputs(i);
    end
    
    
    % Define Previous Output Variables
    for i = 1:size(data.data.outputTableData,1)
        mlepOut.(data.data.outputTableData{i,end}) = mlepOutputVector.(data.data.outputTableData{i,end})(1:kStep);
    end
    
    % Obtain Input Values from Control File
    inputStruct = feval(data.data.funcHandle,'normal',mlepOut, mlepIn, time(1:kStep), data.data.userdata); % NEED TO CHANGE,eplusOutPrev, eplusInPrev, time, userdata
    % Set input in struct
    inputs = setInput2vector(data,inputStruct);
    
    % Define Previous Input Variables
    for i = 1:size(data.data.inputTableData,1)
        mlepInputVector.(data.data.inputTableData{i,end})(kStep) = inputs(i);
        mlepIn.(data.data.inputTableData{i,end}) =  mlepInputVector.(data.data.inputTableData{i,end})(1:kStep);
    end
    
    ep.write(mlepEncodeRealData(VERNUMBER, 0, (kStep-1)*deltaT, inputs));
    
    % Save to loginput
    loginput(kStep, :) = inputs;
    
    kStep = kStep + 1;
end
%%
% Stop EnergyPlus
ep.stop;

% Remove unused entries in logdata
kStep = kStep - 1;
if kStep < MAXSTEPS
    logdata((kStep+1):end,:) = [];
    loginput((kStep+1):end,:) = [];
end
%%
% TIME PARAMETERS
time = [0:(kStep-1)]'*deltaT/3600;

%------------- END CODE --------------
% % Plot results
% plot([0:(kStep-1)]'*deltaT/3600, logdata);
% legend('Heat SP', 'Cool SP', 'Outdoor', 'Zone');
% title('Temperatures');
% xlabel('Time (hour)');
% ylabel('Temperature (C)');
end

function [inputs] = setInput2vector(data, inputStruct)
% Transform Struct to vector for feedback
if size(data.data.inputTableData,1)
    names = fieldnames(inputStruct);
    inputs = zeros(1,size(data.data.inputTableData,1));
    for j = 1:size(data.data.inputTableData,1)
        vecIndex = strcmp(names,data.data.inputTableData{j,4});
        ind = find(vecIndex);
        inputs(j) = getfield(inputStruct, names{ind});
    end
else
    % CASE WHEN THERE ARE NO INPUTS
    inputs = [];
end
end