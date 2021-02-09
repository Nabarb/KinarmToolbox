classdef Subject < handle
    %% Subject class
    
    properties
        ID
        Height
        Weight
        Age
        DateOfBirth
        Gender
        DominantHand
        Notes
        
        Classification
        Sessions
        
    end
    
    properties(Transient = true)
        LinkedExperiment
    end
    
    methods
        function Sub = Subject( c3d, exp)
            
            Sub.LinkedExperiment=exp;
            
            SubNames={'Height','Weight','ID','Age','DateOfBirth','Gender','Notes',...
                'Classification','DominantHand'};
            
            c3dNames={'HEIGHT','WEIGHT','SUBJECT_ID','SUBJECT_AGE','SUBJECT_DOB',...
                'SUBJECT_GENDER','NOTES','SUBJECT_CLASSIFICATION','ACTIVE_ARM'};
            
            FNames=fieldnames(c3d(1).EXPERIMENT);
            
            for i=1:sum(ismember(FNames,c3dNames))
                index=ismember(FNames,c3dNames(i));
                if any(index)
                    Sub.(SubNames{i})=c3d(1).EXPERIMENT.(FNames{index});
                end
            end
            
            Sub.ID=str2double(Sub.ID);
            Sub.Classification =  c3d(1).EXPERIMENT.SUBJECT_CLASSIFICATION;
            Sub.Sessions=[];
%             Sub.AddSession( c3d, exp);
            
        end %Subject
        
        function AddSession(Sub, c3d)
            taskID=c3d(1).EXPERIMENT.TASK_PROTOCOL_CODE;
            index = taskID == Sub.LinkedExperiment.getTaskList;

            if ~ismember(taskID,Sub.LinkedExperiment.getTaskList)
                exp.addTask(c3d);
            end

            NewSession=KinarmToolbox.Session( c3d, Sub.LinkedExperiment.Tasks(index), Sub);
            Sub.Sessions = [Sub.Sessions NewSession];
        end % AddSession
        
        
    end
    
    
    methods 
        function setLinkedExp(Sub,Exp)
            if numel(Sub) == 1
                Sub.LinkedExperiment = Exp;
            else
                setLinkedExp(Sub(1:end-1),Exp);
                setLinkedExp(Sub(end),Exp);
            end
        end
        
        function sub = saveobj(sub)
            fprintf(1,'Subject: Saving data.\n');
        end
    end
end

