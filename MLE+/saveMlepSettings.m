function saveMlepSettings()
%% MLEPSETTINGS
mlepInit;
if ispc
    MLEPSETTINGS.path = MLEPSETTINGS.env;
end
%mlep.eplusPath = mlep.data.MLEPSETTINGS.path{1}{2};
%Select EnergyPlus Directory
currPath = mfilename('fullpath');
% Remove prefix
indexHome = strfind(currPath, 'installFunction');
currPath = currPath(1:indexHome-1);
save([currPath 'gui' filesep 'MLEPSETTINGS.mat'],'MLEPSETTINGS');

end