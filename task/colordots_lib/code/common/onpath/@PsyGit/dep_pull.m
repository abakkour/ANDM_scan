function res_pull = dep_pull(bCaller, varargin)
% DEP_PULL - pull all dependent repos with a tag.
%
% res_pull = dep_pull(bCaller, comment, 'option_name1', option1, ...)
%
% Options & defaults
%     'tag',        'pushed'
%     'remote',     'origin'
%     'local_br',   'master'
%     'pull_opt',   ''
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

repos = PsyGit.dep_repos(bCaller);

res_pull = PsyGit.foreach(repos, ...
    sprintf('pull %s %s %s', S.remote, S.local_br, S.push_opt), S.verbose);