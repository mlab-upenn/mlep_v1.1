% FUNCTION type = model_type(model)
%
% This function returns the type of file
% that the input 'model3d' class was loaded
% from
%
% Options are:
%
%   '3ds'  :   3D Studio Max file format
%   'dxf'  :   Autocad "DXF" file format
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%

function type = model_type(model)
  
  if isa(model,'model3d')==0
    error('Input must be a ''model3d'' type');
  end
  
  type = model.type;
  