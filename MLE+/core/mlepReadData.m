function readpacket = mlepReadData(simsock, tWait)
%MLEPREADDATA Read data packet from the external program.
%   readpacket = mlepReadData(simsock, tWait)
%
%   Read readpacket from the external program via socket simsock.
%
%   simsock should be created by mlepCreate; it is the second returned
%       socket.
%   tWait is the waiting time (in ms); if timeout, readpacket is returned
%       as empty.  Use 0 for infinite waiting time.
%   readpacket is a string and should be parsed by mlepDecodePacket.  Note
%       that if the external program did not send any packet, readpacket
%       will be empty.  So be sure to check isempty(readpacket).
%
%   See also:
%       MLEPCREATE, MLEPENCODEDATA, MLEPENCODEREALDATA
%       MLEPENCODESTATUS, MLEPDECODEPACKET
%       MLEPEXCHANGEDATA, MLEPWRITEDATA
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% Last update: 2010-08-19 by Truong Nghiem

if nargin < 1
    error('Not enough input arguments.');
end
if ~isjava(simsock)
    error('Invalid socket.');
end

if nargin > 1 && tWait >= 0
    simsock.setSoTimeout(tWait);
end

% Read packet
readpacket = char(readLine(java.io.BufferedReader(java.io.InputStreamReader(simsock.getInputStream))));

end

