% FUNCTION mout = plus(m1,m2)
%
% This function does one of two things:
%
% 1. If one of the inputs is a 'model3d' class
%    and the other a 3D vector, this function
%    adds the vector to each vertex in the model
%    and returns the new model as the output
%
% 2. If both the inputs are a 'model3d' class,
%    the function concatenates the layers of each
%    input model into an output model.  This means
%    the output model is simply the two input models
%    combined.
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
% 
function d3 = plus(d1,d2)

dd = 0;
dp = 0;

% Are we adding together 2 model3d objects
if isa(d1,'model3d') && isa(d2,'model3d')
  l1 = length(d1.layers);
  l2 = length(d2.layers);
  d3 = d1;
  d3.layers(l1+1:l1+l2) = d2.layers(1:l2);
  return;
end

% If not, we are presumabely adding together
% a DXF and a vector.  So, we figure out which is which, 
% and do the math
if isa(d1,'model3d')
    dd = d1;
elseif isa(d2,'model3d')
    dd = d2;
else
    error('One of the inputs must be a DXF object')
end

if isnumeric(d2)
    dp = d2;
elseif isnumeric(d1)
    dp = d1;
end

if numel(dp) ~= 3 
    error('Numeric portion must have 3 elements')
end

dp = single(dp);

d3 = dd;
for idx=1:length(d3.layers)
    if isempty(d3.layers(idx).vertices)==0
        d3.layers(idx).vertices(1,:) = ...
            d3.layers(idx).vertices(1,:) + dp(1);
        d3.layers(idx).vertices(2,:) = ...
            d3.layers(idx).vertices(2,:) + dp(2);
        d3.layers(idx).vertices(3,:) = ...
            d3.layers(idx).vertices(3,:) + dp(3);
    end
    if isempty(d3.layers(idx).facets)==0
        d3.layers(idx).facets(1,:) = ...
            d3.layers(idx).facets(1,:) + dp(1);
        d3.layers(idx).facets(2,:) = ...
            d3.layers(idx).facets(2,:) + dp(2);
        d3.layers(idx).facets(3,:) = ...
            d3.layers(idx).facets(3,:) + dp(3);
    end
    
    
end

    