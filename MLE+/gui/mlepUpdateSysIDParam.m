function [mlep] = mlepUpdateSysIDParam(mlep)

% Update parameters to index
if isfield(mlep.data,'sysIDinputIndex')
    index = mlep.data.sysIDinputIndex;
    if isfield(mlep.data,'sysIDinputParam')
        if ~isempty(mlep.data.sysIDinputParam)
            set(mlep.sysIDeditConrolStep,'String',num2str(mlep.data.sysIDinputParam{index,1}));
            %if isempty(mlep.data.sysIDinputParam{index,2})
            %mlep.data.sysIDinputParam{index,2} = 1;
            %end
            set(mlep.sysIDpopupType,'Value',mlep.data.sysIDinputParam{index,2});
            set(mlep.sysIDeditWlow,'String',num2str(mlep.data.sysIDinputParam{index,3}));
            set(mlep.sysIDeditWhigh,'String',num2str(mlep.data.sysIDinputParam{index,4}));
            set(mlep.sysIDeditMinu,'String',num2str(mlep.data.sysIDinputParam{index,5}));
            set(mlep.sysIDeditManu,'String',num2str(mlep.data.sysIDinputParam{index,6}));
            set(mlep.sysIDeditScale,'String',num2str(mlep.data.sysIDinputParam{index,7}));
%             set(mlep.sysIDselectSignal,'String',num2str(mlep.data.sysIDinputParam{index,8}));
%             set(mlep.sysIDcheck,'Value',mlep.data.sysIDinputParam{index,9});
%             
        end
    end
end
end