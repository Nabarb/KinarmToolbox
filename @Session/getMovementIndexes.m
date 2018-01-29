function [CenterOutIndex,OutCenterIndex,Traj]=getMovementIndexes(Ses,ind)

if nargin<2
    ind='all';
end


if ~isnumeric(ind) && strcmp(ind,'all')
    ind=1:Ses.LinkedTask.NTrials;
end

NTrials=Ses.LinkedTask.NTrials;
MovType=Ses.LinkedTask.MovType;
Targets=Ses.getTargetsPerTrial;
CenterOutIndex = zeros(length(ind),2)*NaN;
OutCenterIndex = CenterOutIndex;

for i=1:length(ind)
    j=ind(i);
    TrajX_=Ses.IntrestingData(j).([ Ses.Hand '_HandX']);
    TrajY_=Ses.IntrestingData(j).([ Ses.Hand '_HandY']);
    tol=.1;
    [speed,pkspeed,pkind] = Ses.getSpeed(j);
    
    [~,EnterTargetEventSample] = Ses.getEventTime('ENTER_TARGET',j);
    [~,ExitCenterEventSample]  = Ses.getEventTime('EXIT_CENTER',j);
    [~,FalseStartEventSample]  = Ses.getEventTime('FALSE_START',j);
    
    % if a false start is present in the data, only consider the data
    % after it.
    if ~isempty(FalseStartEventSample)
        EnterTargetEventSample = EnterTargetEventSample(EnterTargetEventSample>FalseStartEventSample(end))-FalseStartEventSample(end);
        ExitCenterEventSample  = ExitCenterEventSample(ExitCenterEventSample>FalseStartEventSample(end))-FalseStartEventSample(end);
        speed=speed(FalseStartEventSample(end):end);
    end
    ExitCenterEventSample=round(ExitCenterEventSample);
    EnterTargetEventSample=round(EnterTargetEventSample);
    if strcmp(MovType,'Both'), IntersectNum=4; else, IntersectNum=2; end
    
    while true
        ttol=(pkspeed*tol+speed(end)*(1-tol));
        StartInd = ExitCenterEventSample- find(speed(ExitCenterEventSample:-1:1) < ttol,1,'first');
        
        intersect=StartInd+find(diff(sign(speed(StartInd-10:end)-ttol),1));
        tol=tol+.01;
%                             plot(speed)
%                             hold on
%                             a=plot(ttol*ones(1,length(speed)));
%                             hold off
        if length(intersect)>IntersectNum-1
            break;
        elseif tol<1
            tol=.5;
            ttol=pkspeed*tol;
            intersect=StartInd+find(diff(sign(speed(StartInd-10:end)-ttol),1));
            
            break;
        end
    end
    
    %     intersect=ExitCenterEventSample+find(diff(sign(speed(ExitCenterEventSample:end)-ttol),1));
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Center Out movement
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if strcmp(MovType,'CenterOut')||strcmp(MovType,'Both')
        Acc=diff(speed);
        StartInd =  intersect(1)-find(diff(sign(Acc(intersect(1):-1:1))),1,'first');
        if isempty(StartInd)
            StartInd =  find(speed(1:ExitCenterEventSample) < ttol*.2,1,'last');
        end
        if isempty(StartInd)
            StartInd =  1;
        end
        EndInd = EnterTargetEventSample - 1+find(diff(sign(Acc(EnterTargetEventSample:end))),1,'first');
        if isempty(EndInd)
            EndInd = EnterTargetEventSample - 1 + find(speed(EnterTargetEventSample:end) > ttol*.2,1,'last');
        end
        if isempty(EndInd)
            EndInd = length(speed);
        end
        CenterOutIndex(i,:) = [StartInd EndInd];
        TrajX = TrajX_(StartInd:EndInd);
        TrajY = TrajY_(StartInd:EndInd);
        
        if strcmp(MovType,'Both')
            Traj{i*2-1} = [TrajX TrajY];
            
        else
            Traj{i} = [TrajX TrajY];
        end
    end
    
    
    
    
    %
    %         P=1:length(speed);
    %         plot(speed)
    %
    %         hold on
    %         plot(P(StartInd:EndInd),speed(StartInd:EndInd))
    %
    %         plot(ttol*ones(1,length(speed)));
    %     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Out Center Movement
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if strcmp(MovType,'OutCenter')||strcmp(MovType,'Both')
        
        EndCenterOut = EnterTargetEventSample + find(speed(EnterTargetEventSample:end) < ttol,1,'first');
        StartInd =  intersect(3)-find(diff(sign(Acc(intersect(3):-1:1))),1,'first');
        EndInd =StartInd -1 + find(speed(StartInd:end) > speed(StartInd),1,'last');
        OutCenterIndex(i,:) = [StartInd EndInd];
        
        TrajX = TrajX_(StartInd:EndInd);
        TrajY = TrajY_(StartInd:EndInd);
        
        if strcmp(MovType,'Both')
            Traj{i*2} = [TrajX TrajY];
            
        else
            Traj{i} = [TrajX TrajY];
            
            
        end
        
    end
    
    
    %         plot(P(StartInd:EndInd),speed(StartInd:EndInd))
    %         hold off
end
