function mlepWriteEPModel(tfile, ofile, varargin)
%MLEPWRITEEPMODEL Write EnergyPlus model file from template.
%   mlepWriteEPModel(tfile, ofile, key1, value1, key2, value2,...)
%
%   This function replaces keys in template file tfile with values, and
%   write the output file to ofile.
%
%   tfile is a file name as a string.
%   ofile is a file name as a string.
%   Each pair (keyn, valuen) is a pair of strings, where keyn specifies the
%       sequence of characters to be replaced with the sequence of
%       characters in valuen.  The key strings should have very special
%       format, for example "%KEY%".
%
%   All occurences of keyn in the template file will be replaced by valuen.
%   The final content, with all keys replaced by corresponding values, is
%   written to the output file.  The output file must be different from the
%   template file.
%
%   Note that the replacement is carried out line by line, so if a key
%   string is split into two lines, it will not be replaced.
%
% (C) 2010 by Truong Nghiem (nghiem@seas.upenn.edu)

% Check input arguments
error(nargchk(4, inf, nargin));

if ~ischar(tfile)
    error('Template file name tfile must be a string.');
end

if ~ischar(ofile)
    error('Output file name ofile must be a string.');
end

npairs = length(varargin);

% An even number of keys & values arguments is required
if mod(npairs, 2) ~= 0
    error('Keys and values must come in pairs.');
end

if ~iscellstr(varargin)
    error('Keys and values must be strings.');
end

keys = varargin(1:2:(npairs-1));
values = varargin(2:2:npairs);
npairs = npairs/2;


% Open template file for reading
ftemplate = fopen(tfile, 'r');
if ftemplate == -1
    error('Cannot open template file.');
end

% Open output file for writing
fmodel = fopen(ofile, 'w');
if fmodel == -1
    fclose(ftemplate);
    error('Cannot open output file for writing.');
end


% Replace line by line
tline = fgetl(ftemplate);
while ischar(tline)
    for kk = 1:npairs
        tline = strrep(tline, keys{kk}, values{kk});
    end
    
    % Write to output model file
    fprintf(fmodel, '%s\n', tline);
    
    % Read next line
    tline = fgetl(ftemplate);
end

fclose(ftemplate);
fclose(fmodel);

end