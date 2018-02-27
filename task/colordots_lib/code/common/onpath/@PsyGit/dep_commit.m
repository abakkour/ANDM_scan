function varargout = dep_commit(bCaller, varargin)
% [msg, committed, comment] = dep_commit(bCaller, comment, addOpt, verbose)
%
% See also commit, commit_all

[varargout{1:nargout}] = PsyGit.commit(PsyGit.dep_repos(bCaller), varargin{:});