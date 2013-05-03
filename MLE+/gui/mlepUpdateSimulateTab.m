function [mlep] = mlepUpdateSimulateTab(mlep)
% Load Results
% filePath = regexprep(mlep.data.idfFile, 'idf', 'csv');
% [mlep.data.vars, mlep.data.varsData, ts] = mlepLoadEPResults([mlep.data.projectPath filePath]);
% 
% mlep.data.simulateListboxText = {};
% for i = 1:size(mlep.data.vars,1)
%     mlep.data.simulateListboxText{i} = [mlep.data.vars(i).object '-' mlep.data.vars(i).name];
% end
if isfield(mlep.data,'simulateListboxText')
    set(mlep.simulateListbox,'string',mlep.data.simulateListboxText);
end

cla(mlep.graph,'reset');
cla(mlep.dxfAxes,'reset');
end


