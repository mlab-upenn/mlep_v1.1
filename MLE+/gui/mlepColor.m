function [mlep] = mlepColor(mlep)

mlep.background = [0.85 0.85 0.85];
mlep.colorSelected = 'c';
mlep.colorWhite = 'white';
% 1
set(0,'defaultUicontrolBackgroundColor',mlep.background);
% % 2
set(0,'defaultUicontainerBackgroundColor',mlep.background);
% % 3
set(0,'defaultHgjavacomponentBackgroundColor',mlep.background);
% % 4
set(0,'defaultUipanelBackgroundColor',mlep.background);
%javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel');
%javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');

%% DEFAULT COLOR
% 1 factoryUicontrolBackgroundColor: [0.9412 0.9412 0.9412]
% 2 factoryUicontainerBackgroundColor: [0.9412 0.9412 0.9412]
% 3 factoryHgjavacomponentBackgroundColor: [0.9412 0.9412 0.9412]
% 4 factoryUipanelBackgroundColor: [0.9412 0.9412 0.9412]
% 5 factoryUipanelForegroundColor: [0 0 0]
% 6 factoryUipanelHighlightColor: [1 1 1]
% 7 factoryUipanelShadowColor: [0.5000 0.5000 0.5000]
% 8 factoryUiflowcontainerBackgroundColor: [0.9412 0.9412 0.9412]
% 9 factoryUigridcontainerBackgroundColor: [0.9412 0.9412 0.9412]
% 10 factoryUitableForegroundColor: [0 0 0]
% 11  factoryUitableBackgroundColor 1.0000    1.0000    1.0000
%                                   0.9608    0.9608    0.9608
% 12 factoryUimenuForegroundColor

end