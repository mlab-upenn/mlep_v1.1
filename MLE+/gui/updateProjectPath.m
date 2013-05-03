function [mlep] = updateProjectPath(mlep)

% IDF
mlep.data.idfFullPath = [mlep.data.projectPath mlep.data.idfFile];
% WEATHER
mlep.data.weatherFullPath = [mlep.eplusPath filesep 'WeatherData' filesep mlep.data.weatherFile];
% CONTROL
mlep.data.controlFullPath = [mlep.data.projectPath mlep.data.controlFileName];
end