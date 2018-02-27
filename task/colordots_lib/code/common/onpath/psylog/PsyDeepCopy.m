classdef PsyDeepCopy < matlab.mixin.Copyable
    % PsyDeepCopy: recursive copy of the reference tree.
    % matlab.mixin.Copyable: Shallow copy. Use only when no child is handle.
    %
    % Use Copyable only when the object has no Handle property at all.
    % Use Handle only when the object is never copied at all.
    % In short, use PsyDeepCopy whenever uncertain.
    %
    % In each PsyDeepCopy object, 'parent' should be the direct parent.
    % Avoid referring to multiple steps up the tree., 
    %   e.g., me.(me.parentName).(me.parent.parentName),
    % because it depends on the context the object is used.
    %
    % Refer to the root, or provide the required Handle as an argument.
    % Property name that should be passed on across multiple generations.
    %
    % Properties:
    % 
    % % Be careful not to include the handle to the root in
    % % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
    % % obj.(deepCpStructNames).() !
    % rootName            = '';
    % 
    % % Property name that indicates the parent. The name or the property
    % % itself can be empty.
    % %
    % % Be careful not to include the handle to the parent in
    % % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
    % % obj.(deepCpStructNames).() !
    % parentName          = '';
    % 
    % % Self identifier
    % tag                 = '';
    % 
    % %% Deep copied handles
    % % Row cell vector of names of the properties that are matlab.mixin.Copyable
    % % or its subclasses.
    % deepCpNames         = {};
    % 
    % % Properties that are cell arrays of Copyables.
    % deepCpCellNames     = {};
    % 
    % % Properties that are struct with fields of Copyables.
    % deepCpStructNames   = {};
    % 
    % %% Handles to delete on copy: handles that are neither root nor parent.
    % tempNames           = {};
    % tempCellNames       = {};
    % tempStructNames     = {};
    % 
    % %% The rest of the handles will be shallow-copied.
    
    properties
        % Property name that should be passed on across multiple generations.
        %
        % Be careful not to include the handle to the root in
        % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
        % obj.(deepCpStructNames).() !
        rootName            = '';
        
        % Property name that indicates the parent. The name or the property
        % itself can be empty.
        %
        % Be careful not to include the handle to the parent in
        % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
        % obj.(deepCpStructNames).() !
        parentName          = '';
        
        % Self identifier
        tag                 = '';
    
        %% Deep copied handles
        % Row cell vector of names of the properties that are matlab.mixin.Copyable
        % or its subclasses.
        deepCpNames         = {};
        
        % Properties that are cell arrays of Copyables.
        deepCpCellNames     = {};
        
        % Properties that are struct with fields of Copyables.
        deepCpStructNames   = {};
        
        %% Handles to delete on copy: handles that are neither root nor parent.
        tempNames           = {};
        tempCellNames       = {};
        tempStructNames     = {};
        
        %% The rest of the handles will be shallow-copied.
        
        %% Save behavior
        save_handle_ = false; % Saving handles combined with PsyLogs' copy-on-save wastes space.
    end
    
    
    methods
        function me2 = copyTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = [];   end
            
            me2 = linkTree(me, parent, root, 'copy');
        end
        
        
        function me2 = initTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = [];   end
            
            me2 = linkTree(me, parent, root, 'init');
        end
        
        
        function delTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = []; end
            
            linkTree(me, parent, root, 'del');
        end
        
        function me2 = copy_w_empty_handles(me)
            me2 = copy(me); % shallow copy first.

            if ~isempty(me2.rootName)
                try me2.(me2.rootName) = []; catch err, warning(err_msg(err)); end
            end
            if ~isempty(me2.parentName)
                try me2.(me2.parentName) = []; catch err, warning(err_msg(err)); end
            end
            
            for cc = me2.deepCpNames
                try me2.(cc{1}) = []; catch err, warning(err_msg(err)); end
            end
            for cc = me2.deepCpCellNames
                try me2.(cc{1}) = cell(size(me2.(cc{1}))); catch err, warning(err_msg(err)); end
            end
            for cc = me2.deepCpStructNames
                try
                    if isstruct(me2.(cc{1}))
                        f   = fieldnames(me2.(cc{1}));
                        n_f = length(f);

                        me2.(cc{1}) = cell2struct(cell([n_f, size(me2.(cc{1}))]), f, 1);
                    end
                catch err, 
                    warning(err_msg(err)); 
                end
            end
            
            for cc = me2.tempNames
                try me2.(cc{1}) = []; catch err, warning(err_msg(err)); end
            end
            for cc = me2.tempCellNames
                try me2.(cc{1}) = cell(size(me2.(cc{1}))); catch err, warning(err_msg(err)); end
            end
            for cc = me2.tempStructNames
                try
                    if isstruct(me2.(cc{1}))
                        f   = fieldnames(me2.(cc{1}));
                        n_f = length(f);

                        me2.(cc{1}) = cell2struct(cell([n_f, size(me2.(cc{1}))]), f, 1);
                    end
                catch err, 
                    warning(err_msg(err)); 
                end
            end
        end
        
        function me2 = linkTree(me, parent, root, mode)
            % me2 = linkTree(me, parent, root, mode)
            %
            %  mode
            %--------------------------------------------------------------------
            % 'copy': Make a new copy and link new parents & root, recursively.
            %
            % 'init': Link existing parents & root recursively without copying any.
            %
            % 'del' : Delete objects in the entire tree, starting from the leaves.
            
            
            %% Whether to copy me
            switch mode
                case {'copy'}
                    me2 = copy(me);
                    
                case {'init', 'del'}
                    me2 = me;
                    
                otherwise
                    error('Unsupported mode: %s', mode);
            end
            
            
            %% Linking root & parent
            if strcmp(me.rootName, me.tag)
                root = me2; 
            end
            
            if ~isempty(me.parentName)
                if isequal(me2.(me.parentName), me)
                    me2.(me.parentName) = me2;
                    
                elseif isempty(parent)
                    error('Parent is not given, although parentName is not empty!');
                    
                else
                    me2.(me.parentName) = parent;
                end
            end
            
            if ~isempty(me.rootName)
                if isequal(me2.(me.parentName), me)
                    me2.(me.rootName) = me2;
                    
                elseif isempty(root)
                    error('Root is not given, although rootName is not empty!');
                    
                else
                    me2.(me.rootName) = root;
                end
            end
            
            
            %% Recursive operation
            for cDeepCp = me2.deepCpNames
                if isempty(cDeepCp{1}) || isempty(me2.(cDeepCp{1})), continue; end
                if isa(me2.(cDeepCp{1}), 'PsyDeepCopy')                 
                    % PsyDeepCopy: recursive copy of the reference tree.
                    me2.(cDeepCp{1}) = linkTree(me2.(cDeepCp{1}), ...
                                                me2, root, mode); 
                else
                    try
                        % matlab.mixin.Copyable: Shallow copy. 
                        % Use only when no child is handle.
                        me2.(cDeepCp{1}) = copy(me2.(cDeepCp{1})); 
                    catch
                        error(['A nonempty property .%s is neither PsyDeepCopy ' ...
                               'nor matlab.mixin.Copyable!'], cDeepCp{1});
                    end
                end
            end

            for cCell = me2.deepCpCellNames
                for iCell = 1:length(me2.(cCell{1}))
                    if isempty(me2.(cCell{1}){iCell}), continue; end
                    if isa(me2.(cDeepCp{1}), 'PsyDeepCopy')                 
                        % PsyDeepCopy: recursive copy of the reference tree.
                        me2.(cCell{1}){iCell} = linkTree(me2.(cCell{1}){iCell}, ...
                                                         me2, root, mode);
                    else
                        try
                            % matlab.mixin.Copyable: Shallow copy. 
                            % Use only when no child is handle.
                            me2.(cCell{1}){iCell} = copy(me2.(cCell{1}){iCell});
                        catch
                            error(['A nonempty property .%s{%d} is neither PsyDeepCopy ' ...
                                   'nor matlab.mixin.Copyable!'], cCell{1}, iCell);
                        end
                    end
                end
            end

            for cStruct = me2.deepCpStructNames
                if isempty(me2.(cStruct{1})), continue; end
                for cField = fieldnames(me2.(cStruct{1}))'
                    if isempty(me2.(cStruct{1}).(cField{1})), continue; end
                    if isa(me2.(cStruct{1}).(cField{1}), 'PsyDeepCopy')                 
                        me2.(cStruct{1}).(cField{1}) = linkTree(me2.(cStruct{1}).(cField{1}), ...
                                                                me2, root, mode);
                    else
                        try
                            me2.(cStruct{1}).(cField{1}) = copy(me2.(cStruct{1}).(cField{1}));
                        catch
                            error(['A nonempty property .%s.%s is neither PsyDeepCopy ' ...
                                   'nor matlab.mixin.Copyable!'], cStruct{1}, cField{1});
                        end
                    end
                end
            end
            
            
            %% Postprocess
            switch mode
                case 'copy'
                    % Delete temporary handles, if copyTree.
                    for cProp = me2.tempNames
                        delete(me2.(cProp{1}));
                    end
                    
                    for cCell = me2.tempCellNames
                        for iCell = 1:length(me2.(cCell{1}))
                            delete(me2.(cCell{1}){iCell});
                        end
                    end
                    
                    for cStruct = me2.tempStructNames
                        for cField = fieldnames(me2.(cStruct{1}))'
                            delete(me2.(cStruct{1})(cField{1}));
                        end
                    end
                    
                case 'del'
                    % Delee me, if delTree.
                    delete(me);
            end
        end
        
%         function me2 = copy(me, ignoreError)
%             
%             % Shallow copy
%             me2 = copy@matlab.mixin.Copyable(me);
%             
% %             me2 = eval(class(me));
% %             if nargin < 2, ignoreError = true; end
% 
% %             % Copy root and parent first
% %             if ~isempty(me.rootName)
% %                 if ignoreError
% %                     try me2.(me.rootName)   = me.(me.rootName);   catch LE, warning(LE.message); end
% %                 else
% %                     me2.(me.rootName)   = me.(me.rootName);
% %                 end
% %             end
% %             if ~isempty(me.parentName)
% %                 if ignoreError
% %                     try me2.(me.parentName) = me.(me.parentName); catch LE, warning(LE.message); end
% %                 else
% %                     me2.(me.parentName) = me.(me.parentName);
% %                 end
% %             end
%             
% %             % Copy the rest
% %             if ignoreError
% %                 try
% %                     me2 = copyFields(me2, me, {}, true);
% %                 catch LE
% %                     warning(LE.message);
% %                 end
% %             else
% %                 me2 = copyFields(me2, me);
% %             end
%         end
        
        %% ----- Save -----
        function me2 = saveobj(me)
            if me.save_handle_
                me2 = me;
            else
%                 disp(['Saving ' me.tag]); % DEBUG
%                 if strcmp(me.tag, 'MDDTrial') % DEBUG
%                     keyboard;
%                 end
                me2 = copy_w_empty_handles(me);
            end
        end
        
        %% ----- Etc -----
        function disp(me)
            try
                disp@handle(me);
            catch err_disp
                warning('Error during disp(%s_object):', class(me));
                warning(err_msg(err_disp));
            end
        end
        
    end
end