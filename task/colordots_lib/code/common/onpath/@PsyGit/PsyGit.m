classdef PsyGit < matlab.mixin.Copyable
    % Give names with one or more Git hash(es). Commits if necessary.
    %
    % 2013 (c) Yul Kang. hk2699 at columbia dot edu.
    
    properties
        depPaths = {};
        depFiles = {};
        repos    = {};
        hashes   = {};
        
        baseCallerPath = '';
        baseCallerName = '';
        
        % opt
        %   Miscellaneous
        %   .opt.opt.verbose
        %
        %   Git
        %   .comment    : Commit message. Updated on construction or on new commit.
        %   .trackDep
        %      true     : Track dependencies and add paths.
        %   .addOpt     
        %     '''*.m'' -A'': Untracked files will not be added.
        %                 Will change to '-A' once ignoring is implemented. % TODO
        %
        %   Naming
        %   .codeBase   : Set to a folder where all codes belong to.
        %   .dataBase   : Set to a folder where all data belongs to.
        %   .defaultBases
        %               : Determines codeBase-dataBase pair if not given by arguments.
        %                 The first codeBase pattern that appear in baseCaller's
        %                 path is chosen, and is replaced with the paired dataBase
        %                 pattern in name().
        %   .commitOnName
        %      true     : name() automatically adds & commits before giving names.
        %
        %   .folderFormat
        %   .fileFormat
        %   For folder and file formats, funFullFile and funPrintf with
        %   the following rule applies:
        %     rule = {'B', me.baseCallerName, ...
        %             'K', kind, ...
        %             'T', me.datestr, ...
        %             'd', me.dateOnly, ...
        %             't', me.timeOnly, ...
        %             'H', me.hashesStr, ...
        %             'C', me.opt.comment, ...
        %             'c', me.opt.postRunComment, ...
        %             'S', me.opt.subjName, ...
        %             ...
        %             'b', me.baseCallerPath, ...
        %             'p', strrep(me.baseCallerPath, me.opt.codeBase, me.opt.dataBase), ...
        %             's', subFolder};
        %
        %   .folderTmp and .fileTmp have examples for the most common use.
        %
        %   .logFile
        %     'byFile'  : Save fullpath/file.ext.log file for every file named.
        %     'byFile_hide' : Save fullpath/.file.ext.log (add '.' in front so it's hidden in Finder.)
        %     'none'    : Don't save log file.
        %
        %   .askOverwriting
        %      true     : .name() prompts if the same name exists.
        opt = struct( ...
            ... Miscellaneous
            'verbose'   , true, ...
            ... Git
            'comment'   , '', ...
            'postRunComment', '', ...
            'timeStamp' , now, ...
            'useCommitTimeStamp', false, ...
            'trackOpt'  , {{}}, ...
            'trackDep'  , true, ...
            'addOpt'    , '''*.m'' -A', ... 
            ... Dep2zip
            'dep2zip'   ,   true, ... % On commit, also zip dependencies.
            'dep2zip_dir',  '*PsyScr', ...
            'dep2zip_file', '*PsyScr_run', ...
            'dep2zip_filt',   {{'toolbox', '@dataset/private/'}}, ...
            'dep2zip_filtIn', false, ...
            ... Naming
            'commitOnAdd',   true, ...
            'commitBefName', true, ...
            'codeBase'  ,    '', ...
            'dataBase'  ,    '', ...
            'defaultBases',  {PsyGit.defaultBases}, ...
            'folderFormat',  '*PsyScr', ...
            'fileFormat',    '*PsyScr_full', ... 
            'subjName',      '', ...
            'logFile',       'byFile_hide', ...
            'askOverwriting', true, ...
            'diaryOnConstruct', false, ...
            'diaryFile',        'diary.txt', ...
            'diaryOn',          false);
    
        %   .folderTmp
        %     'p/B/S/s'   : (Default) In baseCaller's path, substitute codeBase with 
        %                 dataBase to get the data file's path.
        %     'b/B_S/s' : basePath/baseCaller_subjName/orig
        folderTmp = struct( ...
            'parallel',  'p/B/S/s', ...
            'PsyScr',    'p/B/S/s', ...
            'oldPsyScr', 'b/B_S/s');
        
        %   .fileTmp
        %     'K_(D%TT_H)_C': (Default) Kind_(DateTTime_Hashes)_Comment
        %                  'Kind' is the general class of the output file that is 
        %                  specified in the script or function.
        %                  'Comment' is specific to the particular version of the
        %                  file.
        % 
        %                  Automatic checkout will detect time & hashes based on
        %                  the first "_(" followed by 8 numbers, "T", and another 6 numbers.
        %                  Don't use it in the 'Kind' part.
        %
        %     'B_S_D%TT': Old PsyScr format for trial .mat files and run .edf files.
        %                 S denotes subject name.
        %     'B_S_K'   : Old PsyScr format for Trial files, where kind = 'Tr'
        %     'B_S_D%TT_C': Old PsyScr format for run comment files.
        fileTmp = struct( ...
            'kind_time_comment',      'B_K_T_C_c', ...
            'kind_time',              'B_K_T', ...
            'kind',                   'B_K', ...
            'kind_time_hash_comment', 'B_K_(T_H)_C_c', ...
            'PsyScr_trial', 'B_S_T', ...
            'PsyScr_Tr',    'B_S_%T%r%i%a%l', ...
            'PsyScr_Tr_bak','B_S_%T%r%i%a%l_T', ...
            'PsyScr_run',   'B_S_T_C', ...
            'PsyScr_diary', 'B_S_T_C_c', ...
            'PsyScr_full',  'B_S_K_T_C_c');
        
        journal_keep = true;
        journal_verbose = true;
    end
    
    properties (Dependent)
        n
        baseCaller
        hash_short
    end
    
    methods
        %% Construction
        function me = PsyGit(paths, varargin)
            % me = PsyGit(paths, 'opt1', opt1, ...)
            %
            % paths: Cell array of function or directory names to cover.
            %
            %        When an entry is both function and a directory name,
            %        function name takes precedance.
            %
            %        Defaults to the caller function or script (same as giving {}),
            %        Give functions/directories that need to be checked. Those
            %        should also be under Git version control.
            %
            %        Multiple entries are needed only when they belong to different
            %        repositories.
            %
            %        baseCallerPath and Name are set to paths{1}'s if provided.
            %
            % Options: See help PsyGit.opt
            
            userOpt = varargin2S(varargin);
            me.opt = copyFields(me.opt, userOpt);
            
            if me.opt.diaryOnConstruct
                me.diary('on');
            end
            
            if exist('paths', 'var')
                paths = arg2cell(paths);
                paths = paths(:)';
            else
                paths = {};
            end
            
            % When functions or paths are specified
            if ~isempty(paths)
                % Convert to absolute paths
                [providedPath, providedName, providedExt] = PsyGit.fun2path(paths(1));
                providedBaseCaller = fullfile(providedPath{1}, [providedName{1}, providedExt{1}]);
            end
            
            % Detect baseCaller
            detectedBaseCaller = baseCaller;
            [~, detectedBaseCallerName] = fileparts(detectedBaseCaller);
            
            baseDetected = ~strcmp(detectedBaseCallerName, 'PsyGit');
            baseProvided = exist('paths', 'var') && ~isempty(paths) && ~isempty(paths{1});
            
            if baseDetected || baseProvided
                % Modify paths{1} if necessary:                
                % If a valid baseCaller is detected (not called from cell mode)
                if baseDetected
                    % If detected baseCaller differs from the provided one, warn.
                    if baseProvided && ~strcmp(detectedBaseCaller, providedBaseCaller)
                        fprintfLine;
                        warning(['Actual and provided basecallers differ:\n', ...
                                 '  Provided: %s\n', ...
                                 '  Actual: %s\n', ...
                                 'Will use actual basecaller.\n\n'], ...
                                 providedBaseCaller, detectedBaseCaller);
                    % If baseCaller not provided or is the same as provided one, just display it.
                    else
                        fprintfLine;
                        fprintf('PsyGit: Using detected baseCaller %s\n\n', detectedBaseCaller);
                    end
                    paths{1} = detectedBaseCaller;

                % When called from cell mode, use provided baseCaller. 
                elseif baseProvided
                    fprintfLine;
                    fprintf('PsyGit: Using provided baseCaller %s\n\n', providedBaseCaller);
                    paths{1} = providedBaseCaller;
                end
                
                % Fill baseCaller info from paths{1}
                [me.baseCallerPath me.baseCallerName] = baseCallerParts(paths{1});

                % Fill depPaths from paths(:)
                [me.depPaths depFuns depExts] = PsyGit.fun2path(paths);
                
                % If asked to track dependencies, track baseCaller's dependency
                if me.opt.trackDep
                    fprintfLine;
%                     origDepPaths = me.depPaths;

                    me.update_dep;
                    
%                     % Track all the speicifed paths
%                     for iDep = 1:length(origDepPaths)
%                         cDep = fullfile(origDepPaths{iDep}, [depFuns{iDep} depExts{iDep}]);
% 
%                         % Don't track directories. Only track files.
%                         if exist(cDep, 'file')
%                             [c_depPaths, c_depFiles] = dep2paths(cDep);
%                             me.depPaths = union(me.depPaths, ...
%                                 c_depPaths, 'stable');
%                             me.depFiles = union(me.depFiles, ...
%                                 c_depFiles, 'stable');
%                         end
%                     end
%                     fprintf('\n');
                end
            else            
                fprintfLine;
                warning(['PsyGit: BaseCaller neither provided nor detected!\n' ...
                         'Will use repository of current directory, %s\n' ...
                         'When you use cell mode, provide explicit function/directory name(s)' ...
                         'to prevent misnaming of the results!\n'], cd);
                    
                me.baseCallerPath = cd;
                me.baseCallerName = 'base';
                me.depPaths = {cd};
            end
            
            % Determine codeBase and dataBase automatically
            if ~isfield(userOpt, 'codeBase') && ~isfield(userOpt, 'dataBase')
                cBase = strfinds(me.baseCallerPath, me.opt.defaultBases(:,1), 'first');
                if isempty(cBase), cBase = 1; end
                
                me.opt.codeBase = me.opt.defaultBases{cBase,1};
                me.opt.dataBase = me.opt.defaultBases{cBase,2};
            end
            
            % Detect repos and
            % warn about directories without version control
            me.repos = PsyGit.dep_repos(me.depPaths);
            
            % Get hashes
            me.getHashes;
                
            % Show status before getting comment
            me.getStatusAll;
            
            % Get comments regardless whether change happened or not
            if isempty(me.opt.comment)
                fprintfLine;
                me.opt.comment = input('Enter comment for this run: ', 's'); 
                fprintf('\n');
            else
                fprintfLine;
                fprintf('Comment for this run: %s\n\n', me.opt.comment);
            end            
            
            % Keep journal
            if me.journal_keep
                journal('PsyGit: Constructed.\n', {}, 'verbose', me.journal_verbose);
                journal('PsyGit: Construction comment: %s\n', {me.opt.comment}, 'verbose', me.journal_verbose);
            end
            
            % Commit changes if any
            me.commit_all(me.opt.comment);
        end
        
        %% Interaction with git
        function cHashes = getHashes(me, toCheck)
            % Get hashes in all repos.
            
            if ~exist('toCheck', 'var'), 
                toCheck = 1:me.n;
            elseif islogical(toCheck), 
                toCheck = find(toCheck);
            end
            
            me.hashes(toCheck) = PsyGit.getHash(me.repos(toCheck));
            
            if nargout >= 1
                cHashes = me.hashes(toCheck);
            end
        end
        
        function [anyChanges, toAdds, toStages, toCommits, statusAll, allOutputs] = getStatusAll(me, toCheck)
            % [anyChanges, toAdds, toStages, toCommits, statusAll, allOutputs] = getStatusAll(me, toCheck)
            % Get status in all repos.
            
            if me.opt.verbose
                fprintfLine;
                fprintf('Checking status of the repositories:\n\n');
            end
            
            if ~exist('toCheck', 'var')
                toCheck = 1:me.n;
            elseif islogical(toCheck), 
                toCheck = find(toCheck); 
            end
            
            [anyChanges, toAdds, toStages, toCommits, statusAll, allOutputs] = ...
                PsyGit.getStatus(me.repos(toCheck), me.opt.verbose);
        end
        
        function [msg, committed] = commit_all(me, comment)
            % Commits in all repos with the given comment and update hashes.
            % Ignore new files before this. This function will add all new files
            % and commit them.
            
            if ~exist('comment', 'var')
                comment = me.opt.comment;
            end
            
            pDir = pwd;
            
            [msg, committed, me.opt.comment] = PsyGit.commit( ...
                me.repos, comment, me.opt.addOpt, me.opt.verbose);

            if any(committed)
                journal('PsyGit: Commit message: %s\n', {comment}, 'verbose', me.journal_verbose);
                arrayfun(@(c) journal('PsyGit: Committed %s\n', c, 'verbose', me.journal_verbose), ...
                    me.repos(committed));
                
                me.opt.timeStamp = now;
                if me.opt.verbose
                    fprintf('cd %s\n\n', pDir);
                    fprintfLine;
                    fprintf('Committed the following repositories:\n');
                    fprintf('  %s\n', me.repos{committed});
                    fprintf('\n');
                    fprintfLine;
                    fprintf('Time stamp updated to the time of commit: %s\n\n', ...
                            me.datestr);
                end

                if me.opt.dep2zip
                    fprintfLine;
                    fprintf('Since there was a change and opt.dep2zip==true,\n');
                    fprintf('dependent files are being zipped:\n');
                    zip_file = me.nameStr('dep2zip', 'dep2zip', '.zip', ...
                                    me.opt.dep2zip_file, me.opt.dep2zip_dir); 
                                
                    if ~isfield(me.opt, 'trackDep') || ~me.opt.trackDep
                        me.update_dep;
                    end                        
                                
                    if ~isempty(me.depFiles)
                        if ~exist(fileparts(zip_file), 'dir')
                            mkdir(fileparts(zip_file));
                        end
                        zip(zip_file, me.depFiles);
                        fprintf('%d files are zipped to %s\n\n', ...
                            numel(me.depFiles), zip_file);
                        
%                         zip_packages(... % FIXIT - not working for now
%                             filt_str_cell(me.depFiles, ...
%                                 me.opt.dep2zip_filt, me.opt.dep2zip_filtIn), ...
%                             zip_file);
                    else
                        fprintf('No dependent files detected!\n');
                    end
                end
            else
                fprintfLine;
                fprintf('Nothing was committed. Time stamp was kept still.\n\n');
            end            
            
            % Update hashes.
            me.getHashes; 
        end
        
        function update_dep(me) % needs more testing
            % UPDATE_DEP - Updates depPaths and depFiles based on which(me.baseCallerName)
            fprintf('Tracking dependencies:\n');
            
            if ~isempty(which(me.baseCallerName))
                [c_depPaths, c_depFiles] = dep2paths(which(me.baseCallerName));
                me.depPaths = union(me.depPaths, ...
                    c_depPaths, 'stable');
                me.depFiles = union(me.depFiles, ...
                    c_depFiles, 'stable');
            end
            
            fprintf('\n');
        end
        
        %% Naming
        function [res, dontProceed] = nameStr(me, subFolder, kind, ext, ...
                fileFormat, folderFormat, moreRules)
            % Returns formatted name.
            % 
            % [res, dontProceed] = nameStr(me, subFolder, kind, ext='', ...
            %     fileFormat, folderFormat, rules)
            %
            % kind       : String that describes what the file is.
            %              e.g., 'graph_motion_energy'.
            % fileFormat : Give NaN to skip. See help PsyGit.opt
            % folderFormat: Give NaN to skip. See help PsyGit.opt
            % rules      : Cell vector with pairs of a char and a substituting
            %              string, common to fileFormat and folderFormat.
            %              e.g., {'g', 'graph', 'G', 'Giraffe'}.
            %
            % res        : Name formatted according to .opt.
            % dontProceed: True when .opt.warnOverwriting==true,
            %              the same file exists, and the user enters 'n'.
            %
            % To see what the folder & file name format will be,
            % see help PsyGit.opt, under section .folderFormat and .fileFormat, 
            % and check me.opt.folderFormat and me.opt.fileFormat.
            % Omit or give NaN as file/folderFormat to use me.opt.file/folderFormat.
            %
            % Start fileFormat or folderFormat with '*' to use predefined templates,
            % fileTmp and folderTmp.
            %
            % See also PsyGit.name, PsyGit.nameScr, PsyGit.opt, funFullFile, funPrintf
            
            if ~exist('subFolder', 'var'), subFolder = ''; end
            if ~exist('kind', 'var'), kind = ''; end
            if ~exist('ext', 'var'), ext = ''; end
            
            if ischar(subFolder)
                superFolder = '';
            elseif iscell(subFolder)
                if numel(subFolder) == 2
                    superFolder = subFolder{1};
                    subFolder   = subFolder{2};
                elseif numel(subFolder) == 1
                    superFolder = '';
                    subFolder   = subFolder{1};
                elseif isempty(subFolder)
                    superFolder  = '';
                    subFolder   = '';
                else
                    error('Second argument should be char or cell of 0, 1, or 2 strings!');
                end
            else
                error('Second argument should be char or cell of 0, 1, or 2 strings!');
            end
            
            if ~exist('fileFormat', 'var') || any(isnan(fileFormat)), 
                fileFormat = me.opt.fileFormat; 
            end
            if ~isempty(fileFormat) && fileFormat(1)=='*'
                fileFormat = me.fileTmp.(fileFormat(2:end));
            end
            if ~exist('folderFormat', 'var') || any(isnan(folderFormat)), 
                folderFormat = me.opt.folderFormat; 
            end
            if ~isempty(folderFormat) && folderFormat(1)=='*'
                folderFormat = me.folderTmp.(folderFormat(2:end));
            end
            if ~exist('moreRules', 'var'), moreRules = {}; end
            
            rule = {'B', me.baseCallerName, ...
                    'K', kind, ...
                    'T', me.datestr, ...
                    'd', me.dateOnly, ...
                    't', me.timeOnly, ...
                    'H', me.hashesStr, ...
                    'C', me.opt.comment, ...
                    'c', me.opt.postRunComment, ...
                    'S', me.opt.subjName, ...
                    ...
                    'b', me.baseCallerPath, ...
                    'p', strrep(me.baseCallerPath, me.opt.codeBase, me.opt.dataBase), ...
                    'P', superFolder, ...
                    's', subFolder};
            rule_dir  = [rule, moreRules(:)'];
            rule_file = [rule, {'S', strrep(me.opt.subjName, '/', '__')}, moreRules(:)'];
                
            file = funPrintfConnect(fileFormat, '_', rule_file{:});
            
            res  = fullfile(funFullFileConnect(folderFormat, '_', rule_dir{:}), [file, ext]);            
            
            journal('PsyGit.nameStr: named %s\n', {res}, 'verbose', me.journal_verbose);
        end
        
        function varargout = nameScr(me, kindScr, subDir, ext, varargin)
            % Wrapper for calls from PsyScr
            %
            % res = Git.nameScr('Tr', subDir, ext)
            % res = Git.nameScr('run', subDir, ext)
            % res = Git.nameScr('diary', subDir, ext, postRunComment)
            % res = Git.nameScr('trial', subDir, ext, timeStamp)
            
            if ~exist('subDir', 'var'), subDir = ''; end
            if ~exist('ext', 'var'), ext = ''; end
            
            switch kindScr
                case 'Tr'
                    [varargout{1:nargout}] = ...
                        me.nameStr(subDir, '', ext, '*PsyScr_Tr');
                    
                case 'Tr_bak'
                    [varargout{1:nargout}] = ...
                        me.nameStr(subDir, '', ext, '*PsyScr_Tr_bak');
                    
                case {'trial', 'run'}
                    if isempty(varargin), 
                        timeStamp = me.opt.timeStamp;
                    else
                        timeStamp = varargin{1};
                    end
                    [varargout{1:nargout}] = ...
                        me.nameStr(subDir, '', ext, ['*PsyScr_', kindScr], nan, ...
                        {'T', datestr(timeStamp, 'yyyymmddTHHMMSS')});
                    
                case 'diary'
                    if ~exist('ext', 'var'), ext = '.txt'; end
                    if isempty(varargin)
                        me.opt.postRunComment = '';
                    else
                        me.opt.postRunComment = varargin{1};
                    end
                    [varargout{1:nargout}] = ...
                        me.nameStr(subDir, '', ext, '*PsyScr_diary');
            end
        end
        
        function varargout = nameScrLog(me, varargin)
            % Same as nameScr but saves .log file.
            [varargout{1:max(1,nargout)}] = me.nameScr(varargin{:});
            
            me.saveLog(varargout{1});
        end
        
        function res = nameDir(me, varargin)
            res = fileparts(nameStr(me, varargin{:}));
        end
        
        function finder(me, varargin)
            finder(nameDir(me, varargin{:}));
        end
        
        function varargout = name(me, subFolder, kind, ext, dataFiles, varargin)
            % NAME - Same as nameStr() but commits before naming, and saves .log.
            %
            % [res, dontProceed] = name(me, subFolder, kind, ext='', dataFiles, ...
            %     fileFormat, folderFormat, rules))
            %
            % dataFiles - added to log file.
            
            if ~exist('subFolder', 'var'), subFolder = ''; end
            if ~exist('kind', 'var'),      kind = ''; end
            if ~exist('ext', 'var'),       ext = ''; end
            if ~exist('dataFiles', 'var'), dataFiles = {}; end
            
            dataFiles = arg2cell(dataFiles);
            
            if me.opt.commitBefName
                me.commit_all;
            end
            
            [res, varargout{2:nargout}] = me.nameStr(subFolder, kind, ext, varargin{:});
            
            if ~exist(fileparts(res), 'dir'), mkdir(fileparts(res)); end
            
            if me.opt.askOverwriting && ...
                    exist(res, 'file')
                yne = '';
                
                while ~any(strcmp(yne, {'y', 'Y', 'n', 'N', 'e', 'E'}))
                    yne = input(...
                        sprintf(...
                        'PsyGit: %s already exists! Do you want to overwrite it (y/n/e: issue error)? ', ...
                        res), 's');
                    switch yne
                        case {'y', 'Y'}
                            dontProceed = false;

                        case {'n', 'N'}
                            dontProceed = true;
                            return;

                        case {'e', 'E'}
                            % Issue error so that the current process stops.
                            error('%s already exists.', res);
                    end
                end
            end
            saveLog(me, res, dataFiles);
            
            if nargout>=1
                varargout{1} = res;
            end
        end
        
        function res = time_stamp(me, src)
            if nargin >= 2
                res = src;
            elseif me.opt.useCommitTimeStamp
                res = me.opt.timeStamp;
            else
                res = now;
            end
        end
        
        function res = datestr(me, varargin)
            res = datestr(me.time_stamp(varargin{:}), 'yyyymmddTHHMMSS');
        end
        
        function res = dateOnly(me, varargin)
            res = datestr(me.time_stamp(varargin{:}), 'yyyymmdd');
        end
        
        function res = timeOnly(me, varargin)
            res = datestr(me.time_stamp(varargin{:}), 'HHMMSS');
        end
        
        function res = hashesStr(me)
            res = funPrintfBridge('_', me.hash_short{:});
        end
        
        %% Diary file
        function varargout = diary(me, op, varargin)
            % 'on'          : Start keeping diary somewhere.
            % 'off'         : Stop keeping diary
            % 'del'         : Delete diary file
            % 'file'        : Return diary file name
            % 'moveTo', dst : Move diary file to dst.
            % 'moveAndLog', dst   : Move and name as dst, and save log.
            % 'moveAndName', args : Move and name using nameStr format, and save log.
            % 'moveToScr', postRunComment : Move and add postRunComment.
            
            switch op
                case 'on'
                    diary(me.opt.diaryFile);
                    fprintf('PsyGit: Keeping diary on %s\n\n', ...
                        me.opt.diaryFile);
                    me.opt.diaryOn = true;
                    
                case 'off'
                    fprintf('PsyGit: Closing diary on %s\n', ...
                        me.opt.diaryFile);
                    diary off;
                    me.opt.diaryOn = false;
                    
                case 'del'
                    diary off;
                    me.opt.diaryOn = false;
                    
                    if exist(me.opt.diaryFile, 'file')
                        delete(me.opt.diaryFile);
                    else
                        warning('%s doesn''t exist!\n', me.opt.diaryFile);
                    end
                    
                case 'file'
                    varargout{1} = me.opt.diaryFile;
                    
                case 'print_link'
                    fprintf('Click to view & edit %s\n\n', cmd2link(['edit(''' me.diary('file') ''')'], 'diary'));
                    
                case 'moveTo'
                    dst = varargin{1};
                    
                    if ~strcmp(me.opt.diaryFile, dst)
                        if ~exist(fileparts(dst), 'dir')
                            mkdir(fileparts(dst));
                        end
                        
                        if length(dst) > 250
                            dst = dst(1:250); 
                            warning('Too long file name - cutting at 250');
                        end
                        
                        movefile(me.opt.diaryFile, dst);
                        fprintf('PsyGit: Moved %s to %s\n\n', me.opt.diaryFile, dst);
                        me.opt.diaryFile = dst;
                    end
                    if me.opt.diaryOn
                        diary(me.opt.diaryFile);
                    end
                    
                case 'moveAndName'
                    me.diary('moveAndLog', me.nameStr(varargin{:}));
                    
                case 'moveToScr'
                    if isempty(varargin)
                        postRunComment = '';
                    else
                        postRunComment = varargin{1};
                    end
                    me.diary('moveAndLog', me.nameScr('diary', 'orig', '.txt', postRunComment));
                    
                case 'moveAndLog'
                    me.diary('moveTo', varargin{:});
                    me.saveLog(me.opt.diaryFile);
            end
        end
        
        %% Log file
        function saveLog(me, fileName, dataFiles, add_fields)
            % SAVELOG - Saves log file.
            %
            % saveLog(me, fileName)
            % saveLog(me, fileName, dataFiles={dataFile1, ...})
            % saveLog(me, fileName, dataFiles, {'field1', field1, ...})
            %
            % field should not be a multidimensional cell array or
            % an object, due to limitation in jsonlab.
            %
            % See also PsyGit.name
            
            if ~exist('add_fields', 'var'), add_fields = {}; end
            if ~exist('dataFiles', 'var'),  dataFiles  = {}; end
            
            switch me.opt.logFile
                case 'byFile'
                    [logPath, logName, logExt] = fileparts(fileName);
                    logFull = fullfile(logPath, [logName logExt '.log']);
                    
                case 'byFile_hide'
                    [logPath, logName, logExt] = fileparts(fileName);
                    logFull = fullfile(logPath, ['.' logName logExt '.log']);
                    
                case 'none'
                    return;
            end
            
            if ~exist(logPath, 'dir')
                mkdir(logPath);
            end
            
            % Fill obj, the struct to save in json format to the log file.
            obj.baseCallerName  = me.baseCallerName;
            obj.baseCallerPath  = me.baseCallerPath;
            obj.comment         = me.opt.comment;
            obj.timeStamp       = me.datestr; % should limit to commit timestamp
            obj.repos           = me.repos(:)';
            obj.hashes          = me.hashes(:)';
            obj.depPaths        = me.depPaths(:)';
            obj.dataFiles       = dataFiles(:)';
            obj.matlabSearchPath= path;
            obj = copyFields(obj, varargin2S(add_fields));
            
            %            
            savejson_cell('', obj, logFull);
            
            fprintf('Saved %s\n\n', logFull);
        end
        
%         function res = nameCheckbackLog(me) % Should load checkback info first.
%             res = me.name('_checkback', '_checkback', '.log');
%         end
        
        %% Dependent properties
        function res = get.n(me)
            res = length(me.repos);
        end
        
        function res = get.hash_short(me)
            res = cellfun(@(s) s(1:min(end, 7)), me.hashes, 'UniformOutput', false);
        end
        
        function res = get.baseCaller(me)
            if any(me.baseCallerName == '.')
                ix = find(me.baseCallerName == '.', 1, 'last');
                bName = [me.baseCallerName((ix+1):end) '.m'];
            elseif strcmp(me.baseCallerName, 'base')
                bName = 'base';
            else
                bName = [me.baseCallerName '.m'];
            end
            res = fullfile(me.baseCallerPath, bName);
        end
    end
    
    %% Static methods
    methods (Static)
        [gitHash, allOutput] = getHash(inDir)
        [anyChange, toAdd, toStage, toCommit, status, allOutput] = getStatus(inDir, verbose)
        
        [pth, nam, ext] = fun2path(src)
        repoDir = locateRepo(inDir)
        [repos, repoIx] = paths2repos(paths)
        bases = defaultBases
        
        [msg, committed, comment] = commit(repos, comment, addOpt, verbose)
        
        res = submodule_recur(varargin)
        res = foreach(repos_src, git_command, verbose)
        [repos, repo_ix, not_versioned] = dep_repos(bCaller_or_depPaths)
        [res_push, res_tag] = dep_push(bCaller, comment, varargin)
        res_pull = dep_pull(bCaller, varargin)
        varargout = dep_commit(bCaller, varargin)
        [res, repos] = dep_ignore(bCaller, op, arg, verbose)
        [res, repos] = dep_status(bCaller, verbose)
    end
end