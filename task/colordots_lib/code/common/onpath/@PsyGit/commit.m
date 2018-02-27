function [msg, committed, comment] = commit(repos, comment, addOpt, verbose)
% [msg, committed, comment] = commit(repos, comment, addOpt, verbose)
%
% addOpt can be either a string or a cell of strings.
% 
% See also commit_all, dep_commit

% import Ext.git
repos = arg2cell(repos);

committed = false(1,length(repos));

if ~exist('comment', 'var') 
    comment = '';
end
if ~exist('verbose', 'var')
    verbose = true;
end
if ~exist('addOpt', 'var')
    addOpt = '''*.m'' -A';
end
addOpt = arg2cell(addOpt);

% Commit in all repos with comment
toCommit = find(PsyGit.getStatus(repos, verbose));

if verbose
    fprintfLine;
    if isempty(toCommit)
        fprintf('No repository has any change.\n');
    else
        fprintf('Changes in the following directories are detected:\n');
        fprintf(' %s\n', repos{toCommit});
        fprintf('Will commit all of them.\n\n');
    end
end

% Prompt to get comment string if not given or empty.
if isempty(comment) && ~isempty(toCommit)
    fprintfLine;
    comment = input('Enter a common commit message. Type ''no'' to cancel commit: ', 's');
    fprintf('\n');
    if strcmpi(comment, 'no'), 
        fprintf('Commit cancelled.\n');
        msg = 'no'; 
        comment = '';
        return; 
    end
end

msg(1:length(repos)) = struct('add', {repmat({''}, [1, length(addOpt)])}, 'commit', '');

if ~isempty(toCommit) 
    if verbose
        fprintfLine;
        fprintf('Commiting...\n\n');
    end

    pDir = cd;
    for ii = toCommit
        cd(repos{ii});

        msg(ii).add = cell(1,length(addOpt));
        for jj = 1:length(addOpt)
            msg(ii).add{jj} = git(['add ', addOpt{jj}]);
        end
        msg(ii).commit = git(sprintf('commit -a -m "%s"', comment));

        if verbose
            fprintf('\n');
            fprintf('cd %s\n', repos{ii});
            for jj = 1:length(addOpt)
                fprintf('git add %s\n', addOpt{jj});
                disp(msg(ii).add{jj});
            end
            fprintf('git commit -a -m "%s"\n', comment);
            disp(msg(ii).commit);
        end

        committed(ii) = isempty(strfind(msg(ii).commit, 'nothing added to commit'));
    end

    cd(pDir);
end
end