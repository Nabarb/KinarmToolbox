%% Task protocol specific correction

clear('ALLc3d');



CatchTrialsList = 19:36;
NullBlock = 1:6;
RandBlock = 7:12;
LoadBlock = 13:18;
BlockIndexList=[0 72  276   348   553   625];

%% trials type table

TrialsTypeIndexList = {1:6;
                       7:12;
                       13:18;
                       19:24;
                       25:30;
                       31:36};
                 
TrialsTypeConditionName={'NullField';
                         'RandomField';
                         'DeterministicField';
                         'CatchTrial1';
                         'CatchTrial2';
                         'CatchTrial3'
                         };
                     
TrialsTypeColor = {[25, 46, 91]./255;
                 [0, 116, 63]./255;
                 [242, 161, 4]./255;
                 [29, 101, 166]./255;
                 [114, 162, 192]./255;
                 [220, 47, 8]./255;
                };


c3dFiles=dir('*c3d.mat');
NumFiles=length(c3dFiles);

TP_LIST={''};

for i=1:NumFiles
    tmp = load(c3dFiles(i).name);
    c3dFieldNames = fieldnames(tmp);
    
    if i==1
        for k=1:length(c3dFieldNames)
            ALLc3d.(c3dFieldNames{k}) = [];
        end
    end
    
    
    for k=1:length(c3dFieldNames)
        ALLc3d.(c3dFieldNames{k}) = append(ALLc3d.(c3dFieldNames{k}),tmp.(c3dFieldNames{k}));
    end
end

TPListAsNumber=zeros(1,length(ALLc3d.c3d));
for i=1:length(ALLc3d.c3d)
TPListAsNumber(i)=ALLc3d.c3d(i).TRIAL.TP;
end

for i = 1:length(BlockIndexList)-1
    ALLc3d.c3d(1).BLOCK_TABLE.TP_LIST{i}=sprintf('%.0f,',TPListAsNumber((BlockIndexList(i)+1):BlockIndexList(i+1)));
    ALLc3d.c3d(1).BLOCK_TABLE.CATCH_TP_LIST{i}=sprintf('%.0f,',CatchTrialsList);
    ALLc3d.c3d(1).BLOCK_TABLE.LIST_REPS(i)=1;
    ALLc3d.c3d(1).BLOCK_TABLE.BLOCK_REPS(i)=1;
    ALLc3d.c3d(1).BLOCK_TABLE.RANDOMIZED(i)=0;
end        

%% Tables correction
Table={'TP_TABLE','TARGET_TABLE','BLOCK_TABLE'};
for i=1:3
    tmp=fieldnames(ALLc3d.c3d(1).(Table{i}));
    tmp=tmp(~ismember(tmp,{'COLUMN_ORDER','USED','DESCRIPTIONS',...
        'FRAME_OF_REFERENCE','FRAME_OF_REFERENCE_LIST'}));
    ALLc3d.c3d(1).(Table{i}).USED=sum(ALLc3d.c3d(1).(Table{i}).(tmp{1})~=0);
end
ALLc3d.c3d(1).BLOCK_TABLE.USED=length(BlockIndexList)-1;


%% Additional infos correction

ALLc3d.c3d(1).EXPERIMENT.TASK_PROTOCOL_CODE=2;
ALLc3d.c3d(1).EXPERIMENT.MOV_TYPE='CenterOut';
ALLc3d.c3d(1).EXPERIMENT.SUBJECT_ID=num2str(01);
ALLc3d.c3d(1).EXPERIMENT.SUBJECT_AGE=0;
ALLc3d.c3d(1).EXPERIMENT.SUBJECT_DOB=0;
ALLc3d.c3d(1).EXPERIMENT.SUBJECT_GENDER='M';
ALLc3d.c3d(1).EXPERIMENT.SUBJECT_NOTES='';
% ALLc3d.c3d(1).EXPERIMENT.SUBJECT_CLASSIFICATION='healthy control';

ALLc3d.c3d(1).TrialsType.IndexList=TrialsTypeIndexList;
ALLc3d.c3d(1).TrialsType.ConditionName=TrialsTypeConditionName;
ALLc3d.c3d(1).TrialsType.Color=TrialsTypeColor;

save('Allc3d.mat','-struct','ALLc3d')


function c=append(a,b)
    if iscolumn_(a) && iscolumn_(b)
        c=[a;b];
    elseif iscolumn_(a) && ~iscolumn_(b)
        c=[a;b'];
    elseif ~iscolumn_(a) && iscolumn_(b)
        c=[a';b];
    elseif ~iscolumn_(a) && ~iscolumn_(b)
        c=[a,b];
    end
end

function B=iscolumn_(a)
    [M,N]=size(a);
    B = M>N;
end
