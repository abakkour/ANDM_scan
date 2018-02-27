function res = foreach(repos_src, git_command, verbose)
% FOREACH - run the same Git command for multiple repos
%
% res = foreach(repos_src, git_command, verbose)

% import Ext.git

if ~exist('verbose', 'var'), verbose = false; end

prev_dir = pwd;

[repos, res] = arg2cell(repos_src);

for ii = 1:length(repos)
    cd(repos{ii});
    res{ii} = git(git_command);
    
    if verbose
        disp(fullfile(repos{ii}, ['git ', git_command]));
        disp(res{ii});
        fprintf('\n');
    end
    
    cd(prev_dir);
end

res = cell2arg(iscell(repos_src), res);