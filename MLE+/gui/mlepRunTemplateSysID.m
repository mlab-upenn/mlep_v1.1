function [time loginput logdata mlep] = mlepRunTemplateSysID(mlep)
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

%% Create an mlepProcess instance and configure it
mlep.data.stopSimulation = 0;
mlep.data.noInput = 0;
mlep.data.noOutput = 0;

ep = mlepProcess; 
% Remove .idf .epw 
indexIdf = strfind(mlep.data.idfFile, '.idf');
indexEpw = strfind(mlep.data.weatherFile, '.epw');
ep.arguments = {mlep.data.idfFile(1:indexIdf(1)-1), mlep.data.weatherFile(1:indexEpw(1)-1)};
%ep.arguments = {'/Users/willyg/Documents/MATLAB/MLE+/Example/SmOffPSZ', 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3'};
ep.acceptTimeout = 8000; %800000
VERNUMBER = 2;  % version number of communication protocol (2 for E+ 6.0.0)


%% Start EnergyPlus cosimulation
%cd(mlep.data.projectPath) % Change to project directory
[status, msg] = ep.start;

if status ~= 0
    error('Could not start EnergyPlus: %s.', msg);
end

%% The main simulation loop
% READ timestep from file
% READ simulation time from file
% timeStep = 1;   % time step in minute
% deltaT = timeStep*60;  % time step in seconds
% kStep = 1;  % current simulation step
% timeStepsPerMin = 60/timeStep;
% MAXSTEPS = 3*24*timeStepsPerMin;  % max simulation time = 4 days

%%
mlep.data.timeStep; % Time Step in min 
deltaT = 60*mlep.data.timeStep;   % turn it into seconds
kStep = 1;  % current simulation step
MAXSTEPS = (mlep.data.runPeriod+1)*24*60/mlep.data.timeStep;  % max simulation time = 4 days

% logdata stores set-points, outdoor temperature, and zone temperature at
% each time step.
logdata = zeros(MAXSTEPS, size(mlep.data.outputTableData,1));
loginput = zeros(MAXSTEPS, size(mlep.data.inputTableData,1));
mlepInputVector = struct;
mlepOutputVector = struct;
for i = 1:size(mlep.data.inputTableData,1)
    mlepInputVector.(mlep.data.inputTableData{i,end}) = zeros(1,MAXSTEPS);
end

if size(mlep.data.outputTableData,1)
    mlep.data.noOutput = 1;
end
for i = 1:size(mlep.data.outputTableData,1)
    mlepOutputVector.(mlep.data.outputTableData{i,end}) = zeros(1,MAXSTEPS);
end
time = (0:(MAXSTEPS-1))'*deltaT/3600;

% Create Handle
% Check whether SYS or SIM
% SYSID
if (mlep.data.sysID == 1) 
    mlep.data.funcHandle = str2func('sysIDcontrol');
    %mlep.data.stepNumber = 1;
else
    % SIM    
    % Remove .m in control file name
    %mlep.data.stepNumber = 1;
    index_m = strfind(mlep.data.controlFileName, '.m');
    mlep.data.controlFunctionName = mlep.data.controlFileName(1:index_m(1)-1);
    mlep.data.funcHandle = str2func(mlep.data.controlFunctionName);
end

mlep.data.stepNumber = [];
mlep.data.inputFieldNames = {};
for i = 1:size(mlep.data.inputTableData,1)
    mlep.data.inputFieldNames{i} = mlep.data.inputTableData{i,4};
    mlep.data.stepNumber(i) = 1;
end
 
%% USERDATA CHECK
if ~isfield(mlep.data,'userdata')
    mlep.data.userdata = struct();
end

%%
mlepIn = [];
mlepOut = [];
cmd = 'init';
while kStep <= MAXSTEPS
    % Read a data packet from E+
    packet = ep.read;
    if isempty(packet)
        error('Could not read outputs from E+.');
    end
     
    % Parse it to obtain building outputs
    [flag, eptime, outputs] = mlepDecodePacket(packet);
    if flag ~= 0
        %flag
        break;
    end
    
    %% INPUTS EXIST
    if mlep.data.noOutput
        % Save to logdata
        logdata(kStep, :) = outputs;
        for i = 1:size(mlep.data.outputTableData,1)
            mlepOutputVector.(mlep.data.outputTableData{i,end})(kStep) = outputs(i);
        end
    end
     
    % Define Previous Output Variables
    if size(mlep.data.outputTableData,1)
        for i = 1:size(mlep.data.outputTableData,1)
            mlepOut.(mlep.data.outputTableData{i,end}) = mlepOutputVector.(mlep.data.outputTableData{i,end})(1:kStep);
        end
    else
        % No Outputs Specified    
        mlepOut  = struct();
    end
    
    % Obtain Input Values from Control File (SIM vs. SYSID)
    if (mlep.data.sysID == 1)
        [inputStruct, mlep] = feval(mlep.data.funcHandle,cmd,mlepOut, mlepIn, time(1:kStep), kStep, mlep); % NEED TO CHANGE,eplusOutPrev, eplusInPrev, time, userdata
        cmd = 'normal';
    else 
        try
        [inputStruct, mlep.data.userdata] = feval(mlep.data.funcHandle, cmd, mlepOut, mlepIn, time(1:kStep), kStep, mlep.data.userdata); %.data.userdata NEED TO CHANGE,eplusOutPrev, eplusInPrev, time, userdata
        catch err
            if (strcmp(err.identifier,'MATLAB:unassignedOutputs'))
                if isempty(mlep.data.inputTableData)
                    mlep.data.noInput = 1;
                    inputs = ones(1,0);
                end
            else
                rethrow(err);
            end
        end
        cmd = 'normal';
    end
    
    %% INPUTS EXIST
    if ~mlep.data.noInput
        % Set input in struct
        [inputs, mlep] = setInput2vector(mlep,inputStruct);
        if (mlep.data.stopSimulation)
            return;
        end
        
        % Define Previous Input Variables
        if size(mlep.data.inputTableData,1)
            for i = 1:size(mlep.data.inputTableData,1)
                mlepInputVector.(mlep.data.inputTableData{i,end})(kStep) = inputs(i);
                mlepIn.(mlep.data.inputTableData{i,end}) =  mlepInputVector.(mlep.data.inputTableData{i,end})(1:kStep);
            end
        else
            % No inputs Specified
            mlepIn = struct();
        end
       
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

%------------- SET INPUT/OUPUT --------------
mlep.data.mlepIn = mlepIn;
mlep.data.mlepOut = mlepOut;
end

function [inputs, mlep] = setInput2vector(mlep, inputStruct)


% Transform Struct to vector for feedback
if size(mlep.data.inputTableData,1)
    names = fieldnames(inputStruct);
    
    
    inputs = zeros(1,size(mlep.data.inputTableData,1));
    for j = 1:size(mlep.data.inputTableData,1)
        vecIndex = strcmp(names,mlep.data.inputTableData{j,4});
        % CHECK IF ALL INPUTS SPECIFIED
        if sum(vecIndex == 1)
            inputs(j) = inputStruct.(names{vecIndex});
        else
            mlep.data.mlepError = 'notAllInputsSpecified';
            mlepThrowError(mlep);
            mlep.data.stopSimulation = 1;
            return;
        end
    end
else
    % CASE WHEN THERE ARE NO INPUTS
    inputs = [];
end
end