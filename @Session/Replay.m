%% Plot Targets Animation
function Replay(Ses,saveGIF)
%% Plots kinarm data in animated way.
% Takes as input directly the raw c3d data al loaded by kinarm scripts.

%% Init
if nargin <2
  pars.saveGIF = false; 
else
    pars.saveGIF = saveGIF;
end

% Initialize pars
pars.AnimationPaused = true;
pars.ActTrial = [1 1]; % trial, sample

pars.Ses = Ses;
pars.NTrials=Ses.LinkedTask.NTrials;
pars.Fs = Ses.LinkedTask.Fs;
pars.fps = 60;
pars.scalefactor = 100;
pars.ActFps = floor(pars.Fs / floor(pars.Fs/pars.fps));

% make fig
Objs = makefig(Ses);
Objs.F.UserData = pars;

function flag =  Animation(save,Objs,NTrials,Ses)
flag = true;
scalefactor = Objs.F.UserData.scalefactor;
i = Objs.F.UserData.ActTrial(1);
while i<NTrials
    Objs.LabelH.String=num2str(i);
%     TP=Ses.getTP(i);   % Current trial protocol    
    cursorpos=[Ses.IntrestingData(i).Right_HandX, Ses.IntrestingData(i).Right_HandY]'.*scalefactor;
    
    %%
    %     T=1/Fs;
%     hold(AX,'off')
    k = Objs.F.UserData.ActTrial(2);
    fx = Ses.IntrestingData(i).Right_Hand_ForceCMD_X./2;
    fy = Ses.IntrestingData(i).Right_Hand_ForceCMD_Y./2;
        
    Targets_Tbl=Ses.LinkedTask.TargetTable;
    Ntargets = size(Targets_Tbl,1);
    
    % Only the active target has to be visible
    Targets = Ses.getTargetsPerTrial(i);
    TargetState = mat2cell(char(ones(Ntargets,1)*'off'),ones(1,Ntargets),3);
    TargetState(Targets)={'on'};
    
    clearpoints(Objs.trajectory);
    
    % Actual animation, loops on the data and updates the objects
    % properties
    while k < length(cursorpos)
        tic
        if any(isnan(cursorpos(1,k))) || any(isnan(cursorpos(2,k))), continue; end
        
        set(Objs.cursor,'XData',cursorpos(1,k));
        set(Objs.cursor,'YData',cursorpos(2,k));
        
        addpoints(Objs.trajectory,cursorpos(1,k),cursorpos(2,k));
        
        set(Objs.force,'XData',cursorpos(1,k));
        set(Objs.force,'YData',cursorpos(2,k));
        set(Objs.force,'UData',fx(k));
        set(Objs.force,'VData',fy(k));
        
        speed = Objs.hscrollbar.Value*7+1;
        RefreshRate= 1 / (Objs.F.UserData.ActFps);
        k = k + floor(Objs.F.UserData.Fs/Objs.F.UserData.ActFps * speed);
        Objs.F.UserData.ActTrial = [i k];
        lag=toc;
        pause(max(RefreshRate-lag,0));
        
        
        if Objs.F.UserData.AnimationPaused
            flag = false;
            return;
        end
        
        if save
            frame = getframe(AX);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            imwrite(imind,cm,filename,'gif','WriteMode','append');
        end
    end
    k = 1;
    i=i+1;
    Objs.F.UserData.ActTrial = [i k];
end

function buttoncallback(PushButton, evt, Objs)
pars = Objs.F.UserData;
pars.AnimationPaused = ~pars.AnimationPaused;
if pars.AnimationPaused
    set(PushButton,'String','Start')
    disp('Paused!');
    Objs.F.UserData = pars;
%     waitfor(PushButton,'String');
else
%     StartTrial=str2double( PushButton.Parent.Children(4).String);
    set(PushButton,'String','Pause')
    disp('Started!');
    Objs.F.UserData = pars;
    Animation(pars.saveGIF,Objs,pars.NTrials,pars.Ses);
end


function GraphObj = makefig(Ses)
% Initializing figure
scrsz = get(groot,'ScreenSize');
GraphObj.F=figure('Position',[scrsz(4)/3 scrsz(4)/3 scrsz(3)/2 scrsz(4)/2]);

% Init Axes
axespos=[0.05 0.045 0.7 0.9];
GraphObj.AX=axes(GraphObj.F, 'Units','normalized','Position',axespos);

%% UiControls
% Button
buttonpos=[axespos(2)+axespos(4)-0.17 0.43 0.2 0.15];
GraphObj.ButtonH=uicontrol('Parent',GraphObj.F,'Style','pushbutton','String','Start',...
    'Units','normalized','Position',buttonpos,'Visible','on');

labelpos=[axespos(2)+axespos(4)-0.17 0.73 0.2 0.05];
GraphObj.LabelH=uicontrol('Parent',GraphObj.F,'Style','edit','String','0',...
    'Units','normalized','Position',labelpos,'Visible','on');

% Scrollbar
scrollbarpos=buttonpos+[0 -buttonpos(4) 0 -.05];
GraphObj.hscrollbar=uicontrol('style','slider','units','normalized',...
    'position',scrollbarpos,'String','Speed');
% Scrollbar Labels
uicontrol('style','text','units','normalized',...
    'position',[ 0.765    0.32   0.026    0.028],'String','1x');

uicontrol('style','text','units','normalized',...
    'position',[ 0.953    0.32   0.026    0.028],'String','8x');

%
%% Plot
scalefactor=100;
i=1;
    GraphObj.LabelH.String=num2str(i);
    TP=Ses.getTP(i);   % Current trial protocol
    
    cursorpos=[Ses.IntrestingData(i).Right_HandX, Ses.IntrestingData(i).Right_HandY]'.*scalefactor;
    
    %%
    %     T=1/Fs;
    fps=60;         % glorious PC master race
    hold(GraphObj.AX,'off')
    k=1;
    fx=Ses.IntrestingData(i).Right_Hand_ForceCMD_X./2;
    fy=Ses.IntrestingData(i).Right_Hand_ForceCMD_Y./2;

        Targets_Tbl=Ses.LinkedTask.TargetTable;
        Ntargets = size(Targets_Tbl,1);
        for j=1:Ntargets
            colr=num2str(Targets_Tbl.Initial_Color(j));
            if(strcmp(colr,'0')),continue; end
            
            % Targets color
            colr=str2num([colr(1:3),' ',colr(4:6),' ',colr(7:9)])./255; %#ok<ST2NM>
            GraphObj.Targets(j)=plot(GraphObj.AX,Targets_Tbl.X_GLOBAL(j)./1,...
                Targets_Tbl.Y_GLOBAL(j)./1,...
                '.','MarkerSize',140,'Color',colr);
            
            hold(GraphObj.AX,'on')
        end
        box(GraphObj.AX,'off')
        
        XL=get(GraphObj.AX,'XLim');
        YL=get(GraphObj.AX,'YLim');
        XLNew = XL + abs(diff(XL)*.2) .* [-1 1];
        YLNew = YL + abs(diff(YL)*.2) .* [-1 1];

        
        set(GraphObj.AX,'XLim',XLNew)
        set(GraphObj.AX,'YLim',YLNew)
        GraphObj.trajectory = animatedline('LineWidth',1.2,'Color',[49, 122, 246]./255);
        
        GraphObj.cursor=plot(cursorpos(1,1),cursorpos(2,1),'.','MarkerSize',70,...
            'LineWidth',5,'Color',[0 0 0]);
        %    trajectory = plot(cursorpos(1,1),cursorpos(2,1),...
        %         'LineWidth',.9);
        
        
        GraphObj.force=quiver(cursorpos(1,1),cursorpos(2,1),fx(1),fy(1),0,...
            'MaxHeadSize',1.5,'LineWidth',1.5,'Color',[246, 76, 49]./255);
%         waitfor(ButtonH,'String');


set(GraphObj.ButtonH,'Callback',@(a,b)buttoncallback(a,b,GraphObj))
