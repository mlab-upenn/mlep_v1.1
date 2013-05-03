% FUNCTION mout = qrot(model,1)
%
% Description:
%
%  This fuction rotates the input model
%  by the supplied quaternion
%
%  Inputs:
%
%   model:     The input model
%
%   q:         The quaternion of rotation
%
%   Optionally, the user can pass in for the 2nd and
%   3rd argument an axis of rotation (3 element vector)
%   and a rotation magnitude in radians
%
% Output:
%
%   mout :     The output model
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/05

function mout = qrot(min,varargin)
  
  if isa(min,'model3d')==0
    error('Input must be ''model3d'' type');
  end
  
  rotHandle = @myQRot3D;
  % Do we have the much much faster
  % qrot3d function available (compiled MATLAB
  % file for fast quaternion rotation)
  % 'qrot3d' is available from the MATLAB 
  % Central File Exchange
  if exist('qrot3d')==3
    rotHandle = @qrot3d
  end
  
  
  mout = min;
  
  for i1=1:length(mout.layers)
  
    if isempty(mout.layers(i1).vertices)==0
      mout.layers(i1).vertices = ...
          rotHandle(mout.layers(i1).vertices',varargin{1:end})';
    end
    if isempty(mout.layers(i1).facets) == 0
      mout.layers(i1).facets = ...
          rotHandle(mout.layers(i1).facets',varargin{1:end})';
    end
    
  end
end

% A very slow quaternion rotation funciton
% that rotates a Nx3 array of 3D vectors
function vout = myQRot3D(vin,varargin)

  for idx=1:length(vin(:,1))

    % Construct the quaternion from the input
    % arguments
    if(nargin < 3)
      q = varargin{1};
    else
      q = [cos(varargin{2}/2), ...
           sin(varargin{2}/2).*varargin{1}];
    end
    qconj = q;
    qconj(2:4) = -qconj(2:4);
    
    % Do the quaternion rotation
    tmp = [0 vin(idx,:)];
    tmp = qmult3d(tmp,qconj);
    tmp = qmult3d(q,tmp);
    vout(idx,:) = tmp(2:4);  
  end
end

% A function for quaternion multiplication
function qc = qmult3d(qa,qb)
  qc(1) = qa(1)*qb(1)-qa(2)*qb(2)-qa(3)*qb(3)-qa(4)*qb(4);
  qc(2) = qa(1)*qb(2)+qa(2)*qb(1)+qa(3)*qb(4)-qa(4)*qb(3);
  qc(3) = qa(1)*qb(3)-qa(2)*qb(4)+qa(3)*qb(1)+qa(4)*qb(2);
  qc(4) = qa(1)*qb(4)+qa(2)*qb(3)-qa(3)*qb(2)+qa(4)*qb(1);
end
 	 	 	 
  			 
  			 
