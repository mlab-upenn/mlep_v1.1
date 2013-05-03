function [serversock, simsock, status, msg, pid] = ...
    mlepCreate(progname, arguments, workdir, timeout, port, host, bcvtbdir, configfile, env, execcmd)
%MLEPCREATE Create a new co-simulation instance.
%   This function creates a new co-simulation instance by starting a given
%   external simulation program in a separate process and establishing a
%   TCP/IP connection to it.  The simulation program must support the BCVTB
%   co-simulation protocol.
%
%   Call syntax:
%       [serversock, simsock, status, msg, pid] = ...
%           mlepCreate(progname, arguments, workdir, timeout, port,
%                       host, bcvtbdir, configfile)
%
%   Inputs:
%       progname: a nonempty string which is the name of the external
%                   program.
%       arguments: a string or a cell array of strings which are the
%                   arguments to the external program.
%       workdir: a string which is the working directory of the simulation
%                   program. If it is empty or is omitted, the current
%                   directory will be used. The system will change to this
%                   directory before executing the external program. The
%                   socket configuration file will also be written to this
%                   directory by default, so the current user should have
%                   write permission to this directory.
%       timeout: connection time-out, in milliseconds (10000 by default).
%       port:    port number of the server socket for listening to incoming
%                   connections; if 0 then any available port will be used;
%                   if a ServerSocket java object and it is not closed then
%                   that socket will be reused.
%       host:    a string which is the host address or name. If it is
%                   omitted or empty, the localhost will be used and the
%                   socket config file will contain the host name;
%                   otherwise, this host address/name will be used and be
%                   written to the socket config file.
%       bcvtbdir: the directory of BCVTB, which contains the bcvtb library
%                   that the client may need to use. By default, it is the
%                   current directory.
%       configfile: an optional string that specifies the socket config
%                   file.  By default, the config file is named
%                   "socket.cfg" and is placed in the working directory.
%                   If it is the number -1, the config file will not be
%                   written (e.g. it is already there).
%       env:        environment variables, a cell of cells, each contains
%                   two or three strings:
%                   + the first is the env variable name
%                   + the second is the value if that env name does not
%                     exist.
%                   + the third is the value that will overwrite the
%                     current value.
%                   If the variable does not exist, it will be created
%                   with the value of the second string.  If it exists and
%                   the third string is provided, it will be overwritten
%                   with this string; otherwise, it will keep its current
%                   value.
%       execcmd:    how to execute external processes (E+) from Matlab; one
%                   of the following text values:
%                   'system'  - Use the standard Matlab's system function
%                   'java'    - Use Java
%
%   Outputs:
%       serversock: server socket ID/object.
%       simsock:    the socket of the connection to the external program.
%                   This value must be saved to use in other functions.
%       status:     status returned by the external program: 0 if
%                   successful, !=0 if error.
%       msg:        string message returned by the external program.
%       pid:        process ID of the external program (not used now but
%                   may be needed later).
%
%   When the cosimulation finishes, the sockets should be closed (e.g. by
%   calling <a href="matlab:help mlepClose">mlepClose</a>).
%
%   This function will throw an error if an error happened (e.g. the
%   external program could not be started).  In this case, both sockets
%   should be empty.  However, if either of them is non-empty, it needs to
%   be closed.
%
%   See also:
%       <a href="https://gaia.lbl.gov/bcvtb">BCVTB (hyperlink)</a>
%       MLEPCLOSE
%
% (C) 2010-2011 by Truong Nghiem (nghiem@seas.upenn.edu)

% Last update: 2011-07-13 by Truong X. Nghiem
% HISTORY:
%   2011-07-13  Back to using system command for executing E+ by default
%               (because Windows seems not like the Java solution).
%               Added 'evn' parameter for environment variables.
%               Added 'execcmd' parameter to choose system/Java for
%               executing external processes.
%   2011-04-28  Used Java for executing E+ instead of system command.

ni = nargin;
if ni < 1
    error('Not enough input arguments: at least program name must be specified.');
end

% Process arguments
if ni < 2, arguments = {}; end
bWorkDir = (ni >= 3) && ~isempty(workdir);
if ni < 4 || isempty(timeout) || timeout <= 0, timeout = 10000; end
if ni < 5 || isempty(port), port = 0; end  % any port that is free
if ni < 8 || isempty(configfile)
    configfile = 'socket.cfg';
end

if ni < 9, env = {}; end

% Set BCVTB_HOME environment
if ni >= 7 && ~isempty(bcvtbdir)
    env = [env, {{'BCVTB_HOME', bcvtbdir, bcvtbdir}}];  % Always overwrite
else
    env = [env, {{'BCVTB_HOME', pwd}}];
end

% Exec command by default is 'system'
if ni < 10 || isempty(execcmd), execcmd = 'system'; end


% Save current directory and change directory if necessary
if bWorkDir
    oldCurDir = pwd;
    cd(workdir);
end
workdir = pwd;   % Get the correct directory


% If port is a ServerSocket java object then re-use it
if isa(port, 'java.net.ServerSocket')
    if port.isClosed
        port = 0;   % Create a new socket
    else
        serversock = port;
    end
end

% Create server socket if necessary
if isnumeric(port)
    % If any error happens, this function will be interrupted
    if ni >= 6 && ~isempty(host)
        serversock = java.net.ServerSocket(port, 0, host);
        hostname = host;
    else
        serversock = java.net.ServerSocket(port);
        
        % The following get local host address for incoming connections even
        % from outside, but it seems unstable, sometimes E+ cannot connect.
        % hostname = char(getHostName(java.net.InetAddress.getLocalHost));
        
        % The following get address that can only be used locally on this
        % machine, no connections from outside. It may be more stable.
        hostname = char(getHostName(javaMethod('getLocalHost', 'java.net.InetAddress')));
        %hostname = char(getHostAddress(serversock.getInetAddress));
    end
else
    hostname = char(getHostName(javaMethod('getLocalHost', 'java.net.InetAddress')));
    %hostname = char(getHostAddress(serversock.getInetAddress));
end

serversock.setSoTimeout(timeout);

% Write socket config file if necessary (configfile ~= -1)
if configfile ~= -1
    fid = fopen(configfile, 'w');
    if fid == -1
        % error
        serversock.close; serversock = [];
        error('Error while creating socket config file: %s', ferror(fid));
    end
    
    % Write socket config to file
    socket_config = [...
        '<?xml version="1.0" encoding="ISO-8859-1"?>\n' ...
        '<BCVTB-client>\n' ...
        '<ipc>\n' ...
        '<socket port="%d" hostname="%s"/>\n' ...
        '</ipc>\n' ...
        '</BCVTB-client>'];
    fprintf(fid, socket_config, serversock.getLocalPort, hostname);
    
    [femsg, ferr] = ferror(fid);
    if ferr ~= 0  % Error while writing config file
        serversock.close; serversock = [];
        fclose(fid);
        error('Error while writing socket config file: %s', femsg);
    end
    
    fclose(fid);
end

% Create the external process
try
    switch execcmd
        case 'java'
            [status, pid] = startProcessJRE(progname, arguments, env, workdir);
        otherwise
            [status, pid] = startProcess(progname, arguments, env, workdir);
    end
    
    if status ~= 0
        error('Error while starting external co-simulation program.');
    end
catch ErrObj
    serversock.close; % serversock = [];
    rethrow(ErrObj);
end

% Listen for the external program to connect
try
    simsock = serversock.accept;
catch ErrObj
    % Error, usually because the external program failed to connect
    serversock.close; % serversock = [];
    rethrow(ErrObj);
end

% Now that the connection is established, return the sockets

% Restore current directory
if bWorkDir
    cd(oldCurDir);
end

msg = '';

end

function [status, pid] = startProcess(cmd, args, env, workdir)
% This helper function starts a new process of a given program in the
% background and returns the status and process ID.
% cmd: the command that will be executed
% args: arguments, either a string or a cell of strings
% env: environment variables, a cell of cells, each contains two or three
%       strings:
%       + the first is the env variable name
%       + the second is the value if that env name does not exist.
%       + the third is the value that will overwrite the current value.
%      So, if the variable does not exist, then it will be created with
%      value being the second string.  If it exists and the third string is
%      provided, it will be overwritten with this string; otherwise, it
%      will keep its current value.
% workdir: working directory
%
% status: 0 if successful, != 0 if error (then status is error code)
% (obsolete) msg: string message returned by the program (e.g. its standard output)
% pid: process ID/object; this ID is often not used but may be useful
% later.

% Process input arguments
if nargin >= 2
    if ischar(args)
        numArgs = 1;
        args = {args};
    elseif iscellstr(args)
        numArgs = numel(args);
    else
        error('Arguments must be provided in a string or a cell array of strings.');
    end
else
    numArgs = 0;
end

for kk = 1:numel(args)
    cmd = [cmd ' ' args{kk}];
end

% Process and set env variables
if nargin >= 3
    assert(iscell(env), 'Environment variables must be provided as a cell array of cell arrays of strings.');
    
    for kk = 1:numel(env)
        setenv(env{kk}{1}, env{kk}{2});
    end
end

[status, result] = system([cmd ' &']);
pid = 0;

end


function [status, pid] = startProcessJRE(cmd, args, env, workdir)
% This helper function starts a new process of a given program in the
% background and returns the status and process ID.
% cmd: the command that will be executed
% args: arguments, either a string or a cell of strings
% env: environment variables, a cell of cells, each contains two or three
%       strings:
%       + the first is the env variable name
%       + the second is the value if that env name does not exist.
%       + the third is the value that will overwrite the current value.
%      So, if the variable does not exist, then it will be created with
%      value being the second string.  If it exists and the third string is
%      provided, it will be overwritten with this string; otherwise, it
%      will keep its current value.
% workdir: working directory
%
% status: 0 if successful, != 0 if error (then status is error code)
% (obsolete) msg: string message returned by the program (e.g. its standard output)
% pid: process ID/object; this ID is often not used but may be useful later.

if nargin < 1 || ~ischar(cmd)
    error('The command must be provided as a string.');
end

% Process input arguments
if nargin >= 2
    if ischar(args)
        numArgs = 1;
        args = {args};
    elseif iscellstr(args)
        numArgs = numel(args);
    else
        error('Arguments must be provided in a string or a cell array of strings.');
    end
else
    numArgs = 0;
end

% Construct command line as a Java array of strings
jCmds = javaArray('java.lang.String', 1 + numArgs);
jCmds(1) = java.lang.String(cmd);
for kk = 1:numArgs
    jCmds(kk+1) = java.lang.String(args{kk});
end
%% WILLY 
for kk = 1:numel(args)
    cmd = [cmd ' ' args{kk}];
end

% Create the ProcessBuilder
jPB = java.lang.ProcessBuilder(jCmds);

% Process and set env variables
if nargin >= 3
    assert(iscell(env), 'Environment variables must be provided as a cell array of cell arrays of strings.');
    
    for kk = 1:numel(env)
        setenv(env{kk}{1}, env{kk}{2});
    end
end

%% WILLY 
[status, result] = system([cmd ' &'],'-echo'); % ' &'
pid = 0;
status = 0;
%%
% % Create the ProcessBuilder
% jPB = java.lang.ProcessBuilder(jCmds);
% 
% % Process and set env variables
% if nargin >= 3
%     assert(iscell(env), 'Environment variables must be provided as a cell array of cell arrays of strings.');
%     
%     jEnvMap = jPB.environment();
%     
%     for kk = 1:numel(env)
%         if jEnvMap.containsKey(env{kk}{1}) && numel(env{kk}) == 3
%             jEnvMap.put(env{kk}{1}, env{kk}{3});
%         else
%             jEnvMap.put(env{kk}{1}, env{kk}{2});
%         end
%     end
% end
% 
% % Set working directory
% if nargin >= 4
%     assert(ischar(workdir), 'Working directory must be a string.');
%     
%     jPB.directory(java.io.File(workdir));
% end 

% Start the process (the object is the process ID)
% WILLY COMMENTED LINES
% pid = jPB.start();
% status = 0;   % If this line is reached, it should be successful
end