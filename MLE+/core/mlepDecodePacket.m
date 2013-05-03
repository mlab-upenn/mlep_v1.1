function [flag, timevalue, realvalues, intvalues, boolvalues] = mlepDecodePacket(packet)
%MLEPDECODEPACKET Decode packet to data.
%   [flag, timevalue, realvalues, intvalues, boolvalues] =
%           mlepDecodePacket(packet)
%
%   Decode a packet (a string) to data.  The packet format follows the
%   BCVTB co-simulation communication protocol.
%
%   Inputs:
%       packet: the packet to be decoded (a string).
%
%   Outputs:
%       flag: an integer specifying the (status) flag. Refer to the BCVTB
%                   protocol for allowed flag values.
%       timevalue: a real value which is the current simulation time in
%                   seconds.
%       realvalues: a vector of received real value data.
%       intvalues: a vector of received integer value data.
%       boolvalues: a vector of received boolean value data.
%
%       Each of the received data vector can be empty if there is no data
%       of that type sent.
%
%   See also:
%       MLEPENCODEDATA, MLEPENCODEREALDATA, MLEPENCODESTATUS
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% HISTORY:
%   2010-11-23  Remove non-printable characters from packet before
%               processing it (maybe a bug of E+).

% Remove non-printable characters from packet, then
% convert packet string to a vector of numbers
[data, status] = str2num(packet(isstrprop(packet, 'print')));  % This function is very fast
if ~status
    error('Error while parsing the packet string: %s', packet);
end

% Check data
datalen = length(data);
if datalen < 2
    error('Invalid packet format: length is only %d.', datalen);
end

% data(1) is version number
if data(1) <= 2
    % Get the flag number
    flag = data(2);
    
    realvalues = [];
    intvalues = [];
    boolvalues = [];
    
    if flag == 0  % Read on
        if datalen < 5
            error('Invalid packet: lacks lengths of data.');
        end
        
        data(3:5) = fix(data(3:5));
        pos1 = data(3) + data(4);
        pos2 = pos1 + data(5);
        if 6 + pos2 > datalen
            error('Invalid packet: not enough data.');
        end
        
        % Now read data to vectors
        timevalue = data(6);
        realvalues = data(7:6+data(3));
        intvalues = data(7+data(3):6+pos1);
        boolvalues = logical(data(7+pos1:6+pos2));
    else
        % Non-zero flag --> don't need to read on
        timevalue = [];
    end
    
else
    error('Unsupported packet format version: %g.', data(1));
end

end

% Protocol Version 1 & 2:
% Packet has the form:
%       v f dr di db t r1 r2 ... i1 i2 ... b1 b2 ... \n
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
%   \n   - carriage return
%
% Note that if f is non-zero, other values after it will not be processed.