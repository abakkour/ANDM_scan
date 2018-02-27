function tf = strfinds(str, pattern, opt)
% STRFINDS  Return indices of text(s) that include the pattern(s).
%
% tf = strfinds(cellstr, pattern)
% : Unlike strfind, strfinds returns a logical array, not a cell array.
% 
% ix = strfinds(cellstr, pattern, 'numeric')
% : Returns numeric indices.
%
% ix = strfinds(cellstr, pattern, 'first')
% ix = strfinds(cellstr, pattern, 'last')
% : First/last index.
%
% tf = strfinds(cellstr, pattern, 'from')
% tf = strfinds(cellstr, pattern, 'to')
% : True from the first/to the last index.
%
% See also STRFIND

if iscell(str) && ischar(pattern)
    tf = ~cellfun(@isempty, strfind(str, pattern));
elseif ischar(str) && iscell(pattern)
    tf = cellfun(@(p) ~isempty(strfind(str, p)), pattern);
else
    error('One of STR and PATTERN should be a string, the other a cell array of strings!');
end

if nargin >= 3
    switch opt
        case 'numeric'
            tf = find(tf);
        case 'first'
            tf = find(tf, 1, 'first');
        case 'last'
            tf = find(tf, 1, 'last');
        case 'from'
            ix = find(tf, 1, 'first');
            tf(1:(ix-1)) = false;
            tf(ix:end) = true;
        case 'to'
            ix = find(tf, 1, 'last');
            tf(1:ix) = true;
            tf((ix+1):end) = false;
    end
end