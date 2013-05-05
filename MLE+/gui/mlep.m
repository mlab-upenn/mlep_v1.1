function mlep 
% This R2010b code does not use 'v0' syntax and updates properties
clear mlep;

mlep = struct();
% Color for selected fields
[mlep] = mlepColor(mlep);


% Font Size
if ispc
    mlep.fontLarge = 14;
    mlep.fontMedium = 11; % 10 
    mlep.fontSmall = 8; % 8
else
    mlep.fontLarge = 16;
    mlep.fontMedium = 13; % 10 
    mlep.fontSmall = 10; % 8    
end
%% INITIALIZE NECESSARY VARIABLES
% HomePath
mlep.homePath = mfilename('fullpath');
indexHome = strfind(mlep.homePath, ['gui' filesep 'mlep']);
mlep.homePath = mlep.homePath(1:indexHome-1);

% load MLEPSETTINGS
var = load([mlep.homePath 'gui' filesep 'MLEPSETTINGS.mat']);
mlep.data.MLEPSETTINGS = var.MLEPSETTINGS;
if ispc
    mlep.data.MLEPSETTINGS.path = mlep.data.MLEPSETTINGS.env;
end
mlep.eplusPath = mlep.data.MLEPSETTINGS.path{1}{2};

mlep.version1 = 1;
mlep.version2 = 1;

% BacnetDir 
mlep.BACnetDir = [mlep.homePath 'bacnet-tools-0.7.1' filesep];

%% SCREEN SIZE
[mlep] = mlepScreenSize(mlep);
 
% Create Handle
mlep.data.runTemplateHandle = str2func('runTemplate.m'); 
mlep.data.projectPath = pwd;

%% DATA
data = [];

%% CREATE FIGURE
myhandle = figure('Units','pixels','OuterPosition',mlep.mainPosition, 'HandleVisibility', 'callback', 'Name', 'MLE+ Front-End', 'NumberTitle', 'off'); % [0.05 0.05 0.9 0.9]
mlep.handle = myhandle;
set(myhandle, 'CloseRequestFcn', {@mlepPresentationFunction,myhandle,'exit'});

% PANEL SETTINGS
mlep.mainBox = uiextras.VBox( 'Parent', mlep.handle, 'Padding', 0, 'Spacing', 0  );
    % MAIN PANEL
    mlep.mainPanel = uiextras.Panel( 'Parent', mlep.mainBox, 'BorderType', 'none', 'Padding', 0 );
        
    % SETTINGS PANEL
    mlep.settingsPanel = uiextras.Panel( 'Parent', mlep.mainBox, 'Padding', 10, 'BorderType', 'none', 'BorderWidth', 1);% , 'Title', 'SETTINGS'
        mlep.settingsPanel1 = uiextras.Panel( 'Parent', mlep.settingsPanel, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Settings', 'FontSize', mlep.fontMedium );% 
        mlep.settingsButton = uiextras.HBox( 'Parent', mlep.settingsPanel1, 'Padding', 10, 'Spacing', 40  );
            uicontrol( 'String', 'Load Project', 'Parent', mlep.settingsButton, 'FontSize', mlep.fontMedium, 'Callback', {@mlepPresentationFunction,myhandle,'loadProject'} );
            uicontrol( 'String', 'Save Project', 'Parent', mlep.settingsButton, 'FontSize', mlep.fontMedium, 'Callback', {@mlepPresentationFunction,myhandle,'saveProject'} );
            uicontrol( 'String', 'Clear Project', 'Parent', mlep.settingsButton, 'FontSize', mlep.fontMedium, 'Callback', {@mlepPresentationFunction,myhandle,'clearProject'}  );
            uicontrol( 'String', 'Exit', 'Parent', mlep.settingsButton, 'FontSize', mlep.fontMedium, 'Callback', {@mlepPresentationFunction,myhandle,'exit'} );
    
% SET SIZE
set(mlep.mainBox, 'Sizes', [-6 120]);  
  
% TAB GROUP    
mlep.guiTab = uitabgroup('Parent',mlep.mainPanel,'TabLocation','top');        % Do not use the 'v0' argument
%set(mlep.guiTab,'BackgroundColor',get(gcf,'Color'))
set(myhandle, 'Resize','on');
set(myhandle, 'ResizeFcn',{@figResize,myhandle});
guidata(myhandle,mlep);

%% PRESENTATION TAB
mlep = mlepPresentation(myhandle);

%% SYSID TAB
mlep = mlepVariable(myhandle);
mlep = mlepSysID(myhandle);

%% CONTROL TAB
mlep = mlepControl(myhandle); 

%% SIMULATE TAB
mlep = mlepSimulate(myhandle);

%% BACNET TAB
mlep = mlepBacnet(myhandle);

%% TABS SWITCHING 
% Tabs switching function
MatlabVersion = getversion;
if MatlabVersion == 8
    set(mlep.guiTab,'SelectionChangeFcn', @(obj,evt) selectionChangeCbk(obj,evt)); % Formerly SelectionChangeFcn
else
    set(mlep.guiTab,'SelectionChangeCallback', @(obj,evt) selectionChangeCbk(obj,evt)); % Formerly SelectionChangeFcn
end
    %set(mlep.guiTab,'SelectedTab',mlep.presentationTab);          % Replaces SelectedIndex property

% Get the underlying Java reference (use hidden property)
jTabGroup = getappdata(handle(mlep.guiTab),'JTabbedPane');
% Equivalent manners to set a red tab foreground:
% jTabGroup.setForegroundAt(1,java.awt.Color(1.0,0,0)); % tab #1
jTabGroup.setTitleAt(0,'<html><font face="helvetica", color="black",size=5>1. Start');
jTabGroup.setTitleAt(1,'<html><font face="helvetica", color="black",size=5>2. System ID');
jTabGroup.setTitleAt(2,'<html><font face="helvetica", color="black",size=5>3. Control');
jTabGroup.setTitleAt(3,'<html><font face="helvetica", color="black",size=5>4. Simulation');
jTabGroup.setTitleAt(4,'<html><font face="helvetica", color="black",size=5>5. BACnet');
%jTabGroup.setTitleAt(2,'<html><div style="background:#ffff00">3. CONTROL');'<html><b><i><font size=+2>Tab #2'
% jTabGroup.setForeground(java.awt.Color.red);

% Equivalent manners to set a yellow tab background:
%jTabGroup.setTitleAt(0,'<html><div style="background:#ffff00;">Panel 1');
%jTabGroup.setTitleAt(0,'<html><div style="background:yellow;">Panel 1');

% Add an icon to tab #1 (=second tab)
% icon = javax.swing.ImageIcon('new_image.png');
% jLabel = javax.swing.JLabel('Tab #2');
% jLabel.setIcon(icon);
% jTabGroup.setTabComponentAt(1,jLabel);	% Tab #1 = second tab
 
% Note: icon is automatically grayed when label is disabled
%jLabel.setEnabled(false);
%jTabGroup.setEnabledAt(1,false);  % disable only tab #1

if MatlabVersion == 7.10
    set(mlep.guiTab,'SelectedTab',1);          % Replaces SelectedIndex property
else
    set(mlep.guiTab,'SelectedTab',mlep.presentationTab);          % Replaces SelectedIndex property
end
 
data = [];

figResize(1,0,myhandle);
guidata(myhandle, mlep);
end

function selectionChangeCbk(src,evt) 
% This new code uses tab handles to directly access tab properites

%oldTab = evt.OldValue;                % Event member is tab handle
%oldName = get(oldTab,'title');        % Access child tab directly
%newTab = evt.NewValue;                % Event member is tab handle
%newName = get(newTab,'title');        % Access child tab directly
%disp(['It was ' oldName ' time; now it is ' newName ' time.'])

% Switch between tabs

end

function figResize(varargin)
% Retrieve data
myhandle = varargin{3};
mlep = guidata(myhandle);

% Get size parameters
fposPixels = get(myhandle,'OuterPosition');

%set(mle.guiHandle, 'Units', 'pixels');
%fposPixels = get(mle.guiHandle,'OuterPosition');

% Check if smaller than threshold
if (fposPixels(3) < mlep.defaultSizePixels(3))
    figureSize(3) = mlep.defaultSizePixels(3);
end
if (fposPixels(4) < mlep.defaultSizePixels(4))
    figureSize(4) = mlep.defaultSizePixels(4);
end



% ASPECT RATIO
if mlep.guiRatio > fposPixels(3)/fposPixels(4);
    % HORIZONTAL STRETCH
    fposPixels(4) = ceil(fposPixels(3)/mlep.guiRatio);
elseif mlep.guiRatio < fposPixels(3)/fposPixels(4);
    % VERTICAL STRETCH
    fposPixels(3) = ceil(fposPixels(4)*mlep.guiRatio);
end

% Set New Figure Size
% set(myhandle,'OuterPosition',mlep.defaultSizePixels)
%set(myhandle,'OuterPosition',mlep.mainPosition)

end

