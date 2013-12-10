function installMlep()
% INSTALLMLEP code to install MLE+
%      Run this script before using MLE+.
%
%      installMlep() does not return anything. 
%
%      In installMlep you need to spedicy whether you want to use the GUI
%      mode or the Manual mode. Set manualInstall = 0 if you do not want to
%      use the GUI. 

% Last Modified by Willy Bernal willyg@seas.upenn.edu 30-Jul-2013 16:29:59

%% Manual Install
% 1 = Install Manually
% 0 = Install through GUI
manualInstall = 0;

% Paths
if ispc
    % Windows
    eplusPath = 'C:\EnergyPlusV8-0-0';
    javaPath = 'C:\Program Files\Java\jre7\bin\';
else
    % Unix
    eplusPath = '/Applications/EnergyPlus-8-0-0';
end

%%%%%%%%%%%%%%%%%%%%%% DO NOT MODIFY AFTER THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MLEP PATH
mlepFolder = mfilename('fullpath');
% Remove
indexHome = strfind(mlepFolder, ['installMlep']);
mlepFolder = mlepFolder(1:indexHome-1);
cd(mlepFolder);

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
else % Manual Install
    %Select EnergyPlus Directory
    currPath = mfilename('fullpath');
    % Remove prefix
    indexHome = strfind(currPath, 'installMlep');
    currPath = currPath(1:indexHome-1);
    % Save paths into mat files
    if ispc
        % Remove last filesep
        if eplusPath(end) == filesep
            eplusPath = eplusPath(1:end-1);
        end
        save([currPath 'gui' filesep 'eplusPath.mat'],'eplusPath');
        save([currPath 'gui' filesep 'javaPath.mat'],'javaPath');
        % Replaced RunEPlus.bat
        [status,message,messageid] = copyfile([mlepFolder 'gui' filesep 'RunEPlus.bat'] ,[eplusPath filesep 'RunEPlus.bat'], 'f');
        if ~status
            disp('ERROR: CHECK E+ PATHS AND JAVA PATHS');
            disp(message);
            disp(messageid);
        else
            disp('INSTALLATION COMPLETED');
        end
    else
        save([currPath 'gui' filesep 'eplusPath.mat'],'eplusPath');
    end
    saveMlepSettings();
end

%% SAVEPATH
savepath;
end

