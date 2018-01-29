classdef Experiment < handle
    %% Experiment class for kinarm usage
    % is a handle class because there should be only one copy of any instance
    % of Experiment. To create a new instance call the constructor.
    
    properties
        Subjects;
        Tasks;
        Parameters;
        Filename;

    end %properties
    
    methods
        plotAnimation(Subject);
        
        function Exp=Experiment(c3d)
            %% Constructor method for class Experiment
            % Please be sure you have the field c3d(1).EXPERIMENT.MOV_TYPE
            % set to the correct value ('CenterOut','OutCenter','Both')
            if nargin==1
                Exp.Tasks=[];
                Exp.addTask(c3d,c3d(1).EXPERIMENT.MOV_TYPE);
                
                Exp.Subjects=[];
                Exp.addSubject(c3d);
                
                SubjID=str2double(c3d(1).EXPERIMENT.SUBJECT_ID);
                index = SubjID == Exp.getSubjectList;
                
                %             Exp.Subjects(index).Sessions=[];
                Exp.Subjects(index).AddSession(c3d,Exp);
                
                Exp.Parameters=c3d(1).EXPERIMENT;
            elseif nargin==0
                Exp.Tasks=[];                
                Exp.Subjects=[];                                
                %             Exp.Subjects(index).Sessions=[];                
                Exp.Parameters=[];
                Exp.Filename=[];
            end
        end %Experiment
        
        function addTask(Exp,c3d,MovType)
            NewTask=Task(c3d,MovType);
            Exp.Tasks= [Exp.Tasks NewTask];
        end %addTask
        
        function st = saveobj(Exp)
            for i=1:length(Exp.Subjects)
                st.Subjects(i)=save(Exp.Subjects(i));
            end
            for j=1:length(Exp.Tasks)
                st.Tasks(j)=save(Exp.Tasks(j));
            end
            st.Parameters=Exp.Parameters;
            st.Filename=Exp.Filename;
            Exp.Tasks=[];
            Exp.Subjects=[];
            display('Experiment: Saving data');
        end %save

        function addSubject(Exp,c3d)
            NewSubject=Subject( c3d,Exp);
            Exp.Subjects=[Exp.Subjects NewSubject];
        end %addSubject
        
        function IDs=getTaskList(Exp)
            IDs=cat(1,Exp.Tasks.ID);
        end %getTaskList
        
        function IDs=getSubjectList(Exp)
            IDs=cat(1,Exp.Subjects.ID);
        end %getSubjectList
        
        function Index=getSubjectInList(Exp,SubjID)
            Index = (SubjID==Exp.getSubjectList);
        end %getSubjectInList
        
        function addData(Exp,c3d)
            taskID=c3d(1).EXPERIMENT.TASK_PROTOCOL_CODE;
            SubjID=str2double(c3d(1).EXPERIMENT.SUBJECT_ID);
            
            if ~ismember(taskID,Exp.getTaskList)
                Exp.addTask(c3d,c3d(1).EXPERIMENT.MOV_TYPE);
            end
            
            if ~ismember(SubjID,Exp.getSubjectList)
                Exp.addSubject(c3d);
            end
            index = SubjID == Exp.getSubjectList;
            Exp.Subjects(index).AddSession(c3d,Exp);
            
        end %addData
        
        function plotLateralDeviation(Exp)
            
            %% get
            LatDev=cell(1,numel(Exp.getTaskList));
            Titles=LatDev;
            NTrial=cell(1,length(Exp.Tasks));
            BlockIndex=cell(1,length(Exp.Tasks));
            CatchTrialIndex=cell(1,length(Exp.Tasks));
            j=1;
            for i=Exp.Subjects
                for k=i.Sessions
                    TaskIndex=ismember(Exp.getTaskList,k.LinkedTask.ID);
                    NTrial{TaskIndex}=1:Exp.Tasks(TaskIndex).NTrials;
                    BlockIndex{TaskIndex}=Exp.Tasks(TaskIndex).ChangeBlockIndex;
                    CatchTrialIndex{TaskIndex}=Exp.Tasks(TaskIndex).CatchIndex;
                    [LatDevFull,LatDevNonCatch]=k.getLateralDeviation;
                    if isempty(LatDev{TaskIndex})
                        LatDev{TaskIndex}= LatDevFull*0;
                    end
                    LatDev{TaskIndex}= LatDev{TaskIndex} + LatDevFull./length(Exp.Subjects);
                    Titles{TaskIndex}= k.LinkedTask.TaskProtocol;
                    
                end %k
            end %i
            
            %% plot
            C1=[0, 114,189]./255;
            C2=[189, 75, 0]./255;
            C3=[0, 181, 26]./255;
            for j=1:length(LatDev)
                figure('Color',[1 1 1]);
                ax=axes;
                pbaspect(ax,[3,2,1])
                a=LatDev{j};
                hold(ax, 'on');
                plot(ax,NTrial{j},zeros(size(a)),'--','Color',C2,'LineWidth',.3);
                
                for k=1:1:length(BlockIndex{j})-1
                    for i=1:size(Exp.Tasks(j).TrialsType,1)
                        index=(BlockIndex{j}(k)+1):BlockIndex{j}(k+1);
                        TPList=Exp.Subjects(1).Sessions.getTP(index);
                        index=index(ismember(TPList,Exp.Tasks(j).TrialsType.IndexList(i,:)));
                        if all(ismember(Exp.Tasks(j).TrialsType.IndexList(i,:),Exp.Tasks(j).BlockTable.CATCH_TP_LIST{2}))
                            LineType='*';
                        else
                            LineType='';
                        end
                        plot(ax,NTrial{j}(index),a(index),LineType,'LineWidth',1.5);
                    end
                end
                
                xlabel(ax,'# Trials')
                ylabel(ax,'Mean error [m]')
                box(ax,'off');
                hold(ax, 'off');
                title('Across subjects lateral deviation')
                
            end %j
            
        end %plotLateralDeviation
        
        function plotPulseDeviation(Exp)
            %% get
            PulseDev=cell(1,numel(Exp.getTaskList));
            Response=PulseDev;
            Titles=PulseDev;
            TPIndex=PulseDev;
            PulseTpNumber=25:30;
            
            for i=Exp.Subjects
                for k=i.Sessions
                    ind=find(ismember(k.getTP,PulseTpNumber));
                    
                    TaskIndex=ismember(Exp.getTaskList,k.LinkedTask.ID);
                    [MaxDev,Resp] = k.getPulseDeviation(ind,PulseTpNumber);
                    if isempty(PulseDev{TaskIndex})
                        PulseDev{TaskIndex}= MaxDev*0;
                        Response{TaskIndex}= Resp*0;
                    end
                    PulseDev{TaskIndex}= PulseDev{TaskIndex} + MaxDev./length(Exp.Subjects);
                    %                     Response{TaskIndex}= Response{TaskIndex} + Resp  ./length(Exp.Subjects);
                    TPIndex{TaskIndex} = k.getTP(ind);
                    Titles{TaskIndex}= k.LinkedTask.TaskProtocol;
                    
                end %k
            end %i
            
            %% plot
            Color=rand(3,numel(PulseTpNumber));
            
            
            for j=1:length(PulseDev)
                figure
                hold on
                t=[1:length(PulseDev{j})]';
                h=1;
                for k=unique(TPIndex{j})'
                    index=TPIndex{j}==k;
                    plot(t(index),PulseDev{j}(index),'*','Color',Color(:,h))
                    p = polyfit(t(index),PulseDev{j}(index),1);
                    yfit=p(1) * t(index) + p(2);
                    plot(t(index),yfit,'Color',Color(:,h));
                    h=h+1;
                    %         tmp(k,:)=MaxDev(index);
                end
                title(Titles{j});
            end %j
            
            %             for h=1:length(Response)
            %                 figure
            %                 title(Titles{h});
            %
            %                 hold on
            %                 j=1;
            %                 for i=TPIndex{h}
            %                     plot(Response{h}(j,:),'Color',Color(:,i-PulseTpNumber(1)-1));
            %                     j=j+1;
            %                 end %i
            %
            %             end %h
            
        end %plotLateralDeviation
      
        
        
    end %methods

    methods(Static)
    
        function Exp = loadobj(Str)
          if isstruct(Str)
             newEx=Experiment;
             newEx.Filename=Str.Filename;
             newEx.Parameters=Str.Parameters;
             for i=1:length(Str.Subjects)
                
             end
             for j=1:length(Str.Tasks)
                
             end

             Exp = newEx;
          end
        end
    
    end % methods(Static)

end
