function res = submodule_recur(varargin)
% UNDER CONSTRUCTION

% import Ext.git

st_dir = pwd;

res = {};

c_res = cell(1, 1+length(varargin));
c_res{1} = st_dir;

d = dirCell('*');

for ii = 1:length(d)
    c_d = d{ii};
    
    if ~any(c_d, {'.', '..'})
        try
            cd(c_d);
            if exist('.git', 'dir')
                res = [res; PsyGit.submodule_recur(varargin{:})]; %#ok<AGROW>
            end
        catch
        end
        
        cd(st_dir);
    end
end

for ii = 1:length(varargin)
    try
        c_res{ii+1} = git(varargin{ii});
    catch
    end
end

res = [res; c_res];