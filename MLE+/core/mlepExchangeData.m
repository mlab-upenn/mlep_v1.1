function readpacket = mlepExchangeData(simsock, sendpacket)
%MLEPEXCHANGEDATA Exchange data packet with the external program.
%   readpacket = mlepExchangeData(simsock, sendpacket)
%
%   Send sendpacket to the external program and read readpacket from it.
%   The communication is via a TCP/IP socket simsock.
%
%   simsock should be created by mlepCreate; it is the second returned
%       socket.
%   sendpacket is a string and should be encoded by one of mlepEncode*.
%   readpacket is a string and should be parsed by mlepDecodePacket.  Note
%       that if the external program did not send any packet, readpacket
%       will be empty.  So be sure to check isempty(readpacket).
%
%   See also:
%       MLEPCREATE, MLEPENCODEDATA, MLEPENCODEREALDATA
%       MLEPENCODESTATUS, MLEPDECODEPACKET
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

% Read packet
readpacket = char(readLine(java.io.BufferedReader(java.io.InputStreamReader(simsock.getInputStream))));

end

