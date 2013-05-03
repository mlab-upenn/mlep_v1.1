function [mlep] = mlepControl(myhandle)
% Retrieve data
mlep = guidata(myhandle);

mlep.controlTab = uitab('parent',mlep.guiTab); % ,'title','2. Control'
%set(mlep.guiTab,'SelectedTab',mlep.controlTab); 
mlep.controlPanel = uiextras.Panel( 'Parent', mlep.controlTab, 'BorderType', 'none', 'Padding', 15);
    mlep.controlBox = uiextras.VBox( 'Parent', mlep.controlPanel, 'Padding', 0, 'Spacing', 15  );
        % INPUT/OUTPUT BOX
        mlep.controlVarPanel = uiextras.Panel('Parent', mlep.controlBox, 'Padding', 0, 'BorderType', 'none', 'BorderWidth', 1 ); % etchedin etchedout beveledin beveledout line  
        mlep.controlVar = uiextras.HBox( 'Parent', mlep.controlVarPanel, 'Padding', 0, 'Spacing', 15 );
            % INPUT BOX
            mlep.controlVarInPanel = uiextras.Panel('Parent', mlep.controlVar, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Input', 'ForegroundColor', 'b', 'FontSize', mlep.fontMedium);
            mlep.controlVarIn = uiextras.HBox( 'Parent', mlep.controlVarInPanel, 'Padding', 10, 'Spacing', 0 );
                mlep.controlInListbox = uicontrol( 'style', 'listbox', 'Parent', mlep.controlVarIn, 'Callback', {@mlepControlFunction,myhandle,'getInputIndex'}, 'FontSize', mlep.fontSmall );
                uiextras.Empty( 'Parent', mlep.controlVarIn );
                mlep.controlInComment = uicontrol( 'style', 'edit', 'Parent', mlep.controlVarIn, 'Background', 'white', 'HorizontalAlignment', 'left', 'Callback', {@mlepControlFunction,myhandle,'editInputComment'}, 'FontSize', mlep.fontSmall );
            set(mlep.controlVarIn, 'Sizes', [-3 -1 -3]);
            % OUTPUT BOX
            mlep.controlVarOutPanel = uiextras.Panel('Parent', mlep.controlVar, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Output', 'ForegroundColor', 'r', 'FontSize', mlep.fontMedium );
            mlep.controlVarOut = uiextras.HBox( 'Parent', mlep.controlVarOutPanel, 'Padding', 10, 'Spacing', 0 );
                mlep.controlOutListbox = uicontrol( 'style', 'listbox', 'Parent', mlep.controlVarOut, 'Callback', {@mlepControlFunction,myhandle,'getOutputIndex'}, 'FontSize', mlep.fontSmall);
                uiextras.Empty( 'Parent', mlep.controlVarOut );
                mlep.controlOutComment = uicontrol( 'style', 'edit', 'Parent', mlep.controlVarOut, 'Background', 'white', 'HorizontalAlignment', 'left', 'Callback', {@mlepControlFunction,myhandle,'editOutputComment'}, 'FontSize', mlep.fontSmall );
            set(mlep.controlVarOut, 'Sizes', [-3 -1 -3]);
        % CONTROL PANEL 
        mlep.controlFeedbackPanel = uiextras.Panel('Parent', mlep.controlBox, 'Padding', 0, 'BorderType', 'none', 'BorderWidth', 1); % etchedin etchedout beveledin beveledout line  
            mlep.controlFeedbackBox = uiextras.HBox( 'Parent', mlep.controlFeedbackPanel, 'Padding', 0, 'Spacing', 20 );
                mlep.controlFeedbackLeft = uiextras.Panel('Parent', mlep.controlFeedbackBox, 'Padding', 0, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Configuration', 'FontSize', mlep.fontMedium  );
                    mlep.controlLoadVariablesBox = uiextras.VButtonBox( 'Parent', mlep.controlFeedbackLeft, 'Spacing', 20, 'Padding', 20, 'ButtonSize', [200 50]); %,
                        uicontrol( 'style', 'push', 'String', 'Variables', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'}, 'FontSize', mlep.fontSmall );
                        uicontrol( 'style', 'push', 'String', 'Open EnergyPlus File', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'openIdf'}, 'FontSize', mlep.fontSmall );
                        uicontrol( 'style', 'push', 'String', 'NOT AVAILABLE', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'}, 'FontSize', mlep.fontSmall );
                        uicontrol( 'style', 'push', 'String', 'NOT AVAILABLE', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'}, 'FontSize', mlep.fontSmall );

                mlep.controlFeedbackRight = uiextras.Panel('Parent', mlep.controlFeedbackBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Controller Type', 'FontSize', mlep.fontMedium  ); 
                    % TAB 
                    mlep.controlFeedbackTab = uiextras.TabPanel( 'Parent', mlep.controlFeedbackRight, 'Padding', 5, 'TabSize', 200, 'FontSize', mlep.fontMedium );
                    %% Tab 1
                    % PANEL TAB 1 
                    mlep.controlFeedbackPanel1 = uiextras.Panel( 'Parent', mlep.controlFeedbackTab, 'BorderType', 'none' );
                        mlep.controlFeedback1Box = uiextras.HBox( 'Parent', mlep.controlFeedbackPanel1, 'Padding', 0, 'Spacing', 20 );
                            mlep.controlFeedback1BoxVBox = uiextras.VBox( 'Parent', mlep.controlFeedback1Box, 'Padding', 5, 'Spacing', 5 );
                                mlep.controlInListboxPID = uicontrol( 'style', 'listbox', 'Parent', mlep.controlFeedback1BoxVBox, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'}, 'FontSize', mlep.fontSmall );
                                uicontrol( 'style', 'push', 'Parent', mlep.controlFeedback1BoxVBox, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'}, 'FontSize', mlep.fontSmall );
                            set(mlep.controlFeedback1BoxVBox,'Sizes',[-4 -1]);    
                            uicontrol( 'style', 'push', 'Parent', mlep.controlFeedback1Box, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'}, 'FontSize', mlep.fontSmall );
                        set(mlep.controlFeedback1Box,'Sizes',[-1 -4]);

                    %% TAB 4 USER DEFINED
                    % PANEL TAB 4 
                    mlep.controlFeedbackPanel4 = uiextras.Panel( 'Parent', mlep.controlFeedbackTab, 'BorderType', 'none', 'BorderWidth', 1);
                        % HBOX
                        mlep.controlFeedback4Box = uiextras.HBox( 'Parent', mlep.controlFeedbackPanel4, 'Padding', 5, 'Spacing', 20 );
%                             % PANEL CONTROL FILE
%                             mlep.controlControlFilePanel = uiextras.Panel( 'Parent', mlep.controlFeedback4Box, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Control File', 'FontSize', mlep.fontMedium);
                                % VBOX FOR BUTTONS
                                mlep.controlFeedbackFile = uiextras.VBox( 'Parent', mlep.controlFeedback4Box, 'Padding', 10, 'Spacing', 10 );
                                    uicontrol( 'style', 'text', 'Parent', mlep.controlFeedbackFile, 'String', {'Select Control File'}, 'FontSize', mlep.fontMedium );
                                    mlep.controlFeedbackFileTop = uiextras.HButtonBox( 'Parent', mlep.controlFeedbackFile, 'ButtonSize', [200 60] );
                                        mlep.controlFeedbackFileCreate = uicontrol( 'style', 'push', 'Parent', mlep.controlFeedbackFileTop, 'String', 'Create Control File', 'Callback', {@mlepControlFunction,myhandle,'createControlFile'}, 'FontSize', mlep.fontSmall);
                                        mlep.controlFeedbackCreateEdit = uicontrol( 'style', 'edit', 'Parent', mlep.controlFeedbackFileTop, 'Background', 'white', 'String', 'controlFile.m', 'Callback', {@mlepControlFunction,myhandle, 'editControlFile'}, 'FontSize', mlep.fontSmall, 'Enable', 'inactive' );
                                    mlep.controlFeedbackFileMid = uiextras.HButtonBox( 'Parent', mlep.controlFeedbackFile, 'ButtonSize', [200 60] );
                                        mlep.controlFeedbackFileLoad = uicontrol( 'style', 'push', 'Parent', mlep.controlFeedbackFileMid, 'String', 'Load Control File', 'Callback', {@mlepControlFunction,myhandle,'loadControlFile'}, 'FontSize', mlep.fontSmall );
                                        mlep.controlFeedbackLoadEdit = uicontrol( 'style', 'edit', 'Parent', mlep.controlFeedbackFileMid, 'Background', 'white', 'String', 'controlFile.m', 'FontSize', mlep.fontSmall, 'Enable', 'inactive' );
                                    mlep.controlFeedbackFileBot = uiextras.HButtonBox( 'Parent', mlep.controlFeedbackFile, 'ButtonSize', [200 60] );
                                    mlep.controlEditControlFile = uicontrol( 'style', 'push', 'String', 'Edit Control File', 'Parent', mlep.controlFeedbackFileBot, 'Callback', {@mlepControlFunction,myhandle,'editControl'}, 'FontSize', mlep.fontSmall );
%                             % PANEL USER DATA 
%                             mlep.controlUserDataPanel = uiextras.Panel( 'Parent', mlep.controlFeedback4Box, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'User Data', 'FontSize', mlep.fontMedium);
                                % VBUTTONBOX USER DATA
                                mlep.controlFeedbackDataButton = uiextras.VButtonBox( 'Parent', mlep.controlFeedback4Box, 'ButtonSize', [200 60], 'Padding',20 ); %
                                    uicontrol( 'style', 'text', 'Parent', mlep.controlFeedbackDataButton, 'String', {'User Data'}, 'FontSize', mlep.fontMedium, 'HorizontalAlignment', 'center');
                                    mlep.controlUpdateWorkspace = uicontrol( 'style', 'push', 'Parent', mlep.controlFeedbackDataButton, 'String', 'Update Worspace', 'Callback', {@mlepControlFunction,myhandle,'updateWorkspace'}, 'FontSize', mlep.fontSmall );
                                    mlep.controlPopupUserdata = uicontrol( 'style', 'popupmenu', 'Parent', mlep.controlFeedbackDataButton, 'String', 'Select User Data', 'Callback', {@mlepControlFunction,myhandle,'selectUserdata'}, 'Enable','off', 'FontSize', mlep.fontSmall);

                % Set Default Tab and Names
                mlep.controlFeedbackTab.TabNames = {'1. PID ', '2. User Defined'}; % '1. PID ', '2. MPC ', '3. Neural Networks ', 
                mlep.controlFeedbackTab.SelectedChild = 2;
                
            % Set size Box 
            set(mlep.controlFeedbackBox, 'Sizes', [-1.5 -5]);

% SET SIZE            
set( mlep.controlBox, 'Sizes', [-2 -4] );
%set( mlep.controlBox, 'Sizes', [-2 -2 -1] );

% Store Data        
guidata(myhandle,mlep); 
end

