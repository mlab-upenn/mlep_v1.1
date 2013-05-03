function installMlep()
%% Manual Install 
manualInstall = 0;


%% MLEP PATH
mlepFolder = mfilename('fullpath');
% Remove 
indexHome = strfind(mlepFolder, ['installMlep']);
mlepFolder = mlepFolder(1:indexHome-1);
cd(mlepFolder);

%% Folders
EplusFolder = 'EnergyPlusV7-2-0';
JavaFolder = 'Java';
BcvtbFolder = 'bcvtb';

%% VERSION PATH
addpath([pwd filesep 'gui' filesep 'version']);

%% MLEP CORE/GUI PATH
addpath([pwd filesep 'core' filesep]);
addpath([pwd filesep 'gui' filesep]);
addpath(pwd);

%% STRUCTDLG
addpath([pwd filesep 'gui' filesep 'structdlg']);

%% DXF PATH
addpath([pwd filesep 'gui' filesep 'model3d']);

%% BACNET PATH
addpath([pwd filesep 'bacnet-tools-0.7.1']);

%% GUILAYOUT PATH
run(['GUILayout-v1p13' filesep 'install']);

%% INSTALLATION DIALOG
% CREATE FIGURE
if ~manualInstall
    if ispc
        %[install myhandle] = pcInstall(mlepFolder);
        installationWin;
    else
        %[install myhandle] = unixInstall(mlepFolder);
        installationUnix;
    end
else
    
end
%% SAVEPATH
savepath;
end