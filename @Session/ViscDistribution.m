function varargout=ViscDistribution(Ses,ind)

if nargin<2
    ind='all';
end


if ~isnumeric(ind) && strcmp(ind,'all')
    ind=1:Ses.LinkedTask.NTrials;
end
G=zeros(1,length(ind));
j=1;
for i=ind
    G(j)=mean(Ses.IntrestingData(i).FX_from_VY(round(4*end/5)));
    j=j+1;
end
[Y,x]=hist(G);
if nargout==0
    bar(x,Y)
    hold on
    hold off
    title('Viscosity Distribution')
elseif nargout==1
   varargout{1}=G; 
end


end