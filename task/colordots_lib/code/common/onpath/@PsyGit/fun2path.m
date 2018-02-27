function [pth nam ext] = fun2path(src)
% res = fun2path(src)
%
% src: Cell array of function names or directories. Function names have precedance.
% res: Paths of the functions determined by which(). 

if ~iscell(src)
    if ischar(src)
        src = {src};
    else
        error('Provide a string or a cell array of function names and/or paths!');
    end
end
                
n   = length(src);
pth = cell(n,1);
nam = cell(n,1);
ext = cell(n,1);
for ii = 1:n
    wch = which(src{ii});
    
    if isempty(wch)
        if exist(src{ii}, 'dir')
            pth{ii} = src{ii};
            nam{ii} = '';
            ext{ii} = '';
        elseif isempty(src{ii})
            pth{ii} = '';
            nam{ii} = '';
            ext{ii} = '';
        else
            error('Directory doesn''t exist: %s\n', src{ii});
        end
    else
        [pth{ii}, nam{ii}, ext{ii}] = fileparts(wch);
    end
end