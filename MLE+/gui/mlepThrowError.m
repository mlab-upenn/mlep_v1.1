function [mlep] = mlepThrowError(mlep)

if strcmp(mlep.data.mlepError, 'fileNotFound')
    errordlg('File not found','File Error');
elseif strcmp(mlep.data.mlepError, 'emptyArray')
    errordlg('Empty Array','Array Error');
elseif strcmp(mlep.data.mlepError, 'noSelection')
    errordlg('No Selection','Selection Error');
elseif strcmp(mlep.data.mlepError, 'noOutputFileFound')
    errordlg('No Output File Found (.csv)', 'File Error');
elseif strcmp(mlep.data.mlepError, 'emptyWorspace')
    errordlg('No Available Variables In Workspace', 'Empty Workspace');
elseif strcmp(mlep.data.mlepError, 'userDataMissing')
    errordlg('No User Data Selected', 'Variable Error');
elseif strcmp(mlep.data.mlepError, 'idfMissing')
    errordlg('No EnergyPlus File Selected (.idf)', 'File Error');
elseif strcmp(mlep.data.mlepError, 'weatherMissing')
    errordlg('No Weather File Selected (.epw)', 'File Error');
elseif strcmp(mlep.data.mlepError, 'notNumber')
    errordlg('Need to Specify a Number', 'Input Error');
elseif strcmp(mlep.data.mlepError, 'notAllInputsSpecified')
    errordlg('Not All Inputs Specified in Control File. Simulation Stopped!', 'Control File Error');
end

return;
end
