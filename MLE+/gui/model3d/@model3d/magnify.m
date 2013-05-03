% FUNCTION mout = magnify(model,magnification);
%
% This function magnifies the model without
% translating it and puts the output in the "mout"
% variable
% The "center" of the magnification is the 
% "center-of-mass" of the model
% (see center_of_mass function)
%
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005



function mout = magnify(model,magnification)
  
  if isa(model,'model3d')==0
    error('1st input must be a ''model3d'' class');
  end
  
  com= center_of_mass(model);
  mout = model -com;
  mout = mout * magnification;
  mout = mout + com;
  