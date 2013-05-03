function packet = mlepEncodeStatus(vernumber, flag)
%MLEPENCODESTATUS Encode status flag to a packet.
%   packet = mlepEncodeStatus(vernumber, flag)
%
%   Encode a status flag to a packet (a string) that can be sent to the
%   external program.  This function is a special version of
%   mlepEncodeData in which only a flag (non-zero) is transferred. 
%
%   Inputs:
%       vernumber: version of the protocol to be used. Currently, version 1
%                   and 2 are supported.
%       flag: an integer specifying the (status) flag. Refer to the BCVTB
%                   protocol for allowed flag values.
%
%   Output:
%       packet is a string that contains the encoded data.
%
%   See also:
%       MLEPDECODEPACKET, MLEPENCODEDATA, MLEPENCODEREALDATA
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

ni = nargin;
if ni < 2
    error('Not enough arguments: all input arguments are required.');
end

if vernumber <= 2
    packet = sprintf('%d %d', vernumber, flag);
else
    packet = '';
end

end

% Protocol Version 1 & 2:
% Packet has the form:
%       v f dr di db t r1 r2 ... i1 i2 ... b1 b2 ...
% where
%   v    - version number (1,2)
%   f    - flag (0: communicate, 1: finish, -10: initialization error,
%                -20: time integration error, -1: unknown error)
%   dr   - number of real values
%   di   - number of integer values
%   db   - number of boolean values
%   t    - current simulation time in seconds (format %20.15e)
%   r1 r2 ... are real values (format %20.15e)
%   i1 i2 ... are integer values (format %d)
%   b1 b2 ... are boolean values (format %d)
%
% Note that if f is non-zero, other values after it will not be processed.