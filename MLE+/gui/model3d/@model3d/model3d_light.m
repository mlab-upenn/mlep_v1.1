% Function model3d_light(model)
%
% Description:
%
%  This function sets the lighting in the figure
%  to be that defined in the model.
%
%  If no lighting is defined in the model, 
%  nothing is done.
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
function varargout = model3d_light(model)
  
  if isa(model,'model3d')==0
    error('First argument must be of type ''model3d''');
  end
  
  
  % Create the lights according to the positions
  % defined in the file
  for i1 = 1:length(model.lights)
    l(i1) = light;
    set(l,'position',double(model.lights(i1).pos));
  end

  % Set the light to interpolate between faces
  lighting gouraud
  
  if(nargout > 0)
    varargout{1} = l;
  end
  
