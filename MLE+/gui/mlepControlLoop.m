function [eplus_in_curr,userdata] = control_loop(cmd,eplus_out_prev, eplus_in_prev, time, userdata) 
% ---------------INPUTS---------------
% eplus_in_prev - Data Structure% eplus_in_prev.u1 - Vector state for variable "u1"
% eplus_in_prev.u2 - Vector state for variable "u2"
% eplus_out_prev - Data Structure
% eplus_out_prev.y1 - Vector state for variable "y1"
% eplus_out_prev.y2 - Vector state for variable "y2"
% time - vector with timesteps% userdata  - user defined variable which can be changed and evolved
% ---------------OUTPUTS---------------
% eplus_in_curr - vector with the values of the input parameters.
% This should be a 1xn vector where n is number of eplus_in parameters
% ---------------WRITE YOUR CODE---------------
if strcmp(cmd,'init')
	% Initialization mode. This part sets the
	% input parameters for the first time step.
	 eplus_in_curr = [19 23]; 
elseif strcmp(cmd,'normal') 
	% ---------------WRITE YOUR CODE---------------
	% Normal mode. This part sets the input 
	% parameters for the subsequent time steps.
	 eplus_in_curr = [eplus_in_prev.u1(end) eplus_in_prev.u2(end)];
end
end
