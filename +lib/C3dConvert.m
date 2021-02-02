function C3dConvert(folder_name,target_name)
%% Simple sript for converting c3d files to mat format
if nargin < 1
    folder_name = uigetdir(cd,'Pick the folder with Zip-files.');
    target_name = uigetdir(cd,'Pick the analysis folder.');
elseif nargin < 2
    target_name = uigetdir(cd,'Pick the analysis folder.');
end
%% Experiment dependent 
id=strsplit(folder_name,filesep);
id=id{end-1};
data=KinarmToolbox.lib.zip_load('dir',folder_name);
%%

% removing training block
index=[];
for ii=1:length(data)
    if strcmp(data(ii).c3d(1).EXPERIMENT.TASK_PROTOCOL,'Training')
        source = fullfile(folder_name,data(ii).filename{:});
        target = fullfile(folder_name,[data(ii).filename{:} '.training']);
        movefile(source,target)
        index=[index ii];
    end
end
data(index)=[];


mkdir(fullfile(folder_name,'RawKinarm'))
movefile([folder_name filesep '*.zip'],[folder_name filesep 'RawKinarm'])
if exist([folder_name filesep '*.training'],'file')
    movefile([folder_name filesep '*.training'],[folder_name filesep 'RawKinarm'])
end

DataPath = fullfile(target_name,'KINanalysis',id);
if (~isfolder(DataPath))
    mkdir(DataPath)
end
copyfile(fullfile(fileparts(mfilename('fullpath')),'Correct.m'),DataPath);

for ii=1:length(data)
    disp('################################################################')
    disp(data(ii).filename)
    
    % BKIN provided scripts, the magic numbers are inherited from their
    % tutorial
    data(ii) = KinarmToolbox.lib.sort_trials(data(ii));
    data(ii) = KinarmToolbox.lib.correctXTorque(data(ii));
    data(ii).c3d = KinarmToolbox.lib.KINARM_add_friction(data(ii).c3d, 0.06, 0.0025);
    data(ii).c3d = KinarmToolbox.lib.KINARM_add_hand_kinematics(data(ii).c3d);
    data(ii).c3d = KinarmToolbox.lib.c3d_filter_dblpass(data(ii).c3d, 'standard', 'fc', 10, 'fs', 1000);
    
    tmp=data(ii);
    saveP = fullfile(DataPath,strrep(data(ii).filename{1},'.zip','c3d.mat'));
    save(saveP ,'-struct','tmp');
    
    %
end
