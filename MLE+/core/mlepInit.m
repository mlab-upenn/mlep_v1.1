% This script sets up the environment for MLE+.
% It should be modified to the actual settings of the computer,
% including path to BCVTB, EnergyPlus, etc.
% Run this script once before using any MLE+ functions.
% Generally, this is only necessary on Windows machines.  On
% Linux/MacOS, the default settings often work.
%
% (C) 2011 by Truong X. Nghiem (nghiem@seas.upenn.edu)

% Last update: 2011-07-13 by Truong X. Nghiem

global MLEPSETTINGS

homePath = mfilename('fullpath');
% Remove 
indexHome = strfind(homePath, 'mlepInit');
homePath = homePath(1:indexHome-1);
bcvtbDir = [homePath '..' filesep 'bcvtb'];

load([homePath '..' filesep 'gui' filesep 'eplusPath.mat']);
EplusDir = eplusPath;
if ispc
    load([homePath '..' filesep 'gui' filesep 'javaPath.mat']);
    JavaDir = javaPath;
end

if ispc
    % Windows
    MLEPSETTINGS = struct(...
        'version', 2,...   % Version of the protocol
        'program', [EplusDir filesep 'RunEplus'],...   % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...   % Path to BCVTB installation
        'execcmd', 'system'...   % Use the system command to execute E+
        );
    MLEPSETTINGS.env = {...
        {'ENERGYPLUS_DIR', EplusDir},...  % Path to the EnergyPlus folder
        {'PATH', [JavaDir ';' EplusDir]}...  % System path, should include E+ and JRE
        };
else
    % Mac and Linux
    MLEPSETTINGS = struct(...
        'version', 2,...   % Version of the protocol
        'program', 'runenergyplus',...   % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...   % Path to BCVTB installation bcvtbDir
        'execcmd', 'java'...   % Use Java to execute E+
        );
    
    MLEPSETTINGS.env = {};
    MLEPSETTINGS.path = {    ...
        {'ENERGYPLUS_DIR', EplusDir},...  % Path to the EnergyPlus
        {'PATH', ['usr/bin/java' ';' EplusDir]}...  % System path, should include E+ and JRE
        };
    % JavaDir = '/usr/bin/java'
    
end