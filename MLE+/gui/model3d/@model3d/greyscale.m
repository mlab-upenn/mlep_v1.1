% FUNCTION gmodel = greyscale(model)
%
% Description:
%  
%  This function converts an input 'model3d'
%  class to greyscale.  The greyscale color
%  value is set to the intensity of the original
%  layer color: 
%  sqrt(red*red + blue*blue + green*green)
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/23/2004

function gmodel = greyscale(model)
  
  gmodel = model;
  for i1=1:length(gmodel.layers)
    c = gmodel.layers(i1).ambient;
    gmodel.layers(i1).ambient = ones(1,3)*norm(c);
    c = gmodel.layers(i1).diffuse;
    gmodel.layers(i1).diffuse = ones(1,3)*norm(c);
    c = gmodel.layers(i1).specular;
    gmodel.layers(i1).specular = ones(1,3)*norm(c);
  end