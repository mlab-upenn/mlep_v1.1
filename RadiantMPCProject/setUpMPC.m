function [userdata] = setUpMPC(userdata)

load ./MATfiles/ssModel.mat
plant = ssModel;
plant.Ts = 1;
plant.TimeUnit = 'minutes';

%% INPUTS 
% plant.InputName
%     'ZONE 1 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%     'ZONE 2 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%     'ZONE 3 RADIANT FLOOR Electric Low Temp Radiant Electric Power'
%     'WEST ZONE Zone Total Internal Total Heat Gain Rate'
%     'EAST ZONE Zone Total Internal Total Heat Gain Rate'
%     'NORTH ZONE Zone Total Internal Total Heat Gain Rate'
%     'WEST ZONE Zone Transmitted Solar'
%     'ZN001:FLR001 Surface Inside Face Temperature'
%     'Environment Outdoor Dry Bulb'

%% OUTPUTS
% plant.OutputName
%     'WEST ZONE Zone Mean Air Temperature'
%     'EAST ZONE Zone Mean Air Temperature'
%     'NORTH ZONE Zone Mean Air Temperature'

%% DEFINE PLANT 
plant=setmpcsignals(plant,'MV',[1 2 3],'MD',[4 5 6 7 8 9],'MO',[1,2,3]);

%% CREATE MPC OBJECT
Ts = 15;    % Sampling Time
P = 6;    % Prediction Horizon
M = 3;      % Control Horizon
mpcobj = mpc(plant,Ts,P,M);

%% INPUT CONSTRAINTS
mpcobj.MV(1).Min = 0;
mpcobj.MV(1).Max = 8000;
mpcobj.MV(2).Min = 0;
mpcobj.MV(2).Max = 8000;
mpcobj.MV(3).Min = 0;
mpcobj.MV(3).Max = 12000;

%% OUTPUT CONSTRAINTS
mpcobj.OV(1).Min = 22.35;
mpcobj.OV(1).Max = 24;
mpcobj.OV(2).Min = 22.35;
mpcobj.OV(2).Max = 24;
mpcobj.OV(3).Min = 22.45;
mpcobj.OV(3).Max = 24;

%% CHANGE WEIGHTS
mpcobj.Weights.ManipulatedVariables = 1*[.8 0.8 0.8];
mpcobj.Weights.ManipulatedVariablesRate = 0*ones(1,3);
mpcobj.Weights.OutputVariables = 0*ones(1,3);
mpcobj.Weights.ECR = 1e10;

%% GET INITIAL STATE
x = mpcstate(mpcobj);

%% Simulate the closed-loop response by calling mpcmove iteratively.
r = [16 16 16]; %reference signal. There is no measured disturbance.

%% SET USERDATA VARIABLE
userdata = struct();
userdata.mpcobj = mpcobj;
userdata.x = x; 
userdata.Ts = Ts;
userdata.r = r;
userdata.cost = [];
userdata.slack = [];
userdata.range = 8;
userdata.maxPow = [8000 8000 12000];
userdata.v = zeros(userdata.mpcobj.PredictionHorizon-1,6);
%% GET PREDICTED VALUES
load ./MATfiles/Prediction.mat
userdata.predictData = result;

