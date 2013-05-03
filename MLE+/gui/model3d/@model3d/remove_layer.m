% FUNCTION newmodel = remove_layer(model,rmlist)
%
% Thsi function takes an input model, removes the
% layers indicated in "rmlist" and outputs the 
% result
%
% Inputs:
%
%   model   :   a 'model3d' class
%
%   rmllist :   The array of layers to be removed
%
% Outputs:
%
%   newmodel :  The model with the layers removed
%
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%


function model = remove_layer(oldmodel,rmlist)
  
  if isa(oldmodel,'model3d')==0
    error('First input must be a ''model3d'' type');
  end
  
  
  l = 1:length(oldmodel.layers);
  
  vlist = setxor(l,rmlist);
  model = oldmodel;
  model.layers = model.layers(vlist);
  