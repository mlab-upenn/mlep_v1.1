% Function names = layer_names(model)
%
% This function returns a cell array containing
% the names of all the layres in 'model',
% which should be an object of 'model3d' type
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/05
%
function names = layer_names(model)
  
  if isa(model,'model3d')==0
    error('Input must be a 3d model');
  end
  
  for idx=1:length(model.layers)
    names{idx} = model.layers(idx).name;
  end;
  