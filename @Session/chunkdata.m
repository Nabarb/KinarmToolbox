function Data=chunkdata(Ses)

    for j=1:length(Ses.IntrestingData)
        [~,FalseStartEventSample]  = Ses.getEventTime('FALSE_START',j);
        [EnterCenterEventTime,EnterCenterEventSample]  = Ses.getEventTime('ENTER_CENTER',j);
        if ~isempty(FalseStartEventSample)
            indx=find(EnterCenterEventSample>FalseStartEventSample(end),1);
            StartIndexSmpl = round(EnterCenterEventSample(indx));
            StartIndexTime = EnterCenterEventTime(indx)-1/Ses.LinkedTask.Fs;
            Names = fieldnames(Ses.IntrestingData);
            Names = Names(~ismember(Names,'EVENTS'));
            for i=1:length(Names)
                Tmp=Ses.IntrestingData(j).(Names{i});
                ChunkedIntrestingData(j).(Names{i})=Tmp(StartIndexSmpl:end);
            end
            indx=(Ses.IntrestingData(j).EVENTS.TIMES>=StartIndexTime);

            ChunkedIntrestingData(j).EVENTS.LABELS = Ses.IntrestingData(j).EVENTS.LABELS(indx);
            ChunkedIntrestingData(j).EVENTS.TIMES = Ses.IntrestingData(j).EVENTS.TIMES(indx)-...
                StartIndexTime;
        else
            ChunkedIntrestingData(j)=Ses.IntrestingData(j);
        end
    end

    if nargout<1
        Ses.IntrestingData=ChunkedIntrestingData;

    elseif nargout==1
        Data=ChunkedIntrestingData;
    else
        error('Too many output arguments!');
    end

end