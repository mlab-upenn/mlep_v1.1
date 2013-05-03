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
function d3 = times(d1,d2)
 
d3 = mtimes(d1,d2);