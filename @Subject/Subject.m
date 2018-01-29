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
        
        function AddSession(Sub, c3d, exp)
            taskID=c3d(1).EXPERIMENT.TASK_PROTOCOL_CODE;
            index = taskID == exp.getTaskList;

            if ~ismember(taskID,exp.getTaskList)
                exp.addTask(c3d);
            end

            NewSession=Session( c3d, exp.Tasks(index), Sub);
            Sub.Sessions = [Sub.Sessions NewSession];
        end % AddSession
        
        function Struc=saveobj(Sub)
            FN=fieldnames(Sub);
            FN=FN((cellfun(@isempty,strfind(FN,'Linked'))));
            for i=1:length(FN)
                CurrField=Sub.(FN{i});
                Struc.(FN{i})=CurrField;
            end
        end %save
        
    end
    
end

