function [] = mlepControlFunction(varargin)
% Main Function

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
%mlep.handle = handle;
functionName = varargin{4};


if strcmp(functionName,'getInputIndex')
    [mlep] = getInputIndex(mlep);
elseif strcmp(functionName,'getOutputIndex')
    [mlep] = getOutputIndex(mlep);
elseif strcmp(functionName,'editInputComment')
    [mlep] = editInputComment(mlep);
elseif strcmp(functionName,'editOutputComment')
    [mlep] = editOutputComment(mlep);
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
elseif strcmp(functionName,'getInputIndexPID')
    [mlep] = getInputIndexPID(mlep);
elseif strcmp(functionName,'loadVariables')
    [mlep] = loadVariables(mlep);
elseif strcmp(functionName,'openIdf')
    [mlep] = openIdf(mlep);
end

% Save data structure
guidata(handle, mlep);
end

function [mlep] = getInputIndex(mlep)
% Callback for get_scheduleIndex
% Get Selection Index
mlep.data.controlListInputIndex = get(mlep.controlInListbox,'Value');
if ~isempty(mlep.data.controlListInputIndex)
    set(mlep.controlInComment, 'String',mlep.data.listInputExt2{mlep.data.controlListInputIndex,6});
end
end

function [mlep] = getOutputIndex(mlep)
% Callback for get_scheduleIndex
% Get Selection Index
mlep.data.controlListOutputIndex = get(mlep.controlOutListbox,'Value');
if ~isempty(mlep.data.controlListOutputIndex)
    set(mlep.controlOutComment, 'String',mlep.data.listOutputExt2{mlep.data.controlListOutputIndex,5});
end
end

function [mlep] = editInputComment(mlep)
% Callback for editInputComment
if isfield(mlep.data,'controlListInputIndex')
    if ~isempty(mlep.data.controlListInputIndex)
        mlep.data.listInputExt2{mlep.data.controlListInputIndex,6} = get(mlep.controlInComment, 'String');
        set(mlep.controlInComment, 'String',mlep.data.listInputExt2{mlep.data.controlListInputIndex,6});
    end
end
end

function [mlep] = editOutputComment(mlep)
% Callback for editInputComment
if isfield(mlep.data,'controlListOutputIndex')
    if ~isempty(mlep.data.controlListOutputIndex)
        mlep.data.listOutputExt2{mlep.data.controlListOutputIndex,5} = get(mlep.controlOutComment, 'String');
        set(mlep.controlOutComment, 'String',mlep.data.listOutputExt2{mlep.data.controlListOutputIndex,5});
    end
end
end

function [mlep] = editControlFile(mlep)
% Callback for editInputComment
mlep.data.controlFileName = get(mlep.controlFeedbackCreateEdit, 'String');
end

function [mlep] = createControlFile(mlep)
mlep.data.controlFileName = get(mlep.controlFeedbackCreateEdit, 'String');
set(mlep.controlFeedbackLoadEdit, 'Background', 'white');
set(mlep.controlFeedbackCreateEdit, 'Background', 'c');
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
    set(mlep.controlFeedbackLoadEdit, 'Background', 'c');
    set(mlep.controlFeedbackCreateEdit, 'Background', 'white');
    mlep.data.controlCreated = 0;
    mlep.data.controlLoaded = 1;
    % Update text box
    set(mlep.controlFeedbackLoadEdit,'string',mlep.data.controlFileName);
end

end

function [mlep] = updateWorkspace(mlep)
% Update UserData workspace
mlep.data.workVars = evalin('base','who');
if isempty(mlep.data.workVars)
    mlep.data.mlepError = 'emptyWorspace';
    mlepThrowError(mlep);
    set(mlep.controlPopupUserdata,'String','Select User Data');
    set(mlep.controlPopupUserdata,'Enable','off');
    return;
else
    set(mlep.controlPopupUserdata,'String',mlep.data.workVars,'Enable','on');
end
end

function [mlep] = selectUserdata(mlep)
% Select UserData variable
mlep.data.workVars = evalin('base','who');
if isempty(mlep.data.workVars)
    mlep.data.mlepError = 'emptyWorspace';
    mlepThrowError(mlep);
    set(mlep.controlPopupUserdata,'Background','white','Enable','off','String','Select User Data');
    return;
else
    set(mlep.controlPopupUserdata,'Enable','on','Background','c');
    val = get(mlep.controlPopupUserdata, 'Value');
    mlep.data.userdata =  evalin('base',mlep.data.workVars{val});
end

end

function [mlep] = editControl(mlep)
% Select Edit Control File
cd(mlep.data.projectPath);
edit(mlep.data.controlFileName);
end

function [mlep] = getInputIndexPID(mlep)



end

function [mlep] = loadVariables(mlep)
%set(mlep.variableHandle,'visible','on');
%set(mlep.variableIdfName,'string',mlep.data.idfFile);
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
