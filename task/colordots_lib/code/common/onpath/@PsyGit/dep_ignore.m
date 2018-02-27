function [res, repos] = dep_ignore(bCaller, op, arg, verbose)
% [res, repos] = dep_ignore(bCaller, op, arg, verbose)
%
% op: 'view', 'add', 'remove'

if ~exist('arg', 'var'), arg = []; end
if ~exist('verbose', 'var'), verbose = true; end

repos = PsyGit.dep_repos(bCaller);

n   = length(repos);
res = cell(1,n);
arg = arg2cell(arg);

for ii = 1:n
    c_repo = repos{ii};
    c_gitignore = fullfile(c_repo, '.gitignore');
    
    switch op
        case 'view'
            if ~exist(c_gitignore, 'file')
                if verbose
                    fprintf('File doesn''t exist: %s\n\n', c_gitignore);
                end
            else
                f = fopen(c_gitignore, 'r');
                c = textscan(f, '%s\n');
                res{ii} = c{1};
                fclose(f);

                disp_contents;
            end
            
        case 'add'
            if ~exist(c_gitignore, 'file') && verbose
                fprintf('Created %s\n\n', c_gitignore);
            end
                
            f = fopen(c_gitignore, 'a+');
            fprintf(f, '\n');
            cfprintf(f, '%s\n', arg);
            fclose(f);
            
            f = fopen(c_gitignore, 'r');
            c = textscan(f, '%s\n');
            res{ii} = c{1};
            fclose(f);
            
            disp_contents;
            
        case 'remove'
            if ~exist(c_gitignore, 'file') && verbose
                fprintf('File doesn''t exist: %s\n\n', c_gitignore);
            else
                f = fopen(c_gitignore, 'r');
                c = textscan(f, '%s\n');
                res{ii} = c{1};
                fclose(f);
                
                [tf, intersectStrs] = strcmps(arg, res{ii});
                          
                if any(tf)
                    res{ii}(tf) = [];
                    
                    f = fopen(c_gitignore, 'w+');
                    cfprintf(f, '%s\n', res{ii});
                    fclose(f);
                end

                disp_contents;

                if any(tf) && verbose
                    fprintf('Removed lines from above:\n');
                    cfprintf('  %s\n', intersectStrs);
                    fprintf('\n');
                end
            end
    end    
end

function disp_contents
    if verbose
        fprintf('Contents of %s\n', c_gitignore);
        cfprintf('  %s\n', res{ii});
        fprintf('\n');
    end
end
end