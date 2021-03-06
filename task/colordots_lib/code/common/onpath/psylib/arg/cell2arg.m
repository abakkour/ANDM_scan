function varargout = cell2arg(keep_as_cell, varargin)
% CELL2ARG - Returns v{1} if keep_as_cell==false
%
% [v1, v2, ...] = cell2arg(keep_as_cell, v1, v2, ...)
%
% Example:
%
% res = cell2arg(iscell(src), res) % res matches src's class
%
% See also arg2cell, arg, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if ~keep_as_cell
    varargout = cellfun(@(c) c{1}, varargin, 'UniformOutput', false);
else
    varargout = varargin;
end