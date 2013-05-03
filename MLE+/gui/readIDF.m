function data = readIDF(filename, classnames)
% READIDF - Read and parse EnergyPlus IDF file.
%   data = readIDF(filename) reads all data entries from an IDF
%   file with name filename. The output data is a structure array,
%   where each item is one data entry. Each item k has two fields:
%     data(k).class is a string of the class name
%     data(k).fields is a cell array of strings, each cell is a
%                    data field after the class name.
%   The order of the entries is the same as in the IDF file.
%
%   data = readIDF(filename, classnames) reads all data entries
%   of the classes given in classnames, from a given IDF
%   file. Input argument classnames is either a string or a cell
%   array of strings specifying the class(es) that will be
%   read. Data entries not of those classes will be skipped. The output
%   'data' is a structure array (a bit DIFFERENT from above): each item k
%   of the array contains ALL data entries for CLASS k in 'classnames' (not
%   entry k in the IDF file), with 2 fields:
%     data(k).class is a string, the name of the class k in 'classnames',
%                   converted to lower-case (e.g. 'TimeStep' becomes
%                   'timestep').
%     data(k).fields is a cell array of cell arrays of strings, each cell
%                   contains the fields' strings for one entry of class k.
%                   If there is no entry of class k then this field is an
%                   empty cell.
%
% Class names are case insensitive.
%
% Examples:
%   data = readIDF('SmOffPSZ.idf', 'Timestep')
%       to read only the time step, e.g. data could be
%           data = 
%               class: 'timestep'
%               fields: {{1x1 cell}}
%           with data(1).fields{1} = {'4'}
%
%   data = readIDF('SmOffPSZ.idf',...
%                   {'Timestep', 'ExternalInterface:Schedule'})
%       to read time step and all external schedule variables.
%           data = 
%           1x2 struct array with fields:
%               class
%               fields
%
%           data(2) =
%               class: 'externalinterface:schedule'
%               fields: {{1x3 cell}  {1x3 cell}}
%
%
% (C) 2012 by Truong X. Nghiem (nghiem@seas.upenn.edu)

% HISTORY:
%   2012-05-16 Speed up and change output structure.
%   2012-05-09 Started.

error(nargchk(1, 2, nargin));
assert(ischar(filename), 'File name must be a string.');
if ~exist('classnames', 'var')
    classnames = {};
else
    % Lower case strings in classnames
    if ischar(classnames)
        classnames = {lower(classnames)};
    elseif iscell(classnames)
        assert(all(cellfun(@ischar, classnames)),...
               'classnames must be a cell array of strings.');
        classnames = cellfun(@lower, classnames,...
                             'UniformOutput', false);
    else
        error('classnames must be either a string or a cell array.');
    end
end

noClassnames = isempty(classnames);
nClassnames = length(classnames);


% Open the file in text mode
[fid, msg] = fopen(filename, 'rt');
if fid < 0
    error('Cannot open IDF file: %s', msg);
end

% Read line by line and parse
syntaxerr = false;  % If there is a syntax error in the IDF file
syntaxmsg = '';

% Pre-allocate the data struct for faster performance and less
% fragmented memory
if noClassnames
    nBlocks = 0;  % Number of blocks read from file
    data = repmat(struct('class', '', 'fields', {{}}), 1, 128);
else
    data = struct('class', classnames, ...
        'fields', repmat({{}}, 1, nClassnames));
end

inBlock = false;  % A block is a block of code ended with ;
saveBlock = false;  % Is the current block being saved?

% The regular expression for parsing a line in the IDF file
%   A field is a group of 0 or more characters not including comma,
%   semi-colon and exclamation; a line consists of a number of fields,
%   separated by either a comma or a semi-colon.
rexp = '([^,;]*)([;,])';

while true
    l = fgetl(fid);
    
    if ~ischar(l), break; end % EOF
    
    if isempty(l), continue; end
    % Although MATLAB documents say that an empty line is an indication of
    % error, the errnum code returned is actually an EOF. That's confusing.
    % So I simply continue the reading for now.
    %%%%%
    %    [msg, errnum] = ferror(fid);
    %    if errnum ~= 0
    %        disp(errnum);
    %        error('Error while reading IDF file: %s', msg);
    %    end
    %end
    
    % Now that l is read successfully, remove all surrounding spaces
    l = strtrim(l);
    
    % If l is empty or a comment line, ignore it
    if isempty(l) || l(1) == '!' % ~isempty(regexp(l, '^!.*', 'start', 'once'))
        continue;
    end
    
    % Remove the comment part if available
    foundIdx = strfind(l, '!');
    if ~isempty(foundIdx)
        % Remove from the first occurence of '!' to the end
        l = strtrim(l(1:foundIdx(1)-1));
    end
    
    % If we are not in a block and if class names are given, we search
    % for any class name in the current line and only parse the line if we
    % find an interested class name.  Because we are not in a block, the
    % class name must be at the beginning of the line.
    if ~inBlock && ~noClassnames
        lowerL = lower(l);
        foundClassname = false;
        
        for k = 1:nClassnames
            if ~isempty(strmatch(classnames{k}, lowerL))
                foundClassname = true;
                break;
            end
        end
        
        if ~foundClassname
            % Could not find a class name in l, then skip this line
            continue;
        end
    end
    
    toks = regexp(l, rexp, 'tokens');
    if isempty(toks)
        % Syntax error
        syntaxerr = true;
        syntaxmsg = l;
        break;
    end

    for k = 1:length(toks)
        if ~inBlock
            % Start a new block
            inBlock = true;
            
            % Only save the block if its class name is desired
            if noClassnames
                saveBlock = true;
                nBlocks = nBlocks + 1;
                data(nBlocks).class = strtrim(toks{k}{1});
                data(nBlocks).fields = {};
            else
                [saveBlock, classIdx] = ...
                    ismember(lower(strtrim(toks{k}{1})), classnames);
                
                if saveBlock
                    data(classIdx).fields{end+1} = {};
                end
            end
        elseif saveBlock
            % Continue the previous block
            if noClassnames
                data(nBlocks).fields{end+1} = strtrim(toks{k}{1});
            else
                data(classIdx).fields{end}{end+1} = strtrim(toks{k}{1});
            end
        end
        
        % If the delimiter is ; then close the block
        if toks{k}{2} == ';'
            inBlock = false;
        end
    end
end

fclose(fid);

if syntaxerr
    error('Syntax error: %s', syntaxmsg);
end

% Free unused spaces (if any)
if noClassnames
    data((1+nBlocks):end) = [];
end

end
