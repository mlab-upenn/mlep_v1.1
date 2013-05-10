function [] = mlepPresentationFunction(varargin)
% callback for pushbutton

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
functionName = varargin{4};

%% IDF FILE 
if strcmp(functionName,'selectIdf')
    [mlep] = selectIdf(mlep);
elseif strcmp(functionName,'openIdf')
    [mlep] = openIdf(mlep);
elseif strcmp(functionName,'loadIdf')
    [mlep] = loadIdf(mlep);
elseif strcmp(functionName,'getTimeStep')
    [mlep] = getTimeStep(mlep);

%% WEATHER FILE
elseif strcmp(functionName,'selectWeather')
    [mlep] = selectWeather(mlep);

%% SETTINGS 
elseif strcmp(functionName,'loadProject')
    [mlep] = loadProject(mlep);
elseif strcmp(functionName,'saveProject')
    [mlep] = saveProject(mlep);
elseif strcmp(functionName,'clearProject')
    [mlep] = clearProject(mlep);
elseif strcmp(functionName,'exit')
    [mlep] = closeGui(mlep);
end

if ~strcmp(functionName,'exit')
    % Save data structure
    guidata(handle, mlep);
end
end


%% IDF FILE 
function [mlep] = selectIdf(mlep)
% Select idf file
[FileName,PathName] = uigetfile('*.idf','Select IDF-file');
mlep.data.idfFile = FileName;
mlep.data.idfFullPath = [PathName FileName];
mlep.data.projectPath = PathName;
% Update text box
set(mlep.presentationIdfEdit,'string',mlep.data.idfFile);

% Update Time Step
if isfield(mlep.data,'idfFile')
    if ~isempty(mlep.data.idfFile)
        if ischar(mlep.data.idfFullPath)
            if exist(mlep.data.idfFullPath,'file')
                % EDIT IDF FILE
                timeStep = readIDF(mlep.data.idfFullPath,'Timestep');
                mlep.data.timeStep = 60/str2double(char(timeStep.fields{1}));
                ind = find(mlep.data.timeStep==str2double(mlep.timeStepList));
                set(mlep.presentationTimeStep, 'Value', ind);
            else
                %set(mlep.presentationTimeStep, 'Enable', 'off')
                
                mlep.data.mlepError = 'fileNotFound';
                mlepThrowError(mlep);
            end
        else
            mlep.data.mlepError = 'fileNotFound';
            mlepThrowError(mlep);
        end
    end
end

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

function [mlep] = loadIdf(mlep)
%% LOAD DATA IDF FILE
if ~isfield(mlep.data,'idfFile')
        errordlg('File not found','File Error');
    return
end

idfStruct = readIDF(mlep.data.idfFullPath,{'Timestep',...
    'RunPeriod',...
    'ExternalInterface:Schedule',...
    'ExternalInterface:Actuator',...
    'ExternalInterface:Variable',...
    'Output:Variable'});
mlep.data.timeStep = 60/str2double(char(idfStruct(1).fields{1}));
mlep.data.runPeriod = (str2double(char(idfStruct(2).fields{1}(4))) - str2double(char(idfStruct(2).fields{1}(2))))*31 + 1 + str2double(char(idfStruct(2).fields{1}(5))) - str2double(char(idfStruct(2).fields{1}(3)));
mlep.data.schedule = idfStruct(3).fields;
mlep.data.actuator = idfStruct(4).fields;
mlep.data.variable = idfStruct(5).fields;
mlep.data.output = idfStruct(6).fields;
end

function [mlep] = getTimeStep(mlep)
if isfield(mlep.data,'idfFile')
    if ~isempty(mlep.data.idfFile)
        if exist(mlep.data.idfFullPath,'file')
            % EDIT IDF FILE
            mlep.data.timeStep = 60/str2double(char(idfStruct(1).fields{1}));
        else
            mlep.data.mlepError = 'fileNotFound';
            mlepThrowError(mlep);
        end
    end
end
end

%% WEATHER FILE 
function [mlep] = selectWeather(mlep)
% load MLEPSETTINGS
var = load([mlep.homePath 'gui' filesep 'MLEPSETTINGS.mat']);
mlep.data.MLEPSETTINGS = var.MLEPSETTINGS;

% Select idf file [mlep.data.MLEPSETTINGS.path{1}{2} '.', filesep, 'WeatherData']
weatherPath = mlep.data.MLEPSETTINGS.path{1}{2};

if weatherPath(end) == filesep
    weatherPath = [weatherPath 'WeatherData'];
else
    weatherPath = [weatherPath filesep 'WeatherData'];
end
    
[FileName,PathName] = uigetfile('*.epw','Select EPW-file',weatherPath);
mlep.data.weatherFile = FileName;
mlep.data.weatherFullPath = [PathName FileName];
% Update text box 
set(mlep.presentationWeatherEdit,'string',mlep.data.weatherFile);
end


%% SETTINGS 
function [mlep] = loadProject(mlep)
% Load Project
% Select Project.prj file
[FileName,PathName] = uigetfile('*.prj','Select project file (.prj)' );

% If not picked any File
if (~ischar(FileName) || ~ischar(PathName))
    return;
else
    % Load Project.prj
    data = importdata([PathName FileName]);
    mlep.data = data;
    % Check for version 
    if (mlep.data.version1 ~= mlep.version1 || mlep.data.version2 ~= mlep.version2)
        mlep.data.mlepError = 'diffVersion';
        mlepThrowError(mlep);
        return; 
    end
    % Set Project Path
    mlep.data.projectPath = [PathName];
    
    % CD to Project Path
    cd (mlep.data.projectPath);
    % Update project Path
    [mlep] = updateProjectPath(mlep);
    % Callback for Writing cfg file
    if isfield(mlep.data,'inputTableData') && isfield(mlep.data,'outputTableData')
        % create variable.cfg
        [mlep] = mlepWriteConfig(mlep);
    end
    
    % Update presentation tab
    [mlep] = mlepUpdatePresentationTab(mlep);
    % Update system ID  tab
    [mlep] = mlepUpdateSysIDTab(mlep);
    % Update variable tab
    [mlep] = mlepUpdateVariableTab(mlep);
    % Update control tab
    [mlep] = mlepUpdateControlTab(mlep);
    % Update simulate tab
    [mlep] = mlepUpdateSimulateTab(mlep);
end

%% INITIALIZE NECESSARY VARIABLES
mlepInit;
mlep.data.MLEPSETTINGS = MLEPSETTINGS;
mlep.data.MLEPSETTINGS = MLEPSETTINGS;
mlep.data.MLEPSETTINGS.path = mlep.data.MLEPSETTINGS.env;
end

function [mlep] = saveProject(mlep)
% Save Project
% Version 
mlep.data.version1 = mlep.version1;
mlep.data.version2 = mlep.version2;
data = mlep.data;
% Select where to store and name file
[FileName,PathName] = uiputfile('mlepProject.prj','Save file name',[mlep.data.projectPath]);
% If no File Picked
if (~ischar(FileName) || ~ischar(PathName))
    return;
else
    save([PathName FileName], 'data');
    disp(['Saved Project File ' PathName FileName] );
end
end

function [mlep] = clearProject(mlep)
names = fieldnames(mlep.data);
 
for i = 1:size(names,1)
    if strcmp(class(mlep.data.(names{i})),'struct')
        mlep.data = setfield(mlep.data,names{i},struct());
    elseif strcmp(class(mlep.data.(names{i})),'cell')
        mlep.data = setfield(mlep.data,names{i},{});
    else
        mlep.data = setfield(mlep.data,names{i},[]);
    end        
end
%mlep.data = [];
% Update presentation tab
[mlep] = mlepUpdatePresentationTab(mlep);
% Update variable tab
[mlep] = mlepUpdateVariableTab(mlep);
% Update variable tab
[mlep] = mlepUpdateSysIDTab(mlep);
% Update control tab
[mlep] = mlepUpdateControlTab(mlep);
% Update simulate tab
[mlep] = mlepUpdateSimulateTab(mlep);

%% INITIALIZE NECESSARY VARIABLES
mlepInit;
mlep.data.MLEPSETTINGS = MLEPSETTINGS;
mlep.data.MLEPSETTINGS = MLEPSETTINGS;
mlep.data.MLEPSETTINGS.path = mlep.data.MLEPSETTINGS.env;
end

function [mlep] = closeGui(mlep)
% Deleting Variable Figure 
if isfield(mlep,'variableHandle')
	delete(mlep.variableHandle);
end
% Deleting Main Figure
delete(gcf);
end