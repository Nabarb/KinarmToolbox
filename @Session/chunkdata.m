function Data=chunkdata(Ses)
%% Chunks data, based on triggers. Here it cuts out all the recordings in each trial prior to the last "False Start Event", so that each tiral in IntrestingData only has meaningful information
% % Future developments, generalize this option so that it can accept any
% trigger as a starting trigger.

ChunkedIntrestingData=Ses.IntrestingData; % Preinitialized conservativly. if some fields are skipped for some reason, they'll be the same as the unchunked version

for j=1:length(Ses.IntrestingData)
    [~,tmp1]  = Ses.getEventTime('FALSE_START',j);
    [~,tmp2] = Ses.getEventTime('START_OF_TRIAL',j);
    FalseStartEventSample = [tmp1 tmp2];
    [EnterCenterEventTime,EnterCenterEventSample]  = Ses.getEventTime('ENTER_CENTER',j);
    if ~isempty(FalseStartEventSample)
        indx=find(EnterCenterEventSample>FalseStartEventSample(end),1);
        StartIndexSmpl = round(EnterCenterEventSample(indx));
        StartIndexTime = EnterCenterEventTime(indx)-1/Ses.LinkedTask.Fs;
        Names = fieldnames(Ses.IntrestingData);
        Names = Names(~ismember(Names,{'EVENTS','TRIAL'}));
        ExcludedFields = {'TRIAL'};
        
        for i=1:length(ExcludedFields)
            ChunkedIntrestingData(j).(ExcludedFields{i})=Ses.IntrestingData(j).(ExcludedFields{i});
        end
        
        for i=1:length(Names)
            Tmp=Ses.IntrestingData(j).(Names{i});
            ChunkedIntrestingData(j).(Names{i})=Tmp(StartIndexSmpl:end);
        end
        
        indx=(Ses.IntrestingData(j).EVENTS.TIMES>=StartIndexTime);
        
        ChunkedIntrestingData(j).EVENTS.LABELS = Ses.IntrestingData(j).EVENTS.LABELS(indx);
        ChunkedIntrestingData(j).EVENTS.TIMES = Ses.IntrestingData(j).EVENTS.TIMES(indx)-...
            StartIndexTime;
        
        ChunkedIntrestingData(j).EVENTS.LABELS = Ses.IntrestingData(j).EVENTS.LABELS(indx);
        
    else
        ChunkedIntrestingData(j)=Ses.IntrestingData(j);
    end
end %j

for j=1:length(Ses.IntrestingData)
    
    
    ChunkedIntrestingData(j).OriginalEVENTS.LABELS = Ses.IntrestingData(j).EVENTS.LABELS;
    ChunkedIntrestingData(j).OriginalEVENTS.TIMES = Ses.IntrestingData(j).EVENTS.TIMES;
end

if nargout<1
    Ses.IntrestingData=ChunkedIntrestingData;
    
elseif nargout==1
    Data=ChunkedIntrestingData;
else
    error('Too many output arguments!');
end

end