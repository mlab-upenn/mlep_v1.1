function [out] = mlepCreateControlFile(mlep)

fid = fopen([mlep.data.projectPath mlep.data.controlFileName],'wt');

if isfield(mlep.data,'inputFieldNames')
    sizeInput = length(mlep.data.inputFieldNames);
else
    sizeInput = 0;
end
if isfield(mlep.data,'outputFieldNames')
    sizeOutput = length(mlep.data.outputFieldNames);
else
    sizeOutput = 0;
end
header = ['function [eplus_in_curr,userdata] = controlFile(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata) \n',...
    '%% ---------------FUNCTION INPUTS---------------\n'];

explaInput = ['\n%% INPUTS TO ENERGYPLUS\n',...
    '%% eplus_in_prev - Data Structure with all previous inputs\n'];
inputComment = [];
for i = 1:sizeInput
   inputComment = [inputComment '%% \teplus_in_curr.' char(mlep.data.inputFieldNames(i)) ' = ; \n']; 
end

explaInput = [explaInput inputComment];

explaInput1 = ['\n%% OUTPUTS FROM ENERGYPLUS \n',...
    '%% eplus_out_prev - Data Structure with all previous outpus\n'];

outputComment = [];
for i = 1:sizeOutput
   outputComment = [outputComment '%% \teplus_out_curr.' char(mlep.data.outputFieldNames(i)) ' = ; \n']; 
end

explaInput1 = [explaInput1 outputComment];
    
explaInput2 = ['\n%% OTHER INPUTS\n',...
    '%% cmd  - MLE+ Command to distinguish init or normal step\n',... 
    '%% userdata  - user defined variable which can be changed and evolved\n',...
    '%% time - vector with timesteps\n',...
    '%% stepNumber - Number of Time Step in the simulation (Starts at 1)\n'];

explaInput = [explaInput explaInput1 explaInput2];

explaOutput = ['\n%% ---------------FUNCTION OUTPUTS---------------\n',...
    '%% eplus_in_curr - vector with the values of the input parameters.\n',...
    '%% This should be a 1xn vector where n is number of eplus_in parameters\n',...
    '%% userdata - user defined variable which can be changed and evolved\n\n'];

init = ['if strcmp(cmd,''init'')\n',...
    '\t%% ---------------WRITE YOUR CODE---------------\n',...
    '\t%% Initialization mode. This part sets the\n',...
    '\t%% input parameters for the first time step.\n'];

input = [];
for i = 1:sizeInput
   input = [input '\t eplus_in_curr.' char(mlep.data.inputFieldNames(i)) ' = ; \n']; 
end

normal = ['elseif strcmp(cmd,''normal'') \n',...
    '\t%% ---------------WRITE YOUR CODE---------------\n',...
    '\t%% Normal mode. This part sets the input \n',...
    '\t%% parameters for the subsequent time steps.\n'];

ending = ['end\n',...
    'end\n'];

text = [header explaInput explaOutput init input normal input ending];
fprintf(fid, text);
fclose(fid);
disp([mlep.data.controlFileName ' created'])
out = 1;
end








