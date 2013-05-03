% FUNCTION model = model3d(filename)
%
% Description:
%
%  This function loads a model from either 
%  a DXF or a 3DS file.  The model can be
%  plotted and manipulated using the functions
%  associated with this class.  
%
%  I do not claim that this works with all '3ds' or
%  'dxf' files, but it has worked for all I have 
%  come across so far
%
%  It also works with my own file format 'm3d'.  These 
%  files can be created from 'model3d' classes via
%  the 'serialize' function
%
% Inputs:
%
%   filename :   a string containing the filename to load
%
% Outputs:
%
%   model    :   the abstract 'model' associated with
%                this class
%
% Author: Steven Michael (smichael@ll.mit.edu)
%
% Date:   5/19/2005
%