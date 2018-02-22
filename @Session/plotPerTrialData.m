function Ax=plotPerTrialData(Ses,varargin)
%% Plots a generic data vector, using different colors for each block defined in Task
% Ax = plotPerTrialData([Ses],ax,data,baseline)
% Return a handle to the axis where the plot was made.
% Input : ax, handle to existent axis, if not provided creates a new one
%         data, data to plot
%         baseline, line of reference to plot underneath the data
%
%   The function plotLateralDeviation calls this function


NTrial=1:Ses.LinkedTask.NTrials;
% C1=[0, 114,189]./255;
C2=[189, 75, 0]./255;
% C3=[0, 181, 26]./255;
switch nargin
    case 2
        data=varargin{1};
        figure('Color',[1 1 1]);
        ax=gca;
        pbaspect(ax,[3,2,1])
        data=varargin{1};
        baseline='off';
        
    case 3
        if isgraphics(varargin{1})
            ax=varargin{1};
            data=varargin{2};
            baseline='off';
        else
            figure('Color',[1 1 1]);
            ax=gca;
            pbaspect(ax,[3,2,1])
            data=varargin{1};
            baseline=varargin{2};
        end
        
    case 4
        ax=varargin{1};
        data=varargin{2};
        baseline=varargin{3};
end

if ~isvector(data)|| length(data)~= Ses.LinkedTask.NTrials
    error(['Invalid dimensions for data! It has to be a vector of '...
        Ses.LinkedTask.NTrials ' elements!'] )
end

hold(ax,'on');
if isnumeric(baseline)
    plot(ax,NTrial,ones(size(data)).*baseline,'--','Color',C2,'LineWidth',.3);
end
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
        plot(ax,NTrial(index),data(index),LineType,'LineWidth',1.5,'Color',color);
    end
end

box(ax,'off');
hold(ax, 'off');

if nargout==1
    Ax=ax;
end

end