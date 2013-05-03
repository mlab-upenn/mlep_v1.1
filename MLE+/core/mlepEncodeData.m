function packet = mlepEncodeData(vernumber, flag, timevalue, realvalues, intvalues, boolvalues)
%MLEPENCODEDATA Encode data to packet.
%   packet = mlepEncodeData(vernumber, flag, timevalue, realvalues,
%                            intvalues, boolvalues)
%
%   Encode data to a packet (a string) that can be sent to the external
%   program.  The packet format follows the BCVTB co-simulation
%   communication protocol.
%
%   Inputs:
%       vernumber: version of the protocol to be used. Currently, version 1
%                   and 2 are supported.
%       flag: an integer specifying the (status) flag. Refer to the BCVTB
%                   protocol for allowed flag values.
%       timevalue: a real value which is the current simulation time in
%                   seconds.
%       realvalues: a vector of real value data to be sent. Can be empty.
%       intvalues: a vector of integer value data to be sent. Can be empty.
%       boolvalues: a vector of boolean value data to be sent. Can be
%                   empty.
%
%   Output:
%       packet is a string that contains the encoded data.
%
%   See also:
%       MLEPDECODEPACKET, MLEPENCODEREALDATA, MLEPENCODESTATUS
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

ni = nargin;
if ni < 2
    error('Not enough arguments: at least vernumber and flag must be specified.');
end

if vernumber <= 2
    if flag == 0
        if ni < 3
            error('Not enough arguments: time must be specified.');
        end
        
        if ni < 4, realvalues = []; end
        
        if ni < 5, intvalues = []; end

        if ni < 6
            boolvalues = [];
        else
            boolvalues = logical(boolvalues(:)');   % Convert to boolean values
        end

        % NOTE: although we can use num2str to print vectors to string, its
        % performance is worse than that of sprintf, which would cause this
        % function approx. 3 times slower.
        packet = [sprintf('%d 0 %d %d %d %20.15e ', vernumber,...
                            length(realvalues), ...
                            length(intvalues), ...
                            length(boolvalues), timevalue),...
                  sprintf('%20.15e ', realvalues),...
                  sprintf('%d ', intvalues),...
                  sprintf('%d ', boolvalues)];
    else
        % Error
        packet = sprintf('%d %d', vernumber, flag);
    end
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