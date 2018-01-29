function [MaxDev,Resp]=getPulseDeviation(Ses,ind,PulseTpNumber)
if nargin<3
    PulseTpNumber=25:30;
end


if nargin<2
    ind=find(ismember(Ses.getTP,PulseTpNumber));
end


if ~isnumeric(ind) && strcmp(ind,'all')
    ind=1:Ses.LinkedTask.NTrials;
end


TPTableIndex=ismember(Ses.LinkedTask.TrialProtocolTable.Names,'load');
loadRow=Ses.LinkedTask.TrialProtocolTable.Matrix(Ses.getTP(ind),TPTableIndex);
LoadTableIndex=ismember(Ses.LinkedTask.LoadTable.Names,{'X_Pulse','Y_Pulse'});
PulseDir = Ses.LinkedTask.LoadTable.Matrix(loadRow,LoadTableIndex)';
PulseDir=PulseDir./sqrt(sum(PulseDir.*PulseDir,1));

j=1;
MaxDev=ind;


for i=ind'
    Target= Ses.LinkedTask.TargetTable(Ses.getTargetsPerTrial(i),:)./100;
    StartTargetX=Target(1,1);
    StartTargetY=Target(1,2);
    [~,perturb]=Ses.getEventTime('PERTURB',i);
    [~,lbeep]=Ses.getEventTime('LAST_BEEP',i);
    lbeep=lbeep+50;
    
    Response=[Ses.IntrestingData(i).Right_HandX(perturb:lbeep)-StartTargetX,...
        Ses.IntrestingData(i).Right_HandY(perturb:lbeep)-StartTargetY]*...
s        PulseDir(:,j);
    MaxDev(j)=max(Response);
    if j~=1
        Resp(j,:)=resample(Response,length(Resp(1,:)),length(Response));
    else
        Resp(j,:)=Response;
    end
    j=j+1;
    
end





end