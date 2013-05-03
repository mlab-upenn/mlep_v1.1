function mlepWriteData(simsock, sendpacket)
%MLEPWRITEDATA Write data packet to the external program.
%   mlepWriteData(simsock, sendpacket)
%
%   Send sendpacket to the external program.
%   The communication is via a TCP/IP socket simsock.
%
%   simsock should be created by mlepCreate; it is the second returned
%       socket.
%   sendpacket is a string and should be encoded by one of mlepEncode*.
%
%   See also:
%       MLEPCREATE, MLEPENCODEDATA, MLEPENCODEREALDATA
%       MLEPENCODESTATUS, MLEPDECODEPACKET
%       MLEPEXCHANGEDATA, MLEPREADDATA
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% Last update: 2010-08-19 by Truong Nghiem

if nargin < 2
    error('Not enough input arguments.');
end
if ~isjava(simsock)
    error('Invalid socket.');
end

% Send packet
wr = java.io.BufferedWriter(java.io.OutputStreamWriter(simsock.getOutputStream));
wr.write(sprintf('%s\n', sendpacket));
wr.flush;

end

