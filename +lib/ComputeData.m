%% Script per ottenere gli indici dei cath trial e la viscosità trial by trial
% usa il toolbox per l'analisi kinarm. Presuppone di essere inserito nella
% cartella contenente le subdirectory con tutti i dati comportamentali
% pretrattati con gli script C3dConvert e Correct

load('01MM231117\Allc3d.mat')
ex=Experiment(c3d);
load('02JS301117\Allc3d.mat')
ex.addData(c3d);
load('03GT011217\Allc3d.mat')
ex.addData(c3d);
load('04RG061217\Allc3d.mat')
ex.addData(c3d)
load('05MZ071217\Allc3d.mat')
ex.addData(c3d)

for subj=1:5
     % valori dela viscosità per trial
    Visc(subj,:)=ex.Subjects(subj).Sessions.ViscDistribution;  
    % special catch trial, bool vector
    CatchNormal(subj,:)=ismember(ex.Subjects(subj).Sessions.getTP,ex.Tasks.TrialsType.IndexList{5}); 
    % normal catch trial, bool vector
    CatchSpecial(subj,:)=ismember(ex.Subjects(subj).Sessions.getTP,ex.Tasks.TrialsType.IndexList{4}); 
end

