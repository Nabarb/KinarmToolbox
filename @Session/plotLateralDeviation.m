function Fig=plotLateralDeviation(Ses,ax)
[a,b,c,d]=Ses.getLateralDeviation;

NTrial=1:Ses.LinkedTask.NTrials;
% C1=[0, 114,189]./255;
% C2=[189, 75, 0]./255;
% C3=[0, 181, 26]./255;
if nargin<2
    figure('Color',[1 1 1]);
    ax=gca;
    pbaspect(ax,[3,2,1])

end
hold(ax,'on');
plot(ax,NTrial,zeros(size(a)),'--','Color',C2,'LineWidth',.3);
BlockIndex=Ses.LinkedTask.ChangeBlockIndex;

for k=1:1:length(BlockIndex)-1
    for i=1:size(Ses.LinkedTask.TrialsType,1)
        index=(BlockIndex(k)+1):BlockIndex(k+1);
        TPList=Ses.getTP(index);
        index=index(ismember(TPList,Ses.LinkedTask.TrialsType.IndexList{i}));
        if all(ismember(Ses.LinkedTask.TrialsType.IndexList{i},Ses.LinkedTask.BlockTable.CATCH_TP_LIST{2}))
            LineType='*';
        else
            LineType='';
        end
        color= Ses.LinkedTask.TrialsType.Color{i};
        plot(ax,NTrial(index),a(index),LineType,'LineWidth',1.5,'Color',color);
    end
end
ylim(ax,Ses.LinkedTask.ErrorLims)
xlabel(ax,'# Trials')
ylabel(ax,'Mean error [m]')
box(ax,'off');
hold(ax, 'off');
title(ax,['Subject ID:' num2str(Ses.LinkedSubject.ID)]);

if nargout==1
    Fig=ancestor(ax,'Figure');
end

Nmov=length(d);
for k=1:Nmov
   MaxL(k)=length(d{k});   
end
MaxL=max(MaxL);
tmp=zeros(Nmov,MaxL);
tmp2=tmp;
for i=1:Nmov
    for j=1:length(d{1,i})
        tmp(i,j)=tmp(i,j)+d{1,i}(j);
        tmp2(i,j)=tmp2(i,j)+d{2,i}(j);
    end
end
tmp=mean(tmp,1);
tmp2=mean(tmp2,1);

% figure
% hold on
% for i=1:length(BlockIndex)-1
%     index=find(and(BlockIndex(i)+1<d{2,1},BlockIndex(i+1)>d{2,1}));
%     im=plot(tmp2(index),tmp(index),'LineWidth',1.5);
% end



% plot(mean(tmp,1));

end