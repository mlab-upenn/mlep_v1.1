function [] = mlepBacnetFunction(varargin)
% Main Function

% Get the structure.
handle = varargin{3};
mlep = guidata(handle);
functionName = varargin{4};

%% LIST DEVICES
if strcmp(functionName,'listAllDevices')
    [mlep] = listAllDevices(mlep);
elseif strcmp(functionName,'listRangeDevices')
    [mlep] = listRangeDevices(mlep);
elseif strcmp(functionName,'listDevicesID')
    [mlep] = listDevicesID(mlep);
elseif strcmp(functionName,'getListDevicesIndex')
    [mlep] = getListDevicesIndex(mlep);

%% READ      
elseif strcmp(functionName,'getReadDeviceID')
    [mlep] = getReadDeviceID(mlep);
elseif strcmp(functionName,'getReadObjectIndex')
    [mlep] = getReadObjectIndex(mlep);
elseif strcmp(functionName,'getReadPropertyIndex')
    [mlep] = getReadPropertyIndex(mlep);
elseif strcmp(functionName,'functionReadProperty')
    [mlep] = functionReadProperty(mlep);
    
    
    
%% WRITE    
elseif strcmp(functionName,'getWriteDeviceID')
    [mlep] = getWriteDeviceID(mlep);
elseif strcmp(functionName,'getWriteObjectIndex')
    [mlep] = getWriteObjectIndex(mlep);
elseif strcmp(functionName,'getWritePropertyIndex')
    [mlep] = getWritePropertyIndex(mlep);
elseif strcmp(functionName,'getWriteApplicationIndex')
    [mlep] = getWriteApplicationIndex(mlep);
elseif strcmp(functionName,'getWriteValue')
    [mlep] = getWriteValue(mlep);
elseif strcmp(functionName,'functionWriteProperty')
    [mlep] = functionWriteProperty(mlep);
end

% Save data structure
guidata(handle, mlep);
end

%% LIST DEVICES 
function [mlep] = listAllDevices(mlep)
% Callback for listAllDevices
% CALL WI
[mlep.data.BACnetStatus,mlep.data.BACnetResults] = dos([mlep.BACnetDir 'bacwi -1']);
if ~mlep.data.BACnetStatus
    % Show information about device
    set(mlep.bacnetDeviceInfo,'String',mlep.data.BACnetResults);
end
    % Throw Error 
    mlep.data.mlepError = 'noBACnetDevice';
    mlepThrowError(mlep);
end

function [mlep] = listRangeDevices(mlep)
% Callback for listRangeDevices

end

function [mlep] = listDevicesID(mlep)
% Callback for listDevicesID

end

function [mlep] = getListDevicesIndex(mlep)
% Callback for getListDevicesIndex

end

%% READ
function [mlep] = getReadDeviceID(mlep)
% Callback for getReadDeviceID
value = get(mlep.readDeviceID, 'String');

% CHECK IT IS NUMBER
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
mlep.data.readBacnetDeviceID = value;

end

function [mlep] = getReadObjectIndex(mlep)
% Callback for getReadObjectIndex
mlep.readBACnetObject;
mlep.readBACnetObjectValue = [2 1 3 4];
index = get(mlep.readBACnetObjectSelect,'Value');
mlep.data.readBACnetObjectSelected = mlep.readBACnetObjectValue(index);
end

function [mlep] = getReadPropertyIndex(mlep)
% Callback for getReadPropertyIndex
mlep.readBACnetProperty;
mlep.readBACnetPropertyValue = [85 77 65 69 108];
index = get(mlep.readBACnetPropertySelect,'Value');
mlep.data.readBACnetPropertySelected = mlep.readBACnetPropertyValue(index);
end

function [mlep] = functionReadProperty(mlep)
% Callback for getReadPropertyIndex
[mlep.data.BACnetStatus,mlep.data.BACnetResults] = dos([mlep.BACnetDir 'bacrp ' num2str(mlep.data.readBacnetDeviceID) ' ' num2str(mlep.data.readBACnetObjectSelected)...
    ' 1 ' num2str(mlep.data.readBACnetPropertySelected)]);
if ~mlep.data.BACnetStatus
    set(mlep.bacnetReadResult,'String',mlep.data.BACnetResults);
    set(mlep.readFunction, 'Background', 'c');
else
    set(mlep.bacnetReadResult,'String','Error');
    set(mlep.readFunction, 'Background', 'r');
end
set(mlep.bacnetReadInfo, 'String', mlep.data.BACnetResults);
end

%% WRITE 
function [mlep] = getWriteDeviceID(mlep)
% Callback for getWriteDeviceID
value = get(mlep.writeDeviceID, 'String');

% CHECK IT IS NUMBER
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
mlep.data.writeBacnetDeviceID = value;

end

function [mlep] = getWriteObjectIndex(mlep)
% Callback for getWriteObjectIndex
mlep.writeBACnetObject;
mlep.writeBACnetObjectValue = [2 1 3 4];
index = get(mlep.writeBACnetObjectSelect,'Value');
mlep.data.writeBACnetObjectSelected = mlep.writeBACnetObjectValue(index);
end

function [mlep] = getWritePropertyIndex(mlep)
% Callback for getWritePropertyIndex
mlep.writeBACnetProperty;
mlep.writeBACnetPropertyValue = [85 77 65 69 108];
index = get(mlep.writeBACnetPropertySelect,'Value');
mlep.data.writeBACnetPropertySelected = mlep.writeBACnetPropertyValue(index);
end


function [mlep] = getWriteApplicationIndex(mlep)
% Callback for getWritePropertyIndex
mlep.writeApplicationTag;
mlep.writeApplicationTagValue = [1 4 7 2];
index = get(mlep.bacnetWriteApplicationTagSelect,'Value');
mlep.data.writeBACnetTagSelected = mlep.writeApplicationTagValue(index);
end

function [mlep] = getWriteValue(mlep)
% Callback for getWriteDeviceID
value = get(mlep.bacnetWriteEditValue, 'String');

% CHECK IT IS NUMBER
if ~isletter(value)
    value = str2num(value);
else
    mlep.data.mlepError = 'notNumber';
    mlepThrowError(mlep);
end
% Set parameter
mlep.data.writeBacnetValue = value;
end

function [mlep] = functionWriteProperty(mlep)
% Callback for getReadPropertyIndex
[mlep.data.BACnetStatus,mlep.data.BACnetResults] = dos([mlep.BACnetDir 'bacwp '...
    num2str(mlep.data.writeBacnetDeviceID) ' ' num2str(mlep.data.writeBACnetObjectSelected) ' 1 ' num2str(mlep.data.writeBACnetPropertySelected) ' 16 -1 '...
    num2str(mlep.data.writeBACnetTagSelected) ' ' num2str(mlep.data.writeBacnetValue)]);

% STATUS
if ~mlep.data.BACnetStatus 
    set(mlep.writeFunction,'Background','c');
    
else
    set(mlep.writeFunction,'Background','r');
end
set(mlep.bacnetWriteInfo, 'String', mlep.data.BACnetResults);
end

