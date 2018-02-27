function [repos, repo_ix, not_versioned] = dep_repos(bCaller_or_depPaths)
% [repos, repo_ix, not_versioned] = dep_repos(bCaller_or_depPaths)

if ischar(bCaller_or_depPaths)
    bCaller = bCaller_or_depPaths;
    depPaths = dep2paths(bCaller);
else
    depPaths = bCaller_or_depPaths;
end

% Detect repos and
% warn about directories without version control            
p_repos = {};
not_versioned = true(length(depPaths), 1);
while any(not_versioned)
    % Detect repositories from depPaths
    [repos, repo_ix] = PsyGit.paths2repos(depPaths);
    not_versioned = repo_ix == 0;
                    
    new_repos = setdiff(repos, p_repos);
    p_repos   = repos;
    
    fprintfLine;
    fprintf('Added repositories:\n');
    cfprintf('  %s\n', new_repos);
    fprintf('\n');
    
    if any(not_versioned)
        fprintfLine;
        warning([sprintf('The following directories are not under version control:\n'), ...
                 sprintf('%s\n', depPaths{not_versioned})]);
        fprintf('To enable rollback, keep everything under version control.\n');
        fprintf('It is highly recommended to stop here and add to version control!\n');
        fprintf('Add version control to them NOW and continue this process!\n');
        to_check_again = inputYN('Do you want to check version control status again (y) or proceed anyway (n)? ');
        if ~to_check_again
            break;
        end
    end
end