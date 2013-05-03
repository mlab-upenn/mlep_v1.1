classdef mlepProcess < handle
    %mlepProcess A class of a cosimulation process
    %   This class represents a co-simulation process. It enables data
    %   exchanges between the host (in Matlab) and the client (the
    %   cosimulation process), using the communication protocol defined in
    %   BCVTB.
    %
    %   This class wraps the mlep* functions.
    %
    %   See also:
    %       <a href="https://gaia.lbl.gov/bcvtb">BCVTB (hyperlink)</a>
    %
    % (C) 2010-2011 by Truong Nghiem (nghiem@seas.upenn.edu)

    % Last update: 2011-07-13 by Truong X. Nghiem
    
    % HISTORY:
    %   2011-07-13  Added global settings and execution command selection.
    %   2011-04-28  Changed to use Java process for running E+.
    %   2010-11-23  Changed to protocol version 2.
    
    properties
        version;        % Current version of the protocol
        program;
        env;
        arguments = {}; % Arguments to the client program
        workDir = '';   % Working directory (default is current directory)
        port = 0;       % Socket port (default 0 = any free port)
        host = '';      % Host name (default '' = localhost)
        bcvtbDir;       % Directory to BCVTB (default '' means that if
                        % no environment variable exist, set it to current
                        % directory)
        configFile = 'socket.cfg';  % Name of socket configuration file
        configFileWriteOnce = false;  % if true, only write the socket config file
                                      % for the first time and when server
                                      % socket changes.
        acceptTimeout = 20000;  % Timeout for waiting for the client to connect
        execcmd;        % How to execute EnergyPlus from Matlab (system/Java)
    end
    
    properties (SetAccess=private, GetAccess=public)
        rwTimeout = 0;      % Timeout for sending/receiving data (0 = infinite)
        isRunning = false;  % Is co-simulation running?
        serverSocket = [];  % Server socket to listen to client
        commSocket = [];    % Socket for sending/receiving data
        writer;             % Buffered writer stream
        reader;             % Buffered reader stream
        pid = [];           % Process ID for E+
    end
    
    properties (Constant)
        CRChar = sprintf('\n');
    end
    
    methods
        function obj = mlepProcess
            defaultSettings(obj);
        end
        
        function [status, msg] = start(obj)
            % status and msg are returned from the client process
            % status = 0 --> success
            if obj.isRunning, return; end
            
            % Check parameters
            if isempty(obj.program)
                error('Program name must be specified.');
            end
            
            % Call mlepCreate
            try
                if ~isempty(obj.serverSocket)
                    theport = obj.serverSocket;
                    if obj.configFileWriteOnce
                        theConfigFile = -1;  % Do not write socket config file
                    else
                        theConfigFile = obj.configFile;
                    end
                else
                    theport = obj.port;
                    theConfigFile = obj.configFile;
                end
                
                [obj.serverSocket, obj.commSocket, status, msg, obj.pid] = ...
                    mlepCreate(obj.program, obj.arguments, obj.workDir,...
                    obj.acceptTimeout, theport, obj.host,...
                    obj.bcvtbDir, theConfigFile, obj.env, obj.execcmd);
            catch ErrObj
                obj.closeCommSockets;
                rethrow(ErrObj);
            end
            
            if status == 0 && isjava(obj.commSocket)
                % Create writer and reader
                obj.createStreams;
                obj.isRunning = true;
            end
        end
        
        function stop(obj, stopSignal)
            if ~obj.isRunning, return; end
            
            % Send stop signal
            if nargin < 2 || stopSignal
                obj.write(mlepEncodeStatus(obj.version, 1));
            end
            
            % Close connection
            obj.closeCommSockets;
            
            % Destroy process E+
            if isa(obj.pid, 'java.lang.Process')
                obj.pid.destroy();
            end
            
            obj.isRunning = false;
        end
        
        function packet = read(obj)
            if obj.isRunning
                packet = char(obj.reader.readLine);
            else
                error('Co-simulation is not running.');
            end
        end
        
        function write(obj, packet)
            if obj.isRunning
                obj.writer.write([packet mlepProcess.CRChar]);
                obj.writer.flush;
            else
                error('Co-simulation is not running.');
            end
        end
        
        function [status, TOut, ROut, IOut, BOut] = feedInputs(obj,...
                                    TInputs, RInputs, IInputs, BInputs)
            % Runs simulation with sequences of inputs, and returns outputs
            % The process will be started if it is not running, and it will
            % not be stopped when this function returns.
            % status: 0 if successful, 1 if the client terminates before
            %       all inputs are fed, -1 if other errors.
            % TInputs and TOut are vectors of input & output time instants.
            % All input and output sequences are matrices where each row
            % contains input/output data for one time instant, each column
            % corresponds to an input/output signal. R*, I*, B* are for
            % real, integer, boolean signals respectively.
            %
            % This function does not check for validity of arguments, so
            % take appropriate caution.
            
            if nargin < 5
                error('Not enough parameters.');
            end
            
            ROut = [];
            IOut = [];
            BOut = [];
            status = 0;

            nRuns = length(TInputs);
            if nRuns < 1
                disp('nRuns is zero.');
                status = -1; 
                return; 
            end
            
            TOut = nan(nRuns, 1);
            
            if ~obj.isRunning
                obj.start;
                if ~obj.isRunning
                    disp('Cannot start the simulation process.');
                    status = -1;
                    return;
                end
            end
            
            if isempty(RInputs), RInputs = zeros(nRuns, 0); end
            if isempty(IInputs), IInputs = zeros(nRuns, 0); end
            if isempty(BInputs), BInputs = zeros(nRuns, 0); end
            
            % Run the first time to obtain the size of outputs
            obj.write(mlepEncodeData(obj.version, 0, TInputs(1),...
                RInputs(1,:), IInputs(1,:), BInputs(1,:)));
            
            readpacket = obj.read;
    
            if isempty(readpacket)
                disp('Cannot read first input packets.');
                status = -1;
                return;
            else
                [flag, timevalue, rvalues, ivalues, bvalues] = mlepDecodePacket(readpacket);
                switch flag
                    case 0
                        TOut(1) = timevalue;
                        
                        ROut = nan(nRuns, length(rvalues)); ROut(1,:) = rvalues;
                        IOut = nan(nRuns, length(ivalues)); IOut(1,:) = ivalues;
                        BOut = nan(nRuns, length(bvalues)); BOut(1,:) = bvalues;
                    case 1
                        obj.stop(false);
                        status = 1;
                        return;
                    otherwise
                        fprintf('Error from E+ with flag %d.\n', flag);
                        obj.stop(false);
                        status = -1;
                        return;
                end
            end
                
            for kRun = 2:nRuns
                fprintf('Run %d at time %g with U = %g.\n', kRun, TInputs(kRun), RInputs(kRun,:));
                obj.write(mlepEncodeData(obj.version, 0, TInputs(kRun),...
                    RInputs(kRun,:), IInputs(kRun,:), BInputs(kRun,:)));
                
                % Try to read a number of times (there is some problem with
                % TCP connection).
                nTrials = 0;
                while nTrials < 10
                    readpacket = obj.read;
                    if isempty(readpacket)
                        nTrials = nTrials + 1;
                    else
                        break;
                    end
                end
                
                if isempty(readpacket)
                    disp('Cannot read input packets.');
                    status = -1;
                    break;
                else
                    [flag, timevalue, rvalues, ivalues, bvalues] = mlepDecodePacket(readpacket);
                    switch flag
                        case 0
                            TOut(kRun) = timevalue;
                            ROut(kRun,:) = rvalues;
                            IOut(kRun,:) = ivalues;
                            BOut(kRun,:) = bvalues;
                        case 1
                            obj.stop(false);
                            status = 1;
                            break;
                        otherwise
                            fprintf('Error from E+ with flag %d.\n', flag);
                            obj.stop(false);
                            status = -1;
                            break;
                    end
                end
            end
        end
        
        function setRWTimeout(obj, value)
            if value < 0, value = 0; end
            obj.rwTimeout = value;
            if isjava(obj.commSocket)
                obj.commSocket.setSoTimeout(value);
                obj.createStreams;  % Recreate reader and writer streams
            end
        end
        
        function delete(obj)
            if obj.isRunning
                obj.stop;
            end
            
            % Close server socket
            if isjava(obj.serverSocket)
                obj.serverSocket.close;
                obj.serverSocket = [];
            end
        end
        
    end
    
    methods (Access=private)
        function closeCommSockets(obj)
            if isjava(obj.commSocket)
                obj.commSocket.close;
                obj.commSocket = [];
            end
            obj.reader = [];
            obj.writer = [];
            % if isjava(obj.serverSocket)
            %     obj.serverSocket.close;
            %     obj.serverSocket = [];
            % end
        end
        
        function createStreams(obj)
            obj.writer = java.io.BufferedWriter(java.io.OutputStreamWriter(obj.commSocket.getOutputStream));
            obj.reader = java.io.BufferedReader(java.io.InputStreamReader(obj.commSocket.getInputStream));
        end
        
        function defaultSettings(obj)
            % Obtain default settings from the global variable MLEPSETTINGS
            % If that variable does not exist, assign default values to
            % settings.
            global MLEPSETTINGS
            
            noSettings = isempty(MLEPSETTINGS) || ~isstruct(MLEPSETTINGS);
            if noSettings
                % Try to run mlepInit
                if exist('mlepInit', 'file') == 2
                    mlepInit;
                    noSettings = isempty(MLEPSETTINGS) || ~isstruct(MLEPSETTINGS);
                end
            end
            
            if noSettings || ~isfield(MLEPSETTINGS, 'version')
                obj.version = 2;    % Current version of the protocol
            else
                obj.version = MLEPSETTINGS.version;
            end
            
            if noSettings || ~isfield(MLEPSETTINGS, 'program')
                obj.program = '';
            else
                obj.program = MLEPSETTINGS.program;
            end
            
            if noSettings || ~isfield(MLEPSETTINGS, 'bcvtbDir')
                obj.bcvtbDir = '';
            else
                obj.bcvtbDir = MLEPSETTINGS.bcvtbDir;
            end
            
            if noSettings || ~isfield(MLEPSETTINGS, 'env')
                obj.env = {};
            else
                obj.env = MLEPSETTINGS.env;
            end
            
            if noSettings || ~isfield(MLEPSETTINGS, 'execcmd')
                obj.execcmd = '';
            else
                obj.execcmd = MLEPSETTINGS.execcmd;
            end 
        end
    end
end

