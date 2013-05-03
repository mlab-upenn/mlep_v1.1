function [mlep] = mlepUpdateSysIDTab(mlep)

mlep.data.sysIDListInputIndex = 1;
mlep.data.sysIDListOutputIndex = 1;

%% CHECK EXISTENCE
% Ext2
if ~isfield(mlep.data,'listInputExt2')
    mlep.data.listInputExt2 = [];
end
% Ext2
if ~isfield(mlep.data,'listOutputExt2')
    mlep.data.listOutputExt2 = [];
end

%% CHECK SIZE - Inputs/Input ID Listbox - Comments
if size(mlep.data.listInputExt2,1)
    % INput Variables
    set(mlep.sysIDInComment, 'String',mlep.data.listInputExt2{mlep.data.sysIDListInputIndex,6}, 'Enable', 'on');
    set(mlep.sysIDInListbox, 'Value', mlep.data.sysIDListInputIndex);
    set(mlep.sysIDInListbox, 'String', mlep.data.listInputExt2(:,7), 'Enable', 'on');
    set(mlep.sysIDInListboxID, 'Value', mlep.data.sysIDListInputIndex);
    set(mlep.sysIDInListboxID, 'String', mlep.data.listInputExt2(:,7), 'Enable', 'on');
else
    % Inactive
    set(mlep.sysIDInComment, 'String', [], 'Enable', 'off');
    set(mlep.sysIDInListbox, 'String', [], 'Enable', 'off');
    set(mlep.sysIDInListboxID, 'String', [], 'Enable', 'off');
end

%% CHECK SIZE - Outputs Listbox - Comments
if size(mlep.data.listOutputExt2,1)
    % OUTput Variables
    set(mlep.sysIDOutComment, 'String',mlep.data.listOutputExt2{mlep.data.sysIDListOutputIndex,5}, 'Enable', 'on');
    set(mlep.sysIDOutListbox, 'Value', mlep.data.sysIDListOutputIndex);
    set(mlep.sysIDOutListbox, 'String', mlep.data.listOutputExt2(:,6), 'Enable', 'on');
else
    % Inactive
    set(mlep.sysIDOutComment, 'String', [], 'Enable', 'off');
    set(mlep.sysIDOutListbox, 'String', [], 'Enable', 'off');
end

%% Set Variables Listbox
if ~isfield(mlep.data,'sysIDvarsIndex')
    mlep.data.sysIDvarsIndex = 1;
end
set(mlep.sysIDvarsListbox, 'Value', mlep.data.sysIDvarsIndex);

if isfield(mlep.data,'sysIDvarsText')
    set(mlep.sysIDvarsListbox, 'String', mlep.data.sysIDvarsText, 'Enable', 'on');
else
    set(mlep.sysIDvarsListbox, 'Enable', 'off');
end

%% Set Input IDDATA
% Set index of input listbox 
if ~isfield(mlep.data,'sysIDInputTextSelectedIndex')
    mlep.data.sysIDInputTextSelectedIndex = 1;
end
set(mlep.sysIDInputListboxSelected, 'Value', mlep.data.sysIDInputTextSelectedIndex);

% Check for Input selected
if isfield(mlep.data,'sysIDInputTextSelected')
    set(mlep.sysIDInputListboxSelected, 'String', mlep.data.sysIDInputTextSelected, 'Enable', 'on');
else
    set(mlep.sysIDInputListboxSelected, 'Enable', 'off');
end

%% Set Output IDDATA
% Set index of output listbox 
if ~isfield(mlep.data,'sysIDOutputTextSelectedIndex')
    mlep.data.sysIDOutputTextSelectedIndex = 1;
end
set(mlep.sysIDOutputListboxSelected, 'Value', mlep.data.sysIDOutputTextSelectedIndex);

% Check for Output selected
if isfield(mlep.data,'sysIDOutputTextSelected')
    set(mlep.sysIDOutputListboxSelected, 'String', mlep.data.sysIDOutputTextSelected, 'Enable', 'on');
else
    set(mlep.sysIDOutputListboxSelected, 'Enable', 'off');
end

%% SET SYS PARAM
[mlep] = mlepUpdateSysIDParam(mlep);
end