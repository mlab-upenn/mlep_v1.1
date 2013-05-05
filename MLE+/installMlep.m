function installMlep()
%% Manual Install
% 1 = Install Manually
% 0 = Install through GUI
manualInstall = 0;

% Paths
if ispc
    % Windows
    eplusPath = 'C:\EnergyPlus-7-2-0\';
    javaPath = 'C:\Program Files\Java\jre1.6.0_22\bin\';
else
    % Unix
    eplusPath = '/Applications/EnergyPlus-7-2-0/';
end

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
        % WIN
        installationWin;
    else
        % UNIX
        installationUnix;
    end
else
    %Select EnergyPlus Directory
    currPath = mfilename('fullpath');
    % Remove prefix
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    % Save paths into mat files
    if ispc
        save([currPath 'gui' filesep 'eplusPath.mat'],'eplusPath');
        save([currPath 'gui' filesep 'javaPath.mat'],'javaPath');
    else
        save([currPath 'gui' filesep 'eplusPath.mat'],'eplusPath');
    end
    saveMlepSettings();
end

%% SAVEPATH
savepath;
end

