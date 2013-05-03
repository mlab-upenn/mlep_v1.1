function [mlep] = mlepUpdateVariableTab(mlep)

% Input Table
if ~isfield(mlep.data,'inputTableData')
    mlep.data.inputTableData = [];
end
% List Input
if ~isfield(mlep.data,'listInput')
    mlep.data.listInput = [];
end
% Output Table
if ~isfield(mlep.data,'outputTableData')
    mlep.data.outputTableData = [];
end
% List Output
if ~isfield(mlep.data,'listOutput')
    mlep.data.listOutput = [];
end
% Ext1 
if ~isfield(mlep.data,'listInputExt1')
    mlep.data.listInputExt1 = [];
end
% Input Comment 
if ~isfield(mlep.data,'listInputComment')
    mlep.data.listInputComment = [];
end	

% Output Comment 
if ~isfield(mlep.data,'listOutputComment')
    mlep.data.listOutputComment = [];
end	

% SET 
set(mlep.inputTable, 'Data', mlep.data.inputTableData);
set(mlep.variableInputListbox, 'String', mlep.data.listInput);
set(mlep.outputTable, 'Data', mlep.data.outputTableData);
set(mlep.variableOutputListbox, 'String', mlep.data.listOutput);

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