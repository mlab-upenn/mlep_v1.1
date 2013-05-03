function [mlep] = mlepUpdatePresentationTab(mlep)
% EnergyPlus edit
if ~isfield(mlep.data,'idfFile')
    set(mlep.presentationIdfEdit,'string','EnergyPlus File');
else
    set(mlep.presentationIdfEdit,'string',mlep.data.idfFile);
end
% Weather edit
if ~isfield(mlep.data,'weatherFile')
    set(mlep.presentationWeatherEdit,'string','Weather File');
else
    set(mlep.presentationWeatherEdit,'string',mlep.data.weatherFile);
end
end




