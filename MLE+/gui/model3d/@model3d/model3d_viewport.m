% FUNCTION model3d_viewport(model,ax)
%
% Description:
%
%   This function sets the current axis viewport
%   to be that defined in the model
%
%   If no viewport is defined in the model
%   the default viewport is returned
%
%   see help for the 'view' function'
%
% Inputs:
%
%  model :     A 'model3d' class
%
%  ax    :     An optional second argument 
%              containing the axis to act upon.
%              If not passed in, the default
%              axis is used
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
function model3d_viewport(model)
  
  if(nargin > 2)
    ax = varargin{1};
  else
    ax = gca;
  end
  
  if isa(model,'model3d') == 0
    error('Argument must be of type ''model3d''');
  end
  
  if isempty(model.campos) || isempty(model.camtarget)
    view(ax,3);
    return;
  end
  
  set(ax,'cameraposition',double(model.campos),...
          'cameratarget',double(model.camtarget));
  