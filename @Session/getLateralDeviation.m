function [lat_devCOMPLETE,lat_devFF,lat_dev_orderedCOMPLETE,lat_dev_ordered] =...
    getLateralDeviation(Ses,ind)
% function [lat_devFF,lat_devCOMPLETE,offset,lat_dev_ordered,lat_dev_orderedCOMPLETE] = get_lateral_deviation(Data)
% Calculates maximum lateral deviation normalized in relation to the baseline
% for a given trajectory
% (C) F. Barban, 2017


if nargin<2
    ind='all';
end


if ~isnumeric(ind) && strcmp(ind,'all')
    ind=1:Ses.LinkedTask.NTrials;
end

lat_devFF=zeros(1,sum(~Ses.isCatchTrial(ind)));
Indexlat_devFF=1;
lat_devCOMPLETE=zeros(1,length(ind));
MovIndex=zeros(1,length(ind));
BadTrial=logical(lat_devCOMPLETE);

task=Ses.LinkedTask;
% if any(ismember(task.TrialProtocolTable.Properties.VariableNames,'End_Target'))
%     STR='End_Target';
% elseif any(ismember(task.TrialProtocolTable.Properties.VariableNames,'True_End_Target'))
%     STR='True_End_Target';
% end
Targets=Ses.getTargetsPerTrial;
%% Find baseline values
BaseInd=(Ses.LinkedTask.ChangeBlockIndex(1)+1):Ses.LinkedTask.ChangeBlockIndex(2);
BaseUniqueMov=Ses.getUniqueMovement(BaseInd);
NUniqueMov=length(unique(BaseUniqueMov));
BaselineMeanLatDev=zeros(1,NUniqueMov);

%% If Ses.LateralDeviation is empty, evauates the lateral deviation and saves it in the right field

if isempty(Ses.LateralDeviation)
    j=1;
    for i=1:Ses.LinkedTask.NTrials
        
        actTarget=Targets(i,2);
        strtTarget=Targets(i,1);
        actTargetCoord=[task.TargetTable(actTarget,:).X_GLOBAL task.TargetTable(actTarget,:).Y_GLOBAL]./100;
        strTtargetCoord=[task.TargetTable(strtTarget,:).X_GLOBAL task.TargetTable(strtTarget,:).Y_GLOBAL]./100;
        
        thetraj = Ses.getMovement(i);
        direz=(actTargetCoord-thetraj(1,:));
        thetraj=thetraj-thetraj(1,:);
        dist=norm(direz);
        direz=direz./(dist);
        
        n_direz = [-direz(2) direz(1)];
        if isempty(thetraj)
            BadTrial(i)=true;
            continue;
        end
       
        t_norm = n_direz*thetraj';
        %
        Ind=Ses.getMovementIndexes(i);
        [~,~,s]=Ses.getSpeed(i);
        s=s-Ind(1);
        lat_devCOMPLETE(j) = mean(t_norm(-50+s:s+50));
        
        %% Other equivalents indexes
%         [~,I]=max(abs(t_norm));
%         lat_devCOMPLETE(j) = t_norm(I);
        
%         cm5Index=find(direz*thetraj'>.9*dist,1);
%         if isempty(cm5Index)
%             cm5Index=floor(length(thetraj)/2);
%         end
%         lat_devCOMPLETE(j) = t_norm(cm5Index);
        
        %% % % debug stuff
        % %             hold on
        % %             plot(thetraj(cm5Index,1),thetraj(cm5Index,2),'*')
        % %                     plot(t_norm)
        % %                     hold on
        % %                     plot(cm5Index,t_norm(cm5Index),'*')
        % %                     hold off
        %         end
        j=j+1;
    end
    %     lat_devFF=Ses.LateralDeviation(~Ses.isCatchTrial);
    
    %% Baseline normalization
    BaseLineLatDev=lat_devCOMPLETE(BaseInd);
    for i=unique(BaseUniqueMov)'
        BaselineMeanLatDev(i)=mean(BaseLineLatDev(BaseUniqueMov==i));
    end
    
    UniqueMovAll=Ses.getUniqueMovement;
    for i=1:length(BaselineMeanLatDev)
        lat_devCOMPLETE(UniqueMovAll==i)=lat_devCOMPLETE(UniqueMovAll==i)-BaselineMeanLatDev(i);
    end
    %% Saving
    
    Ses.LateralDeviation=lat_devCOMPLETE;
    if Ses.LinkedTask.ErrorLims(2)<max(lat_devCOMPLETE)*1.1
        Ses.LinkedTask.ErrorLims(2)=max(lat_devCOMPLETE)*1.1;
    end
    if Ses.LinkedTask.ErrorLims(1)>min(lat_devCOMPLETE)*1.1
        Ses.LinkedTask.ErrorLims(1)=min(lat_devCOMPLETE)*1.1;
    end
end




switch nargout
    case 1
        lat_devCOMPLETE=Ses.LateralDeviation(ind);
    case 2
        lat_devCOMPLETE=Ses.LateralDeviation(ind);
        lat_devFF=lat_devCOMPLETE(~Ses.isCatchTrial);
    case 3
        lat_devCOMPLETE=Ses.LateralDeviation(ind);
        lat_devFF=lat_devCOMPLETE(~Ses.isCatchTrial(ind));
        MovIndex=Ses.getUniqueMovement(ind);
        for l=1:length(Ses.LinkedTask.UniqueMovements)
            lat_dev_orderedCOMPLETE{1,l}=lat_devCOMPLETE(MovIndex==l);
            lat_dev_orderedCOMPLETE{2,l}=ind(MovIndex==l);

        end
    case 4
        lat_devCOMPLETE=Ses.LateralDeviation;
        lat_devFF=lat_devCOMPLETE(~Ses.isCatchTrial);
        MovIndex=Ses.getUniqueMovement(ind);
        for l=1:length(Ses.LinkedTask.UniqueMovements)
            lat_dev_orderedCOMPLETE{1,l}=lat_devCOMPLETE(MovIndex==l);
            lat_dev_orderedCOMPLETE{2,l}=ind(MovIndex==l);
            MovIndNoCath=MovIndex(~Ses.isCatchTrial(ind));
            lat_dev_ordered{1,l}=lat_devFF(MovIndNoCath==l);
            lat_dev_ordered{2,l}=ind(MovIndNoCath==l);

        end
end
%%

