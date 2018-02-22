
%% Simple sript for converting c3d files to mat format
folder_name = uigetdir(cd);
cd(folder_name)
id=strsplit(folder_name,'/');
id=id{end};
% data=zip_load('dir',folder_name);

index=[];
for i=1:length(data)
if strcmp(data(i).c3d(1).EXPERIMENT.TASK_PROTOCOL,'Training')
    movefile(data(i).filename{:},[data(i).filename{:} '.training'])
    index=[index i];
end
end
data(index)=[];


mkdir([folder_name filesep 'RawKinarm'])
movefile([folder_name filesep '*.zip'],[folder_name filesep 'RawKinarm'])
movefile([folder_name filesep '*.training'],[folder_name filesep 'RawKinarm'])
DataPath=[strrep(folder_name,id,'') filesep 'KINanalysis' filesep id];
if (~isdir(DataPath))
    mkdir(DataPath)
end
copyfile('../Correct.m',DataPath);

for i=1:length(data)
    disp('################################################################')
    disp(data(i).filename)
    
    % BKIN provided scripts
    data(i) = sort_trials(data(i));
    data(i) = correctXTorque(data(i));
    data(i).c3d = KINARM_add_friction(data(i).c3d, 0.06, 0.0025);
    data(i).c3d = KINARM_add_hand_kinematics(data(i).c3d);
    data(i).c3d = c3d_filter_dblpass(data(i).c3d, 'standard', 'fc', 10, 'fs', 1000);
    
    tmp=data(i);
    save([DataPath filesep strrep(data(i).filename{1},'.zip','c3d.mat')] ,'-struct','tmp')
    
    %
end
