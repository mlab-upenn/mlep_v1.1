% FUNCTION newmodel = minus(model,vec)
%
%  This functions subtracts the input 3D vector
%  from each element of the input model 
%  and outputs the new model
%
% Inputs:
%  
%   model :  The 'model3d' class input
%
%   vec   :  The 3D vector
%
% Outputs:
%
%   newmodel : the output 'model3d' class
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%
  
function d3 = minus(d1,d2)
  
  if(isnumeric(d2)==0)
    error('Second argument must be a 3 element vector')
  end
  
  d3 = plus(d1,-d2);