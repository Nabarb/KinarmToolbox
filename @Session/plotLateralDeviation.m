function Fig=plotLateralDeviation(Ses,ax)
[a,b,c,d]=Ses.getLateralDeviation;

if nargin<2
    figure('Color',[1 1 1]);
    ax=gca;
    pbaspect(ax,[3,2,1])
end

ax=plotPerTrialData(Ses,ax,a,0);

ylim(ax,Ses.LinkedTask.ErrorLims)
xlabel(ax,'# Trials')
ylabel(ax,'Mean error [m]')
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