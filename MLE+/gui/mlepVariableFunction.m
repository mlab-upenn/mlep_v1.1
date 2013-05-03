function [] = mlepVariableFunction(varargin)
% Main Function

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
functionName = varargin{4};

if strcmp(functionName,'idfLoad')
    [mlep] = loadIdf(mlep);
elseif strcmp(functionName,'idfOpen')
    [mlep] = openIdf(mlep);
elseif strcmp(functionName,'getInputIndex')
    [mlep] = getInputIndex(mlep);
elseif strcmp(functionName,'getOutputIndex')
    [mlep] = getOutputIndex(mlep);
elseif strcmp(functionName,'addInput')
    [mlep] = addInput(mlep);
elseif strcmp(functionName,'deleteInput')
    [mlep] = deleteInput(mlep);
elseif strcmp(functionName,'duplicateInput')
    [mlep] = duplicateInput(mlep);
elseif strcmp(functionName,'addOutput')
    [mlep] = addOutput(mlep);
elseif strcmp(functionName,'deleteOutput')
    [mlep] = deleteOutput(mlep);
elseif strcmp(functionName,'duplicateOutput')
    [mlep] = duplicateOutput(mlep);
elseif strcmp(functionName,'editInputTable')
    [mlep] = editInputTable(mlep);
elseif strcmp(functionName,'editOutputTable')
    [mlep] = editOutputTable(mlep);
elseif strcmp(functionName,'writeCfgCall')
    [mlep] = writeConfigCall(mlep);
elseif strcmp(functionName,'editInputComment')
    [mlep] = editInputComment(mlep);
elseif strcmp(functionName,'editOutputComment')
    [mlep] = editOutputComment(mlep);
elseif strcmp(functionName,'getInputIndexID')
    [mlep] = getInputIndexID(mlep);
elseif strcmp(functionName,'closeVariableTab')
    [mlep] = closeVariableTab(mlep);
end

% Save data structure
guidata(handle, mlep);
end

function [mlep] = loadIdf(mlep)
%% COLLECT DATA IDF FILE
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

% Format
% List Schedules
mlep.data.listInput = {};
mlep.data.listInputExt1 = {};
mlep.data.listInputExt2 = {};
mlep.data.listInputComment = {};
for i = 1:size(mlep.data.schedule,2)
    if ~size(mlep.data.schedule,1)
        break;
    end
    mlep.data.listInput{i} = char(mlep.data.schedule{i}(1));
    mlep.data.listInputExt1{i,1} = 'Ptolomy';
    mlep.data.listInputExt1{i,2} = 'schedule';
    mlep.data.listInputExt1{i,3} = char(mlep.data.schedule{i}(1));
    mlep.data.listInputExt1{i,4} = char(mlep.data.schedule{i}(2));
    mlep.data.listInputExt1{i,5} = char(mlep.data.schedule{i}(3));
    mlep.data.listInputExt1{i,6} = ['SCHEDULE: ', char(mlep.data.schedule{i}(1)), ' - ',char(mlep.data.schedule{i}(2)), ' - ', char(mlep.data.schedule{i}(3))];
    mlep.data.listInputExt1{i,7} = 'Alias';
end

% List Actuators
inputSize = size(mlep.data.listInput,2);
for i = 1:size(mlep.data.actuator,2)
    if ~size(mlep.data.actuator,1)
        break;
    end
    mlep.data.listInput{inputSize+i} = char(mlep.data.actuator{i}(1));
    mlep.data.listInputExt1{inputSize+i,1} = 'Ptolomy';
    mlep.data.listInputExt1{inputSize+i,2} = 'actuator';
    mlep.data.listInputExt1{inputSize+i,3} = char(mlep.data.actuator{i}(1));
    mlep.data.listInputExt1{inputSize+i,4} = char(mlep.data.actuator{i}(2));
    mlep.data.listInputExt1{inputSize+i,5} = char(mlep.data.actuator{i}(3));
    mlep.data.listInputExt1{inputSize+i,6} = ['ACTUATOR: ', char(mlep.data.actuator{i}(1)), ' - ', char(mlep.data.actuator{i}(2)), ' - ', char(mlep.data.actuator{i}(3))];
    mlep.data.listInputExt1{inputSize+i,7} = 'Alias';
end

% List Variable
inputSize = size(mlep.data.listInput,2);
for i = 1:size(mlep.data.variable,2)
    if ~size(mlep.data.variable,1)
        break;
    end
    mlep.data.listInput{inputSize+i} = char(mlep.data.variable{i}(1));
    mlep.data.listInputExt1{inputSize+i,1} = 'Ptolomy';
    mlep.data.listInputExt1{inputSize+i,2} = 'variable';
    mlep.data.listInputExt1{inputSize+i,3} = char(mlep.data.variable{i}(1));
    mlep.data.listInputExt1{inputSize+i,4} = char(mlep.data.variable{i}(2));
    mlep.data.listInputExt1{inputSize+i,5} = 'Variable';
    mlep.data.listInputExt1{inputSize+i,6} = ['VARIABLE: ', char(mlep.data.variable{i}(1)), ' - ', char(mlep.data.variable{i}(2))];
    mlep.data.listInputExt1{inputSize+i,7} = 'Alias';
end

% List Outputs
mlep.data.listOutput = {};
mlep.data.listOutputExt1 = {};
mlep.data.listOutputExt2 = {};
mlep.data.listOutputComment = {};
for i = 1:size(mlep.data.output,2)
    mlep.data.listOutput{i} = char(mlep.data.output{i}(2));
    mlep.data.listOutputExt1{i,1} = 'EnergyPlus';
    mlep.data.listOutputExt1{i,2} = char(mlep.data.output{i}(1));
    mlep.data.listOutputExt1{i,3} = char(mlep.data.output{i}(2));
    mlep.data.listOutputExt1{i,4} = char(mlep.data.output{i}(3));
    mlep.data.listOutputExt1{i,5} = ['OUTPUT: ', char(mlep.data.output{i}(1)), ' - ', char(mlep.data.output{i}(3))];
    mlep.data.listOutputExt1{i,6} = 'Alias';
end

mlep.data.inputTableData = {};
mlep.data.outputTableData = {};

% Update Variable Tab
[mlep] = mlepUpdateVariableTab(mlep);

%% UPDATE FIELDS
% Input
mlep.data.listInputIndex = 1;
set(mlep.variableInputListbox,'String',mlep.data.listInput);
if size(mlep.data.listInputExt1,1) == 0
    comment = [];
else
    comment = mlep.data.listInputExt1{mlep.data.listInputIndex,6};
end
set(mlep.variableInputComment,'String', comment);

% Output
mlep.data.listOutputIndex = 1;
set(mlep.variableOutputListbox, 'String', mlep.data.listOutput);
if size(mlep.data.listOutputComment,1) == 0
    comment = [];
else
    comment = mlep.data.listOutputExt1{mlep.data.listOutputIndex,5};
end
set(mlep.variableOutputComment,'String', comment);
end

function [mlep] = openIdf(mlep)
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
end

function [mlep] = getInputIndex(mlep)
% Callback for getScheduleIndex
% Get Selection Index
mlep.data.listInputIndex = get(mlep.variableInputListbox,'Value');
set(mlep.variableInputComment,'String',mlep.data.listInputExt1{mlep.data.listInputIndex,6});
end

function [mlep] = getOutputIndex(mlep)
% Callback for getOutputIndex
% Get Selection Index
mlep.data.listOutputIndex = get(mlep.variableOutputListbox,'Value');
set(mlep.variableOutputComment,'String',mlep.data.listOutputExt1{mlep.data.listOutputIndex,5});
end

function [mlep] = addInput(mlep)
% Empty Array
if ~size(mlep.data.listInput,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Callback for add input
mlep.data.inputTableData = [mlep.data.inputTableData; {false, mlep.data.listInputExt1{mlep.data.listInputIndex,2}, mlep.data.listInputExt1{mlep.data.listInputIndex,3},  mlep.data.listInputExt1{mlep.data.listInputIndex,7}}];
mlep.data.listInputExt2 = [mlep.data.listInputExt2; mlep.data.listInputExt1(mlep.data.listInputIndex,:)];
mlep.data.listInputExt1(mlep.data.listInputIndex,:) = [];
mlep.data.listInput(mlep.data.listInputIndex) = [];

index = mlep.data.listInputIndex-1;
if index==0
    index = 1;
end
set(mlep.variableInputListbox,'Value',index);
mlep.data.listInputIndex = index;

% Update table & listbox
[mlep] = mlepUpdateVariableTab(mlep);

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = deleteInput(mlep)
% Callback for delete input
% Get data from table
eraseList = [];
mlep.data.inputTableData = get(mlep.inputTable, 'Data');
for i=1:size(mlep.data.inputTableData,1)
    if mlep.data.inputTableData{i,1} == true
        eraseList = [eraseList i];
    end
end
if ~isempty(eraseList)
    mlep.data.listInputExt1 = [mlep.data.listInputExt1; mlep.data.listInputExt2(eraseList,:)];
    mlep.data.listInput = [mlep.data.listInput, mlep.data.listInputExt2(eraseList,3)'];
    mlep.data.listInputExt2(eraseList,:) = [];
    mlep.data.inputTableData(eraseList,:) = [];
else
    mlep.data.mlepError = 'noSelection';
    [mlep] = mlepThrowError(mlep);
end

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = duplicateInput(mlep)
% % Callback for duplicate input
% % Get data from table
% duplicateList = [];
% mlep.data.inputTableData = get(mlep.inputTable, 'Data');
% for i=1:size(mlep.data.inputTableData,1)
%     if mlep.data.inputTableData{i,1} == true
%         duplicateList = [duplicateList i];
%     end
% end
%
% if ~isempty(duplicateList)
%     mlep.data.listInputExt2 = [mlep.data.listInputExt2; mlep.data.listInputExt2(duplicateList,:)];
%     mlep.data.inputTableData = [mlep.data.inputTableData; mlep.data.inputTableData(duplicateList,:)];
% else
%     mlep.data.mlepError = 'noSelection';
%     [mlep] = mlepThrowError(mlep);
% end
%
% % Update table & listbox
% [mlep] = mlepUpdateVariableTab(mlep);
%
% % Load Control Variables
% loadControlVar(mlep);
end

function [mlep] = addOutput(mlep)
% Empty Array
if ~size(mlep.data.listOutput,2)
    mlep.data.mlepError = 'emptyArray';
    [mlep] = mlepThrowError(mlep);
    return;
end

% Callback for add output
mlep.data.outputTableData = [mlep.data.outputTableData; {false, mlep.data.listOutputExt1{mlep.data.listOutputIndex,2}, mlep.data.listOutputExt1{mlep.data.listOutputIndex,3}, mlep.data.listOutputExt1{mlep.data.listOutputIndex,6}}];
mlep.data.listOutputExt2 = [mlep.data.listOutputExt2; mlep.data.listOutputExt1(mlep.data.listOutputIndex,:)];
mlep.data.listOutputExt1(mlep.data.listOutputIndex,:) = [];
mlep.data.listOutput(mlep.data.listOutputIndex) = [];

index = mlep.data.listOutputIndex-1;
if index==0
    index = 1;
end
set(mlep.variableOutputListbox,'Value',index);
mlep.data.listOutputIndex = index;

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = deleteOutput(mlep)
% Callback for delete input
% Get data from table
eraseList = [];
mlep.data.outputTableData = get(mlep.outputTable, 'Data');
for i=1:size(mlep.data.outputTableData,1)
    if mlep.data.outputTableData{i,1} == true
        eraseList = [eraseList i];
    end
end
if ~isempty(eraseList)
    mlep.data.listOutputExt1 = [mlep.data.listOutputExt1; mlep.data.listOutputExt2(eraseList,:)];
    mlep.data.listOutput = [mlep.data.listOutput, mlep.data.listOutputExt2(eraseList,3)'];
    mlep.data.listOutputExt2(eraseList,:) = [];
    mlep.data.outputTableData(eraseList,:) = [];
else
    mlep.data.mlepError = 'noSelection';
    [mlep] = throwError(mlep);
end

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = duplicateOutput(mlep)
% Callback for duplicate input
% Get data from table
duplicateList = [];
mlep.data.outputTableData = get(mlep.outputTable, 'Data');
for i=1:size(mlep.data.outputTableData,1)
    if mlep.data.outputTableData{i,1} == true
        duplicateList = [duplicateList i];
    end
end

if ~isempty(duplicateList)
    mlep.data.listOutputExt2 = [mlep.data.listOutputExt2; mlep.data.listOutputExt2(duplicateList,:)];
    mlep.data.outputTableData = [mlep.data.outputTableData; mlep.data.outputTableData(duplicateList,:)];
else
    mlep.data.mlepError = 'noSelection';
    [mlep] = mlepThrowError(mlep);
end

% Update table & listbox
[mlep] = mlepUpdateVariableTab(mlep);

% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = editInputTable(mlep)
% Callback for editInputTable
% Update table data
mlep.data.inputTableData = get(mlep.inputTable, 'Data');
mlep.data.listInputExt2(:,7) = mlep.data.inputTableData(:,4);
% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = editOutputTable(mlep)
% Callback for editInputTable
% Update table data
mlep.data.outputTableData = get(mlep.outputTable, 'Data');
mlep.data.listOutputExt2(:,6) = mlep.data.outputTableData(:,4);
% Load Control Variables
loadControlVar(mlep);
end

function [mlep] = writeConfigCall(mlep)
% Callback for Writing cfg file
set(mlep.inputTable, 'Data', mlep.data.inputTableData);
set(mlep.outputTable, 'Data', mlep.data.outputTableData);
% create variable.cfg
[mlep] = mlepWriteConfig(mlep);
% Create Struct to store SYSID info
mlep.data.sysIDinputParam = cell(size(mlep.data.inputTableData,1),9);

% Init Param
for i = 1:size(mlep.data.inputTableData,1)
    mlep.data.sysIDinputParam{i,1} = 1;
    mlep.data.sysIDinputParam{i,2} = 1;
    mlep.data.sysIDinputParam{i,3} = 0;
    mlep.data.sysIDinputParam{i,4} = 1;
    mlep.data.sysIDinputParam{i,5} = 0;
    mlep.data.sysIDinputParam{i,6} = 1;
    mlep.data.sysIDinputParam{i,7} = 1;
    mlep.data.sysIDinputParam{i,8} = 0;
    mlep.data.sysIDinputParam{i,9} = 0;
end
% Update
%[mlep] = mlepUpdateSysIDParam(mlep);

end

function [mlep] = loadControlVar(mlep)
% Load control variables
[mlep] = mlepUpdateVariableTab(mlep);
[mlep] = mlepUpdateSysIDTab(mlep);
[mlep] = mlepUpdateControlTab(mlep);
end

function [mlep] = editInputComment(mlep)
% Edit Input Comment
if size(mlep.data.listInput,2)
    mlep.data.listInputExt1{mlep.data.listInputIndex,6} = get(mlep.variableInputComment, 'String');
    set(mlep.variableInputComment,'String', mlep.data.listInputExt1{mlep.data.listInputIndex,6});
end
end

function [mlep] = editOutputComment(mlep)
% Edit Output Comment
if size(mlep.data.listOutput,2)
    mlep.data.listOutputExt1{mlep.data.listOutputIndex,5} = get(mlep.variableOutputComment, 'String');
    set(mlep.variableOutputComment,'String', mlep.data.listOutputExt1{mlep.data.listOutputIndex,5});
end
end


function [mlep] = getInputIndexID(mlep)
% Callback for getScheduleIndex
% Get Selection Index
mlep.data.listInputIndexID = get(mlep.sysIDInListboxID,'Value');
end

function [mlep] = closeVariableTab(mlep)
% Callback for close request
if isfield(mlep.data,'inputTableData')
    mlep.data.sysIDinputParam = cell(size(mlep.data.inputTableData,1),9);
    % Init Checkbox
    for i = 1:size(mlep.data.inputTableData,1)
        mlep.data.sysIDinputParam{i,1} = 1;
        mlep.data.sysIDinputParam{i,2} = 1;
        mlep.data.sysIDinputParam{i,3} = 0;
        mlep.data.sysIDinputParam{i,4} = 1;
        mlep.data.sysIDinputParam{i,5} = 0;
        mlep.data.sysIDinputParam{i,6} = 1;
        mlep.data.sysIDinputParam{i,7} = 1;
        mlep.data.sysIDinputParam{i,8} = 0;
        mlep.data.sysIDinputParam{i,9} = 0;
    end
end
mlep.data.sysIDinputIndex = 1;

set(mlep.variableHandle,'Visible', 'off');
end

%
% set(mlep.inputTable, 'Data', mlep.inputTableData);
% set(mlep.variableInputListbox, 'String', mlep.listInput);
% set(mlep.variableInputComment,'String', mlep.listInputExt1{mlep.listInputIndex,6});
