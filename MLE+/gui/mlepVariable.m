function [mlep] = mlepVariable(myhandle)
% Retrieve data
mlep = guidata(myhandle);
mlep.variableHandle = figure('Units','pixels','OuterPosition',mlep.variablePosition, 'CloseRequestFcn', {@mlepVariableFunction,myhandle,'closeVariableTab'}, 'Visible', 'off', 'HandleVisibility', 'callback', 'Name', 'Variable Configuration', 'NumberTitle', 'off'); % ,'WindowStyle','modal' ,'CloseRequestFcn',{@mlepVariableFunction,myhandle,'closeFunction'}

%set(mlep.guiTab,'SelectedTab',mlep.variableTab);
mlep.variablePanel = uiextras.Panel( 'Parent', mlep.variableHandle, 'BorderType', 'none' );
    % BOX
    mlep.variableBox = uiextras.VBox( 'Parent', mlep.variablePanel );
        % LOAD
        mlep.variableFilePanel = uiextras.Panel('Parent', mlep.variableBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'LOAD FILES' ); % etchedin etchedout beveledin beveledout line  
        mlep.variableFile = uiextras.HBox( 'Parent', mlep.variableFilePanel, 'Padding', 1, 'Spacing', 40  );
            mlep.variableIdfName = uicontrol( 'style', 'edit', 'string', 'IDFFILE', 'Parent', mlep.variableFile, 'Background', 'white', 'HorizontalAlignment', 'center', 'FontSize', mlep.fontSmall );
            mlep.variableIdfOpen = uicontrol( 'style', 'push', 'string', 'Open IDF', 'Parent', mlep.variableFile, 'Callback', {@mlepVariableFunction,myhandle,'idfOpen'}, 'FontSize', mlep.fontSmall );
            mlep.variableIdfLoad = uicontrol( 'style', 'push', 'string', 'Load IDF', 'Parent', mlep.variableFile, 'Callback', {@mlepVariableFunction,myhandle,'idfLoad'}, 'FontSize', mlep.fontSmall );
            mlep.variableIdfUpdate = uicontrol( 'style', 'push', 'string', 'Update IDF', 'Parent', mlep.variableFile, 'Callback', {@mlepPresentationFunction,myhandle,'loadIdf'}, 'FontSize', mlep.fontSmall);
            %uiextras.Empty( 'Parent', mlep.variableFile );
            mlep.variableWriteCfg = uicontrol( 'style', 'push', 'string', 'Write variables.cfg', 'Parent', mlep.variableFile, 'Callback', {@mlepVariableFunction,myhandle,'writeCfgCall'}, 'Background', 'g' );
            
%             mlep.variableConfigPopup = uicontrol( 'style', 'popupmenu', 'string', 'variables.cfg', 'Parent', mlep.variableFile, 'Background', 'white'  );
%             mlep.variableConfigLoad = uicontrol( 'style', 'push', 'string', 'LOAD .CFG', 'Parent', mlep.variableFile, 'Callback', {@mlepVariableFunction,myhandle,'loadCfg'} );
        set(mlep.variableFile, 'Sizes', [250 100 100 100 200 ] );
        set(mlep.variableIdfName, 'Enable', 'inactive');
        % INPUT
        mlep.variableInputPanel = uiextras.Panel('Parent', mlep.variableBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Input to EnergyPlus', 'ForegroundColor', 'b', 'FontSize', mlep.fontMedium ); % etchedin etchedout beveledin beveledout line  
        mlep.variableInput = uiextras.HBox( 'Parent', mlep.variableInputPanel, 'Padding', 5, 'Spacing', 5 );
            % LEFT SIDE
            mlep.variableInputTable = uiextras.HBox( 'Parent', mlep.variableInput, 'Padding', 5, 'Spacing', 5 );
                % INPUT TABLE
                columnname =   {'[]','Type', 'Name', 'Alias'};
                columnformat = {[],'char','char','char'};
                columneditable =  [true true true true];
                % TABLE
                mlep.inputTable = uitable('ColumnName', columnname,'ColumnFormat', columnformat,...
                        'ColumnEditable', columneditable, 'ColumnWidth', {40 70 250 100}, 'Parent', mlep.variableInputTable,...
                        'Background', [1 1 1], 'CellEditCallback', {@mlepVariableFunction,myhandle,'editInputTable'} );
                % ADD/DELETE BUTTON
                mlep.variableInputTableButton = uiextras.VButtonBox( 'Parent', mlep.variableInputTable, 'ButtonSize', [100 40], 'VerticalAlignment', 'top'  );
                uicontrol( 'style', 'push', 'string', '<< add', 'Parent', mlep.variableInputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'addInput'});
                uicontrol( 'style', 'push', 'string', 'delete >>', 'Parent', mlep.variableInputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'deleteInput'});
                uicontrol( 'style', 'push', 'string', 'duplicate', 'Parent', mlep.variableInputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'duplicateInput'});
            % RIGHT SIDE
            mlep.variableInputBox = uiextras.VBox( 'Parent', mlep.variableInput);
                % INPUT
                mlep.variableInputBoxInput = uiextras.HBox( 'Parent', mlep.variableInputBox);
                    mlep.variableInputListbox = uicontrol( 'style', 'listbox', 'Parent', mlep.variableInputBoxInput, 'Background', 'white', 'Callback', {@mlepVariableFunction,myhandle,'getInputIndex'} );
                    uiextras.Empty( 'Parent', mlep.variableInputBoxInput );
                    mlep.variableInputCommentButton = uiextras.VBox( 'Parent', mlep.variableInputBoxInput, 'Spacing', 5, 'Padding', 20 );
                    mlep.variableInputCommentTitle = uicontrol( 'style', 'text','Parent', mlep.variableInputCommentButton, 'string', 'Comments', 'FontSize', mlep.fontMedium );
                    mlep.variableInputComment = uicontrol( 'style', 'edit', 'Max', 3, 'Min', 1, 'Parent', mlep.variableInputCommentButton, 'Background', 'white', 'HorizontalAlignment', 'left', 'Callback', {@mlepVariableFunction,myhandle,'editInputComment'}  );
                    uiextras.Empty( 'Parent', mlep.variableInputCommentButton );
                    set(mlep.variableInputCommentButton, 'Sizes', [-1.2 -3 -2]);

        % OUTPUT
        mlep.variableOutputPanel = uiextras.Panel('Parent', mlep.variableBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Output from EnergyPlus', 'ForegroundColor', 'r', 'FontSize', mlep.fontMedium );
        mlep.variableOutput = uiextras.HBox( 'Parent', mlep.variableOutputPanel, 'Padding', 5, 'Spacing', 5 );
            % LEFT SIDE
            mlep.variableOutputTable = uiextras.HBox( 'Parent', mlep.variableOutput, 'Padding', 5, 'Spacing', 5 );

                columnname =   {'[]','Object', 'Name', 'Alias'};
                columnformat = {[],'char','char','char'};
                columneditable =  [true true true true];
                % OUTPUT TABLE 
                mlep.outputTable = uitable( 'ColumnName', columnname,'ColumnFormat', columnformat,...
                        'ColumnEditable', columneditable,'ColumnWidth', {40 150 210 100},'Parent',mlep.variableOutputTable,...
                        'Background', [1 1 1], 'CellEditCallback', {@mlepVariableFunction,myhandle,'editOutputTable'} );
                % ADD/DELETE BUTTON
                mlep.variableOutputTableButton = uiextras.VButtonBox( 'Parent', mlep.variableOutputTable, 'ButtonSize', [100 40], 'VerticalAlignment', 'top'  );
                uicontrol( 'style', 'push', 'string', '<< add', 'Parent', mlep.variableOutputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'addOutput'});
                uicontrol( 'style', 'push', 'string', 'delete >>', 'Parent', mlep.variableOutputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'deleteOutput'});
                uicontrol( 'style', 'push', 'string', 'duplicate', 'Parent', mlep.variableOutputTableButton, 'Callback', {@mlepVariableFunction,myhandle,'duplicateOutput'});
            
            % RIGHT SIDE
            mlep.variableOutputBox = uiextras.HBox( 'Parent', mlep.variableOutput);
                mlep.variableOutputListbox = uicontrol( 'style', 'listbox', 'Parent', mlep.variableOutputBox, 'Background', 'white', 'Callback', {@mlepVariableFunction,myhandle,'getOutputIndex'} );
                uiextras.Empty( 'Parent', mlep.variableOutputBox );
                mlep.variableOutputBoxButton = uiextras.VBox( 'Parent', mlep.variableOutputBox, 'Spacing', 5, 'Padding', 20 );
                mlep.variableOutputCommentTitle = uicontrol( 'style', 'text','Parent', mlep.variableOutputBoxButton, 'string', 'Comments', 'FontSize', mlep.fontMedium );
                mlep.variableOutputComment = uicontrol( 'style', 'edit', 'Max', 3, 'Min', 1,'Parent', mlep.variableOutputBoxButton, 'Background', 'white', 'HorizontalAlignment', 'left', 'Callback', {@mlepVariableFunction,myhandle,'editOutputComment'}  );
                uiextras.Empty( 'Parent', mlep.variableOutputBoxButton );
                set(mlep.variableOutputBoxButton, 'Sizes', [-1.2 -3 -2]);
        % SETTINGS
        mlep.variableSettingsPanel = uiextras.Panel( 'Parent', mlep.variableBox, 'Padding', 10, 'BorderType', 'etchedin', 'BorderWidth', 1, 'Title', 'Settings', 'FontSize', mlep.fontMedium );
        mlep.variableSettings = uiextras.HBox( 'Parent', mlep.variableSettingsPanel, 'Padding', 5, 'Spacing', 5 );
        mlep.variableSettingsButton = uiextras.HBox( 'Parent', mlep.variableSettings, 'Padding', 5, 'Spacing', 40 );
            uicontrol(  'String', 'Load Project', 'Parent', mlep.variableSettingsButton, 'Callback', {@mlepPresentationFunction,myhandle,'loadProject'}, 'FontSize', 11  ); %  , 'Background', mlep.defaultBackground
            uicontrol( 'String', 'Save Project', 'Parent', mlep.variableSettingsButton, 'Callback', {@mlepPresentationFunction,myhandle,'saveProject'}, 'FontSize', 11 );
            uicontrol(  'String', 'Clear Project', 'Parent', mlep.variableSettingsButton, 'Callback', {@mlepPresentationFunction,myhandle,'clearProject'}, 'FontSize', 11 );
            uicontrol( 'String', 'Close Variable', 'Parent', mlep.variableSettingsButton, 'Callback', {@mlepVariableFunction,myhandle,'closeVariableTab'},'FontSize', 11 );


% SET SIZES
set( mlep.variableBox, 'Sizes', [-0.5 -1.7 -1.7 100], 'Padding', 10, 'Spacing', 10 );
set( mlep.variableInputTable, 'Sizes', [-2 -1] );
set( mlep.variableOutputTable, 'Sizes', [-2 -1] );
set( mlep.variableInputBoxInput, 'Sizes', [-2 -0.5 -2] );
set( mlep.variableOutputBox, 'Sizes', [-2 -0.5 -2] );

% Store Data        
guidata(myhandle,mlep); 
end