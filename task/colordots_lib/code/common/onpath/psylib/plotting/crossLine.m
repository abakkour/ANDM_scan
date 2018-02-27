function varargout = crossLine(vh, varargin)
% CROSSLINE  Draw vert/horz lines across a plot without changing xlim or ylim.
%
% crossLine('v', x1, spec1, [x2, spec2, ...])
% : Draws vertical lines at x1, x2, etc.
% 
% x     : a scalar or vector
% spec  : linespec (such as 'r-'), color (1x3 vector), or {linespec, color}.
%
% crossLine('h', y1, spec1, [y2, spec2, ...])
% : Draws horizontal lines at x1, x2, etc.
%
% crossLine(ORI, offset, [spec1])
% : ORI = 'NE', 'SW', 'NW', or 'SE'. Draws a diagonal line.
%
% [h1, h2, ...] = crossLine(...)
% : Handle to the lines.
%
% See also PLOT, XLIM, YLIM, PARSEPLOTSPEC.
%
% Yul Kang (c) 2013.

if ~verLessThan('matlab', '8.5') && (strcmp(vh, 'h') || strcmp(vh, 'v')) ...
        && (length(varargin) <= 1)
    
    ax = gca;
    if isempty(varargin)
        v = 0;
    else
        v = varargin{1};
    end
    if isscalar(v)
        try
            switch vh
                case 'h'
                    ax.YBaseline.Visible = 'on';
                    ax.YBaseline.BaseValue = v;
                    ax.YBaseline.Color = [0 0 0];

                case 'v'
                    ax.XBaseline.Visible = 'on';
                    ax.XBaseline.BaseValue = v;
                    ax.XBaseline.Color = [0 0 0];
            end
            return;
        catch err
            warning(err_msg(err));
        end
    end
end

%% Save xlim and ylim
xLim = xlim;
yLim = ylim;
hold on;

if nargin < 2
    varargin{1} = 0;
end

varargout = cell(1,floor(length(varargin)/2));

for ii = 1:2:length(varargin)
    
    %% Coordinates
    switch vh
        case 'v'
            x = [varargin{ii}(:)'; varargin{ii}(:)'];
            y = yLim' * ones(1,length(varargin{ii}));
            
        case 'h'
            y = [varargin{ii}(:)'; varargin{ii}(:)'];
            x = xLim' * ones(1,length(varargin{ii}));
            
        case {'NE', 'SW'}
            x = [min(xLim(1), yLim(1)); max(xLim(2), yLim(2))];
            y = bsxfun(@plus, x, varargin{ii}(:)');
            
        case {'NW', 'SE'}
            x = [min(xLim(1), yLim(1)); max(xLim(2), yLim(2))];
            y = bsxfun(@plus, -x, varargin{ii}(:)');
    end
    
    %% Spec
    if length(varargin)>ii
        cc = parsePlotSpec(varargin(ii+1));
    else
        cc = {'k-', 'LineWidth', 0.1};
    end
    
    %% Plot
    h = plot(x, y, cc{:});
    uistack(h, 'bottom');
    varargout{ceil(ii/2)} = h;
end


%% Revert xlim and ylim
hold off;
xlim(xLim);
ylim(yLim);
end