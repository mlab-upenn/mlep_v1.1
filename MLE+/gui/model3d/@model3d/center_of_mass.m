function com = center_of_mass(model)
% FUNCTION com = center_of_mass(model)
%
%  This function retuns the "Center of Mass"
%  which is defined to be the average position]
%  of each vertex in the model
%  
%  The vertices are weighted only once, independent
%  of how many facets they contribute to
%
% Inputs:
%
%   model :   a 'model3d' class
%
% Outputs:
%
%   com   :   a 3x1 vector containing the averate
%             vertex position
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%
  
  
  if isa(model,'model3d')==0
    error('Input must be a ''model3d'' type');
  end
  
  vertices = zeros(3,0);
  nvertices = 0;
  
  for i1=1:length(model.layers)
    if isempty(model.layers(i1).facets)==0
      sz = size(model.layers(i1).facets);
      tmp = reshape(model.layers(i1).facets(:,1:3,:),3,3*sz(3));
      tmp = unique(tmp','rows')';
      sz = size(tmp);      
      vertices(:,nvertices+1:nvertices+sz(2)) = tmp;
      nvertices = nvertices + sz(2);
    end
    
    if isempty(model.layers(i1).vertices)==0
      sz = size(model.layers(i1).vertices);
      vertices(:,nvertices+1:nvertices+sz(2)) = ...
          model.layers(i1).vertices;
      nvertices = nvertices + sz(2);
    end
  end
  
  sz = size(vertices);
  com = sum(vertices,2)/sz(2);
  
    
    
