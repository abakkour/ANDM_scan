function inst = varargin2props(inst, vararginCell, suppressError)
% USAGE: inst = varargin2props(inst, vararginCell, suppressError=false)
%
% For protected or private properties, tries set_PROP_NAME().
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail.

    if nargin < 2 || isempty(vararginCell)
        return; 
    end
    if nargin < 3
        suppressError = false; 
    end
    
    % Enforce behavior consistent with varargin2S and varargin2C
    vararginCell = varargin2C(vararginCell);

    for iArgin = 1:2:numel(vararginCell)
        name = vararginCell{iArgin};
        
        try
            inst.(name) = vararginCell{iArgin+1};
        catch
            try
                inst.(['set_' name])(vararginCell{iArgin+1});
            catch err        
                if ~suppressError
                    if ~isprop(inst, name)
                        warning('No property named %s for class %s!\n', ...
                            name, class(inst));
                    end
                    rethrow(err);
                end
            end
        end
    end
end