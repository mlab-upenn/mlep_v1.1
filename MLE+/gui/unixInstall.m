function [install, myhandle] = unixInstall(mlepFolder)
myhandle = figure('Units','pixels','OuterPosition',[200 200 900 400], 'HandleVisibility', 'callback', 'name', 'MLE+ Installation', 'NumberTitle', 'off', 'DockControls', 'off', 'ToolBar', 'none'); % [0.05 0.05 0.9 0.9]
set(myhandle, 'Resize','off');
install.handle = myhandle;
install.fontMedium = 12;
install.fontLarge = 15;
install.data.eplusPathCheck = 0;
install.data.javaPathCheck = 0;
install.data.homePath = mlepFolder;

install.panel = uiextras.Panel( 'Parent', myhandle, 'BorderType', 'none', 'Padding', 15 );

    % VERTICAL BOX
    install.mainBox = uiextras.VBox( 'Parent', install.panel, 'Padding', 0, 'Spacing', 15  ); 
        % HORIZONTAL BOX FIGURE/ENERGYPLUS
        install.VBox1Panel = uiextras.Panel('Parent', install.mainBox, 'Padding', 5, 'BorderType', 'none', 'BorderWidth', 1, 'FontSize', install.fontLarge, 'Title', 'MLE+ Instructions:', 'TitlePosition', 'centertop'); % , 'BackgroundColor', mlep.defaultBackground  
            install.VBox1 = uiextras.HBox( 'Parent', install.VBox1Panel, 'Padding', 0, 'Spacing', 15); 
                instructions = {'1) Specify the path to EnergyPlus main directory.';...
                                '2) Speficy the path to the folder with Java binaries.';...
                                '3) Replace RunEPlus:';...
                                '      - Sets the Output file to be ./Outputs.';...
                                '      - Prevents deleting files with .mat extension.'};
            	uicontrol( 'style', 'text', 'Parent', install.VBox1, 'String', instructions, 'FontSize', install.fontLarge, 'Callback', {@installFunction,myhandle,'getEplusPath'}, 'HorizontalAlignment', 'left');
                %install.eplusEdit = uicontrol( 'style', 'edit', 'Parent', install.VBox1Panel, 'String', 'EnergyPlus Path', 'Enable', 'inactive', 'Background', 'white', 'Callback', {@installFunction,myhandle,'editEplusPath'}, 'FontSize', install.fontMedium);
        % HORIZONTAL BOX FIGURE/ENERGYPLUS
        % PROBLEM
        install.VBox2Panel = uiextras.Panel('Parent', install.mainBox, 'Padding', 15, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', '1) EnergyPlus Directory (e.g. C:\EnergyPlusV7-1-0 or /Applications/EnergyPlusV7-1-0)', 'FontSize', install.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
            install.VBox2 = uiextras.HBox( 'Parent', install.VBox2Panel, 'Padding', 0, 'Spacing', 25  ); 
            	install.eplusEdit = uicontrol( 'style', 'edit', 'Parent', install.VBox2, 'String', 'EnergyPlus Path', 'Background', 'white', 'FontSize', install.fontMedium); % , 'Callback', {@installFunction,myhandle,'editEplusPath'}
                uicontrol( 'style', 'push', 'Parent', install.VBox2, 'String', 'Select EnergyPlus Directory', 'FontSize', 12, 'Callback', {@installFunction,myhandle,'getEplusPathUnix'});
                
%         % HORIZONTAL BOX FIGURE/ENERGYPLUS
%         install.VBox3Panel = uiextras.Panel('Parent', install.mainBox, 'Padding', 15, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', '2) Java Directory (e.g. C:\Program Files\Java\jre6\bin or /usr/bin/java)', 'FontSize', install.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
%             install.VBox3 = uiextras.HBox( 'Parent', install.VBox3Panel, 'Padding', 0, 'Spacing', 25  ); 
%             	install.javaEdit = uicontrol( 'style', 'edit', 'Parent', install.VBox3, 'String', 'Java Path', 'Background', 'white', 'FontSize', install.fontMedium); % , 'Callback', {@installFunction,myhandle,'editJavaPath'}
%                 uicontrol( 'style', 'push', 'Parent', install.VBox3, 'String', 'Select Java Bin Directory', 'FontSize', 12, 'Callback', {@installFunction,myhandle,'getJavaPathUnix'});
%                 
%         % HORIZONTAL BOX FIGURE/ENERGYPLUS
%         install.VBox4Panel = uiextras.Panel('Parent', install.mainBox, 'Padding', 15, 'BorderType', 'etchedin', 'BorderWidth', 1,  'Title', '3) Replace RunEPlus', 'FontSize', install.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
%             install.VBox4 = uiextras.HBox( 'Parent', install.VBox4Panel, 'Padding', 0, 'Spacing', 25  ); 
% %             	uicontrol( 'style', 'push', 'Parent', install.VBox4, 'String', 'Replace RunEPlus', 'FontSize', 12, 'Callback', {@installFunction,myhandle,'replaceEPlus'});
%                 install.runEPlusEdit = uicontrol( 'style', 'edit', 'Parent', install.VBox4, 'String', 'Replace the file in your EnergyPlus distribution (/EnergyPlusV7-1-0/bin/runenergyplus) with /MLE+/gui/runenergyplus', 'Enable', 'inactive', 'Background', 'white', 'FontSize', install.fontMedium);
        
        % HORIZONTAL BOX FIGURE/ENERGYPLUS
        install.VBox5Panel = uiextras.Panel('Parent', install.mainBox, 'Padding', 15, 'BorderType', 'none', 'BorderWidth', 1, 'FontSize', install.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
            install.VBox5 = uiextras.HBox( 'Parent', install.VBox5Panel, 'Padding', 0, 'Spacing', 25  ); 
            	%uiextras.Empty( 'Parent', install.VBox5);
                uicontrol( 'style', 'push', 'Parent', install.VBox5, 'String', 'Done', 'FontSize', install.fontMedium, 'Callback', {@installFunction,myhandle,'closeInstall'});

                set(install.mainBox, 'Sizes', [-1.5 -1 -1]);    




end
