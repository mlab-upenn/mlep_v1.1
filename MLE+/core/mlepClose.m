function mlepClose(serversock, simsock, pid)
%MLEPCLOSE Close the co-simulation sockets.
%   This function closes the co-simulation sockets, created by mlepCreate,
%   if they are non-empty.  This function should be called at the end of
%   the co-simulation.
%
%   mlepClose(serversock, simsock, pid)
%
%   If pid (the process ID of E+) is provided, it will be destroyed.
%
%   See also: MLEPCREATE
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% Last update: 2011-04-28
% HISTORY:
%   2011-04-28  Destroy the (Java) process if provided.

ni = nargin;

if ni >= 1 && ~isempty(serversock) && isjava(serversock)
    serversock.close;
end

if ni >= 2 && ~isempty(simsock) && isjava(simsock)
    simsock.close;
end

if ni >= 3 && isa(pid, 'java.lang.Process')
    pid.destroy();
end
    
end

