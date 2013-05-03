Overview:

The following MATLAB class provides the ability to load 3D studio MAX (.3ds)
and AutoCad (DXF) files into MATLAB.  Routines exist for plotting the
resulting class using OpenGL and for very simple data manipulation (rotation,
translation, superposition of models, etc...)


Usage:

The model can be loaded using the 'model3d' command.  Allowed manipulations of
the model are described in the accompanying '.m' files.  

Example:

%Load a 3ds model 'sample.3ds' and plot it,
m = model3d('sample.3ds')

m =

        model3d object: 1-by-1

>> plot(m3)
% Create a new model shifted by [10 10 10] in X,Y,Z
>> m2 = m+[10 10 10];

% Superimpose the shifted model on the original
% and output it in m3
>> m3 = m+m2;
% Magnify the model by 3
>> m3 = magnify(m3,3);

Author: Steven Michael (smichael@ll.mit.edu)
Date:   5/19/2005
    