function h = gradLine(x,y,c,varargin)
% Line with gradual change in color
%
% h = gradLine(x,y,c=[0 0 0],varargin)
%
% Options
% -------
% 'EdgeAlpha', 0.5

z = [(1:numel(x))'; NaN];

if nargin < 3 || isempty(c)
    c = [0 0 0];
end

C = varargin2C(varargin, {
    'EdgeAlpha', 0.5
    });

if size(c,1) == 1 && size(c,2) == 3
    c = linspaceN(0.8+zeros(1,3), c, numel(x)+1); % ; nan(1,3)];
elseif size(c,1) == 2 && size(c,2) == 3
    c = linspaceN(c(1,:), c(2,:), numel(x)+1); % ; nan(1,3)];
end

h = patch([x(:);NaN],[y(:);NaN],z, 'CData', permute(c, [1 3 2]), ...
    'FaceColor','none','EdgeColor','interp', C{:});

view(2);