function [gitHash, allOutput] = getHash(inDir_src)
% [gitHash, allOutput] = getHash(inDir)

% import Ext.git

prevDir = pwd;
if nargin == 0, inDir_src = pwd; end

% Enforce input into a cell
inDir = arg2cell(inDir_src);

gitHash   = cell(1,length(inDir));
allOutput = cell(1,length(inDir));

for ii = 1:length(inDir)
    cd(inDir{ii});

    allOutput{ii} = git('log -1 --pretty=format:"%H %s"');
    gitHash{ii}   = allOutput{ii}(1:(find(allOutput{ii}==' ', 1, 'first')-1));

    if strcmp(gitHash{ii}, 'fatal:'), gitHash{ii} = ''; end

    cd(prevDir);
end

% Output type matches input type
[gitHash, allOutput] = cell2arg(iscell(inDir_src), gitHash, allOutput);
