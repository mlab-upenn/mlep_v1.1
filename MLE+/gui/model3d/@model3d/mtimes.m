% Function mout = mtimes(a1,a2)
%
% This function assumes that one of the 
% inputs is a 'model3d' class and the other
% is a scalar.  This simply multiplies each 
% component of each vertex in the model by the
% scalar, thus magnifying the image by the scalar.
%
% The inputs can be in any order; the function will 
% figure it out.
% 
% The output is the scaled 'model3d' class
%
% Author: Steven Michael
%
% Date:   5/19/2005
%
function d3 = mtimes(d1,d2)
 
dd = 0;
ds = 0;

% Extract the DXF object
if(isa(d1,'model3d'))
    dd = d1;
elseif isa(d2,'model3d')
    dd = d2;
else
    error('One of the arguments must be a ''model3d'' object')
end


% Extract the scalar
if isnumeric(d1)
    ds = d1;
elseif isnumeric(d2)
    ds = d2;
else
    error('One of the arguments must be a ''model3d'' object')
end
ds = single(ds);

if numel(ds) ~= 1
    error('Can only multiply ''model3d'' objects by a scalar')
end


d3 = dd;
for idx=1:length(d3.layers)
    if(isempty(d3.layers(idx).vertices)==0)
        d3.layers(idx).vertices = d3.layers(idx).vertices.*ds;
    end
    if(isempty(dd.layers(idx).facets)==0)
        d3.layers(idx).facets = d3.layers(idx).facets.*ds;
    end
end
