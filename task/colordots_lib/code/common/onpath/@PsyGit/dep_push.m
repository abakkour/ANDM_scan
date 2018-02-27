function [res_push, res_tag] = dep_push(bCaller, comment, varargin)
% DEP_PUSH - push all dependent repos with a tag.
%
% [res_push, res_tag] = dep_push(bCaller, comment, 'option_name1', option1, ...)
%
% Options & defaults
%     'tag',        'pushed'
%     'remote',     'origin'
%     'local_br',   'master'
%     'push_opt',   ' --tag'
%     'date_tag',   true
%     'verbose',    true
%
% To skip tagging, provide tag='' and date_tag=false.
%
% See also foreach


S = varargin2S(varargin, {...
    'tag', 'pushed', ...
    'remote', 'origin', ...
    'local_br', 'master', ...
    'push_opt', ' --tag', ...
    'date_tag', true, ...
    'verbose', true ...
    });

if ~exist('comment', 'var'), comment = ''; end

repos = PsyGit.dep_repos(bCaller);

if S.date_tag
    S.tag = funPrintfBridge('_', S.tag, datestr(now, 'yyyymmddTHHMMSS'));
end

if ~isempty(S.tag)S.date_tag
    
    if isempty(comment)
        res_tag  = PsyGit.foreach(repos, sprintf('tag %s', S.tag), S.verbose);
    else
        res_tag  = PsyGit.foreach(repos, ...
            sprintf('tag -a %s -m ''%s''', S.tag, comment), S.verbose);
    end
end

res_push = PsyGit.foreach(repos, ...
    sprintf('push %s %s %s', S.remote, S.local_br, S.push_opt), S.verbose);