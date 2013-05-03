function [mlep] = mlepUpdateControlTab(mlep)

mlep.data.controlListInputIndex = 1;
mlep.data.controlListOutputIndex = 1;

%% EXISTENCE
% Ext2
if ~isfield(mlep.data,'listInputExt2')
    mlep.data.listInputExt2 = [];
end
% Control File 
if ~isfield(mlep.data,'controlFileName')
	mlep.data.controlFileName = [];
end
% Workspace Vars
if ~isfield(mlep.data,'workVars')
	mlep.data.workVars = [];
end
%% SIZE
if size(mlep.data.listInputExt2,1)
    % INput Variables
    set(mlep.controlInComment, 'String', mlep.data.listInputExt2{mlep.data.controlListInputIndex,6}, 'Enable', 'on');
    set(mlep.controlInListbox, 'Value', mlep.data.controlListInputIndex);
    set(mlep.controlInListbox, 'String', mlep.data.listInputExt2(:,7), 'Enable', 'on');
else
    % Inactive
    set(mlep.controlInComment, 'String', [], 'Enable', 'off');
    set(mlep.controlInListbox, 'String', [], 'Enable', 'off');
end

if isfield(mlep.data,'listOutputExt2')
    if size(mlep.data.listOutputExt2,1)
        % OUTput Variables
        set(mlep.controlOutComment, 'String',mlep.data.listOutputExt2{mlep.data.controlListOutputIndex,5}, 'Enable', 'on');
        set(mlep.controlOutListbox, 'Value', mlep.data.controlListOutputIndex);
        set(mlep.controlOutListbox, 'String', mlep.data.listOutputExt2(:,6), 'Enable', 'on');
    else
        % Inactive
        set(mlep.controlOutComment, 'String', [], 'Enable', 'off');
        set(mlep.controlOutListbox, 'String', [], 'Enable', 'off');
    end
end

% Update Controller Type
% User Defined
% Control File used
set(mlep.controlFeedbackLoadEdit,'string',mlep.data.controlFileName);
% Update UserData workspace
if isempty(mlep.data.workVars)
    set(mlep.controlPopupUserdata,'String','Select User Data');
    set(mlep.controlPopupUserdata,'Enable','off');
    return;
else
    set(mlep.controlPopupUserdata,'String',mlep.data.workVars,'Enable','on');
end

% Update Controller Selected
if isfield(mlep.data,'controlLoaded')
    if mlep.data.controlLoaded == 1
        set(mlep.controlFeedbackLoadEdit, 'Background', 'c');
        set(mlep.controlFeedbackCreateEdit, 'Background', 'white');
    end
end
if isfield(mlep.data,'controlCreated')
    if mlep.data.controlCreated == 1
        set(mlep.controlFeedbackLoadEdit, 'Background', 'white');
        set(mlep.controlFeedbackCreateEdit, 'Background', 'c');
    end
end

%%

end