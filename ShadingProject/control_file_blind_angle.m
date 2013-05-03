function [eplus_in_curr, userdata] = control_file_blind(cmd,eplus_out_prev, eplus_in_prev, time, stepNumber, userdata)
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
    eplus_in_curr.ShadeStatus = 0;
    eplus_in_curr.ShadeAngle = 90;
elseif strcmp(cmd,'normal')
    % ---------------WRITE YOUR CODE---------------
    % Outputs
    Solar_Beam_Incident_Cos = eplus_out_prev.CosAngle(end);
    Zone_Sensible_Cool_Rate = eplus_out_prev.WestCoolRate(end);
    Zone_West_Temperature = eplus_out_prev.WestTemp(end);
    Zone_West_Solar = eplus_out_prev.ExtSolar(end);
    
    % CALCULATIONS
    IncidentAngleRad = acos(Solar_Beam_Incident_Cos);
    IncidentAngle = (IncidentAngleRad)*180/pi;

    if Zone_West_Solar > 100 % 100 W/m^2
        % DEPLOYED WHEN SOLAR RADIATION EXCEEDS THRESHOLD
        ShadeStatus = userdata.Shade_Status_Exterior_Blind_On;
        ShadeAngle = IncidentAngle;
    else
        % SHADES NOT DEPLOYED
        ShadeStatus = userdata.Shade_Status_Off;
        ShadeAngle = IncidentAngle;
    end
    
    % FEEDBACK
    eplus_in_curr.ShadeStatus = ShadeStatus; 
    eplus_in_curr.ShadeAngle = ShadeAngle; 
end
end
