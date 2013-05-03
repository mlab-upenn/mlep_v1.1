function mlepSimulinkBlk(block)
%MLEPSIMULINKBLK M-S-Function for E+ Cosimulation block for Simulink.
%   This Matlab S-Function implements the Simulink block for EnergyPlus
%   Cosimulation.  It is part of the MLE+ toolbox.  Open the MLE+ Simulink
%   library mlepBlockset.mdl to use this block.
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% Last update: 2010-11-23 by Truong Nghiem

% HISTORY:
%   2010-11-23 Started, support BCVTB protocol version 2.

% The setup method is used to setup the basic attributes of the
% S-function such as ports, parameters, etc. Do not add any other
% calls to the main body of the function.
setup(block);

%endfunction

% Function: setup ===================================================
% Abstract:
%   Set up the S-function block's basic characteristics such as:
%   - Input ports
%   - Output ports
%   - Dialog parameters
%   - Options
%
%   Required         : Yes
%   C-Mex counterpart: mdlInitializeSizes
%
function setup(block)

% Register number of ports
block.NumInputPorts  = 1;  % real, int, and boolean signals
block.NumOutputPorts = 3;  % flag, time, real, int, and boolean outputs

% Register parameters
% The dialog parameters
% progname, modelfile, weatherfile, workdir, timeout,
% port, host, bcvtbdir, deltaT, noutputd
block.NumDialogPrms  = 10;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions  = -1;  % inherited size
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

% block.InputPort(2).Dimensions  = -1;  % inherited size
% block.InputPort(2).DatatypeID  = -1;  % inherited type
% block.InputPort(2).Complexity  = 'Real';
% block.InputPort(2).DirectFeedthrough = false;
% 
% block.InputPort(3).Dimensions        = -1;  % inherited size
% block.InputPort(3).DatatypeID  = -1;  % inherited type
% block.InputPort(3).Complexity  = 'Real';
% block.InputPort(3).DirectFeedthrough = false;


% Override output port properties
block.OutputPort(1).Dimensions  = 1;  % flag
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'sample';

block.OutputPort(2).Dimensions  = 1;  % time
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'sample';

nDim = block.DialogPrm(10).Data;  % real outputs
if nDim < 1, nDim = 1; end
block.OutputPort(3).Dimensions  = nDim;
block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'sample';

% nDim = block.DialogPrm(11).Data;  % real outputs
% if nDim < 1, nDim = 1; end
% block.OutputPort(4).Dimensions  = nDim;  % int outputs
% block.OutputPort(4).DatatypeID  = 0; % double
% block.OutputPort(4).Complexity  = 'Real';
% block.OutputPort(4).SamplingMode = 'sample';
% 
% nDim = block.DialogPrm(12).Data;  % real outputs
% if nDim < 1, nDim = 1; end
% block.OutputPort(5).Dimensions  = nDim;  % bool outputs
% block.OutputPort(5).DatatypeID  = 0; % double
% block.OutputPort(5).Complexity  = 'Real';
% block.OutputPort(5).SamplingMode = 'sample';

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [block.DialogPrm(9).Data 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The M-file S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

% block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
% block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required
block.RegBlockMethod('SetInputPortDimensions', @SetInputPortDimensions);
block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
% function DoPostPropSetup(block)
% block.NumDworks = 1;
%   
% block.Dwork(1).Name            = 'x1';
% block.Dwork(1).Dimensions      = 1;
% block.Dwork(1).DatatypeID      = 0;      % double
% block.Dwork(1).Complexity      = 'Real'; % real
% block.Dwork(1).UsedAsDiscState = true;

%% Set sampling mode for input ports
function SetInputPortSamplingMode(block, port, mode)
block.InputPort(port).SamplingMode = mode;

% endfunction

%% Set dimension for input ports
function SetInputPortDimensions(block, port, dimsInfo)
block.InputPort(port).Dimensions = dimsInfo;

% endfunction


%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
% function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)

% block.Dwork(1).Data = 0;

% Dialog parameters
% progname, modelfile, weatherfile, workdir, timeout,
% port, host, bcvtbdir, deltaT, noutputd,
% noutputi, noutputb

% Create the mlepProcess object and start EnergyPlus
processobj = mlepProcess;
processobj.program = block.DialogPrm(1).Data;
processobj.workDir = block.DialogPrm(4).Data;
processobj.bcvtbDir = block.DialogPrm(8).Data;
processobj.arguments = [block.DialogPrm(2).Data ' ' block.DialogPrm(3).Data];
processobj.acceptTimeout = block.DialogPrm(5).Data;
processobj.port = block.DialogPrm(6).Data;
processobj.host= block.DialogPrm(7).Data;

% Start processobj
[status, msg] = processobj.start;
if status ~= 0
    error('Cannot start EnergyPlus: %s.', msg);
end

% Save processobj to UserData of the block
set_param(block.BlockHandle, 'UserData', processobj);

%endfunction

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

% Get processobj
processobj = get_param(block.BlockHandle, 'UserData');
if ~isa(processobj, 'mlepProcess')
    error('Internal error: Cosimulation process object is lost.');
end


if processobj.isRunning
    
    VERNUMBER = 2;
    
    % Read from E+
    readpacket = processobj.read;
    
    if isempty(readpacket)
        error('Cannot read from EnergyPlus.');
    end
    
    % Currently, ivalues and bvalues are not used
    [flag, timevalue, irvalues] = mlepDecodePacket(readpacket);
    
    % Send signals to E+
    rvalues = block.InputPort(1).Data;
%     ivalues = block.InputPort(2).Data;
%     bvalues = block.InputPort(3).Data;
    
    processobj.write(mlepEncodeRealData(VERNUMBER, 0, block.CurrentTime, rvalues));
    
    if flag ~= 0
        processobj.stop(false);
        block.OutputPort(1).Data = flag;
    else
        if isempty(irvalues), irvalues = 0; end
%         if isempty(ivalues), ivalues = 0; end
%         if isempty(bvalues), bvalues = 0; end

        % Set outputs of block
        block.OutputPort(1).Data = flag;
        block.OutputPort(2).Data = timevalue;
        block.OutputPort(3).Data = irvalues(:);
%         block.OutputPort(4).Data = ivalues(:);
%         block.OutputPort(5).Data = bvalues(:);
    end
end

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
% function Update(block)
% 
% block.Dwork(1).Data = block.InputPort(1).Data;

%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%
% function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

% Get processobj
processobj = get_param(block.BlockHandle, 'UserData');
if ~isa(processobj, 'mlepProcess')
    error('Internal error: Cosimulation process object is lost.');
end

if processobj.isRunning
    processobj.stop(true);
end

%end Terminate