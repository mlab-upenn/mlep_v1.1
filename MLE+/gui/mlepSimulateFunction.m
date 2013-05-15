function [] = simulateFunction(varargin)
% callback for pushbutton

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
functionName = varargin{4};

if strcmp(functionName,'runSimulation')
    [mlep] = runSimulation(mlep);
elseif strcmp(functionName,'plotVariable')
    [mlep] = plotVariable(mlep);
elseif strcmp(functionName,'grid')
    [mlep] = gridToggle(mlep);
elseif strcmp(functionName,'saveResult')
    [mlep] = saveResult(mlep);
elseif strcmp(functionName,'saveAllResult')
    [mlep] = saveAllResult(mlep);
end


% Save data structure
guidata(handle, mlep);
end

function [mlep] = runSimulation(mlep)
% Change Button color
set(mlep.simulateRun, 'Background', mlep.background);
set(mlep.simulateListbox,'string','');
 

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
if (mlep.data.stopSimulation)
    return;
end

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
    % LOAD CSV RESULTS
    % TRY CATCH STATEMENT
    [mlep.data.vars, mlep.data.varsData, ts] = mlepLoadEPResults(pathOutput);
    
    % GET NAMES OF VARIABLES
    mlep.data.simulateListboxText = {};
    for i = 1:size(mlep.data.vars,1)
        mlep.data.simulateListboxText{i} = [mlep.data.vars(i).object '-' mlep.data.vars(i).name];
    end
    % Last Entry
    last = i;
    % Add Input
    for i = 1:size( mlep.data.inputFieldNames,2)
        mlep.data.simulateListboxText{i+last} = mlep.data.inputFieldNames{i};
        mlep.data.varsData(:,i+last) = mlep.data.mlepIn.(mlep.data.inputFieldNames{i})(1:size(mlep.data.varsData,1))';
        mlep.data.vars(i+last).object = mlep.data.inputFieldNames(i);
    end 
    
    if isempty(i)
        i = 0;
    end
    
    last = i+last;
    mlep.data.outputFieldNames = fieldnames(mlep.data.mlepOut);
    % Add Output
    for i = 1:size( mlep.data.outputFieldNames,1)
        mlep.data.simulateListboxText{i+last} = mlep.data.outputFieldNames{i};
        mlep.data.varsData(:,i+last) = mlep.data.mlepOut.(mlep.data.outputFieldNames{i})(1:size(mlep.data.varsData,1))';
        mlep.data.vars(i+last).object = mlep.data.outputFieldNames(i);
    end
    
    
    if size(mlep.data.simulateListboxText,2)
        set(mlep.simulateListbox,'value',1);
    end
    set(mlep.simulateListbox,'string',mlep.data.simulateListboxText);
 
    
else
    disp(['Project Folder' mlep.data.projectPath])
    mlep.data.mlepError = 'noOutputFileFound';
    mlepThrowError(mlep);
    return;
end

[mlep] = mlepDisplayDxf(mlep);

% Change Button color
set(mlep.simulateRun, 'Background', 'g');
end

function [mlep] = mlepDisplayDxf(mlep)

set(gcf,'CurrentAxes', mlep.dxfAxes);
set(mlep.dxfAxes, 'HandleVisibility', 'callback');

% CHECK DIRECTORIES FOR DXF FILE
filePath = regexprep(mlep.data.idfFile, 'idf', 'dxf');
pathOutput = [mlep.data.projectPath 'Output' filesep filePath];

% PLOT DXF IF EXIST
if exist(pathOutput,'file')
    % CHECK FOR CRASH
    try
        dxf = model3d(pathOutput);
        plot(dxf);
        grid on;
        
    catch err
        return;
    end
end
% SET INVISIBLE THE HANDLE
%set(mlep.dxfAxes, 'HandleVisibility', 'off');
end

function [mlep] = plotVariable(mlep)
% Get Selection Index
mlep.data.simulateListboxIndex = get(mlep.simulateListbox,'Value');
if ~isfield(mlep.data,'simulateListboxText')
    mlep.data.mlepError = 'emptyArray';
    mlepThrowError(mlep);
    return;
end

graphTitle = mlep.data.simulateListboxText(mlep.data.simulateListboxIndex);

% GET CURRENT AXES
set(gcf,'CurrentAxes', mlep.graph);
set(mlep.graph, 'HandleVisibility', 'callback');
%get(mlep.graph, 'HandleVisibility')
plot(mlep.data.varsData(:,mlep.data.simulateListboxIndex)); % CHECK THIS melp.graph,

title(mlep.graph,graphTitle);
if size(mlep.data.vars,1) >= mlep.data.simulateListboxIndex
    if size(mlep.data.simulateListboxIndex,2) == 1
        xlabel(mlep.graph,mlep.data.vars(mlep.data.simulateListboxIndex).sampling);
        ylabel(mlep.graph,[mlep.data.vars(mlep.data.simulateListboxIndex).name ' ' mlep.data.vars(mlep.data.simulateListboxIndex).unit]);
    end
    legend(mlep.data.vars(mlep.data.simulateListboxIndex).name)
end
[mlep] = gridToggle(mlep);

end

function [check] = checkInputFiles(mlep)
check = 1;
% Check for all variables
if ~isfield(mlep.data,'userdata')
%     mlep.data.mlepError = 'userDataMissing';
%     mlepThrowError(mlep);
%     check = 0;
    mlep.data.userdata = struct();
end

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

function [mlep] = gridToggle(mlep)
mlep.data.gridToggleValue = get(mlep.gridToggle,'Value');

if mlep.data.gridToggleValue
    set(mlep.graph, 'XGrid', 'on', 'YGrid', 'on');
else
    set(mlep.graph, 'XGrid', 'off', 'YGrid', 'off');
end
end

function [mlep] = saveResult(mlep)
mlep.data.simulateListboxIndex = get(mlep.simulateListbox,'Value');
% Select where to store and name file
[FileName,PathName] = uiputfile('mlepResult.mat','Save Results',[mlep.data.projectPath]);
% If not picked any File
if (~ischar(FileName) || ~ischar(PathName))
    return;
else
    data = struct();
    data.result = mlep.data.varsData(:,mlep.data.simulateListboxIndex);
    data.name = mlep.data.vars(mlep.data.simulateListboxIndex);
    save([PathName FileName], 'data');
    disp(['Saved Result in ' PathName FileName] );
end
end

function [mlep] = saveAllResult(mlep)
% Select where to store and name file
[FileName,PathName] = uiputfile('mlepResult.mat','Save Results',[mlep.data.projectPath]);
% If not picked any File
if (~ischar(FileName) || ~ischar(PathName))
    return;
else
    data = struct();
    data.result = mlep.data.varsData(:,:);
    data.name = mlep.data.vars(:);
    save([PathName FileName], 'data');
    disp(['Saved All Result in ' PathName FileName] );
end
end