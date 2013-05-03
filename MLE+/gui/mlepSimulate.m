% RUN SIMULATION ------------------------------------
function [mlep] = mlepSimulate(myhandle)
% Retrieve data
mlep = guidata(myhandle);

mlep.simulateTab = uitab('parent',mlep.guiTab); % ,'title','4. Simulate'
%set(mlep.guiTab,'SelectedTab',mlep.simulateTab);
mlep.simulatePanel = uiextras.Panel( 'Parent', mlep.simulateTab, 'TitlePosition', 'LeftTop', 'BorderType', 'none', 'Padding', 15);
    mlep.simulateBox = uiextras.VBox( 'Parent', mlep.simulatePanel, 'Spacing', 15, 'Padding', 0 );
        % VARIABLES/ PLOT
        mlep.simulateFeedbackPanel = uiextras.Panel('Parent', mlep.simulateBox, 'Padding', 0, 'BorderType', 'none'); % etchedin etchedout beveledin beveledout line  
        mlep.simulateFeedback = uiextras.HBox( 'Parent', mlep.simulateFeedbackPanel, 'Padding', 0, 'Spacing', 20 );
            % VARIABLE/BUTTONS
            mlep.simulateVariablesPanel = uiextras.Panel( 'Parent', mlep.simulateFeedback, 'Title', 'Variables', 'TitlePosition', 'LeftTop', 'Padding', 0, 'FontSize', mlep.fontMedium );
            mlep.simulateFeedbackBox1 = uiextras.VBox( 'Parent', mlep.simulateVariablesPanel, 'Padding', 20, 'Spacing', 5 );
                uicontrol( 'style', 'text', 'Parent', mlep.simulateFeedbackBox1, 'String', 'Variables', 'FontSize', 12, 'FontSize', mlep.fontMedium );
                mlep.simulateListbox = uicontrol( 'style', 'listbox', 'Max', 3, 'Min', 1, 'Parent', mlep.simulateFeedbackBox1, 'String', '', 'Background', 'white', 'Callback', {@mlepSimulateFunction,myhandle,'select_listbox'}, 'FontSize', mlep.fontSmall );
                mlep.simulateFeedbackBox2 = uiextras.HBox( 'Parent', mlep.simulateFeedbackBox1, 'Padding', 5, 'Spacing', 5 );
                    mlep.simulateRun = uicontrol( 'style', 'push', 'Parent', mlep.simulateFeedbackBox2, 'String', 'Run Simulation', 'Background', 'g', 'Callback', {@mlepSimulateFunction,myhandle,'runSimulation'}, 'FontSize', mlep.fontSmall );
                    mlep.simulateFeedbackBox3 = uiextras.VButtonBox( 'Parent', mlep.simulateFeedbackBox2, 'Padding', 5, 'Spacing', 5, 'ButtonSize', [200 40], 'VerticalAlignment', 'top' );
                        mlep.simulatePlot = uicontrol( 'style', 'push', 'Parent', mlep.simulateFeedbackBox3, 'String', 'Plot', 'Callback', {@mlepSimulateFunction,myhandle,'plotVariable'}, 'FontSize', mlep.fontSmall );
                        uicontrol( 'style', 'push', 'Parent', mlep.simulateFeedbackBox3, 'String', 'save selected', 'Callback', {@mlepSimulateFunction,myhandle,'saveResult'}, 'FontSize', mlep.fontSmall  );
                        uicontrol( 'style', 'push', 'Parent', mlep.simulateFeedbackBox3, 'String', 'save all', 'Callback', {@mlepSimulateFunction,myhandle,'saveAllResult'}, 'FontSize', mlep.fontSmall  );
                %uicontrol( 'Parent', mlep.simulateFeedback, 'Background', 'b' )
            % GRAPH
            mlep.simulateGraph = uiextras.Panel( 'Parent', mlep.simulateFeedback, 'Title', 'Plot', 'TitlePosition', 'LeftTop', 'FontSize', mlep.fontMedium, 'Padding', 10 );
                % TAB 
                mlep.simulateTab = uiextras.TabPanel( 'Parent', mlep.simulateGraph, 'Padding', 0, 'TabSize', 150, 'FontSize', mlep.fontMedium );
                    %% Tab 1
                    % PANEL TAB 1 GRAPH 
                    mlep.simulateGraphPanel = uiextras.Panel( 'Parent', mlep.simulateTab, 'BorderType', 'none' );
                        mlep.simulateGraphBox = uiextras.HBox( 'Parent', mlep.simulateGraphPanel, 'Padding', 0, 'Spacing', 0 );
                            mlep.graph = axes( 'Parent', mlep.simulateGraphBox, 'HandleVisibility', 'callback', 'ActivePositionProperty', 'OuterPosition');
                            %set(mlep.graph, 'HandleVisibility', 'callback');
                            mlep.simulateGraphBoxGrid = uiextras.VBox( 'Parent', mlep.simulateGraphBox, 'Spacing', 1 );
                            mlep.gridToggle = uicontrol( 'style', 'checkbox', 'String', {'Grid'}, 'Parent', mlep.simulateGraphBoxGrid, 'Callback', {@mlepSimulateFunction,myhandle,'grid'}, 'FontSize', mlep.fontMedium );
                        % SIZE GRAPH BOX
                        set( mlep.simulateGraphBox, 'Sizes', [-7 -1] );
                    %% Tab 
                    % PANEL TAB 2 DXF
                    mlep.simulateDxfPanel = uiextras.Panel( 'Parent', mlep.simulateTab, 'BorderType', 'none' );
                        % AXES
                        mlep.dxfAxes = axes( 'Parent', mlep.simulateDxfPanel, 'HandleVisibility', 'callback', 'ActivePositionProperty', 'OuterPosition');
                            
                % Set Default Tab and Names
                mlep.simulateTab.TabNames = {'1. Graph ', '2. Building '};
                mlep.simulateTab.SelectedChild = 1;        

    % SET SIZE
    %set( mlep.simulateBox, 'Sizes', [-6 100]);
    set( mlep.simulateFeedback, 'Sizes', [-1 -3] );
    set( mlep.simulateFeedbackBox1, 'Sizes', [-0.3 -3 -1] );
    set( mlep.simulateFeedbackBox2, 'Sizes', [-1 -1], 'Spacing', 10);

    % Store Data        
guidata(myhandle,mlep);      
end

