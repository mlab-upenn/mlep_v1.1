close all;
f = figure();
layout = uiextras.TabPanel( 'Parent', f );
uicontrol('style','push', 'String', 'Presentation', 'Parent', layout );
uicontrol('style','push', 'String', 'Variables', 'Parent', layout );
uicontrol('style','push', 'String', 'Control', 'Parent', layout );