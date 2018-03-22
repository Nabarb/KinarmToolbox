%% Plot Targets Animation
function PlotTargetAnimation(Ses)
%% Plots kinarm data in animated way.
% Takes as input directly the raw c3d data al loaded by kinarm scripts.

%% Init
% Initialize some useful decriptors
global AnimationPaused;
AnimationPaused=true;
global StartTrial;
global ButtonPressed;

NTrials=Ses.LinkedTask.NTrials;
Fs= Ses.LinkedTask.Fs;

% Initializing figure
scrsz = get(groot,'ScreenSize');
F=figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);

% Init Axes
axespos=[0.05 0.045 0.7 0.9];
AX=axes(F, 'Units','normalized','Position',axespos);

%% UiControls
% Button
buttonpos=[axespos(2)+axespos(4)-0.17 0.43 0.2 0.15];
ButtonH=uicontrol('Parent',F,'Style','pushbutton','String','Start',...
    'Units','normalized','Position',buttonpos,'Visible','on',...
    'Callback',@buttoncallback);

labelpos=[axespos(2)+axespos(4)-0.17 0.73 0.2 0.05];
LabelH=uicontrol('Parent',F,'Style','edit','String','0',...
    'Units','normalized','Position',labelpos,'Visible','on');

% Scrollbar
scrollbarpos=buttonpos+[0 -buttonpos(4) 0 -.05];
hscrollbar=uicontrol('style','slider','units','normalized',...
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
    LabelH.String=num2str(i);
    TP=Ses.getTP(i);   % Current trial protocol
    
    cursorpos=[Ses.IntrestingData(i).Right_HandX, Ses.IntrestingData(i).Right_HandY]'.*scalefactor;
    
    %%
    %     T=1/Fs;
    fps=60;         % glorious PC master race
    hold(AX,'off')
    k=1;
    fx=Ses.IntrestingData(i).Right_Hand_ForceCMD_X./2;
    fy=Ses.IntrestingData(i).Right_Hand_ForceCMD_Y./2;

        Targets_Tbl=Ses.LinkedTask.TargetTable;
        Ntargets = size(Targets_Tbl,1);
        for j=1:Ntargets
            colr=num2str(Targets_Tbl.Initial_Color(j));
            if(strcmp(colr,'0')),continue; end
            
            % Targets color
            colr=str2num([colr(1:3),' ',colr(4:6),' ',colr(7:9)])./255;
            Targets(j)=plot(AX,Targets_Tbl.X_GLOBAL(j)./1,...
                Targets_Tbl.Y_GLOBAL(j)./1,...
                '.','MarkerSize',140,'Color',colr);
            
            hold(AX,'on')
        end
        box(AX,'off')
        
        XL=get(AX,'XLim');
        YL=get(AX,'YLim');
        XLNew = XL + abs(diff(XL)*.2) .* [-1 1];
        YLNew = YL + abs(diff(YL)*.2) .* [-1 1];

        
        set(AX,'XLim',XLNew)
        set(AX,'YLim',YLNew)
        trajectory = animatedline('LineWidth',1.2,'Color',[49, 122, 246]./255);
        
        cursor=plot(cursorpos(1,1),cursorpos(2,1),'.','MarkerSize',70,...
            'LineWidth',5,'Color',[0 0 0]);
        %    trajectory = plot(cursorpos(1,1),cursorpos(2,1),...
        %         'LineWidth',.9);
        
        
        force=quiver(cursorpos(1,1),cursorpos(2,1),fx(1),fy(1),0,...
            'MaxHeadSize',1.5,'LineWidth',1.5,'Color',[246, 76, 49]./255);
        waitfor(ButtonH,'String');
        
ButtonPressed=false;        
i=StartTrial;
while i<NTrials
    LabelH.String=num2str(i);
    TP=Ses.getTP(i);   % Current trial protocol    
    cursorpos=[Ses.IntrestingData(i).Right_HandX, Ses.IntrestingData(i).Right_HandY]'.*scalefactor;
    
    %%
    %     T=1/Fs;
    fps=60;         % glorious PC master race
    hold(AX,'off')
    k=1;
    fx=Ses.IntrestingData(i).Right_Hand_ForceCMD_X./2;
    fy=Ses.IntrestingData(i).Right_Hand_ForceCMD_Y./2;
    
%     if i==1         % first run, plots all the objects
%         Targets_Struc=Ses.c3d(i).TARGET_TABLE;
%         Ntargets = Targets_Struc.USED;
%         for j=1:Ntargets
%             colr=num2str(Targets_Struc.Initial_Color(j));
%             if(strcmp(colr,'0')),continue; end
%             
%             % Targets color
%             colr=str2num([colr(1:3),' ',colr(4:6),' ',colr(7:9)])./255;
%             Targets(j)=plot(AX,Targets_Struc.X_GLOBAL(j)./1,...
%                 Targets_Struc.Y_GLOBAL(j)./1,...
%                 '.','MarkerSize',140,'Color',colr);
%             
%             hold(AX,'on')
%         end
%         box(AX,'off')
%         
%         XL=get(AX,'XLim');
%         YL=get(AX,'YLim');
%         
%         set(AX,'XLim',[XL(1)*0.95 XL(2)*1.05])
%         set(AX,'YLim',[YL(1)*0.95 YL(2)*1.05])
%         trajectory = animatedline('LineWidth',1.2,'Color',[49, 122, 246]./255);
%         
%         cursor=plot(cursorpos(1,1),cursorpos(2,1),'.','MarkerSize',70,...
%             'LineWidth',5,'Color',[0 0 0]);
%         %    trajectory = plot(cursorpos(1,1),cursorpos(2,1),...
%         %         'LineWidth',.9);
%         
%         
%         force=quiver(cursorpos(1,1),cursorpos(2,1),fx(1),fy(1),0,...
%             'MaxHeadSize',1.5,'LineWidth',1.5,'Color',[246, 76, 49]./255);
%         waitfor(ButtonH,'String');
%     end
    
    % Only the active target has to be visible
    Targets=Ses.getTargetsPerTrial(i);
    TargetState=mat2cell(char(ones(Ntargets,1)*'off'),ones(1,Ntargets),3);
    TargetState(Targets)={'on'};

    
%     for j=1:Ntargets
%         if(TargetState{j}~=0)
%         Targets(j).Visible='on';
%         end
%     end
    
    
    clearpoints(trajectory);
    
    % Actual animation, loops on the data and updates the objects
    % properties
    while k<length(cursorpos)
        tic
        if any(isnan(cursorpos(1,k))) || any(isnan(cursorpos(2,k))), continue; end
        
        %         /addpoints(cursor,cursorpos(1,k),cursorpos(2,k));
        set(cursor,'XData',cursorpos(1,k));
        set(cursor,'YData',cursorpos(2,k));
        
        addpoints(trajectory,cursorpos(1,k),cursorpos(2,k));
        %         set(trajectory,'XData',cursorpos(1,1:k));
        %         set(trajectory,'YData',cursorpos(2,1:k));
        
        set(force,'XData',cursorpos(1,k));
        set(force,'YData',cursorpos(2,k));
        set(force,'UData',fx(k));
        set(force,'VData',fy(k));
        
        speed=hscrollbar.Value*7+1;
        RefreshRate=1/fps/speed;
        lag=toc;
        pause(RefreshRate-lag)
        k=k+floor(Fs/fps);
        if ButtonPressed
            i=StartTrial;
            ButtonPressed=false;
            break;
        end
        
    end
    i=i+1;
end

function buttoncallback(PushButton, EventData)
global AnimationPaused;
global StartTrial;
global ButtonPressed;
AnimationPaused=~AnimationPaused;
if AnimationPaused
    set(PushButton,'String','Start')
    disp('Paused!');
    waitfor(PushButton,'String');
else
    StartTrial=str2double( PushButton.Parent.Children(4).String);
    set(PushButton,'String','Pause')
    disp('Started!');

end
ButtonPressed=true;



