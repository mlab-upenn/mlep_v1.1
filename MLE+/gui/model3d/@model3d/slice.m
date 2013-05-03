% FUNCTION model = slice(model_in,xlim,ylim,zlim)
% 
% Description:
% 
%   This function slices a 'model3d' class such that the
%   only facets retained are those within the cube 
%   defined by xlim,ylim,zim.
%   If xlim,ylim,or zlim are empty, no slicing is done
%   in that dimension
%
% Inputs:
% 
%   model_in:     The 'model3d' class object to be sliced
%
%   [xyz]lim:     A 2 element [min,max] array defining the
%                 points in that dimension in which to include
%                 facets
%
% Outputs:
%
%   model:        The sliced 'model3d' class
%
% Example:
%
%   To output a model that includes only facets that fall
%   within the Y axis range [0,5] enter the following:
%
%       model = slice(model_in,[],[0,5],[]);
%
% Author: Steven Michael (smichael@ll.mit.edu
%
% Date:   5/23/05
%
function model = slice(min,xlim,ylim,zlim)
  
  model = min;
  

  lcnt = 0;
  for i1=1:length(min.layers)
    % Extract the valid facet indices
    vidx = ones(1,length(min.layers(i1).vertices(1,:)))*-1;
    f = 1:length(min.layers(i1).vertices);
    if isempty(xlim)==0
      f1 = find(min.layers(i1).vertices(1,:) > xlim(1));
      f2 = find(min.layers(i1).vertices(1,:) < xlim(2));
      f = intersect(f,intersect(f1,f2));
    end
    if isempty(ylim)==0
      f1 = find(min.layers(i1).vertices(2,:) > ylim(1));
      f2 = find(min.layers(i1).vertices(2,:) < ylim(2));
      f = intersect(f,intersect(f1,f2));
    end
    if isempty(zlim)==0
      f1 = find(min.layers(i1).vertices(3,:) > zlim(1));
      f2 = find(min.layers(i1).vertices(3,:) < zlim(2));
      f = intersect(f,intersect(f1,f2));
    end
    
    
    % Are there any valid vertices ?
    if length(f)~=0
      lcnt = lcnt+1;
      for i2=1:length(f)
        vidx(f(i2)) = i2;
      end
      layers(lcnt) = min.layers(i1);
      layers(lcnt).vertices = min.layers(i1).vertices(:,f);
      facetidx = zeros(4,0);
      fcnt = 0;
      for i2=1:length(min.layers(i1).facetidx(1,:))
        if(vidx(min.layers(i1).facetidx(1,i2)) ~= -1 && ...
           vidx(min.layers(i1).facetidx(2,i2)) ~= -1 && ...
           vidx(min.layers(i1).facetidx(3,i2)) ~= -1)
          fcnt = fcnt+1;
          facetidx(1,fcnt) = vidx(min.layers(i1).facetidx(1,i2));
          facetidx(2,fcnt) = vidx(min.layers(i1).facetidx(2,i2));
          facetidx(3,fcnt) = vidx(min.layers(i1).facetidx(3,i2));
          facetidx(4,fcnt) = -1;
          if min.layers(i1).facetidx(4,i2) ~= -1
            if(vidx(min.layers(i1).facetidx(4,i2))~=-1)
              facetidx(4,fcnt) = vidx(min.layers(i1).facetidx(4,i2));
            end            
          end          
        end
        if(min.layers(i1).facetidx(4,i2)~= -1)
          if(vidx(min.layers(i1).facetidx(2,i2)) == -1 && ...
             vidx(min.layers(i1).facetidx(1,i2)) ~= -1 && ...
             vidx(min.layers(i1).facetidx(3,i2)) ~= -1 && ...
             vidx(min.layers(i1).facetidx(4,i2)) ~= -1)
            fcnt = fcnt+1;
            facetidx(1,fcnt) = vidx(min.layers(i1).facetidx(1,i2));
            facetidx(2,fcnt) = vidx(min.layers(i1).facetidx(3,i2));
            facetidx(3,fcnt) = vidx(min.layres(i1).facetidx(4,i2));
            facetidx(4,fcnt) = -1;
          end
        end          
      end % End of iterating through facet indices
      layers(lcnt).facetidx = facetidx;
    end % end of iterating through vertices
  end % end of iterating through layers
  model.layers = layers;