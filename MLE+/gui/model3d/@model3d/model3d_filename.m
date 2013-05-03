% FUNCITON mname = model3d_filename(model)
%
% This function returns the filename that
% the input 'model3d' class was loaded from
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%
 
function mname = model3d_filename(model)
  
  if isa(model,'model3d')==0
    error('argument must be a ''model3d'' class');
  end
  
  mname = model.filename
