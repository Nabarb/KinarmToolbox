classdef Session < handle
    %% Session class
    properties
        IntrestingData
        %c3d
        LinkedTask
        LinkedSubject
        PausesIndex
        Hand;
        LateralDeviation;
        
        
    end
    
    methods
        function Ses = Session(c3d,task,sub)
            
            activeArm=lower(c3d(1).EXPERIMENT.ACTIVE_ARM);
            Ses.Hand=[upper(activeArm(1)) activeArm(2:end)];
%             Ses.c3d=c3d;
            Ses.LinkedTask=task;
            Ses.LinkedSubject=sub;
            Ses.LateralDeviation=[];
            c3dNames={
                [ Ses.Hand '_HandX']
                [ Ses.Hand '_HandY']
                [ Ses.Hand '_HandXVel']
                [ Ses.Hand '_HandYVel']
                [ Ses.Hand '_HandXAcc']
                [ Ses.Hand '_HandYAcc']
                [ Ses.Hand '_Hand_ForceCMD_X']
                [ Ses.Hand '_Hand_ForceCMD_Y']
                [ Ses.Hand '_L1Ang']
                [ Ses.Hand '_L2Ang']
                [ Ses.Hand '_L1Vel']
                [ Ses.Hand '_L2Vel']
                [ Ses.Hand '_L1Acc']
                [ Ses.Hand '_L2Acc']
                [ Ses.Hand '_M1TorCMD']
                [ Ses.Hand '_M2TorCMD']
                [ Ses.Hand '_M1TorFRC']
                [ Ses.Hand '_M2TorFRC']
                [ Ses.Hand '_FS_ForceX']
                [ Ses.Hand '_FS_ForceY']
                [ Ses.Hand '_FS_ForceZ']
                [ Ses.Hand '_FS_TorqueX']
                [ Ses.Hand '_FS_TorqueY']
                [ Ses.Hand '_FS_TorqueZ']
                [ Ses.Hand '_FS_TimeStamp']
                'EVENTS'
                'TRIAL'
                };
            
            for j=1:length(c3d)
                for i=1:length(c3dNames)
                    Ses.IntrestingData(j).(c3dNames{i})=c3d(j).(c3dNames{i});
                end
            end
            
            Ses.chunkdata;
            Ses.LinkedTask.CatchIndex=Ses.isCatchTrial;
        end % Session
        
        function [speed,pkspeed,pkind]=getSpeed(Ses,ind)
            %% Session methods for getting the speed profile
            % [speed,pkspeed,pkind]=getSpeed(Ses,ind)
            % returns the speed(vector), the peak spead value ancd the
            % index of the trials specified in ind. Default value for ind
            % is 'all', in this case the computation is done on all
            % entries.
            
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            if isscalar(ind)
                speed = sqrt(Ses.IntrestingData(ind).Right_HandXVel.^2 + Ses.IntrestingData(ind).Right_HandYVel.^2);
                [pkspeed,pkind]=max(speed);
            else
                speed=cell(1,length(ind));
                pkspeed=zeros(1,length(ind));
                pkind=pkspeed;
                for j=ind
                    speed{j} = sqrt( Ses.IntrestingData(j).Right_HandXVel.^2+ Ses.IntrestingData(j).Right_HandYVel.^2);
                    [pkspeed(j),pkind(j)]=max(speed{j});
                end
            end
            
            
            
            
        end %getSpeed
        
        function initValue(obj,Name,Value)
            obj.(Name)=Value;
        end %initValue
        
        function TP=getTP(Ses,ind)
            %% Returns a list with the trial protocol for every trial
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            
            TrialsInfo=cat(1,Ses.IntrestingData.TRIAL);
            TP=cat(1,TrialsInfo.TP);
            TP=TP(ind);
        end %getTP
        
        function List=isCatchTrial(Ses,ind)
            %% Returns an array of logicals with true when the trial is catch trial
            
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            
%             BLmatrixNames=Ses.LinkedTask.BlockTable.Names;
%             CTCol=ismember(BLmatrixNames,'CATCH_TP_LIST');
             TP=Ses.getTP;
            CatchTrialsProtocol=unique(cat(1,Ses.LinkedTask.BlockTable.CATCH_TP_LIST{:}));
            List=logical(ismember(TP,CatchTrialsProtocol));
            
            if strcmp(Ses.LinkedTask.MovType,'Both')
                tmp=List;
                List(1:2:end*2)=tmp;
                List(2:2:end+1)=tmp;
            end
            List=List(ind);
            
        end %isCatchTrial
        
        function NewList=getTargetsPerTrial(Ses,ind)
            
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            TPTable=Ses.LinkedTask.TrialProtocolTable;
            PossibleEndTargetStrings={'True_End_Target','End_Target'};
            PossibleStrtTargetStrings={'Start_Target'};

            EndTargetStr=PossibleEndTargetStrings{ismember(PossibleEndTargetStrings,TPTable.Properties.VariableNames)};
            StrtTargetStr=PossibleStrtTargetStrings{ismember(PossibleStrtTargetStrings,TPTable.Properties.VariableNames)};
            List=[TPTable.(StrtTargetStr),...
                TPTable.(EndTargetStr)];
            switch Ses.LinkedTask.MovType
                case 'Both'
                    NewList=zeros(2*length(Ses.getTP(ind)),2);
                    NewList(1:2:end,:)=List(Ses.getTP(ind),:);
                    NewList(2:2:end,:)=fliplr(List(Ses.getTP(ind),:));
                case 'CenterOut'
                    NewList=List(Ses.getTP(ind),:);
                case 'OutCenter'
                    NewList=fliplr(List(Ses.getTP(ind),:));
            end
            
        end %getTargetsPerTrial
        
        function Mov=getMovement(Ses,ind)
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            
            [~,~,Mov]=Ses.getMovementIndexes(ind);
            
            if isscalar(ind)
                Mov=Mov{:};
            end
        end %getMovement
        
        [T,S]=getEventTime(Ses,EventName,ind)
        
        [lat_devCOMPLETE,lat_devFF,lat_dev_orderedCOMPLETE,lat_dev_ordered] =...
            getLateralDeviation(Ses,ind)
        
        plotTrial(Ses,varargin)
        
        PlotTargetAnimation(Ses)
        [CenterOutIndex,OutCenterIndex,Traj]=getMovementIndexes(Ses,ind)
        
        plotLateralDeviation(Ses,ax)
        G=ForceDistribution(Ses,ind)
        function plotErrorForceScatter(Ses,ind)
            
            if nargin<2
                ind='all';
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            G=Ses.ForceDistribution(ind);
            [Err]=Ses.getLateralDeviation(ind);
            plot(Err,G,'*')
            ylabel('Viscosity')
            xlabel('Error')
        end %plotErrorForceScatter
        
        %         plotTrajectory()
        
        Data=chunkdata(Ses)
        
        function UniqueMov=getUniqueMovement(Ses,ind)
            if nargin<2
                ind='all';
            end
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            UniqueMov=zeros(length(ind),1);
            j=1;
            for i=ind
                Targets=Ses.getTargetsPerTrial(i);
                [~,UniqueMov(j)]=ismember(Targets,Ses.LinkedTask.UniqueMovements,'rows');
                j=j+1;
            end
            
        end %getUniqueMovement
        
        [MaxDev,Resp]=getPulseDeviation(Ses,ind,PulseTpNumber)
        
        function plotPulseDeviation(Ses,ind)
            
            PulseTpNumber=25:30;
            if nargin<2
                ind=find(ismember(Ses.getTP,PulseTpNumber));
            end
            
            
            if ~isnumeric(ind) && strcmp(ind,'all')
                ind=1:Ses.LinkedTask.NTrials;
            end
            
            [MaxDev,Resp]=getPulseDeviation(Ses,ind,25:30);
            Title=Ses.LinkedTask.TaskProtocol;
            
            Color=rand(3,numel(PulseTpNumber));
            
            figure
            title(Title);
            hold on
            j=1;
            for i=ind'
                plot(Resp(j,:),'Color',Color(:,Ses.getTP(i)-(PulseTpNumber(1)-1)));
                j=j+1;
            end
            
            t=[1:length(MaxDev)]';
            figure
            title(Title);            
            hold on
            k=1;
            ChangeBlockIndex=Ses.LinkedTask.ChangeBlockIndex;
            for j=unique(Ses.getTP(ind))'
                for h=1:(length(ChangeBlockIndex)-1)
                    SelectBlockIndex=and(ind>ChangeBlockIndex(h),ind<ChangeBlockIndex(h+1));
                    index=and(Ses.getTP(ind)==j,SelectBlockIndex);
                    plot(t(index),MaxDev(index),'*','Color',Color(:,k) )
                    p = polyfit(t(index),MaxDev(index),1);
                    yfit=p(1) * t(index) + p(2);
                    plot(t(index),yfit, 'Color',Color(:,k));
                end
                k=k+1;
                %         tmp(k,:)=MaxDev(index);
            end
            
            
            
            
            
            
        end %plotPulseDeviation
        
        function Struc=saveobj(Ses)
            FN=fieldnames(Ses);
            FN=FN((cellfun(@isempty,strfind(FN,'Linked'))));
            for i=1:length(FN)
                CurrField=Ses.(FN{i});
                Struc.(FN{i})=CurrField;
            end
        end %save        
    end
    
end

