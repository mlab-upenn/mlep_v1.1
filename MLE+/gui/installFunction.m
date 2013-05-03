function [] = installFunction(varargin)
% Main Function

% Get the structure.
handle = varargin{3};
install = guidata(handle);
functionName = varargin{4};

if strcmp(functionName,'getEplusPath')
    [install] = getEplusPath(install);
elseif strcmp(functionName,'editEplusPath')
    [install] = editEplusPath(install);
elseif strcmp(functionName,'getJavaPath')
    [install] = getJavaPath(install);
elseif strcmp(functionName,'replaceEPlus')
    [install] = replaceEPlus(install);
elseif strcmp(functionName,'closeInstall')
    [install] = closeInstall(install);
elseif strcmp(functionName,'getEplusPathUnix')
    [install] = getEplusPathUnix(install);
elseif strcmp(functionName,'getJavaPathUnix')
    [install] = getJavaPathUnix(install);
end

if ~strcmp(functionName,'closeInstall')
    % Save data structure
    guidata(handle, install);
end
end


%% EPLUS DIR
function [install] = getEplusPath(install)
if ispc
    startPath = 'C:\';
else
    startPath = ['Applications' filesep];
end

[eplusPath] = uigetdir(startPath,'Select EnergyPlus Directory. (e.g. C:\EnergyPlusV7-1-0)');
if ischar(eplusPath)
    install.data.eplusPath = eplusPath;
    set(install.eplusEdit, 'String', install.data.eplusPath, 'Background', 'g');
    eplusPath = install.data.eplusPath;
    % Check Path
    install.data.eplusPathCheck = 1;
    
    currPath = mfilename('fullpath');
    % Remove
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    save([currPath 'eplusPath.mat'],'eplusPath');
end

end

%% JAVA DIR
function [install] = getJavaPath(install)
if ispc
    startPath = 'C:\';
else
    startPath = ['Applications' filesep];
end

[javaPath] = uigetdir(startPath,'Select Java\Bin Directory. (e.g. C:\Program Files\Java\jre1.6.0_22\bin)');
if ischar(javaPath)
    install.data.javaPath = javaPath;
    set(install.javaEdit, 'String', install.data.javaPath, 'Background', 'g');
    javaPath = install.data.javaPath;
    currPath = mfilename('fullpath');
    % Remove
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    save([currPath 'javaPath.mat'],'javaPath');
end
end

%% REPLACE RUNEPLUS
function [install] = replaceEPlus(install)
if isfield(install.data,'eplusPathCheck')
    if install.data.eplusPathCheck
        % Replace RunEPlus
        if ispc
            [status,message,messageid] = copyfile([install.data.homePath 'gui' filesep 'RunEPlus.bat'] ,[install.data.eplusPath filesep 'RunEPlus.bat'], 'f');
            if status == 1
                set(install.runEPlusEdit, 'Background', 'g');
            end
        else
            [status,message,messageid] = copyfile([install.data.homePath 'gui' filesep 'runenergyplus'] ,[install.data.eplusPath filesep 'bin'], 'f');
            if status == 1
                set(install.runEPlusEdit, 'Background', 'g');
            end
        end    
    end
end
end

%% EPLUS DIR UNIX
function [install] = getEplusPathUnix(install)

if ispc
    startPath = 'C:\';
else
    startPath = ['Applications' filesep];
end

[eplusPath] = uigetdir(startPath,'Select EnergyPlus Directory. (e.g. /Applications/EnergyPlusV7-1-0)');
if ischar(eplusPath)
    install.data.eplusPath = eplusPath;
    set(install.eplusEdit, 'String', install.data.eplusPath, 'Background', 'g');
    eplusPath = install.data.eplusPath;
    % Check Path
    install.data.eplusPathCheck = 1;
    
    currPath = mfilename('fullpath');
    % Remove
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    save([currPath 'eplusPath.mat'],'eplusPath');
end

end

%% EPLUS DIR UNIX
function [install] = getJavaPathUnix(install)

if ispc
    startPath = 'C:\';
else
    startPath = ['Applications' filesep];
end

[javaPath] = uigetdir(startPath,'Select Java/Bin Directory. (e.g. /usr/bin/bin)');
if ischar(javaPath)
    install.data.javaPath = javaPath;
    set(install.javaEdit, 'String', install.data.javaPath, 'Background', 'g');
    javaPath = install.data.javaPath;
    currPath = mfilename('fullpath');
    % Remove
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    save([currPath 'javaPath.mat'],'javaPath');
end

end

%% CLOSE INSTALL
function [install] = closeInstall(install)
% Deleting Main Figure
delete(install.handle);
end
