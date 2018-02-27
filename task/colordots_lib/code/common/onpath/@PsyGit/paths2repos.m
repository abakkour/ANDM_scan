function [repos, repoIx] = paths2repos(paths)
% [repos, repoIx] = paths2repos(paths)

if ~iscell(paths), error('PATHS should be a cell array of path strings!'); end

n        = length(paths);
repoAll  = cell(n,1);
for ii = 1:n
    repoAll{ii} = PsyGit.locateRepo(paths{ii});
end

repoIx   = zeros(n,1);

repo_nonempty = ~cellfun(@isempty, repoAll);
[repos, ~, repoIx(repo_nonempty)] = unique(repoAll(repo_nonempty));
