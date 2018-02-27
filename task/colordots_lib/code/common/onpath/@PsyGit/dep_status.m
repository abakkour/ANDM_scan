function [res, repos] = dep_status(bCaller, verbose)

% import Ext.git

if ~exist('verbose', 'var'), verbose = true; end

repos = PsyGit.dep_repos(bCaller);

n = length(repos);
res = cell(1,n);

prev_dir = pwd;

for ii = 1:n
    cd(repos{ii});
    res{ii} = git('status');
    
    if verbose
        fprintf('%s/git status\n', repos{ii});
        disp(res{ii});
        fprintf('\n');
    end
    
    cd(prev_dir);
end