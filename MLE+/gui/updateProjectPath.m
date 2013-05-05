function [mlep] = updateProjectPath(mlep)

% IDF
if isfield(mlep.data, 'projectPath') && isfield(mlep.data, 'idfFile')
    mlep.data.idfFullPath = [mlep.data.projectPath mlep.data.idfFile];
end
% WEATHER
if isfield(mlep, 'eplusPath') && isfield(mlep.data, 'weatherFile')
    mlep.data.weatherFullPath = [mlep.eplusPath filesep 'WeatherData' filesep mlep.data.weatherFile];
end
% CONTROL
if isfield(mlep.data, 'projectPath') && isfield(mlep.data, 'controlFileName')
    mlep.data.controlFullPath = [mlep.data.projectPath mlep.data.controlFileName];
end
