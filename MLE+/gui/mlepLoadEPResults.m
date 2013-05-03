function [vars, data, ts] = mlepLoadEPResults(theFile, cols)
%MLEPLOADEPRESULTS Load EnergyPlus CSV result data into Matlab.
%   [VARS, DATA, TS] = MLEPLOADEPRESULTS(FILENAME) loads all EnergyPlus
%   simulation result data from CVS file FILENAME to DATA structure.  The
%   output data in FILENAME needs to be requested in the IDF file (by using
%   Output:Variable commands).  After a simulation run, they will be
%   written to a file with the same name as the IDF file but with extension
%   CSV.  FILENAME is the path to that CSV file.  The first column in this
%   file contains date + time data (time step of the simulation).  The
%   other columns contain result data, each for one requested variable.
%   The output arguments are:
%       VARS contains information about the variables, which is an 1-by-M
%       structure array, where M is the number of variables, of fields:
%           .object is the object name, e.g. 'ZONE EAST'
%           .name is the name of the variable, e.g. 'Zone Mean Air
%           Temperature'
%           .unit is the unit of the variable, e.g. 'Celsius'
%           .sampling is the sampling time of the variable, e.g. 'TimeStep'
%           or 'Hourly'
%       DATA contains the result data, which is an N-by-M matrix where N
%       is the number of time steps and column i contains result data for
%       variable VARS(i).  If a value is not available (e.g. an hourly
%       reported variable does not have values at every time step) then the
%       corresponding entry is NaN.
%       TS contains time step information, which is an N-by-5 matrix
%       where each row is of the form [month day hour minute second].
%
%   ... = MLEPLOADEPRESULTS(FID) is the same but uses a file id FID
%   instead of a file name, e.g. opened by FOPEN.
%
%   ... = MLEPLOADEPRESULTS(..., 'all') is the same as above.
%
%   VARS = MLEPLOADEPRESULTS(..., 'vars') reads only the variable
%   information (see above).
%
%   ... = MLEPLOADEPRESULTS(..., COLS) reads only the columns whose indices
%   are specified in the vector COLS.  The indices are numbered from 1.
%   The output order (in VARS, DATA) is the same as specified by COLS.
%
%   This function will throw errors/exceptions if there is any error.
%
% (C) 2012 by Truong X. Nghiem (nghiem@seas.upenn.edu)

% HISTORY:
%   2012-05-23  Truong added options to selectively load columns; improved
%               performance of extracting time info.


% Check arguments
error(nargchk(1,2,nargin));

assert(~isempty(theFile), 'First argument must be either a file name or a file ID.');

% Open the file
fileNeedClose = false;
if ischar(theFile)
    assert(exist(theFile, 'file') == 2, 'File %s does not exist.', theFile);
    
    [theFile, errmsg] = fopen(theFile, 'r+'); % rt
    if theFile < 0
        error('Could not open given file with error message: %s', errmsg);
    end
    
    fileNeedClose = true;   % We will close the file at the end
else
    assert(isnumeric(theFile) && isscalar(theFile) && theFile >= 0,...
        'Invalid file ID.');
end


% Check cols command/column indices
if nargin > 1
    if ischar(cols)
        cols = lower(cols);
        isError = ~ismember(cols, {'all', 'vars'});
    elseif isnumeric(cols)
        cols = cols(:)';
        isError = false;
    else
        isError = true;
    end
    
    if isError
        error('Second argument must be "all", "vars", or a vector of column indices.');
    end
else
    cols = 'all';
end

readData = nargout >= 2;
readTime = nargout >= 3;

if ischar(cols) && strcmp('vars', cols) && nargout > 1
    error('Undefined output arguments while reading only variable information.');
end


%%%%% MAIN PART: read and process result data

% Read the column headers, containing variable names
header = fgetl(theFile);
if isempty(header)
    finish;
    error('No result data to read.');
end

% Process it
% The first part is Date/Time, then the list of variables
variables = textscan(header, '%s', 'Delimiter', ',');
variables = variables{1}(2:end);  % Convert to cell array of var names

NVars = length(variables);

% Extract variable information
vars = cellfun(@extractVarInfo, variables);

% Exit if we do not need to read data
if (ischar(cols) && strcmp('vars', cols)) || nargout < 2
    finish;
    return;
end

if isnumeric(cols)
    assert(all(1 <= cols & cols <= NVars),...
        'Indices in cols are out of range.');
end

if readData, data = []; end
if readTime, ts = []; end


% Now, each row contains the date + time in the first column, then the
% values for the variables.
% We construct the format string for textscan by %s followed by NVars of %f
scanData = textscan(theFile,...
    ['%s' repmat('%f', 1, NVars)],...
    'Delimiter', ',', 'CollectOutput', true);

finish;

if isempty(scanData)
    warning('MLEPLOADEPRESULTS:EmptyDataFile', 'Result file contains no data.');
else
    % scanData is a 1-by-2 cell where scanData{1} is a cell array of date
    % time strings, and scanData{2} contains all the variable values.
    if readData
        if ischar(cols) && strcmp('all', cols)
            data = scanData{2};
        else
            data = scanData{2}(:, cols);
        end
    end
    
    if readTime
        % Extract month, day, hour, minute, second numbers
        % Prepend the year 2000 so that we can account for the leap year
        ts = datevec(strcat('2000/', scanData{1}));
        ts(:, 1) = [];    % Remove the year column
    end
end

    function finish
        % Close the opened file
        if fileNeedClose
            fclose(theFile);
        end
    end

end

function info = extractVarInfo(V)
% Extract information from a variable declaration string
% info is a structure of fields:
% .object: object name
% .name: variable name
% .unit: unit of the variable
% .sampling: sampling time
% The format of V is
%   obj:name [unit] (sampling)

tok = regexpi(strtrim(V), '(.+):(.+)\((.+)\)$', 'tokens');
assert(~isempty(tok) && 3 == length(tok{1}),...
    'Variable info string not in supposed syntax.');

info.object = tok{1}{1};   % the object name

info.sampling = tok{1}{3};   % Sampling time

% The rest, tok{1}{2}, contains the variable name (probably including the
% unit).  Try to extract the unit info first; if it fails, then the name
% does not contain the unit.
info.name = strtrim(tok{1}{2});
tok = regexpi(info.name, '(.+)\[(.*)\]', 'tokens');
if isempty(tok)
    info.unit = '';
else
    info.name = strtrim(tok{1}{1});
    info.unit = strtrim(tok{1}{2});
end

end
