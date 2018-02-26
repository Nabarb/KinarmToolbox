function plotTrajectory(Ses,ax,ind)


switch nargin
    case 1
        ind='all';
        figure('Color',[1 1 1]);
        ax=gca;
        pbaspect(ax,[3,2,1])
    case 2
        if isgraphics(ax)
            ind='all';
        else
            ind=ax;
            figure('Color',[1 1 1]);
            ax=gca;
            pbaspect(ax,[3,2,1])
        end
end
if ~isnumeric(ind) && strcmp(ind,'all')
    ind=1:Ses.LinkedTask.NTrials;
end

CenterOutIndex=Ses.getMovementIndexes(ind);
TP=Ses.getTP(ind);
ColLine=rand(3,size(Ses.LinkedTask.TrialProtocolTable,1));
ColEv=rand(3,numel(Ses.LinkedTask.EventsDefinitions));

hold(ax,'on');
Mov=Ses.getMovement(ind);
Legend={''};
PLegend=[];

if isscalar(ind)
    Mov={Mov};
end

for i=1:length(ind)
    
    T=floor(Ses.IntrestingData(ind(i)).EVENTS.TIMES*1000)-CenterOutIndex(i,1);
    TimeIndex=and(T>0,T<length(Mov{i}));
    Ev=deblank(Ses.IntrestingData(ind(i)).EVENTS.LABELS(TimeIndex));
    
%     plot(ax,Mov{i}(:,1),Mov{i}(:,2),'Color',ColLine(:,TP(i)));
    plot(ax,Mov{i}(:,1)-Mov{i}(1,1),Mov{i}(:,2)-Mov{i}(1,2),'Color',ColLine(:,TP(i)));

%     hold on
    j=1;
    for t=T(TimeIndex)
        P(j)=plot(ax,Mov{i}(t,1)-Mov{i}(1,1),Mov{i}(t,2)-Mov{i}(1,2),...
            '*','Color',ColEv(:,ismember(Ses.LinkedTask.EventsDefinitions,Ev(j))));
        j=j+1;
    end
    
    CheckMembership=ismember(Ev,Legend);
    if i==1,Legend=Ev;end
    %     if ~all(CheckMembership)
    Legend=[Legend Ev(~ismember(Ev,Legend))];
    %     end
    PLegend=[PLegend,P(~CheckMembership)];
end
legend(ax,PLegend,Legend);



end