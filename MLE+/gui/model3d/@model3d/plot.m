% Function h = plot(model,varargin)
%
% Description:
% 
%   This function plots with the highest fidelity possible
%   the 'model3d' class type model.  This includes triangle
%   and color information and, if included in the model, viewport
%   and lighting information
%
% Inputs:  
%
%   model:    the input ''model3d'' model
%
% Outputs:
%
%   h :       an array of 'patch' function returns,
%             1 for each layer of the model
%
% Author:     Steven Michael
%
% Date:       5/19/05
%
function h = plot(d,varargin)
  
  % Clear the axis if we are replacing patches
  if strcmp(get(gca,'nextplot'),'replace')==1
    cla;
  end
  
  % The below 2 lines may or may not be necessary depending
  % on the computer & video card
  % I find them helpful
  set(gcf,'renderer','opengl','renderermode','manual');
  set(gcf,'doublebuffer','on');
  
  for idx=1:length(d.layers)
    
    % The plotting here sets the vertex data with RGB.  
    % This is so something else can be over-plotted that does
    % not use the same color map
    if isempty(d.layers(idx).vertices)==0
      sz = size(d.layers(idx).facetidx);

      hh(idx,1) = patch('vertices',d.layers(idx).vertices',...
                        'faces',d.layers(idx).facetidx(1:3,:)',...
                        'facevertexcdata',...
                        ones(sz(2),1)*d.layers(idx).diffuse,...
                        'facecolor','flat',...
                        'edgecolor','k',...
                        varargin{1:end});
      % Is there a 4th vertex (are we defining squares?
      f = find(d.layers(idx).facetidx(4,:) > 0);
      if length(f) > 0
        hh(idx,2) = patch('vertices',d.layers(idx).vertices',...
                          'faces',d.layers(idx).facetidx([1 3 4],f)',...
                          'facevertexcdata',...
                          ones(sz(2),1)*d.layers(idx).diffuse,...
                          'facecolor','flat',...
                          'edgecolor','k',...
                          varargin{1:end});
      end      
    end
    
    if isempty(d.layers(idx).facets)==0
      sz = size(d.layers(idx).facets);
      tmp = reshape(ones(sz(3)*3,1)*d.layers(idx).diffuse,...
                    3,sz(3),3);
      hh(idx,3) = patch(...
          squeeze(d.layers(idx).facets(1,1:3,:)),...
          squeeze(d.layers(idx).facets(2,1:3,:)),...
          squeeze(d.layers(idx).facets(3,1:3,:)),...
          tmp,...
          'facecolor','b',...
          'edgecolor','k',...
          varargin{1:end}); % WILLY 
      f = find(d.layers(idx).facets(1,4,:) > 1E-8);
      if isempty(f)==0
        hh(idx,4) = patch(...
            squeeze(d.layers(idx).facets(1,[1 3 4],:)),...
            squeeze(d.layers(idx).facets(2,[1 3 4],:)),...
            squeeze(d.layers(idx).facets(3,[1 3 4],:)),...
            tmp,...
            'facecolor','b',...
            'edgecolor','k',...
            varargin{1:end});

      end
    end
    
    % Set the transparency of the layer, if it is not 0
    if(d.layers(idx).transparency ~= 0)
      for i1=1:length(hh(idx,:))
        if hh(idx,i1) ~= 0
          set(hh(idx,i1),'facealpha',...
                         (1.0-d.layers(idx).transparency/100));
        end
      end
    end
    
    
  end % Done iterating through layers
  

  
  % The following two lines may or may not be 
  % desired
  axis equal;
  axis tight;
  
  if(nargout > 0)
    h = hh;
  end;

  % This sets the viewport to be what was
  % defined in the model file (if there was 
  % such a definition).
  model3d_viewport(d);

  % Add light (if it is defined)
  %model3d_light(d);
  
end

