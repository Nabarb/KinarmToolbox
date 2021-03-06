classdef Task < handle
    %% Task Class
    % Contains generical informtions about the task
    
    properties
        Fs
        NTrials
        TaskProtocol
        ID
        MovType
        UniqueMovements
        EventsDefinitions
        
        TargetTable
        LoadTable
        TrialProtocolTable
        BlockTable
        ChangeBlockIndex
        CatchIndex;
        
        TrialsType;
        ErrorLims;
    end
    
    properties(Transient = true)
        LinkedExperiment
    end
    
    methods
        function Tsk = Task(varargin)
            
            if (nargin == 1) && isstruc(varargin{1})
                Struc=varargin{1};
                Tsk=Task;
                FN=fieldnames(Tsk);
                FN=FN((cellfun(@isempty,strfind(FN,'Linked'))));
                for i=1:length(FN)
                    Tsk.(FN{i})=Struc.(FN{i});
                end
            elseif (nargin == 2)
                c3d=varargin{1};
                MovementType=varargin{2};
                %% Movement Type
                Tsk.MovType = MovementType;
                
                %% Sampling Frequency
                Tsk.Fs =  c3d(1).ANALOG.RATE;
                %% NTrials
                Tsk.NTrials = length(c3d);
                
                %% Task Protocol
                Tsk.TaskProtocol=c3d(1).EXPERIMENT.TASK_PROTOCOL;
                Tsk.ID=c3d(1).EXPERIMENT.TASK_PROTOCOL_CODE;
                
                %% Target Table
%                 usedtarget=c3d(1).TARGET_TABLE.USED;
%                 Tsk.TargetTable = [c3d(1).TARGET_TABLE.X_GLOBAL(1:usedtarget)...
%                     c3d(1).TARGET_TABLE.Y_GLOBAL(1:usedtarget)];
                
                FieldName=fieldnames(c3d(1).TARGET_TABLE);
                usedtarget=c3d(1).TARGET_TABLE.USED;
                index=or(or(strcmp(FieldName,'COLUMN_ORDER'),...
                    strcmp(FieldName,'DESCRIPTIONS')),...
                    strcmp(FieldName,'USED'));
                FieldName=FieldName(~index);
                Table=zeros(usedtarget,length(FieldName));
                for j=1:length(FieldName)
                    tmp=c3d(1).TARGET_TABLE.(FieldName{j});
                    Table(:,j) = tmp(1:usedtarget);
                end
                Tsk.TargetTable = array2table(Table,'VariableNames',FieldName);
                
                %% Loads Table
                FieldName=fieldnames(c3d(1).LOAD_TABLE);
                UsedLoads=c3d(1).LOAD_TABLE.USED;
                index=or(or(strcmp(FieldName,'COLUMN_ORDER'),...
                    strcmp(FieldName,'DESCRIPTIONS')),...
                    strcmp(FieldName,'USED'));
                FieldName=FieldName(~index);
                Table=zeros(UsedLoads,length(FieldName));
                for j=1:length(FieldName)
                    tmp=c3d(1).LOAD_TABLE.(FieldName{j});
                    Table(:,j) = tmp(1:UsedLoads);
                end
                Tsk.LoadTable = array2table(Table,'VariableNames',FieldName);
                
                %% Trial Protocol
                FieldName=fieldnames(c3d(1).TP_TABLE);
                UsedTP=c3d(1).TP_TABLE.USED;
                index=or(or(strcmp(FieldName,'COLUMN_ORDER'),...
                    strcmp(FieldName,'DESCRIPTIONS')),...
                    strcmp(FieldName,'USED'));
                FieldName=FieldName(~index);
                Table=zeros(UsedTP,length(FieldName));
                for j=1:length(FieldName)
                    tmp=c3d(1).TP_TABLE.(FieldName{j});
                    Table(:,j) = tmp(1:UsedTP);
                end
                Tsk.TrialProtocolTable =array2table(Table,'VariableNames',FieldName);
                
                
                
                %% Block Table
                FieldName=fieldnames(c3d(1).BLOCK_TABLE);
                UsedBlocks=c3d(1).BLOCK_TABLE.USED;
                index=or(or(strcmp(FieldName,'COLUMN_ORDER'),...
                    strcmp(FieldName,'DESCRIPTIONS')),...
                    strcmp(FieldName,'USED'));
                FieldName=FieldName(~index);
                Table=cell(UsedBlocks,length(FieldName));
                for j=1:length(FieldName)
                    tmp=c3d(1).BLOCK_TABLE.(FieldName{j});
                    if  isempty(tmp), continue, end
                    if ~iscell(tmp)
                        if  iscolumn(tmp), Table(:,j) = mat2cell(tmp(1:UsedBlocks,:),ones(1,UsedBlocks));end
                        if ~iscolumn(tmp), Table(:,j) = mat2cell(tmp(:,1:UsedBlocks)',ones(1,UsedBlocks));end
                    else
                        if  iscolumn(tmp), Table(:,j) = tmp(1:UsedBlocks,:);end
                        if ~iscolumn(tmp), Table(:,j) = tmp(:,1:UsedBlocks);end
                    end
                end
                Tsk.BlockTable =array2table(Table,'VariableNames',FieldName);
                
                % Parsing some elements of the table
                
                Tsk.ParseBlockList;
                
                
                %% Unique Movements
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                % Center Out movement
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                EndTargetStrings={'True_End_Target','End_Target'};
                ActString=EndTargetStrings{ismember(EndTargetStrings,fieldnames(c3d(1).TP_TABLE))};
                END_TARGET_LIST=c3d(1).TP_TABLE.(ActString);
                
                if strcmp(MovementType,'CenterOut')||strcmp(MovementType,'Both')
                    if strcmp(MovementType,'Both')
                        END_TARGET(1:2:UsedTP*2) = END_TARGET_LIST(1:UsedTP);
                        START_TARGET(1:2:UsedTP*2) = c3d(1).TP_TABLE.Start_Target(1:UsedTP);
                        
                    else
                        END_TARGET(1:UsedTP) = END_TARGET_LIST(1:UsedTP);
                        START_TARGET(1:UsedTP) = c3d(1).TP_TABLE.Start_Target(1:UsedTP);
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                %  Out Center Movement
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                if strcmp(MovementType,'OutCenter')||strcmp(MovementType,'Both')
                    if strcmp(MovementType,'Both')
                        END_TARGET(2:2:UsedTP*2) = c3d(1).TP_TABLE.Start_Target(1:UsedTP);
                        START_TARGET(2:2:UsedTP*2) = END_TARGET_LIST(1:UsedTP);
                    else
                        END_TARGET(1:UsedTP) = c3d(1).TP_TABLE.Start_Target(1:UsedTP);
                        START_TARGET(1:UsedTP) = END_TARGET_LIST(1:UsedTP);
                    end
                    
                end
                
                tmp=[START_TARGET' END_TARGET'];
                Tsk.UniqueMovements=unique(tmp,'rows');
                
                %% Events Definition
                Tsk.EventsDefinitions=deblank(c3d(1).EVENT_DEFINITIONS.LABELS);
                %%
                Tsk.ErrorLims=[0 0];
                
                %% Trials description structure
                Tsk.TrialsType=struct2table(c3d(1).TrialsType);
                Tsk.TrialsType.IsCatchTrial=all(ismember(cat(1,Tsk.TrialsType.IndexList{:}),unique(cat(2,Tsk.BlockTable.CATCH_TP_LIST{:}))),2);
            end
        end % Task
        
        ParseBlockList(Tsk)
        
        Ax=plotPerTrialData(Tsk,varargin)
        
    end
    
    methods 
        function setLinkedExp(Tsk,Exp)
            if numel(Tsk) == 1
                Tsk.LinkedExperiment = Exp;
            else
                setLinkedExp(Tsk(1:end-1),Exp);
                setLinkedExp(Tsk(end),Exp);
            end
        end
        
        function tsk = saveobj(tsk)
            fprintf(1,'Task: Saving data.\n');
        end
        
    end
    
end

