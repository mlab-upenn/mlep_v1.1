function [mlep] = mlepPresentation(myhandle)
% Retrieve data
mlep = guidata(myhandle);
%mlep.defaultBackground = [0.8 0.8 0.8];
% PRESENTATION TAB
mlep.presentationTab = uitab('parent',mlep.guiTab); %,'title','1. Presentation' 
%set(mlep.guiTab,'SelectedTab',mlep.presentationTab);
mlep.presentationPanel = uiextras.Panel( 'Parent', mlep.presentationTab, 'BorderType', 'none', 'Padding', 15 );
    % BOX
    mlep.presentationBox = uiextras.VBox( 'Parent', mlep.presentationPanel, 'Padding', 0, 'Spacing', 15  ); 
        % HORIZONTAL BOX FIGURE/ENERGYPLUS
        mlep.presentationIntroTop = uiextras.HBox( 'Parent', mlep.presentationBox, 'Padding', 0, 'Spacing', 20  );
            % PANEL FOR FIGURE
            mlep.presentationIntroPanel = uiextras.Panel('Parent', mlep.presentationIntroTop, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Workflow', 'FontSize', mlep.fontMedium ); %, 'Title', 'WORKFLOW' etchedin etchedout beveledin beveledout line  
                % AXES / FIGURE
                [mlep.workflow,map]=imread([mlep.homePath 'gui' filesep 'figs' filesep 'workflow2.png']);
                
                if exist('imresize')
                    mlep.workflow = imresize(mlep.workflow, 0.65);
                else
                    mlep.workflow = imageresize(mlep.workflow, 0.65, 0.65);
                end
                
                % FIGURE
                uicontrol( 'CDATA', mlep.workflow, 'Parent', mlep.presentationIntroPanel, 'enable', 'inactive');
            % BOX FOR ENERGYPLUS/WEATHER
            mlep.presentationRightBox = uiextras.VBox( 'Parent', mlep.presentationIntroTop );
                % PANEL FOR ENERGYPLUS FILE
                mlep.presentationEnergyPanel = uiextras.Panel('Parent', mlep.presentationRightBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'EnergyPlus', 'FontSize', mlep.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
                    % Box for EnergyPlus and Weather Selection    
                    mlep.presentationIntroTopRight = uiextras.VBox( 'Parent', mlep.presentationEnergyPanel );
                            % PICK ENERGYPLUS FILE
                            mlep.presentationIntroTopRightButton1 = uiextras.HBox( 'Parent', mlep.presentationIntroTopRight, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                mlep.presentationIdfSelect = uicontrol( 'style', 'push', 'Parent', mlep.presentationIntroTopRightButton1, 'String', 'Select IDF file', 'Callback', {@mlepPresentationFunction,myhandle,'selectIdf'}, 'FontSize', mlep.fontSmall );
                                uicontrol( 'style', 'push', 'Parent', mlep.presentationIntroTopRightButton1, 'String', 'Open File', 'Callback', {@mlepPresentationFunction,myhandle,'openIdf'}, 'FontSize', mlep.fontSmall );
                            % ENERGYPLUS NAME    
                            mlep.presentationIntroTopRightButton2 = uiextras.HBox( 'Parent', mlep.presentationIntroTopRight, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                mlep.presentationIdfEdit = uicontrol( 'style', 'edit', 'Parent', mlep.presentationIntroTopRightButton2, 'String', 'EnergyPlus File', 'Enable', 'inactive', 'Background', 'white', 'Callback', {@mlepPresentationFunction,myhandle,'editIdf'}, 'FontSize', mlep.fontSmall );
                            % SELECT TIME STEP
                            mlep.presentationIntroTopRightButton3 = uiextras.HBox( 'Parent', mlep.presentationIntroTopRight, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                mlep.timeStepList = {'1', '2', '3', '4', '5', '6', '10', '12', '15', '20', '30', '60'};
                                uicontrol( 'style', 'text', 'Parent', mlep.presentationIntroTopRightButton3, 'String', 'Select Time Step (min)', 'FontSize', mlep.fontSmall );
                                mlep.presentationTimeStep = uicontrol( 'style', 'popupmenu', 'Parent', mlep.presentationIntroTopRightButton3, 'String', mlep.timeStepList, 'Callback', {@mlepPresentationFunction,myhandle,'getTimeStep'}, 'FontSize', mlep.fontSmall, 'Background', 'w', 'Enable', 'inactive' );
                            % DATE SELECTION
                            mlep.presentationIntroTopRightButton4 = uiextras.HBox( 'Parent', mlep.presentationIntroTopRight, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                % FIRST VERTICAL BOX 
                                mlep.presentationVerticalBox1 = uiextras.VBox( 'Parent', mlep.presentationIntroTopRightButton4, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                    uiextras.Empty( 'Parent', mlep.presentationVerticalBox1 );
                                    uicontrol( 'style', 'text', 'Parent', mlep.presentationVerticalBox1, 'String', 'Begin', 'Enable', 'inactive', 'FontSize', mlep.fontSmall );
                                    uicontrol( 'style', 'text', 'Parent', mlep.presentationVerticalBox1, 'String', 'End', 'Enable', 'inactive', 'FontSize', mlep.fontSmall );
                                % SECOND VERTICAL BOX 
                                mlep.presentationVerticalBox2 = uiextras.VBox( 'Parent', mlep.presentationIntroTopRightButton4, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                    uicontrol( 'style', 'text', 'Parent', mlep.presentationVerticalBox2, 'String', 'Month', 'Enable', 'inactive', 'FontSize', mlep.fontSmall );
                                    mlep.monthList = {'1'; '2';'3'; '4';'5'; '6';'7'; '8';'9'; '10';'11';'12'};
                                    mlep.presentationBeginMonth = uicontrol( 'style', 'edit', 'Parent', mlep.presentationVerticalBox2, 'Background', 'white', 'FontSize', mlep.fontSmall, 'Callback', {@mlepPresentationFunction,myhandle,'getBeginMonth'}, 'Enable', 'inactive' );
                                    mlep.presentationEndMonth = uicontrol( 'style', 'edit', 'Parent', mlep.presentationVerticalBox2, 'Background', 'white', 'FontSize', mlep.fontSmall, 'Callback', {@mlepPresentationFunction,myhandle,'getEndMonth'}, 'Enable', 'inactive' );
                                % THIRD VERTICAL BOX 
                                mlep.presentationVerticalBox3 = uiextras.VBox( 'Parent', mlep.presentationIntroTopRightButton4, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                    uicontrol( 'style', 'text', 'Parent', mlep.presentationVerticalBox3, 'String', 'Day', 'Enable', 'inactive', 'FontSize', mlep.fontSmall );
                                    mlep.dayList = {'1'; '2';'3'; '4';'5'; '6';'7'; '8';'9'; '10';'11';'12'};
                                    mlep.presentationBeginMonth = uicontrol( 'style', 'edit', 'Parent', mlep.presentationVerticalBox3, 'Background', 'white', 'FontSize', mlep.fontSmall, 'Callback', {@mlepPresentationFunction,myhandle,'getBeginDay'}, 'Enable', 'inactive' );
                                    mlep.presentationEndMonth = uicontrol( 'style', 'edit', 'Parent', mlep.presentationVerticalBox3, 'Background', 'white', 'FontSize', mlep.fontSmall, 'Callback', {@mlepPresentationFunction,myhandle,'getEndDay'}, 'Enable', 'inactive' );
                                

                            % UPDATE ENERGYPLUS FILE
                            mlep.presentationIntroTopRightButton5 = uiextras.HBox( 'Parent', mlep.presentationIntroTopRight, 'Spacing', 5, 'Padding', 8 );
                                uiextras.Empty( 'Parent', mlep.presentationIntroTopRightButton5 );
                                %uicontrol( 'style', 'push', 'Parent', mlep.presentationIntroTopRightButton5, 'String', 'Open File', 'Callback', {@mlepPresentationFunction,myhandle,'openIdf'}, 'FontSize', mlep.fontSmall );
                                uicontrol( 'style', 'push', 'Parent', mlep.presentationIntroTopRightButton5, 'String', 'Update File', 'Callback', {@mlepPresentationFunction,myhandle,'loadIdf'}, 'FontSize', mlep.fontSmall );
                % SET SIZES ENERGYPLUS
                set(mlep.presentationIntroTopRight, 'Sizes', [-1 -1 -1 -2 -1] );
                
                % PANEL FOR WEATHER FILE
                mlep.presentationWeatherPanel = uiextras.Panel('Parent', mlep.presentationRightBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Weather', 'FontSize', mlep.fontMedium); % , 'BackgroundColor', mlep.defaultBackground  
                    % Box for Weather Selection    
                    mlep.presentationWeatherVBox = uiextras.VBox( 'Parent', mlep.presentationWeatherPanel );
                        % PICK WEATHER FILE
                            mlep.presentationWeatherButton1 = uiextras.HBox( 'Parent', mlep.presentationWeatherVBox, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                            	mlep.presentationWeatherSelect = uicontrol( 'style', 'push', 'Parent', mlep.presentationWeatherButton1, 'String', 'Select Weather', 'Callback', {@mlepPresentationFunction,myhandle,'selectWeather'}, 'FontSize', mlep.fontSmall );
                                uiextras.Empty( 'Parent', mlep.presentationWeatherButton1 );
                            mlep.presentationWeatherButton2 = uiextras.HBox( 'Parent', mlep.presentationWeatherVBox, 'Spacing', 5, 'Padding', 8 ); % , 'ButtonSize', [200 50]
                                mlep.presentationWeatherEdit = uicontrol( 'style', 'edit', 'Parent', mlep.presentationWeatherButton2, 'String', 'Weather File', 'Enable', 'inactive', 'Background', 'white', 'Callback', {@mlepPresentationFunction,myhandle,'editWeather'}, 'FontSize', mlep.fontSmall );
                                
                                
            % Set Sizes for Energy/Weather Box
            set(mlep.presentationRightBox, 'Sizes', [-5 -2]);
        % Set Sizes for Intro Top Panel            
        set(mlep.presentationIntroTop,'Sizes', [-5 -1.3] );
            
% Store Data        
guidata(myhandle,mlep);        
end