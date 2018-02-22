function [T,S,L]=getEventTime(Ses,varargin)
%% Session class method. Return the times and correspondoing samples nuber of the
    

switch nargin
    case 3
        NumInd = cellfun(@(x) isnumeric(x), varargin); % finds numeric entry in varargin
        StrInd = cellfun(@(x) ischar(x), varargin); % finds string entry in varargin
        ind=varargin{NumInd};
        EventName=varargin{StrInd};
    case 2
        if isnumeric(varargin)
            ind=varargin{1};
        elseif any(ismember(varargin{1},Ses.LinkedTask.EventsDefinitions))
            ind='all';
            EventName=varargin{1};
        else
            ind='all';
            EventName=Ses.LinkedTask.EventsDefinitions;
        end
    case 1
        ind='all';
        EventName=Ses.LinkedTask.EventsDefinitions;
end
    
    if ~isnumeric(ind) && strcmp(ind,'all')
        ind=1:Ses.LinkedTask.NTrials;
    end
    
    if ~iscell(EventName)
        EventName=cellstr(EventName);
    end
    
    if isscalar(ind)
        for EvName=EventName
            t=Ses.IntrestingData(ind).EVENTS.TIMES(strcmp(deblank(Ses.IntrestingData(ind).EVENTS.LABELS),EvName{:}));
            T = t;
            S = round(T*Ses.LinkedTask.Fs)+1;
        end
    else

    T=cell(1,length(ind));
    S=T;
    L=T;

    for i=1:length(ind)
        for EvName=EventName

            t=Ses.IntrestingData(ind(i)).EVENTS.TIMES(strcmp(deblank(Ses.IntrestingData(ind(i)).EVENTS.LABELS),EvName{:}));
            if ~isempty(t)
                T{i} = [T{i} t];
                L{i}=[L{i} repmat(EvName,1,length(t))];
            end
        end
        [T{i},I]=sort(T{i});
        S{i} = round(T{i}*Ses.LinkedTask.Fs)+1;
        L{i} = L{i}(I);
    end
    end

