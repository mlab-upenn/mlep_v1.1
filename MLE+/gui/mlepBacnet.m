function [mlep] = mlepBacnet(myhandle)
% Retrieve data
mlep = guidata(myhandle);

mlep.bacnetTab = uitab('parent',mlep.guiTab); % ,'title','2. Control'
%set(mlep.guiTab,'SelectedTab',mlep.controlTab); 
mlep.bacnetPanel = uiextras.Panel( 'Parent', mlep.bacnetTab, 'BorderType', 'none', 'Padding', 15);
    mlep.bacnetBox = uiextras.VBox( 'Parent', mlep.bacnetPanel, 'Padding', 0, 'Spacing', 15  );
        % LIST DEVICES INFORMATION BOX
        mlep.bacnetDevices = uiextras.Panel('Parent', mlep.bacnetBox, 'Padding', 0, 'BorderType', 'none', 'BorderWidth', 1 ); % etchedin etchedout beveledin beveledout line  
            mlep.bacnetDevicesBox = uiextras.HBox( 'Parent', mlep.bacnetDevices, 'Padding', 0, 'Spacing', 15 );
                % LIST DEVICES BOX
                mlep.bacnetListPanel = uiextras.Panel('Parent', mlep.bacnetDevicesBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Who-Is Request', 'ForegroundColor', 'b', 'FontSize', mlep.fontMedium);
                    mlep.bacnetHBox = uiextras.HBox( 'Parent', mlep.bacnetListPanel, 'Padding', 0, 'Spacing', 10 );
                        mlep.bacnetListBox = uiextras.VButtonBox( 'Parent', mlep.bacnetHBox, 'Padding', 10, 'Spacing', 10, 'ButtonSize', [200 50] );
                            mlep.bacnetListAll = uicontrol( 'style', 'push', 'String', 'All BACnet Devices', 'Parent', mlep.bacnetListBox, 'Callback', {@mlepBacnetFunction,myhandle,'listAllDevices'}, 'FontSize', mlep.fontSmall );
                            mlep.bacnetListRange = uicontrol( 'style', 'push', 'String', 'BACnet Devices in Range', 'Parent', mlep.bacnetListBox, 'Callback', {@mlepBacnetFunction,myhandle,'listRangeDevices'}, 'FontSize', mlep.fontSmall );
                            mlep.bacnetListSpecific = uicontrol( 'style', 'push', 'String', 'BACnet Device ID', 'Parent', mlep.bacnetListBox, 'Callback', {@mlepBacnetFunction,myhandle,'listDevicesID'}, 'FontSize', mlep.fontSmall );
                        mlep.bacnetListEditBox = uiextras.VButtonBox( 'Parent', mlep.bacnetHBox, 'Padding', 10, 'Spacing', 10, 'ButtonSize', [200 50] );
                            uiextras.Empty( 'Parent', mlep.bacnetListEditBox );
                            mlep.bacnetRangeHBox = uiextras.HBox( 'Parent', mlep.bacnetListEditBox, 'Padding', 0, 'Spacing', 15 );
                                mlep.bacnetListRangeLow = uicontrol( 'style', 'edit', 'String', 'Low', 'Parent', mlep.bacnetRangeHBox, 'Callback', {@mlepBacnetFunction,myhandle,'listRangeDevices'}, 'FontSize', mlep.fontSmall, 'Background', 'white' );
                                mlep.bacnetListRangeHigh = uicontrol( 'style', 'edit', 'String', 'High', 'Parent', mlep.bacnetRangeHBox, 'Callback', {@mlepBacnetFunction,myhandle,'listRangeDevices'}, 'FontSize', mlep.fontSmall, 'Background', 'white' );
                            mlep.bacnetListSpecificID = uicontrol( 'style', 'edit', 'String', 'BACnet Device ID', 'Parent', mlep.bacnetListEditBox, 'Callback', {@mlepBacnetFunction,myhandle,'listAllDevices'}, 'FontSize', mlep.fontSmall, 'Background', 'white' );
                     set(mlep.bacnetHBox, 'Sizes', [-3 -2]);
                % COMMENTS/INFO OF DEVICES
                mlep.bacnetInfoPanel = uiextras.Panel('Parent', mlep.bacnetDevicesBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Information', 'ForegroundColor', 'r', 'FontSize', mlep.fontMedium );
                    mlep.bacnetInfoBox = uiextras.HBox( 'Parent', mlep.bacnetInfoPanel, 'Padding', 10, 'Spacing', 0 );
                        %mlep.bacnetDeviceListbox = uicontrol( 'style', 'listbox', 'Parent', mlep.bacnetInfoBox, 'Background', 'white', 'Callback', {@mlepBacnetFunction,myhandle,'getListDevicesIndex'});
                        %uiextras.Empty( 'Parent', mlep.bacnetInfoBox );
                        mlep.bacnetDeviceInfo = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetInfoBox, 'Background', 'white', 'HorizontalAlignment', 'left', 'MAX', 4, 'MIN', 1, 'Enable', 'inactive'); % , 'enable', 'active' 
                    %set(mlep.bacnetInfoBox, 'Sizes', [-3 -1 -3]);
            set(mlep.bacnetDevicesBox, 'Sizes', [-2 -3]);        
        % CONTROL PANEL 
        mlep.bacnetCommunicationPanel = uiextras.Panel('Parent', mlep.bacnetBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Communication', 'FontSize', mlep.fontMedium); % etchedin etchedout beveledin beveledout line  
            % TAB
            mlep.bacnetCommunicationTab = uiextras.TabPanel( 'Parent', mlep.bacnetCommunicationPanel, 'Padding', 5, 'TabSize', 150, 'FontSize', mlep.fontMedium );
            %% Tab 1
            % PANEL TAB 1
            mlep.bacnetCommunicationPanel1 = uiextras.Panel( 'Parent', mlep.bacnetCommunicationTab, 'BorderType', 'none' );
                mlep.bacnetTab1Box = uiextras.HBox( 'Parent', mlep.bacnetCommunicationPanel1, 'Padding', 10, 'Spacing', 15  );
                    mlep.bacnetReadPanel = uiextras.Panel('Parent', mlep.bacnetTab1Box, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Read Property', 'ForegroundColor', 'b', 'FontSize', mlep.fontMedium);
                        mlep.bacnetReadBox = uiextras.VBox( 'Parent', mlep.bacnetReadPanel, 'Padding', 5, 'Spacing', 5  );
                            mlep.bacnetReadBox1 = uiextras.HBox( 'Parent', mlep.bacnetReadBox, 'Padding', 0, 'Spacing', 15  );
                                uicontrol( 'style', 'text', 'String', 'Device ID', 'Parent', mlep.bacnetReadBox1, 'FontSize', mlep.fontMedium );
                                mlep.readDeviceID = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetReadBox1, 'Callback', {@mlepBacnetFunction,myhandle,'getReadDeviceID'}, 'Background', 'white');
                            mlep.bacnetReadBox2 = uiextras.HBox( 'Parent', mlep.bacnetReadBox, 'Padding', 0, 'Spacing', 15  );
                                uicontrol( 'style', 'text', 'String', 'Select Object ', 'Parent', mlep.bacnetReadBox2, 'FontSize', mlep.fontMedium );
                                % READ BACNET OBJECTS 
                                mlep.readBACnetObject = {'Analog Value';'Analog Output';'Binary Input';'Binary Output'};
                                mlep.readBACnetObjectSelect = uicontrol( 'style', 'popupmenu', 'String', mlep.readBACnetObject, 'Parent', mlep.bacnetReadBox2, 'Callback', {@mlepBacnetFunction,myhandle,'getReadObjectIndex'}, 'Background', 'white');
                            mlep.bacnetReadBox3 = uiextras.HBox( 'Parent', mlep.bacnetReadBox, 'Padding', 0, 'Spacing', 15  );
                                uicontrol( 'style', 'text', 'String', 'Select Property', 'Parent', mlep.bacnetReadBox3, 'FontSize', mlep.fontMedium );
                                % READ BACNET PROPERTY 
                                mlep.readBACnetProperty = {'Present Value';'Object Name';'Max Present Value';'Min Present Value';'Setpoint'};
                                mlep.readBACnetPropertySelect = uicontrol( 'style', 'popupmenu', 'String', mlep.readBACnetProperty, 'Parent', mlep.bacnetReadBox3, 'Callback', {@mlepBacnetFunction,myhandle,'getReadPropertyIndex'}, 'Background', 'white');
                            mlep.bacnetReadBox5 = uiextras.HBox( 'Parent', mlep.bacnetReadBox, 'Padding', 0, 'Spacing', 15  );
                                mlep.readFunction = uicontrol( 'style', 'push', 'Parent', mlep.bacnetReadBox5, 'Callback', {@mlepBacnetFunction,myhandle,'functionReadProperty'}, 'String', 'Read Property', 'FontSize', mlep.fontMedium);
                                mlep.bacnetReadResult = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetReadBox5, 'Background', 'w', 'Max', 4, 'Min', 1, 'FontSize', mlep.fontMedium, 'Enable', 'inactive' ); 
                        % INFO
                    mlep.bacnetReadInfoPanel = uiextras.Panel('Parent', mlep.bacnetTab1Box, 'Padding', 20, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Read Result', 'ForegroundColor', 'b', 'FontSize', mlep.fontMedium);
                        mlep.bacnetReadInfo = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetReadInfoPanel, 'Background', 'w', 'FontSize', mlep.fontMedium, 'Enable', 'inactive', 'Max', 4, 'Min', 1, 'HorizontalAlignment', 'left' );
                    % SET SIZE
                    set(mlep.bacnetTab1Box, 'Sizes', [-1 -1]);        
                          
            %% Tab 2
            % PANEL TAB 2
            mlep.bacnetCommunicationPanel2 = uiextras.Panel( 'Parent', mlep.bacnetCommunicationTab, 'BorderType', 'none' );
                mlep.bacnetTab2Box = uiextras.HBox( 'Parent', mlep.bacnetCommunicationPanel2, 'Padding', 10, 'Spacing', 15 );
                    mlep.bacnetWritePanel = uiextras.Panel('Parent', mlep.bacnetTab2Box, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Write Property', 'ForegroundColor', 'r', 'FontSize', mlep.fontMedium);
                            mlep.bacnetWriteBox = uiextras.VBox( 'Parent', mlep.bacnetWritePanel, 'Padding', 5, 'Spacing', 5  );
                                mlep.bacnetWriteBox1 = uiextras.HBox( 'Parent', mlep.bacnetWriteBox, 'Padding', 0, 'Spacing', 15  );
                                    uicontrol( 'style', 'text', 'String', 'Device ID', 'Parent', mlep.bacnetWriteBox1, 'FontSize', mlep.fontMedium );
                                    mlep.writeDeviceID = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetWriteBox1, 'Callback', {@mlepBacnetFunction,myhandle,'getWriteDeviceID'}, 'Background', 'white', 'FontSize', mlep.fontMedium );
                                mlep.bacnetWriteBox2 = uiextras.HBox( 'Parent', mlep.bacnetWriteBox, 'Padding', 0, 'Spacing', 15  );
                                    uicontrol( 'style', 'text', 'String', 'Select Object', 'Parent', mlep.bacnetWriteBox2, 'FontSize', mlep.fontMedium );
                                    % WRITE BACNET OBJECTS 
                                    mlep.writeBACnetObject = {'Analog Value';'Analog Output';'Binary Input';'Binary Output'};
                                    mlep.writeBACnetObjectSelect = uicontrol( 'style', 'popupmenu', 'String', mlep.writeBACnetObject, 'Parent', mlep.bacnetWriteBox2, 'Callback', {@mlepBacnetFunction,myhandle,'getWriteObjectIndex'}, 'Background', 'white');
                                mlep.bacnetWriteBox3 = uiextras.HBox( 'Parent', mlep.bacnetWriteBox, 'Padding', 0, 'Spacing', 15  );
                                    uicontrol( 'style', 'text', 'String', 'Select Property', 'Parent', mlep.bacnetWriteBox3, 'FontSize', mlep.fontMedium );
                                    % WRITE BACNET PROPERTY 
                                    mlep.writeBACnetProperty = {'Present Value';'Object Name';'Max Present Value';'Min Present Value';'Setpoint'};
                                    mlep.writeBACnetPropertySelect = uicontrol( 'style', 'popupmenu', 'String', mlep.writeBACnetProperty, 'Parent', mlep.bacnetWriteBox3, 'Callback', {@mlepBacnetFunction,myhandle,'getWritePropertyIndex'}, 'Background', 'white');
                                mlep.bacnetWriteBox4 = uiextras.HBox( 'Parent', mlep.bacnetWriteBox, 'Padding', 0, 'Spacing', 15  );
                                    uicontrol( 'style', 'text', 'String', 'Select Application Tag', 'Parent', mlep.bacnetWriteBox4, 'FontSize', mlep.fontMedium);
                                    % WRITE BACNET TAG
                                    mlep.writeApplicationTag = {'Boolean';'Real';'Character';'Unsigned Int'};
                                    mlep.bacnetWriteApplicationTagSelect = uicontrol( 'style', 'popupmenu', 'String', mlep.writeApplicationTag, 'Parent', mlep.bacnetWriteBox4, 'Callback', {@mlepBacnetFunction,myhandle,'getWriteApplicationIndex'}, 'Background', 'white', 'FontSize', mlep.fontMedium);
                                mlep.bacnetWriteBox5 = uiextras.HBox( 'Parent', mlep.bacnetWriteBox, 'Padding', 0, 'Spacing', 15  );
                                    mlep.writeFunction = uicontrol( 'style', 'push', 'String', 'Write Property', 'Parent', mlep.bacnetWriteBox5, 'Callback', {@mlepBacnetFunction,myhandle,'functionWriteProperty'}, 'FontSize', mlep.fontMedium );
                                    mlep.bacnetWriteEditValue = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetWriteBox5, 'Callback', {@mlepBacnetFunction,myhandle,'getWriteValue'}, 'FontSize', mlep.fontMedium, 'Background', 'white' );      
                            % INFO
                            mlep.bacnetWriteInfoPanel = uiextras.Panel('Parent', mlep.bacnetTab2Box, 'Padding', 20, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Write Result', 'ForegroundColor', 'r', 'FontSize', mlep.fontMedium);
                                mlep.bacnetWriteInfo = uicontrol( 'style', 'edit', 'Parent', mlep.bacnetWriteInfoPanel, 'Background', 'w', 'FontSize', mlep.fontMedium, 'Enable', 'inactive', 'HorizontalAlignment', 'left', 'Max', 4, 'Min', 1 );
                        % SET SIZE
                        set(mlep.bacnetTab2Box, 'Sizes', [-1 -1]);
            %% Tab 3
            % PANEL TAB 3
            mlep.bacnetCommunicationPanel3 = uiextras.Panel( 'Parent', mlep.bacnetCommunicationTab, 'BorderType', 'none' );
            
            %% SET DEFAULT TAB PROPERTIES
            mlep.bacnetCommunicationTab.SelectedChild = 1;
            mlep.bacnetCommunicationTab.TabNames = {'1. Read ', '2. Write', '3. Panel'};

%                 mlep.bacnetCommunicationBox = uiextras.HBox( 'Parent', mlep.bacnetCommunicationPanel, 'Padding', 0, 'Spacing', 20 );
%                     mlep.bacnetWrite = uiextras.Panel('Parent', mlep.bacnetCommunicationBox, 'Padding', 0, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Configuration', 'FontSize', mlep.fontMedium );
%                         mlep.controlLoadVariablesBox = uiextras.VButtonBox( 'Parent', mlep.controlFeedbackLeft, 'Spacing', 20, 'Padding', 20, 'ButtonSize', [200 50]); %,
%                             uicontrol( 'style', 'push', 'String', 'Variables', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'} );
%                             uicontrol( 'style', 'push', 'String', 'Open EnergyPlus File', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'openIdf'} );
%                             uicontrol( 'style', 'push', 'String', 'Variables2', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'} );
%                             uicontrol( 'style', 'push', 'String', 'Variables3', 'Parent', mlep.controlLoadVariablesBox, 'Callback', {@mlepControlFunction,myhandle,'loadVariables'} );
% 
%                         mlep.controlFeedbackRight = uiextras.Panel('Parent', mlep.controlFeedbackBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Controller Type', 'FontSize', mlep.fontMedium ); 
%                             % TAB 
%                             mlep.controlFeedbackTab = uiextras.TabPanel( 'Parent', mlep.controlFeedbackRight, 'Padding', 5, 'TabSize', 150 );
%                             %% Tab 1
%                             % PANEL TAB 1 
%                             mlep.controlFeedbackPanel1 = uiextras.Panel( 'Parent', mlep.controlFeedbackTab, 'BorderType', 'none' );
%                                 mlep.controlFeedback1Box = uiextras.HBox( 'Parent', mlep.controlFeedbackPanel1, 'Padding', 0, 'Spacing', 20 );
%                                     mlep.controlFeedback1BoxVBox = uiextras.VBox( 'Parent', mlep.controlFeedback1Box, 'Padding', 5, 'Spacing', 5 );
%                                         mlep.controlInListboxPID = uicontrol( 'style', 'listbox', 'Parent', mlep.controlFeedback1BoxVBox, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'} );
%                                         uicontrol( 'style', 'push', 'Parent', mlep.controlFeedback1BoxVBox, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'} );
%                                     set(mlep.controlFeedback1BoxVBox,'Sizes',[-4 -1]);    
%                                     uicontrol( 'style', 'push', 'Parent', mlep.controlFeedback1Box, 'Callback', {@mlepControlFunction,myhandle,'getInputIndexPID'} );
%                                 set(mlep.controlFeedback1Box,'Sizes',[-1 -4]);
%                         % Set Default Tab and Names
%                         mlep.controlFeedbackTab.TabNames = {'1. PID ', '2. MPC ', '3. Neural Networks '};
%                         mlep.controlFeedbackTab.SelectedChild = 4;

                % Set size Box 
%                 set(mlep.controlFeedbackBox, 'Sizes', [-1 -5]);

% SET SIZE            
set( mlep.bacnetBox, 'Sizes', [-2 -4] );
%set( mlep.controlBox, 'Sizes', [-2 -2 -1] );

% Store Data        
guidata(myhandle,mlep); 
end

