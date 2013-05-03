f = figure( 'Name', 'uiextras.HBoxFlex example' );
b = uiextras.HBoxFlex( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' )
uicontrol( 'Parent', b, 'Background', 'b' )
uicontrol( 'Parent', b, 'Background', 'g' )
uicontrol( 'Parent', b, 'Background', 'y' )
set( b, 'Sizes', [-1 100 -2 -1], 'Spacing', 5 );