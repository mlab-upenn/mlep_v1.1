function [] = mlepSysIDFunction(varargin)
% Main Function

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
%mlep.handle = handle;
functionName = varargin{4};

%% INPUTS / OUTPUTS COMMENTS
if strcmp(functionName,'getInputIndex')
    [mlep] = getInputIndex(mlep);
elseif strcmp(functionName,'getOutputIndex')
    [mlep] = getOutputIndex(mlep);
elseif strcmp(functionName,'editInputComment')
    [mlep] = editInputComment(mlep);
elseif strcmp(functionName,'editOutputComment')
    [mlep] = editOutputComment(mlep);
    
    %% Load SYS ID Parameters
elseif strcmp(functionName,'loadVariables')
    [mlep] = loadVariables(mlep,handle);
elseif strcmp(functionName,'openIdf')
    [mlep] = openIdf(mlep);    
elseif strcmp(functionName,'getInputIndexID')
    [mlep] = getInputIndexID(mlep);
elseif strcmp(functionName,'getConrolStep')
    [mlep] = getConrolStep(mlep);
elseif strcmp(functionName,'getType')
    [mlep] = getType(mlep);
elseif strcmp(functionName,'getWlow')
    [mlep] = getWlow(mlep);
elseif strcmp(functionName,'getWhigh')
    [mlep] = getWhigh(mlep);
elseif strcmp(functionName,'getMinu')
    [mlep] = getMinu(mlep);
elseif strcmp(functionName,'getManu')
    [mlep] = getManu(mlep);
elseif strcmp(functionName,'showHelp')
    [mlep] = showHelp(mlep);
elseif strcmp(functionName,'getScale')
    [mlep] = getScale(mlep);
elseif strcmp(functionName,'getCheck')
    [mlep] = getCheck(mlep);    
elseif strcmp(functionName,'selectSignal')
    [mlep] = selectSignal(mlep);
elseif strcmp(functionName,'createControlFile')
    [mlep] = createControlFile(mlep);
elseif strcmp(functionName,'editControlFile')
    [mlep] = editControlFile(mlep);
elseif strcmp(functionName,'loadControlFile')
    [mlep] = loadControlFile(mlep);
elseif strcmp(functionName,'updateWorkspace')
    [mlep] = updateWorkspace(mlep);
elseif strcmp(functionName,'selectUserdata')
    [mlep] = selectUserdata(mlep);
elseif strcmp(functionName,'editControl')
    [mlep] = editControl(mlep);

    
    %% RUN SYS ID
elseif strcmp(functionName,'sysID')
    [mlep] = sysID(mlep);
elseif strcmp(functionName,'getVarsIndexSelected')
    [mlep] = getVarsIndexSelected(mlep);
elseif strcmp(functionName,'getInputIndexIDSelected')
    [mlep] = getInputIndexIDSelected(mlep);
elseif strcmp(functionName,'getOutputIndexIDSelected')
    [mlep] = getOutputIndexIDSelected(mlep);
    
    %% TAB 2 ADD/DELETE SELECT INPUTS AND OUTPUS
    % OUTPUT
elseif strcmp(functionName,'addOutput')
    [mlep] = addOutput(mlep);
elseif strcmp(functionName,'deleteOutput')
    [mlep] = deleteOutput(mlep);
elseif strcmp(functionName,'getOutputIDSelectedIndex')
    [mlep] = getOutputIDSelectedIndex(mlep);
    % INPUT
elseif strcmp(functionName,'addInput')
    [mlep] = addInput(mlep);
elseif strcmp(functionName,'deleteInput')
    [mlep] = deleteInput(mlep);
elseif strcmp(functionName,'getInputIDSelectedIndex')
    [mlep] = getInputIDSelectedIndex(mlep);
    % RUN IDDATA
elseif strcmp(functionName,'runIddata')
    [mlep] = runIddata(mlep);
elseif strcmp(functionName,'runIdent')
    [mlep] = runIdent(mlep);
end

% Save data structure
guidata(handle, mlep);
end


%% INPUTS/OUTPUTS COMMENTS
function [mlep] = getInputIndex(mlep)
% Callback for get_scheduleIndex
% Get Selection Index
mlep.data.sysIDInListboxIndex = get(mlep.sysIDInListbox,'Value');
if ~isempty(mlep.data.sysIDInListboxIndex)
    set(mlep.sysIDInComment, 'String',mlep.data.listInputExt2{mlep.data.sysIDInListboxIndex,6});
end
end

function [mlep] = getOutputIndex(mlep)
% Callback for get_scheduleIndex
% Get Selection Index
mlep.data.sysIDOutListboxIndex = get(mlep.sysIDOutListbox,'Value');
if ~isempty(mlep.data.sysIDOutListboxIndex)
    set(mlep.sysIDOutComment, 'String',mlep.data.listOutputExt2{mlep.data.sysIDOutListboxIndex,5});
end
end

function [mlep] = editInputComment(mlep)
% Callback for editInputComment
if isfield(mlep.data,'sysIDInListboxIndex')
    if ~isempty(mlep.data.sysIDInListboxIndex)
        mlep.data.listInputExt2{mlep.data.sysIDInListboxIndex,6} = get(mlep.sysIDInComment, 'String');
        set(mlep.sysIDInComment, 'String',mlep.data.listInputExt2{mlep.data.sysIDInListboxIndex,6});
    end
end
end

function [mlep] = editOutputComment(mlep)
% Callback for editInputComment
if isfield(mlep.data,'sysIDOutListboxIndex')
    if ~isempty(mlep.data.sysIDOutListboxIndex)
        mlep.data.listOutputExt2{mlep.data.sysIDOutListboxIndex,5} = get(mlep.sysIDOutComment, 'String');
        set(mlep.sysIDOutComment, 'String',mlep.data.listOutputExt2{mlep.data.sysIDOutListboxIndex,5});
    end
end
end

%% Load SYS ID Parameters
function [mlep] = loadVariables(mlep,handle)
%[mlep] = mlepVariable(handle);

if isfield(mlep.data,'idfFile')
    if ~isempty(mlep.data.idfFile)
        if ischar(mlep.data.idfFullPath)
            if exist(mlep.data.idfFullPath,'file')
                set(mlep.variableIdfName,'string',mlep.data.idfFile);
                set(mlep.variableHandle,'visible','on');
            else
                mlep.data.mlepError = 'fileNotFound';
                mlepThrowError(mlep);
            end
        else
            mlep.data.mlepError = 'idfMissing';
            mlepThrowError(mlep);
        end
    else
        mlep.data.mlepError = 'idfMissing';
        mlepThrowError(mlep);
    end
else
    mlep.data.mlepError = 'idfMissing';
    mlepThrowError(mlep);
end

[mlep] = mlepUpdateSysIDTab(mlep);
end

function [mlep] = openIdf(mlep)
    if isfield(mlep.data,'idfFile')
        if ~isempty(mlep.data.idfFile)
            if exist(mlep.data.idfFullPath,'file')
                edit(mlep.data.idfFullPath);
            else
                mlep.data.mlepError = 'fileNotFound';
                mlepThrowError(mlep);
            end
        else
            mlep.data.mlepError = 'idfMissing';
            mlepThrowError(mlep);
        end
    else
        mlep.data.mlepError = 'idfMissing';
        mlepThrowError(mlep);
    end
end

function [mlep] = getInputIndexID(mlep)
% Get index of Input Index
mlep.data.sysIDinputIndex = get(mlep.sysIDInListboxID,'Value');

% update Parameters
[mlep] = mlepUpdateSysIDParam(mlep);
end

function [mlep] = getConrolStep(mlep)
value = get(mlep.sysIDeditConrolStep,'String');
if ~isletter(value)
    value = str2double(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,1} = value;
    end   
end

end

function [mlep] = getType(mlep)
index = get(mlep.sysIDpopupType,'Value');
type = mlep.sysIDpopupmenu{index};
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,2} = index;
    end
end
end

function [mlep] = getWlow(mlep)
value = get(mlep.sysIDeditWlow,'String');
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,3} = value;
    end
end
end

function [mlep] = getWhigh(mlep)
value = get(mlep.sysIDeditWhigh,'String');
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,4} = value;
    end
end
end
function [mlep] = getMinu(mlep)
value = get(mlep.sysIDeditMinu,'String');
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,5} = value;
    end
end
end

function [mlep] = getManu(mlep)
value = get(mlep.sysIDeditManu,'String');
if ~isletter(value)
    value = str2double(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,6} = value;
    end
end
end

function [mlep] = showHelp(mlep)
instructions = idinputHelp(); 
helpdlg(instructions,'Input Signal Help');

end

function [mlep] = getScale(mlep)
value = get(mlep.sysIDeditScale,'String');
if ~isletter(value)
    value = str2double(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,7} = value;
    end
end
end

% function [mlep] = selectSignal(mlep)
% value = get(mlep.sysIDsignal,'String');
% if ~isletter(value)
%     value = str2double(value);
% else
%     mlep.data.mlepError = 'notNumber';
%     mlepThrowError(mlep);
% end
% % Set parameter
% if isfield(mlep.data,'sysIDinputIndex')
%     if ~isempty(mlep.data.sysIDinputIndex)
%         mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,8} = value;
%     end
% end
% end


function [mlep] = editControlFile(mlep)
% Callback for editInputComment
mlep.data.controlFileName = get(mlep.sysIDFeedbackCreateEdit, 'String');
end

function [mlep] = createControlFile(mlep)
mlep.data.controlFileName = get(mlep.sysIDFeedbackCreateEdit, 'String');
set(mlep.sysIDFeedbackLoadEdit, 'Background', 'white');
set(mlep.sysIDFeedbackCreateEdit, 'Background', 'c');
mlep.data.controlCreated = 1;
mlep.data.controlLoaded = 0;
mlepCreateControlFile(mlep);
end

function [mlep] = loadControlFile(mlep)
% Select Control File
[FileName,PathName] = uigetfile('*.m','Select Control File');
if ischar(FileName) && ischar(PathName)
    mlep.data.controlFileName = FileName;
    mlep.data.controlFullPath = [PathName FileName];
    mlep.data.controlFileHandle =  str2func(mlep.data.controlFileName);
    set(mlep.sysIDFeedbackLoadEdit, 'Background', 'c');
    set(mlep.sysIDFeedbackCreateEdit, 'Background', 'white');
    mlep.data.controlCreated = 0;
    mlep.data.controlLoaded = 1;
    % Update text box
    set(mlep.sysIDFeedbackLoadEdit,'string',mlep.data.controlFileName);
end

end

function [mlep] = updateWorkspace(mlep)
% Update UserData workspace
mlep.data.workVars = evalin('base','who');
if isempty(mlep.data.workVars)
    mlep.data.mlepError = 'emptyWorspace';
    mlepThrowError(mlep);
    set(mlep.sysIDPopupUserdata,'String','Select User Data');
    set(mlep.sysIDPopupUserdata,'Enable','off');
    return;
else
    set(mlep.sysIDPopupUserdata,'String',mlep.data.workVars,'Enable','on');
end
end

function [mlep] = selectUserdata(mlep)
% Select UserData variable
mlep.data.workVars = evalin('base','who');
if isempty(mlep.data.workVars)
    mlep.data.mlepError = 'emptyWorspace';
    mlepThrowError(mlep);
    set(mlep.sysIDPopupUserdata,'Background','white','Enable','off','String','Select User Data');
    return;
else
    set(mlep.sysIDPopupUserdata,'Enable','on','Background','c');
    val = get(mlep.sysIDPopupUserdata, 'Value');
    mlep.data.userdata =  evalin('base',mlep.data.workVars{val});
end

end

function [mlep] = editControl(mlep)
% Select Edit Control File
cd(mlep.data.projectPath);
edit(mlep.data.controlFileName);
end


function [mlep] = selectSignal(mlep)
% Select UserData variable
mlep.data.workVars = evalin('base','who');
if isempty(mlep.data.workVars)
    mlep.data.mlepError = 'emptyWorspace';
    mlepThrowError(mlep);
    set(mlep.sysIDselectSignal,'Background','white','Enable','off','String','Select Signal');
    return;
else
    set(mlep.sysIDselectSignal,'Enable','on','Background','c');
    value = get(mlep.sysIDselectSignal, 'Value');
    % mlep.data.signal =  evalin('base',mlep.data.workVars{val});
    % Set parameter
    if isfield(mlep.data,'sysIDinputIndex')
        if ~isempty(mlep.data.sysIDinputIndex)
            mlep.data.sysIDinputParam{mlep.data.sysIDinputIndex,8} = evalin('base',mlep.data.workVars{value});
        end
    end
end

end

function [mlep] = getCheck(mlep)
value = get(mlep.sysIDcheck,'Value');
% if ~isletter(value)
%     value = str2double(value);
% else
%     mlep.data.mlepError = 'notNumber';
%     mlepThrowError(mlep);
% end

% Set parameter
if isfield(mlep.data,'sysIDinputIndex')
    if ~isempty(mlep.data.sysIDinputIndex)
        mlep.data.sysIDselectControl = value;
        if mlep.data.sysIDselectControl
            % Disable IDINPUT
            set(mlep.sysIDeditConrolStep, 'Enable', 'off');
            set(mlep.sysIDeditScale, 'Enable', 'off');
            set(mlep.sysIDpopupType, 'Enable', 'off');
            set(mlep.sysIDeditWlow, 'Enable', 'off');
            set(mlep.sysIDeditWhigh, 'Enable', 'off');
            set(mlep.sysIDeditMinu, 'Enable', 'off');
            set(mlep.sysIDeditManu, 'Enable', 'off');
            % Enable CONtrol FILE
            set(mlep.sysIDFeedbackFileCreate, 'Enable', 'on');
            set(mlep.sysIDFeedbackCreateEdit, 'Enable', 'on');
            set(mlep.sysIDFeedbackFileLoad, 'Enable', 'on');
            set(mlep.sysIDFeedbackLoadEdit, 'Enable', 'on');
            set(mlep.controlEditControlFile, 'Enable', 'on');
            
        else 
            % Enable IDINPUT
            set(mlep.sysIDeditConrolStep, 'Enable', 'on');
            set(mlep.sysIDeditScale, 'Enable', 'on');
            set(mlep.sysIDpopupType, 'Enable', 'on');
            set(mlep.sysIDeditWlow, 'Enable', 'on');
            set(mlep.sysIDeditWhigh, 'Enable', 'on');
            set(mlep.sysIDeditMinu, 'Enable', 'on');
            set(mlep.sysIDeditManu, 'Enable', 'on');
            % Diable CONTROL FILE
            set(mlep.sysIDFeedbackFileCreate, 'Enable', 'off');
            set(mlep.sysIDFeedbackCreateEdit, 'Enable', 'off');
            set(mlep.sysIDFeedbackFileLoad, 'Enable', 'off');
            set(mlep.sysIDFeedbackLoadEdit, 'Enable', 'off');
            set(mlep.controlEditControlFile, 'Enable', 'off');
        end
    end
end


end

%% RUN SYS ID
function [mlep] = sysID(mlep)
if ~isfield(mlep.data, 'sysIDselectControl')
    mlep.data.sysIDselectControl = 0;
end

% IDINPUT
if  ~mlep.data.sysIDselectControl
    % Create idinput
    mlep.data.controlChangeTime = [];
    mlep.data.sysIDinput = [];
    
    % Check if Parameters were entered
    [mlep, check] = checkParameters(mlep);
    if ~check
        mlep.data.mlepError = 'emptyArray';
        mlepThrowError(mlep);
        return;
    end
    
    for i = 1:size(mlep.data.inputTableData,1)
        
        mlep.data.sysIDinput(i,:) = idinput([ceil(mlep.data.runPeriod*24*60/mlep.data.timeStep)+1],...
            mlep.sysIDpopupmenu{mlep.data.sysIDinputParam{i,2}},...
            [mlep.data.sysIDinputParam{i,3}, mlep.data.sysIDinputParam{i,4}],...
            [mlep.data.sysIDinputParam{i,5}, mlep.data.sysIDinputParam{i,6}]);
        %mlep.data.sysIDinputParam{i,2}
        %mlep.data.sysIDinputParam{i,3}
        
        % Time to change control
        mlep.data.controlChangeTime(i) = mlep.data.sysIDinputParam{i,1};
    end
    
    % Run System Simulation IDINPUT
    [mlep] = runSimulationSysID(mlep);
else
    % Run System Simulation CONTROL FILE
    [mlep] = runSimulation(mlep);
end
end

function [mlep, check] = checkParameters(mlep)

% Check Parameters
check = 1;
for i = 1:size(mlep.data.inputTableData,1)
    for j = 1:6
        if isempty(mlep.data.sysIDinputParam{i,j})
            check = 0;
        end
    end
end

end

function [mlep] = runSimulationSysID(mlep)
% Switch to Project Path
cd(mlep.data.projectPath);
mlep.data.sysID = 1;
% Check for all necessary variable to run sim
check = checkInputFiles(mlep);
if ~check
    return;
end

% Run Simulation
[simTime simInput simOutput mlep] = mlepRunTemplateSysID(mlep);
mlep.data.simTime = simTime;
mlep.data.simInput = simInput;
mlep.data.simOutput = simOutput;

% Display Results
mlep = displayResults(mlep);
end

function [mlep] = runSimulation(mlep)
% Switch to Project Path
cd(mlep.data.projectPath);
mlep.data.sysID = 0;

% Check for all necessary variable to run sim
check = checkInputFiles(mlep);
if ~check
    return;
end
 
% Run Simulation 
[data.time data.input data.output mlep] = mlepRunTemplateSysID(mlep);
mlep.data.simTime = data.time;
mlep.data.simInput = data.input;
mlep.data.simOutput = data.output; % simOutput

if (mlep.data.stopSimulation)
    return;
end

% Display Results
mlep = displayResults(mlep);
end



function [mlep] = displayResults(mlep);
%% Check Whether csv got written
filePath = regexprep(mlep.data.idfFile, 'idf', 'csv');
pathOutput = [mlep.data.projectPath 'Output' filesep filePath];

% Small Pause to let files get written 
for count = 1:10
    pause(0.5);
    if exist(pathOutput,'file')
        break;
    end
end

% CHECK DIRECTORIES FOR CSV FILE
if exist(pathOutput,'file')
    mlep.data.sysIDvarsData = [];
    
    [mlep.data.vars, mlep.data.varsData, ts] = mlepLoadEPResults(pathOutput);
    mlep.data.simulateListboxText = {};
    for i = 1:size(mlep.data.vars,1)
        mlep.data.simulateListboxText{i} = [mlep.data.vars(i).object '-' mlep.data.vars(i).name];
    end
    % Create SYS ID results data
    % Struct with Results information
    mlep.data.sysIDvars = [];
    if isfield(mlep.data, 'sysIDvarsSelected')
        mlep.data = rmfield(mlep.data, 'sysIDvarsSelected');
    end
    
    % Create Listbox text for SYSID
    % Add Input Variables
    for i = 1:size(mlep.data.inputTableData,1)
        mlep.data.sysIDvarsText{i} = mlep.data.listInputExt2{i,7};
        mlep.data.sysIDvars(i).object = mlep.data.listInputExt2{i,3};
        mlep.data.sysIDvars(i).sampling = 'TimeStep';
        mlep.data.sysIDvars(i).name = mlep.data.listInputExt2{i,7};
        mlep.data.sysIDvars(i).unit = ' ';
    end
    last = i;
    % Add Outputs from csv
    for i = 1:size(mlep.data.simulateListboxText,2)
        mlep.data.sysIDvarsText{last+i} = mlep.data.simulateListboxText{i};
        mlep.data.sysIDvars(last+i) = mlep.data.vars(i);
    end
    % Data Matrix
    % Add from inputs
    for i = 1:size(mlep.data.inputTableData,1)
        mlep.data.sysIDvarsData(:,i) = mlep.data.simInput(1:size(mlep.data.varsData,1),i); % CHECK THIS
    end
    last = i;
    % Add Outputs from csv
    for i = 1:size(mlep.data.varsData,2)
        mlep.data.sysIDvarsData(:,last+i) = mlep.data.varsData(:,i);
    end
    
    
    % Create Selected Listbox
    mlep.data.sysIDInputTextSelected = {};
    mlep.data.sysIDInputDataSelected = [];
    mlep.data.sysIDInputPropertySelected = struct;
    
    mlep.data.sysIDOutputTextSelected = {};
    mlep.data.sysIDOutputDataSelected = [];
    mlep.data.sysIDOutputPropertySelected = struct;
    
    mlep.data.sysIDvarsIndex = 1;
    mlep.data.sysIDInputTextSelectedIndex = 1;
    mlep.data.sysIDOutputTextSelectedIndex = 1;
    
    % Update Tabs
    [mlep] = mlepUpdateSysIDTab(mlep);
    set(mlep.simulateListbox,'string',mlep.data.simulateListboxText);
    
else
    mlep.data.mlepError = 'noOutputFileFound';
    mlepThrowError(mlep);
    return;
end
[mlep] = mlepDisplayDxf(mlep);

end


function [mlep] = mlepDisplayDxf(mlep)

set(gcf,'CurrentAxes', mlep.dxfAxes);
set(mlep.dxfAxes, 'HandleVisibility', 'callback');

% CHECK DIRECTORIES FOR DXF FILE
filePath = regexprep(mlep.data.idfFile, 'idf', 'dxf');
pathOutput = [mlep.data.projectPath 'Outputs' filesep filePath];

% PLOT IF EXIST
if exist(pathOutput,'file')
    dxf = model3d(pathOutput);
    plot(dxf);
    grid on;
end
% SET INVISIBLE THE HANDLE
%set(mlep.dxfAxes, 'HandleVisibility', 'off');
end

function [check] = checkInputFiles(mlep)
check = 1;

if ~isfield(mlep.data,'idfFile')
    mlep.data.mlepError = 'idfMissing';
    mlepThrowError(mlep);
    check = 0;
end

if ~isfield(mlep.data,'weatherFile')
    mlep.data.mlepError = 'weatherMissing';
    mlepThrowError(mlep);
    check = 0;
end
end

%% TAB 2 ADD/DELETE SELECT INPUTS AND OUTPUS
function  [mlep] = getOutputIndexID(mlep)
% Callback for Output Index
% Get Selection Index
mlep.data.sysIDOutListboxIndexID = get(mlep.sysIDOutputListbox,'Value');
end

function  [mlep] = getVarsIndexSelected(mlep)
% Callback for Variabls index
% Get Selection Index
mlep.data.sysIDvarsIndex = get(mlep.sysIDvarsListbox,'Value');
end

function  [mlep] = addOutput(mlep)
% Empty Array
if ~size(mlep.data.sysIDvarsText,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Callback for add output
% Get size of output listbox
last = 1;
if isfield(mlep.data, 'sysIDOutputTextSelected')
    last = size(mlep.data.sysIDOutputTextSelected,2) + 1;
end
%% TEXT
% Add Output Text
mlep.data.sysIDOutputTextSelected(last) = mlep.data.sysIDvarsText(mlep.data.sysIDvarsIndex);
% Delete Vars Text
mlep.data.sysIDvarsText(mlep.data.sysIDvarsIndex) = [];
%% DATA
% Add Output Data
mlep.data.sysIDOutputDataSelected = [mlep.data.sysIDOutputDataSelected mlep.data.sysIDvarsData(:,mlep.data.sysIDvarsIndex)];
% Delete Vars Data
mlep.data.sysIDvarsData(:,mlep.data.sysIDvarsIndex) = [];
%% PROPERTY
% Add Output Property
if (last == 1)
    mlep.data.sysIDOutputPropertySelected = mlep.data.sysIDvars(mlep.data.sysIDvarsIndex);
else
    mlep.data.sysIDOutputPropertySelected(last) = mlep.data.sysIDvars(mlep.data.sysIDvarsIndex);
end
% Delete Vars Property
mlep.data.sysIDvars(mlep.data.sysIDvarsIndex) = [];
%% INDEX VARS
index = mlep.data.sysIDvarsIndex-1;
if index==0
    index = 1;
end
set(mlep.sysIDvarsListbox,'Value',index);
mlep.data.sysIDvarsIndex = index;
%% INDEX OUTPUT
index = size(mlep.data.sysIDOutputTextSelected,2);
set(mlep.sysIDOutputListboxSelected,'Value',index);
mlep.data.sysIDOutputTextSelectedIndex = index;

% Load Control Variables
loadControlVar(mlep);
end

function  [mlep] = deleteOutput(mlep)
% Callback for delete output

% Empty Array
if ~size(mlep.data.sysIDOutputTextSelected,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Get size of vars listbox
last = 1;
if isfield(mlep.data, 'sysIDvarsText')
    last = size(mlep.data.sysIDvarsText,2) + 1;
end
%% TEXT
% Add vars Text
mlep.data.sysIDvarsText(last) = mlep.data.sysIDOutputTextSelected(mlep.data.sysIDOutputTextSelectedIndex);
% Delete output Text
mlep.data.sysIDOutputTextSelected(mlep.data.sysIDOutputTextSelectedIndex) = [];
%% DATA
% Add Vars Data
mlep.data.sysIDvarsData = [mlep.data.sysIDvarsData mlep.data.sysIDOutputDataSelected(:,mlep.data.sysIDOutputTextSelectedIndex)];
% Delete Output Data
mlep.data.sysIDOutputDataSelected(:,mlep.data.sysIDOutputTextSelectedIndex) = [];
%% PROPERTY
% Add vars Property
mlep.data.sysIDvars(last) = mlep.data.sysIDOutputPropertySelected(mlep.data.sysIDOutputTextSelectedIndex);
% Delete output Property
mlep.data.sysIDOutputPropertySelected(mlep.data.sysIDOutputTextSelectedIndex) = [];
%% INDEX OUTPUT
index = mlep.data.sysIDOutputTextSelectedIndex-1;
if index==0
    index = 1;
end
set(mlep.sysIDOutputListboxSelected,'Value',index);
mlep.data.sysIDOutputTextSelectedIndex = index;
%% INDEX VARS
index = size(mlep.data.sysIDvarsText,2);
set(mlep.sysIDvarsListbox,'Value',index);
mlep.data.sysIDvarsIndex = index;

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = getOutputIDSelectedIndex(mlep)
% Get Output Selected Index
mlep.data.sysIDOutputTextSelectedIndex = get(mlep.sysIDOutputListboxSelected, 'Value');
end

%% INPUT
function  [mlep] = addInput(mlep)
% Empty Array
if ~size(mlep.data.sysIDvarsText,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Callback for add input
% Get size of input listbox
last = 1;
if isfield(mlep.data, 'sysIDInputTextSelected')
    last = size(mlep.data.sysIDInputTextSelected,2) + 1;
end
%% TEXT
% Add Output Text
mlep.data.sysIDInputTextSelected(last) = mlep.data.sysIDvarsText(mlep.data.sysIDvarsIndex);
% Delete Vars Text
mlep.data.sysIDvarsText(mlep.data.sysIDvarsIndex) = [];
%% DATA
% Add Output Data
mlep.data.sysIDInputDataSelected = [mlep.data.sysIDInputDataSelected mlep.data.sysIDvarsData(:,mlep.data.sysIDvarsIndex)];
% Delete Vars Data
mlep.data.sysIDvarsData(:,mlep.data.sysIDvarsIndex) = [];
%% PROPERTY
% Add Output Property
if (last == 1)
    mlep.data.sysIDInputPropertySelected = mlep.data.sysIDvars(mlep.data.sysIDvarsIndex);
else
    mlep.data.sysIDInputPropertySelected(last) = mlep.data.sysIDvars(mlep.data.sysIDvarsIndex);
end
% Delete Vars Property
mlep.data.sysIDvars(mlep.data.sysIDvarsIndex) = [];

%% INDEX VARS
index = mlep.data.sysIDvarsIndex-1;
if index==0
    index = 1;
end
set(mlep.sysIDvarsListbox,'Value',index);
mlep.data.sysIDvarsIndex = index;
%% INDEX OUTPUT
index = size(mlep.data.sysIDInputTextSelected,2);
set(mlep.sysIDInputListboxSelected,'Value',index);
mlep.data.sysIDInputTextSelectedIndex = index;

% Load Control Variables
loadControlVar(mlep);
end

function  [mlep] = deleteInput(mlep)
% Callback for delete input

% Empty Array
if ~size(mlep.data.sysIDInputTextSelected,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Get size of vars listbox
last = 1;
if isfield(mlep.data, 'sysIDvarsText')
    last = size(mlep.data.sysIDvarsText,2) + 1;
end
%% TEXT
% Add vars Text
mlep.data.sysIDvarsText(last) = mlep.data.sysIDInputTextSelected(mlep.data.sysIDInputTextSelectedIndex);
% Delete output Text
mlep.data.sysIDInputTextSelected(mlep.data.sysIDInputTextSelectedIndex) = [];
%% DATA
% Add Vars Data
mlep.data.sysIDvarsData = [mlep.data.sysIDvarsData mlep.data.sysIDInputDataSelected(:,mlep.data.sysIDInputTextSelectedIndex)];
% Delete Input Data
mlep.data.sysIDInputDataSelected(:,mlep.data.sysIDInputTextSelectedIndex) = [];
%% PROPERTY
% Add vars Property
mlep.data.sysIDvars(last) = mlep.data.sysIDInputPropertySelected(mlep.data.sysIDInputTextSelectedIndex);
% Delete output Property
mlep.data.sysIDInputPropertySelected(mlep.data.sysIDInputTextSelectedIndex) = [];
%% INDEX INPUT
index = mlep.data.sysIDInputTextSelectedIndex-1;
if index==0
    index = 1;
end
set(mlep.sysIDInputListboxSelected,'Value',index);
mlep.data.sysIDInputTextSelectedIndex = index;
%% INDEX VARS
index = size(mlep.data.sysIDvarsText,2);
set(mlep.sysIDvarsListbox,'Value',index);
mlep.data.sysIDvarsIndex = index;

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = getInputIDSelectedIndex(mlep)
% Get Output Selected Index
mlep.data.sysIDInputTextSelectedIndex = get(mlep.sysIDInputListboxSelected, 'Value');
end

%% LOAD / UPDATE SYSID TAB
function [mlep] = loadControlVar(mlep)
% Load control variables
[mlep] = mlepUpdateSysIDTab(mlep);
end

%% RUN IDDATA
function [mlep] = runIddata(mlep)
% Package data
% Only use data when solar gains are zero
% {'Power1'; 'Power2'; 'Power3'; 'Ambient'; 'Solar1'; 'SolarFloor1'; 'Gain1'; 'Gain2'; 'Gain3'}
% {'W'; 'W'; 'W'; '^oC'; 'W'; 'W'; 'W'; 'W'; 'W'}
% {'zoh'; 'zoh'; 'zoh'; 'zoh'; 'zoh'; 'zoh'; 'zoh'; 'zoh'; 'zoh'}
% {'T1'; 'T2'; 'T3'}
% {'^oC'; '^oC'; '^oC'}
% 'm'

if ~isfield(mlep.data,'sysIDInputDataSelected') || ~isfield(mlep.data,'sysIDOutputDataSelected')
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
else
    if ~size(mlep.data.sysIDOutputDataSelected,1) && ~size(mlep.data.sysIDInputDataSelected,1)
        mlep.data.mlepError = 'emptyArray';
        [mlep] = mlepThrowError(mlep);
        return;
    end
end

% Set Y = OUTPUTS
y = mlep.data.sysIDOutputDataSelected;
% Set U = INPUTS
u = mlep.data.sysIDInputDataSelected;
% Set Time in Minutes
Ts = mlep.data.timeStep*60;

% SET PROPERTIES
% INPUT NAME
mlep.data.inputName = {};
mlep.data.inputUnit = {};
for i = 1:size(mlep.data.sysIDInputDataSelected,2)
    mlep.data.inputName = [mlep.data.inputName [mlep.data.sysIDInputPropertySelected(i).object ' ' mlep.data.sysIDInputPropertySelected(i).name]];
    mlep.data.inputUnit = [mlep.data.inputUnit mlep.data.sysIDInputPropertySelected(i).unit];
end
% OUTPUT NAME
mlep.data.outputName = {};
mlep.data.outputUnit = {};
for i = 1:size(mlep.data.sysIDOutputDataSelected,2)
    mlep.data.outputName = [mlep.data.outputName [mlep.data.sysIDOutputPropertySelected(i).object ' ' mlep.data.sysIDOutputPropertySelected(i).name]];
    mlep.data.outputUnit = [mlep.data.outputUnit mlep.data.sysIDOutputPropertySelected(i).unit];
end

mlep.data.timeUnit = 'seconds';
 
% IDDATA
mlep.data.estData = iddata(y, u, Ts,...
    'Name', 'Estimated data disturbance',...
    'InputName', mlep.data.inputName,...%    'InputUnit', mlep.data.inputUnit,...
    'OutputName', mlep.data.outputName,... %    'OutputUnit', mlep.data.outputUnit,...
    'TimeUnit', mlep.data.timeUnit,...
    'Tstart', 0,...
    'Notes', 'Estimation data');

% Rename
mlep.data.estData = mlep.data.estData;
estData = mlep.data.estData;
% Select where to store and name file
[FileName,PathName] = uiputfile('EstData.mat','Save file name',[mlep.data.projectPath]);
save([PathName FileName], 'estData');
disp(['Saved Estimated Data File ' PathName FileName] );

%     'InputUnit', mlep.data.inputUnit,...
%    'OutputName', mlep.data.outputName,...
[mlep] = mlepUpdateSysIDTab(mlep);
end

function [mlep] = runIdent(mlep)
    % RUN IDENT 
    ident;
end
