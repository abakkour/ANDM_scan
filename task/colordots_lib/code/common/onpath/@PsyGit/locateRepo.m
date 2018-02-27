function repoDir = locateRepo(inDir)
% repoDir = locateRepo(inDir)
%
% Locate the repo that inDir belongs to.

if nargin >= 1
    prevDir = cd(inDir);
else
    prevDir = pwd;
end

if ~isVersioned
    repoDir = '';    
else
    % Find the first dir with '.git' whle cd-ing up.
    pd = '';
    while ~exist('./.git', 'dir') && ~strcmp(pd, pwd)
        pd = cd('..');
    end
    
    repoDir = pwd;
end
cd(prevDir);
end


function tf = isVersioned
% import Ext.git

allOutput = git('status');
tf = ~any(strfind(allOutput, 'fatal: Not a git repository') == 1);
end