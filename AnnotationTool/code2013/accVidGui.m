% function accVidGui
% GUI for analysing and annotating UvA FlySafe movies and sensor-data.
% 
% author: merijn de bakker. e-mail: merijn.debakker@gmail.com
% note: the cursors used for annotation in this program are based on ...
%   dualcursors.m by: Scott Hirsch: shirsch@mathworks.com. Copyright 2002-2009 ...
%   The MathWorks, Inc. 
%
% created: 23-04-2011
% revised: 10-05-2011
%
% INPUT: buffer size. file input if loaded.
% OUTPUT: file is saved if exported. 
% DEPENDS: accVidGui.fig, dualcursor.m (modified version of S. Hirsch),
% Annotate.m, Annotate.fig
% NOTES: first varargin is the buffersize, the higher this number the
% longer it will take to load the movie, but the less frequent buffering is
% needed when scrolling. Consider the video length by setting this
% parameter.

function varargout = accVidGui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @accVidGui_OpeningFcn, ...
                   'gui_OutputFcn',  @accVidGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end


function accVidGui_OpeningFcn(hObject, eventdata, handles, varargin)

clear global

global MAIN MOV ACC ACCDAT SCHEME

%'ExecutionMode', 'fixedRate', ...
 %                               'Period', round(1/fpsBeh*1000)/1000,...
MAIN.behTimer = timer( 'TimerFcn', {@behTimer_Callback, hObject},...
                                'TasksToExecute', 1, ...
                                'ExecutionMode', 'fixedRate', ...
                                 'StopFcn',{@behTimerStop_Callback,hObject});

accTimer = timer( 'TimerFcn', {@accTimer_Callback, hObject}, ...
                                'TasksToExecute', 1, ...
                                'StopFcn',{@behTimer_stop,hObject});                       

arrayfun(@cla,findall(0,'type','axes'));  
set(handles.pushNextSample, 'Enable', 'off');
set(handles.pushPrevSample, 'Enable', 'off');
set(handles.uipushtoolOpen, 'Enable', 'on');   
set(handles.uipushtoolSave, 'Enable', 'off');  
set(handles.buttonPause, 'Enable', 'off');
set(handles.toggleSelect, 'Enable', 'off');
set(handles.sliderBeh, 'Enable', 'off');
set(handles.sliderAcc, 'Enable', 'off');
set(handles.ToolInit, 'Enable', 'off');                            
set(handles.menuInit, 'Enable', 'off'); 
set(handles.SessionSave, 'Enable', 'off');
set(handles.exportMat, 'Enable', 'off');
set(handles.exportCsv, 'Enable', 'off');

set(handles.figure1,'CloseRequestFcn',@closeGUI);
set(handles.speedOk,'SelectionChangeFcn', @speedOk_SelectionChangeFcn);

axis(handles.movie, 'off')
axis(handles.accPlot, 'off')
% Choose default command line output for accVidGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

end

function buttonPause_CreateFcn(hObject, eventdata, handles)

    handles.Strings = {'Run';'Pause'};
    guidata(hObject,handles);
end

function sliderAcc_CreateFcn(hObject, eventdata, handles)
        
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'));
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end 
    

function sliderBeh_CreateFcn(hObject, eventdata, handles)
    
    
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'));
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

function uiRadioGroup_CreateFcn(hObject, eventdata, handles)   
end

function varargout = accVidGui_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;
end

function buffer
    
    global MAIN SAMPLE ACC;
    
    handles = guidata(gcbo);
    
    MAIN.BEHMOVIE(1:MAIN.VID.NumberOfFrames) = ...
                struct('cdata', zeros(MAIN.VID.Height, MAIN.VID.Width,3, 'uint8'),...
                'colormap', []);
    
    
    playState('Run');
    set(handles.textBuffer, 'String', 'loading');
    SAMPLE.movStart(MAIN.sampleIndex)
    
    try
        
        for i=SAMPLE.movStart(MAIN.sampleIndex):SAMPLE.movStart(MAIN.sampleIndex)+...
                (ACC.endI*MAIN.movSpd)
            MAIN.BEHMOVIE(i).cdata = read(MAIN.VID,i);
        end
    catch ME
        errordlg('out of memory error');
        MAIN.bufferState = 0;
        MAIN.bufferOn = 0;
    end
    
        
  %  MAIN.lastFrame = MAIN.toFrame+MAIN.buffer;
    
  %  MAIN.bufferRange = [MAIN.toFrame MAIN.toFrame+MAIN.buffer];
    set(handles.textBuffer, 'String', ' ');
    
  %  if buttonPauseState == 2
  %      set(handles.buttonPause,'String',handles.Strings{2});
  %  end
    MAIN.bufferState=1;
    playState('Pause');
    guidata(gcbo,handles);
end

function behTimerStop_Callback(timer_object, eventdata, hObject)
    handles = guidata(hObject);    

    set(handles.buttonPause, 'Enable', 'on');
   % set(handles.toggleSelect, 'Enable', 'off');
    set(handles.sliderBeh, 'Enable', 'on');
    set(handles.sliderAcc, 'Enable', 'on');
    
    guidata(hObject,handles);
end

        
%--------------------------------------------------------------------------
function pl = plotAcc(h,beginI, endI)

    global MAIN ACCDAT ACC;
          
    set(handles.accPlot,'ylim', [-2.5 3]);

    xaxis = (beginI:endI);
            
    pl = plot(h,xaxis,ACCDAT.X(beginI:endI,1),'r',xaxis,ACCDAT.Y(beginI:endI,1),'b',...
        xaxis,ACCDAT.Z(beginI:endI,1),'g');
    set(gca,'Fontsize',6);

end

function pl = plotSample(h,data)
    
    global ACC
    
    handles = guidata(gcbo);
    xaxis = (1:size(data,1));
     
    pl = plot(h,xaxis, data(:,1),'r', xaxis, data(:,2), 'b', xaxis, data(:,3),...
        'g');
    
    set(gca,'Fontsize',6);
    set(handles.accPlot,'ylim', [-2.5 3]);
    
    if get(handles.checkHold,'Value')==0
        set(handles.accPlot,'xlim', [ACC.I ACC.endI]);    
    else
        set(handles.accPlot,'xlim', [0 ACC.scale]);
    end
    
    
end

function behTimer_stop(timer_object, eventdata,hObject)
    global Tstop;
    global I;
    handles = guidata(hObject);
    
    Tstop = I;
end

function accTimer_Callback(timer_object, eventdata, hObject)
    global ACCELMOVIE;
    
    %handles = guidata(hObject);
    
    for i = 1:20
        axes(handles.accPlot);
        imshow(ACCELMOVIE(i).cdata);
        drawnow
    end
end
%--------------------------------------------------------------------------

function toolState(state)

    global MAIN ACCDAT
    
    handles = guidata(gcbo);
    
    set(handles.uipushtoolOpen, 'Enable', state);   
    set(handles.uipushtoolSave, 'Enable', state);  
    %set(handles.ToolInit, 'Enable', state);                            
    %set(handles.menuInit, 'Enable', state); 
    set(handles.SessionSave, 'Enable', state);
    set(handles.exportMat, 'Enable', state);
    set(handles.exportCsv, 'Enable', state);
    set(handles.annListbox, 'Enable', state);
    set(handles.pushAnnBox, 'Enable', state);
    set(handles.toggleSynch, 'Enable', state);
    set(handles.toolNew, 'Enable', state); 
    set(handles.exportCsv, 'Enable', state);
    set(handles.exportMat, 'Enable', state);
    
    set(handles.toggleSelect, 'Enable', state);
    
    if MAIN.accOnly == 1
        set(handles.toggleSynch, 'Enable', 'off');
    end
    
      
    if get(handles.toggleSelect,'Value') == get(handles.toggleSelect, 'Max')
        set(handles.annListbox, 'Enable', 'on');
    else
        set(handles.annListbox, 'Enable', 'off');
    end
    
    if ~isnan(ACCDAT.gpsSpd(1))       
        set(handles.radioSpeedOK, 'Enable', 'on');
        set(handles.radioSpeedNotOK, 'Enable', 'on');
    else
        set(handles.radioSpeedOK, 'Enable', 'off');
        set(handles.radioSpeedNotOK, 'Enable', 'off');
    end
    
end


function playState(str)

    handles = guidata(gcbo);
    
    %str = get(handles.buttonPause,'String');
    
    if strcmp(str, 'Run') == 0
        toolState('on')
        set(handles.toggleSelect, 'Enable', 'on');
        
        sampleSelState(1)
        
    else
        sampleSelState(0)
        toolState('off')
        set(handles.toggleSelect, 'Enable', 'off');
        
    end

    guidata(gcbo,handles);
end


function sampleSelState(state)
    global MAIN ACC
    
    handles = guidata(gcbo);

    if state == 0
        set(handles.pushPrevSample, 'Enable', 'off');
        set(handles.pushNextSample, 'Enable', 'off');
    else
        if MAIN.sampleIndex-1<MAIN.firstPossSample           
            set(handles.pushPrevSample, 'Enable', 'off');
            set(handles.pushNextSample, 'Enable', 'on');
            
            if MAIN.accOnly == 0 && (MAIN.sampleIndex==1 && ACC.VPI>ACC.I)
                set(handles.pushPrevSample,'Enable', 'on');
            end
            
        elseif MAIN.sampleIndex+1>MAIN.lastPossSample
            set(handles.pushNextSample, 'Enable', 'off');
            set(handles.pushPrevSample, 'Enable', 'on');
        else
            set(handles.pushPrevSample, 'Enable', 'on');
            set(handles.pushNextSample, 'Enable', 'on');
        end
        
    end
    
    guidata(gcbo, handles);
    

end


function buttonPause_Callback(hObject, eventdata, handles) 
 
    global ACC MOV MAIN;
      
    str = get(hObject,'String');
    state = find(strcmp(str,handles.Strings));
    set(hObject,'String',handles.Strings{3-state}); 

    MAIN.hm = findobj(handles.movie,'type','image');
    
    playState(str)
    
    MAIN.bufferOn = (get(handles.checkBuffer,'Value')==get(handles.checkBuffer,'Max'));
    if MAIN.bufferOn && MAIN.bufferState==0
           
           MAIN.BEHMOVIE(1:MAIN.VID.NumberOfFrames) = ...
                struct('cdata', zeros(MAIN.VID.Height, MAIN.VID.Width,3, 'uint8'),...
                'colormap', []);
           buffer
    end

    
    %DEBUG 
    %length(findobj(handles.movie))
    %length(findobj(handles.accPlot))
    guidata(hObject,handles);
    
    switch MAIN.modusAut
        
        case 1
            
        switch MAIN.bufferOn
        
            case 0
                
                while strcmp(get(hObject,'String'),'Run')==0 && ...
                    ceil(ACC.VPI) < ACC.endI
                
                set(MAIN.hm, 'Cdata', read(MAIN.VID,MOV.I));
                
               
                %MAIN.BEHMOVIE(MOV.I+1).cdata = read(MAIN.VID,MOV.I+1);
                
                ACC.VPI = ACC.I+(MAIN.vpSpd*MAIN.Icounter);
                
                set(ACC.VP,'XData',[ACC.VPI ACC.VPI]);
               
                set(handles.sliderBeh, 'value', MAIN.Icounter); 
                set(handles.sliderAcc, 'value', ACC.VPI);                                       
                set(handles.textVidframe, 'String', MOV.I);
                set(handles.textVidstamp, 'String', datestr(MOV.frameInfo(MOV.I,:),'HH:MM:SS.FFF'));         
                                 
                MOV.I = MOV.I+1;
                MAIN.Icounter = MAIN.Icounter+1;
                drawnow
                pause(MAIN.speed)
                
                end
                        
            case 1
                while strcmp(get(hObject,'String'),'Run')==0 && ...
                    ceil(ACC.VPI) < ACC.endI
                
                set(MAIN.hm, 'Cdata', MAIN.BEHMOVIE(MOV.I).cdata);
                %MAIN.BEHMOVIE(MOV.I+1).cdata = read(MAIN.VID,MOV.I+1);

                ACC.VPI = ACC.I+(MAIN.vpSpd*MAIN.Icounter);
                
                set(ACC.VP,'XData',[ACC.VPI ACC.VPI]);
               
                set(handles.sliderBeh, 'value', MAIN.Icounter); 
                set(handles.sliderAcc, 'value', ACC.VPI);                                       
                set(handles.textVidframe, 'String', MOV.I);
                set(handles.textVidstamp, 'String', datestr(MOV.frameInfo(MOV.I,:),'HH:MM:SS.FFF'));         
                
               % MAIN.BEHMOVIE(MOV.I).cdata = [];                 
                MOV.I = MOV.I+1;
                MAIN.Icounter = MAIN.Icounter+1;
                drawnow
                pause(MAIN.speed)
                
                end
                
                
        end
        
     
        
        if strcmp(get(hObject,'String'),'Run')==0
            set(handles.sliderBeh, 'value', get(handles.sliderBeh, 'max'));
            set(handles.sliderAcc, 'value', get(handles.sliderAcc, 'max'));
            set(ACC.VP,'XData',[ACC.endI ACC.endI]);
        end
   
        set(handles.buttonPause,'String',handles.Strings{1});
        playState(handles.Strings{2})
               
        guidata(hObject,handles);
                
        case 0
            set(handles.pushPrevSample, 'Enable', 'off');
            set(handles.pushNextSample, 'Enable', 'off');
            

            while MOV.I<MOV.nOfFrames && strcmp(get(hObject,'String'),'Run')==0 

                if MAIN.toFrame>MAIN.bufferRange(2) || MAIN.toFrame<MAIN.bufferRange(1);
                   MAIN.skip = MAIN.toFrame - MOV.I;
                   start(MAIN.behTimer);
                   stop(MAIN.behTimer);
                   MOV.I = MAIN.toFrame;
                   disp('buffered')
                end

                MAIN.hm = findobj(handles.movie,'type','image');
                set(MAIN.hm, 'Cdata', MAIN.BEHMOVIE(MOV.I).cdata);
                %MAIN.hm = imshow(MAIN.BEHMOVIE(MOV.I).cdata,'Parent',handles.movie);
                %MAIN.hm = set(handles.movie,'CData',MAIN.BEHMOVIE(MOV.I).cdata);
                set(handles.sliderBeh, 'value', MOV.I);
               
                MAIN.BEHMOVIE(MAIN.lastFrame).cdata = read(MAIN.VID,MAIN.lastFrame);
                MAIN.lastFrame = MAIN.lastFrame+1; 
                
                %corrAccFrame = datefind(MOV.frameInfo(MOV.I),ACC.frameInfo,0.00001);              
%                 corrAccFrame = find(ACC.frameInfo==MOV.frameInfo(MOV.I),1,'first');               
%                 
%                 if isempty(corrAccFrame)==0 && ACCDAT.X(ACC.I+1,3)==0
%                     ACC.synchIndex = ACC.synchIndex+1;
%                 elseif isempty(corrAccFrame)==0 && ACCDAT.X(ACC.I+1,3)~=0
%                      set(handles.accPlot,'xlim',(corrAccFrame+ACC.synchIndex)+...
%                          [-round(MAIN.win/2) round(MAIN.win/2)]);
%                      delete(ACC.VP);
%                      ACC.VP = plot(handles.accPlot,[(corrAccFrame+ACC.synchIndex)...
%                          (corrAccFrame+ACC.synchIndex)],ACC.VPY, '-ks');
%                      set(handles.sliderAcc, 'value', ...
%                          (corrAccFrame+ACC.synchIndex)/MAIN.maxX);
%                      set(handles.textDevice, 'String', ACCDAT.sampleID...
%                          (MAIN.sampleIndex));
%                      set(handles.textDatetime, 'String', datestr(ACCDAT. ...
%                           sampleTime(MAIN.sampleIndex),13));
%                      set(handles.textSample, 'String', MAIN.sampleIndex)
%                      
%                end
%                                      
                set(handles.textVidframe, 'String', MOV.I); 
                set(handles.textVidstamp, 'String', datestr(MOV.frameInfo(MOV.I,:),'HH:MM:SS.FFF'));
                
                ACC.I = ACC.I+1;
                ACC.synchIndex = ACC.synchIndex+1;
                MOV.I = MOV.I+1;
                
                MAIN.BEHMOVIE(MOV.I-1).cdata = []; 
                pause(0.04)
                drawnow;
                %debug:
                %length(findall(gca, 'Type', 'image'))
                %length(findobj(handles.movie))
                guidata(hObject,handles);
            end

       %MAIN.hm = imshow(MAIN.BEHMOVIE(MOV.I).cdata,'Parent',handles.movie);
       guidata(hObject,handles);

    end
   %MOV.waitFrame = imshow(MAIN.BEHMOVIE(MOV.I).cdata,'Parent',handles.movie);
   %delete(MOV.waitFrame);
   guidata(hObject,handles);
end

%---------------------------------------------------------------------------
%slider for the accelerometer plot
function sliderAcc_Callback(hObject, eventdata, handles)
    
    global MAIN ACC SAMPLE MOV
   
    set(handles.buttonPause,'String','Run');
    vpi = get(hObject,'value');
    synchState = get(handles.toggleSynch,'UserData');
    
    if MAIN.initTime==1
            MAIN.Icounter = ACC.I+ (vpi/MAIN.vpSpd);
            toMovF = SAMPLE.movStart(MAIN.sampleIndex)+round(MAIN.Icounter);

            if synchState == 0
                
                set(handles.sliderBeh, 'value',round(MAIN.Icounter));
                
                
            else
            %SAMPLE.movStart(MAIN.sampleIndex)+toMovF
            %    set(handles.sliderBeh, 'value', SAMPLE.movStart(MAIN.sampleIndex)...
            %        +toMovF);
                
                set(handles.sliderBeh, 'value',toMovF);
            end    
            set(ACC.VP,'XData', [vpi vpi]);    
            MOV.waitFrame = imshow(read(MAIN.VID,toMovF),'parent',handles.movie);
            set(handles.textVidstamp, 'String', ...
                    datestr(MOV.frameInfo(toMovF,:),'HH:MM:SS.FFF'));         
            set(handles.textVidframe, 'String', toMovF);
            MOV.I = toMovF;
      
    end
  
    drawnow
    %set(handles.accPlot,'xlim',get(hObject,'value')+[0 size(ACCDAT.X,1)]);
         
    guidata(hObject,handles);
end 

 
%--------------------------------------------------------------------------
%slider for movie
function sliderBeh_Callback(hObject, eventdata, handles)
    global MAIN MOV ACC SAMPLE
    set(handles.buttonPause,'String','Run');
    synchState = get(handles.toggleSynch,'UserData');
    
    if MAIN.initTime==1
       
        
        if synchState == 0
          slidPos = get(hObject,'value'); 
          MAIN.Icounter = 1+round(slidPos);
          toMovF = SAMPLE.movStart(MAIN.sampleIndex)+round(slidPos);
          vpi = floor(ACC.I+(MAIN.vpSpd*MAIN.Icounter));
          
          MOV.waitFrame = imshow(read(MAIN.VID,toMovF), 'parent', handles.movie);
          
          set(ACC.VP,'XData',[vpi vpi]);
          set(handles.sliderAcc, 'value', vpi);
          
          set(handles.textVidframe, 'String', toMovF);
          set(handles.textVidstamp, 'String', datestr(MOV.frameInfo(toMovF,:),'HH:MM:SS.FFF'));         
          
          MOV.I = toMovF;
        elseif synchState == 1
            
            slidPos = get(hObject,'value');
            MOV.fSynch = 0+floor(slidPos);
            
            MOV.waitFrame = imshow(read(MAIN.VID,MOV.fSynch), 'parent', handles.movie);
            
            set(hObject,'value', MOV.fSynch);
            set(handles.textVidframe, 'String', MOV.fSynch);
            set(handles.textVidstamp, 'String', datestr(MOV.frameInfo(MOV.fSynch,:),'HH:MM:SS.FFF'));         
            
            MOV.I = MOV.fSynch;
        end
    end
    
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
end
% --------------------------------------------------------------------
%Initializes the program with the loaded movie and acceleration data

function initialise(timeInit)

    global MAIN ACCDAT MOV ACC SCHEME
    
    MAIN.loadN = 1;
    MAIN.buffer = 1;
    %MAIN.loadedAcc = 0;
    %MAIN.loadedMov = 0;
    MAIN.modusAut = 1;
    %MAIN.sampleIndex = 1; 
    %MAIN.InitType = 0; 
    %MAIN.win = 100;
    %MAIN.firstInit = 1;
    
    
    handles = guidata(gcbo);
    axis(handles.accPlot, 'on')
    ACC.I=1; MOV.I=1;
    MAIN.p = [];
    MAIN.patches = [];
    ACC.corrAccFrame(1)=0;
    ACC.synchIndex=0;
    ACC.falseEmpty = 0; 
    MAIN.bufferOn = 0;
    MAIN.speed = (1-get(handles.sliderSpeed,'Value'))/10;
    %create an empty annotation matrix
    %assignin('base','annotations',[]);
    
    
    arrayfun(@cla,findall(0,'type','axes'));      
    set(handles.buttonPause,'String',handles.Strings{1});
    set(handles.sliderBeh, 'value', 0);
    set(handles.sliderAcc, 'value', 0);
    
    hold(handles.accPlot, 'on');
    %set(handles.accPlot, 'DrawMode', 'fast');
    %set(handles.movie, 'DrawMode', 'fast');
    
    pause on;
    %fill listbox
    if MAIN.loadedAnn == 1

    else
        SCHEME.fileName = '';
        SCHEME.list = cell(1,1);
        SCHEME.data = {[] {} []};
    end
    fillListbox

    switch MAIN.initTime
        case 1
            %init the movie
            [MAIN.BEHMOVIE, MOV.nOfFrames, fr] = readBehMovie(MAIN.VID,1,MAIN.loadN);
            MOV.fps = fr;
            ACC.fps = 20;
            MAIN.vpSpd = ACC.fps/MOV.fps;
            MAIN.movSpd = 1/MAIN.vpSpd;
            %MAIN.toFrame=1;
            %MAIN.sampleIndex = 1;
            %MAIN.toSampleIndex = 1;    
            ACCDAT.annMatrix = [];
            ACC.VPY = get(handles.accPlot,'ylim');
            ACC.VP = plot(handles.accPlot,[ACC.I ACC.I],ACC.VPY, '-ks');
            MAIN.bufferState=0;
            MAIN.vidInitTime = initVidTime(MAIN.iHour,MAIN.iMin,MAIN.iSec,MAIN.iFF); 
            if MAIN.firstInit == 1
                checkAccData(ACCDAT.nOfSamples);             
                %initTimeseries  


                [MAIN.firstPossSample, MAIN.lastPossSample] = findPossSamples;
                makeSamples                       
            end
            %MAIN.sampleIndex = MAIN.firstPossSample;
            MAIN.sampleIndex = 1;
            sampleSelection(MAIN.sampleIndex,handles);
            %MAIN.p = plotAcc(handles.accPlot,1,MAIN.maxX);

            set(handles.textDatetime, 'String', strcat(num2str(ACCDAT.sampleDay),'-',...
                num2str(ACCDAT.sampleMonth),'-',num2str(ACCDAT.sampleYear),' / ',...
                datestr(ACCDAT.sampleTime(ACCDAT.possSamples(MAIN.sampleIndex)),13)))
            set(handles.textSample, 'String', strcat(num2str(MAIN.sampleIndex), ' / ',...
            num2str(MAIN.lastPossSample)));
            %set(handles.textSample, 'String', ACC.I); 
            sampleSelState(1)
            MAIN.hm = findobj(handles.movie,'type','image');
            set(MAIN.hm,'EraseMode','normal');
            set(gcf,'doublebuffer','on');
            set(handles.textVidframe, 'String', MOV.I);
            set(handles.buttonPause, 'Enable', 'on');
            set(handles.sliderBeh, 'Enable', 'on');
            set(handles.sliderAcc, 'Enable', 'on'); 
            set(handles.textLoadedAcc, 'String', strcat('Data: ',ACCDAT.fileName));
            set(handles.textLoadedBeh, 'String', strcat('Movie: ',MOV.fileName));
            set(handles.textBuffer, 'String', ' ');
            set(handles.toggleSynch,'Userdata',0);
   
        
        case 0
          ACCDAT.annMatrix = [];
          MAIN.vidInitTime = 0;
          checkAccData(ACCDAT.nOfSamples);             
          [MAIN.firstPossSample, MAIN.lastPossSample] = findPossSamples;
          makeSamples
          MAIN.sampleIndex = 1;
          sampleSelection(MAIN.sampleIndex,handles);  
          sampleSelState(1)
          set(handles.buttonPause, 'Enable', 'off');
          set(handles.sliderBeh, 'Enable', 'off');
          set(handles.sliderAcc, 'Enable', 'off'); 
          set(handles.toggleSynch, 'Enable', 'off');
          set(handles.sliderSpeed, 'Enable', 'off');
          set(handles.checkBuffer, 'Enable', 'off');
          set(handles.toggleSynch, 'Enable', 'off');
          set(handles.textLoadedAcc, 'String', strcat('Data: ',ACCDAT.fileName));
    end
    

    
    %initializing has finished. enable the functions
    toolState('on');
    
    MAIN.firstInit = 0;
    guidata(gcbo,handles);
    
end


function vidTime = initVidTime(hour,minutes,seconds,ff)
    global MOV;
    global ACCDAT; 
    
    MOV.frameInfo = zeros(MOV.nOfFrames,1);
    
    seconds = seconds+(ff/100);
    vidTime = datenum([ACCDAT.sampleYear(1) ACCDAT.sampleMonth(1) ...
    ACCDAT.sampleDay(1) hour minutes seconds]);
    incr = 1/MOV.fps;
    
    for i = 1:MOV.nOfFrames
        MOV.frameInfo(i) = datenum([ACCDAT.sampleYear(1) ACCDAT.sampleMonth(1) ...
        ACCDAT.sampleDay(1) hour minutes seconds]);
        seconds = seconds+incr;
    end
end

function checkAccData(nOfSamples)
    
    global ACCDAT SAMPLE;

    %keep a copy of the original data for reconstruction
    ACCDAT.XcellO = ACCDAT.Xcell;
    ACCDAT.YcellO = ACCDAT.Ycell;
    ACCDAT.ZcellO = ACCDAT.Zcell;
    
    ACCDAT.maxLength = max(cellfun(@length,ACCDAT.Xcell));
    
    for i = 1:nOfSamples
        lX = length(ACCDAT.Xcell{i});
        lY = length(ACCDAT.Ycell{i});
        lZ = length(ACCDAT.Zcell{i});
        
        maxLength = max([lX,lY,lZ]);
        minLength = min([lX,lY,lZ]);
        
        if (ACCDAT.maxLength-maxLength)>6 || (maxLength-minLength)>2
            SAMPLE.sampleOK(i)=0;
        else 
            SAMPLE.sampleOK(i)=1;
        end
        
        if lX<maxLength
            ACCDAT.Xcell{i}(:,end+1:end+(maxLength-lX))=0;
        end
        if lY<maxLength
            ACCDAT.Ycell{i}(:,end+1:end+(maxLength-lY))=0;
        end
        if lZ<maxLength
            ACCDAT.Zcell{i}(:,end+1:end+(maxLength-lZ))=0;
        end

        
    end
    
end

function [firstPossSample,lastPossSample] = findPossSamples
    global MAIN ACCDAT MOV SAMPLE; 
    
    i = 1;
    ACCDAT.possSamples = [];
    SAMPLE.movStart = [];
%    c = intersect(MOV.frameInfo,ACCDAT.sampleTime)

    

     if (MAIN.accOnly==0)
         try
         
             while i<=ACCDAT.nOfSamples
             %while i<=1
                 sampleTime = ACCDAT.sampleTime(i);
                 diffs = abs(MOV.frameInfo - sampleTime);

                 %if MOV.fps == 25

                     [~,movFrame] = min(diffs);
                     %movFrame = find(MOV.frameInfo == sampleTime,1);
                 %else
                 %end

                 if ~isempty(movFrame) && (movFrame+(size(ACCDAT.Xcell{i},2)*MAIN.movSpd))<=MOV.nOfFrames
                     SAMPLE.movStart(end+1) = movFrame;
                     ACCDAT.possSamples(end+1) = i;
                 end
                 i=i+1;
             end
             
         catch E1
             errordlg('Error finding possible samples.');
         end
                 
     else
         ACCDAT.possSamples = (1:ACCDAT.nOfSamples);
             
         
         
     end

    firstPossSample = 1;
    lastPossSample = ACCDAT.possSamples(end);
end    

function makeSamples

    global ACCDAT MOV SAMPLE MAIN

    SAMPLE.acc = cell(ACCDAT.nOfSamples,1);
    SAMPLE.accTimes = cell(ACCDAT.nOfSamples,1);
    
    nOfPossS = length(ACCDAT.possSamples);
    for j=1:nOfPossS
        
        i = ACCDAT.possSamples(j);
        
%        try

        if ACCDAT.cal == 0
            
            if ACCDAT.calPars(:)==0
                SAMPLE.acc{j} = [ACCDAT.Xcell{i}'./1365,ACCDAT.Ycell{i}'./1365,...
                    ACCDAT.Zcell{i}'./1365];
            else
                X = (ACCDAT.Xcell{i}' - ACCDAT.calPars(1))/ ACCDAT.calPars(2);
                Y = (ACCDAT.Ycell{i}' - ACCDAT.calPars(3))/ ACCDAT.calPars(4);
                Z = (ACCDAT.Zcell{i}' - ACCDAT.calPars(5))/ ACCDAT.calPars(6);
                SAMPLE.acc{j} = [X Y Z];
                
                             
            end
        else
            
            SAMPLE.acc{j} = [ACCDAT.Xcell{i}',ACCDAT.Ycell{i}',...
                ACCDAT.Zcell{i}'];
        end
        
        SAMPLE.accTimes{j} = calcAccFrameTimes(i);
%             if MOV.fps == 25  
%                 SAMPLE.movStart(j) = find(MOV.frameInfo == SAMPLE.accTimes{j}(1),1,'first');                 
%             else
%                 in = datefind(sampleTime, MOV.frameInfo, 0.000001);
%                 SAMPLE.movStart(j) = ind(1);
%                 
%             end
      %      if MAIN.accOnly==0
      %          SAMPLE.movEnd(j) = MOV.frameInfo(SAMPLE.movStart(j)+round(size(SAMPLE.acc{j},1)*MAIN.movSpd));
      %      end
%        catch NS
%            ACCDAT.possSamples(j) = [];
%            continue
%        end
            
            
    end
    %ACCDAT.Xcell{1}
    %size(SAMPLE.acc(1))
end

function frameTimes = calcAccFrameTimes(samplenr)

    global ACCDAT
    
    thisSample = datevec(ACCDAT.sampleTime(samplenr));
    seconds = thisSample(6);
    
    for j=1:size(thisSample,1)
        frameTimes = datenum([thisSample(1) thisSample(2) ...
            thisSample(3) thisSample(4) thisSample(5) seconds]);
        seconds = seconds+0.05;
    end
end

function initTimeseries
    global ACCDAT ACC MAIN
    
    %collect all samples.
    X = []; Y = []; Z = [];
    %X = zeros(numel([ACCDAT.Xcell{1:end}]), 3);
    %Y = zeros(numel([ACCDAT.Ycell{1:end}]), 3);
    %Z = zeros(numel([ACCDAT.Zcell{1:end}]), 3);
     
    for i = 1:ACCDAT.nOfSamples  
        ind = i*ones(length(ACCDAT.Xcell{i}),1);
        offset = 0:length(ACCDAT.Xcell{i})-1;
        %device = ACCDAT.sampleID(i)*ones(length(ACCDAT.Xcell{i}),1);
        %hour = ACCDAT.sampleHour(i);
        %min = ACCDAT.sampleMin(i);
        %sec = ACCDAT.sampleSec(i);
        %timestr = datestr([2000 01 01 hour min sec],13);
        ax = ACCDAT.Xcell{i}'; ay = ACCDAT.Ycell{i}'; az = ACCDAT.Zcell{i}';
        %Xi = [ax./1365, ind, offset']; 
        %Yi = [ay./1365, ind, offset']; 
        %Zi = [az./1365, ind, offset']; 
        X = [X; ax./1365, ind, offset'];
        Y = [Y; ay./1365, ind, offset'];
        Z = [Z; az./1365, ind, offset'];
    end
    
    ACCDAT.X = X; ACCDAT.Y = Y; ACCDAT.Z = Z;
    
    %build the times for each acc.frame
    j= 1;
    MAIN.maxX = size(ACCDAT.X,1);
    
end 
%     for i=1:ACCDAT.nOfSamples   
%          
%          thisSample = datevec(ACCDAT.sampleTime(i));
%          seconds = thisSample(6);
%          indexes = find(ACCDAT.X(:,2)==i);
%          index = indexes(1);
%          
%          for j=1:length(indexes)
%              ACC.frameInfo(index) = datenum([thisSample(1) thisSample(2) ...
%                  thisSample(3) thisSample(4) thisSample(5) seconds]);
%              seconds = seconds+0.05;
%              
%              index = index+1;
%              
%          end
%     end
%     
   
     
function [behFrames,vidLength,fr] = readBehMovie(vid, startFrame, endFrame)
    
    nOfFrames = endFrame-startFrame;
    vidLength = vid.NumberOfFrames;
    vidHeight = vid.Height;
    fr = vid.FrameRate;
    vidWidth = vid.width;
%    behFrame = [];    
     behFrames(1:vidLength) = ...
         struct('cdata', zeros(vidHeight, vidWidth,3, 'uint8'),...
            'colormap', []);
 
%     for i=startFrame:endFrame
%         behFrames(i).cdata = read(vid,i);
%     end
end 
% --------------------------------------------------------------------

function toggleSelect_Callback(hObject, eventdata, handles)
    
    global ACC ACCDAT MOV MAIN SCHEME
    
    MAIN.patches = [];
    toggleState = get(hObject,'Value');

    anns = evalin('base', 'annotations');
    
    %imshow(MAIN.BEHMOVIE(MOV.I).cdata);
  
    if toggleState == 1
        %MOV.waitFrame = imshow(read(MAIN.VID,MOV.I),'Parent',handles.movie);
        axes(handles.accPlot);
        
        try
            if ~isempty(anns)
                dualcursor([anns(end,2), anns(end,3)],[],[],[],[]);
                %dualcursor on;                     
            else
                dualcursor([],[],[],[],[]);
            end
        catch E1
           errordlg('no annotation possible');
        end
            
        set(handles.annListbox, 'Enable', 'on');
    else
        dualcursor off;          
        MOV.waitFrame = [];
        set(handles.annListbox, 'Enable', 'off');
    end
    
    guidata(hObject,handles);
end    
    
 function colorTags(varargin)
        global SCHEME MAIN;
        
        handles = guidata(gcbo);
        axes(handles.accPlot);
        delete(findobj('type','patch'));
        refresh;
        anns = evalin('base', 'annotations');
        
        
        if ~isempty(anns)
            if size(varargin,2)==2
                accRegBegin = varargin{1};
                accRegEnd = varargin{2};
                [r,~] = find(anns(:,2)>=accRegBegin & anns(:,3)<=accRegEnd &...
                    anns(:,1)==MAIN.sampleIndex);
                anns = anns(r,:);
            end
            
            for i = 1:size(anns,1)

                range = [anns(i,2) anns(i,3)+1 anns(i,3)+1 anns(i,2)];

                %lim = ylim;

                yrange = [-2.5 -2.5 3 3];

                zs = -20;
                %colour = find(MAIN.tagColours == anns(i,3));
                tag = anns(i,4);
                index = find(SCHEME.data{1}==tag);

                if isnan(anns(i,4))==0
                    patch(range, yrange,zs*ones(size(range)),...
                        [SCHEME.data{3}(index,1),SCHEME.data{3}(index,2),...
                        SCHEME.data{3}(index,3)]);
                end
                
            end
        end
        
 end     
    
function pushNextSample_Callback(hObject, eventdata, handles)
    global MAIN;global ACCDAT;

    gotoSample = str2double(get(handles.editGoto, 'String'));
   
    if isnan(gotoSample)
        sampleSelection(MAIN.sampleIndex+1,handles)
        
    %if MAIN.sampleIndex+1>MAIN.lastPossSample
    %    set(handles.pushNextSample, 'Enable', 'off')
    %end
    %set(handles.pushPrevSample, 'Enable', 'on');
    else
        sampleSelection(gotoSample,handles)
        set(handles.editGoto, 'String', 'goto');
    end
    
    
    MAIN.bufferState=0;
    
    
    
    guidata(hObject,handles);
end
    
function pushPrevSample_Callback(hObject, eventdata, handles)

    global MAIN;
    
    if MAIN.Icounter>1 && MAIN.accOnly==0
        sampleSelection(MAIN.sampleIndex,handles);
        MAIN.bufferState=1;             
    else
        sampleSelection(MAIN.sampleIndex-1,handles)
        MAIN.bufferState=0;
    end
    
    %if MAIN.sampleIndex-1<MAIN.firstPossSample 
    %    set(handles.pushPrevSample, 'Enable', 'off');
    %end
    %set(handles.pushNextSample, 'Enable', 'on');

    
    guidata(hObject,handles)
end
    

function sampleSelection(toSample,handles)
    global MAIN ACCDAT ACC MOV SAMPLE;
   
    handles = guidata(gcbo);
    
    toggleState = get(handles.toggleSelect,'Value');
    set(handles.pushNextSample, 'Enable', 'off');
    set(handles.pushPrevSample, 'Enable', 'off');
    MAIN.toSampleIndex = toSample;
    anns = evalin('base', 'annotations');
    
    if MAIN.accOnly == 0
        cla(handles.movie);

        MAIN.Icounter = 0;
        MOV.waitFrame = [];

        %DEBUG
        %length(findobj(handles.accPlot))
        %length(findobj(handles.movie))

        try    
            delete(ACC.VP);
            delete(MAIN.p);        

            MAIN.toFrame = SAMPLE.movStart(toSample);

            MOV.I = SAMPLE.movStart(toSample);
            ACC.I = 0;
            ACC.endI = size(SAMPLE.acc{toSample},1);
            ACC.VPI=0;

            MAIN.sampleIndex = MAIN.toSampleIndex;
            sampleSelState(1)
            MOV.waitFrame = imshow(read(MAIN.VID,MAIN.toFrame),'Parent',handles.movie);

            MAIN.p = plotSample(handles.accPlot,SAMPLE.acc{toSample});
            ACC.VPY = get(handles.accPlot,'ylim');
            ACC.VP = plot(handles.accPlot,[ACC.I ACC.I],ACC.VPY, '-ks');

            set(handles.sliderBeh,'value', 0, 'max', floor(ACC.endI*MAIN.movSpd) ,'min',0);
            set(handles.sliderAcc, 'value',0, 'max', ACC.endI, 'min',0); 


            catch FrameFind
               if isempty(MAIN.toFrame)
                   errordlg(...
                      'Error selecting samples');
               end      
               set(handles.buttonPause,'String',handles.Strings{1});

         end   

            set(handles.textDevice, 'String', ACCDAT.sampleID...
                (MAIN.sampleIndex))
            
            
            set(handles.textSample, 'String', strcat(num2str(MAIN.sampleIndex), ' / ',...
                num2str(MAIN.lastPossSample)));
            set(handles.textVidframe, 'String', MAIN.toFrame)
            set(handles.textVidstamp, 'String', datestr(MOV.frameInfo...
                (MAIN.toFrame,:),'HH:MM:SS.FFF'))
            if ~isnan(ACCDAT.gpsSpd(1))
                set(handles.textSpd, 'String', num2str(ACCDAT.gpsSpd(MAIN.sampleIndex)))
            else
                set(handles.textSpd, 'String', '')
            end
    
    else
        delete(MAIN.p);
        MAIN.sampleIndex = MAIN.toSampleIndex;
        ACC.I = 0;
        ACC.endI = size(SAMPLE.acc{toSample},1);

        MAIN.Icounter = round(size(SAMPLE.acc{toSample},1)/2);
        MAIN.p = plotSample(handles.accPlot,SAMPLE.acc{toSample});
        set(handles.textDevice, 'String', ACCDAT.sampleID...
                (MAIN.sampleIndex))
        set(handles.textSample, 'String', strcat(num2str(MAIN.sampleIndex), ' / ',...
                num2str(MAIN.lastPossSample)));
            
        if ~isnan(ACCDAT.gpsSpd(1))
            set(handles.textSpd, 'String', num2str(ACCDAT.gpsSpd(MAIN.sampleIndex)))
        else
            set(handles.textSpd, 'String', '')
        end
            
    
    end
    
    %set(handles.accPlot,'xlim', [ACC.I ACC.endI]);
    if get(handles.checkHold, 'Value')==0
        set(handles.sliderScale, 'value', 0);
    end
    set(handles.accPlot,'ylim', [-2.5 3]);
    set(handles.textDatetime, 'String', strcat(num2str(ACCDAT.sampleDay),'-',...
                num2str(ACCDAT.sampleMonth),'-',num2str(ACCDAT.sampleYear),' / ',...
                datestr(ACCDAT.sampleTime(ACCDAT.possSamples(MAIN.sampleIndex)),13)))
    sampleSelState(1)    
    if SAMPLE.sampleOK(MAIN.sampleIndex)==0
        set(handles.textNotSynch, 'String', '! synch.: data corrupt')
    else
        set(handles.textNotSynch, 'String', ' ')
    end
 
    
    if toggleState==get(handles.toggleSelect,'Max')
        try
            if ~isempty(anns)
                       
                    dualcursor([anns(end,2), anns(end,3)],[],[],[],[]);
            else
                    
                    dualcursor([],[],[],[],[]);
            end
                %dualcursor on;                     
        catch E1
        end
    end
    
    colorTags(ACC.I,ACC.endI);

    guidata(gcbo,handles);

end 

% The menu objects.
% --------------------------------------------------------------------
function ToolInit_ClickedCallback(hObject, eventdata, handles)
    menuInit_Callback(handles.menuInit,[],handles);
end

% --------------------------------------------------------------------
function uipushtoolOpen_ClickedCallback(hObject, eventdata, handles)
end

function uvaPush_ClickedCallback(hObject, eventdata, handles)
   about;
end


% --------------------------------------------------------------------
function menuAnalyse_Callback(hObject, eventdata, handles)
end 
% --------------------------------------------------------------------
function menuFFT_Callback(hObject, eventdata, handles)
    selection = errordlg(['Not yet implemented' ],...
                ['error']);
    
    guidata(hObject,handles);
end
% --------------------------------------------------------------------
function menu_correlation_Callback(hObject, eventdata, handles)
    error = errordlg(['Not yet implemented' ],...
                ['error']);
            
    guidata(hObject,handles);
end
% --------------------------------------------------------------------
function menu_export_Callback(hObject, eventdata, handles)
    global ACCDAT;

    
    annotations = evalin('base', 'annotations');
        
    if ~isempty(annotations)
        for i = 1:ACCDAT.nOfSamples
        
            r = find(annotations(:,1)==i);
            
            ACCDAT.ANN{i}=zeros(size(ACCDAT.Xcell{i}',1),2);
            
            for j = 1:size(r,1)
           
               
               ACCDAT.ANN{i}(annotations(r(j),2):annotations(r(j),3),1)=annotations(r(j),4);
           
            if ~isnan(ACCDAT.gpsSpd(1))
                   ACCDAT.ANN{i}(annotations(r(j),2):annotations(r(j),3),2)=annotations(r(j),6);
            end

                      
                
           end
        end
        
    end
    
%     for i = 1:ACCDAT.nOfSamples
%         fI = find(ACCDAT.X(:,2)==i,1,'first');
%         lI = find(ACCDAT.X(:,2)==i,1,'last');
%         ACCDAT.ANN{i} = ACCDAT.annMatrix(fI:lI,:);
%     end
    
%    ACCDAT.plotData = [ACCDAT.X(:,2:3), ACCDAT.X(:,1),ACCDAT.Y(:,1),...
%        ACCDAT.Z(:,1), ACCDAT.annMatrix];

    outputStruct = struct('nOfSamples', {ACCDAT.nOfSamples}, 'sampleID',...
        {ACCDAT.sampleID'},'year',{ACCDAT.sampleYear'}, 'month', ...
        {ACCDAT.sampleMonth'}, 'day', {ACCDAT.sampleDay'}, 'hour', ...
        {ACCDAT.sampleHour'}, 'min', {ACCDAT.sampleMin'}, 'sec', {ACCDAT.sampleSec},...
        'accX', {ACCDAT.Xcell'}, 'accY', {ACCDAT.Ycell'},'accZ', {ACCDAT.Zcell'},...
        'accP', {ACCDAT.Pcell'}, 'accT', {ACCDAT.Tcell'}, 'tags',{ACCDAT.ANN}, 'annotations', {annotations},...
        'gpsSpd', {ACCDAT.gpsSpd});
    
    
    [name, path] = uiputfile('*.mat', 'Export data as .mat file');
       
       if isequal(name,0) || isequal(path,0)
           
       else
           fn = strcat(path,name);
           save(fn, 'outputStruct');
       end
    
       
    guidata(hObject,handles);
end 

% --------------------------------------------------------------------
function uipushtoolSave_ClickedCallback(hObject, eventdata, handles)

    menu_export_Callback(handles.menu_export,[],handles);
end 

% --------------------------------------------------------------------
function menuSession_Callback(hObject, eventdata, handles)
% hObject    handle to menuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function menuFlow_Callback(hObject, eventdata, handles)

end

% --------------------------------------------------------------------
function SessionImport_Callback(hObject, eventdata, handles)

    clear global
    global MAIN SCHEME ACC ACCDAT MOV SAMPLE;
    
    [file,path] = uigetfile('*.mat');
    
    
    if ~isequal(file,0)
       try
          file = strcat(path,file);
          lf = load(file);
          sn = fieldnames(lf);
          sessionStruct = lf.(sn{1});
          MAIN.accOnly = sessionStruct.accOnly;
          assignin('base','annotations', sessionStruct.annotations);
          MAIN.speedOK = 1;
          
          if MAIN.accOnly == 0
              ACCDAT = sessionStruct.accdat;
              % ------------ by Elena Ranguelova, 31.07.2014--------------
              if verLessThan('MATLAB','7.11') 
                MAIN.VID = mmreader(sessionStruct.movF);
              else
                MAIN.VID = VideoReader(sessionStruct.movF);
              end     
              %-----------------------------------------------------------
              
              MOV.fileName = sessionStruct.movF;
              ACC = sessionStruct.acc;
              SAMPLE = sessionStruct.samples;
              timeVec = datevec(sessionStruct.time);
              MOV = sessionStruct.mov;
              MAIN.firstPossSample = sessionStruct.fPoss;
              MAIN.lastPossSample = sessionStruct.lPoss;
              MAIN.loadedAcc = 1;
              MAIN.loadedMovie = 1;
              MAIN.loadedAnn = sessionStruct.loadedAnn;
              SCHEME = sessionStruct.scheme;
              MAIN.firstInit = 0;

              if sessionStruct.timeInit == 1

                    MAIN.iHour = timeVec(4);
                    MAIN.iMin = timeVec(5);
                    MAIN.iSec = timeVec(6);
                    MAIN.iFF= 00;
                    MAIN.initTime = 1;

                    initialise(1);

              else

                    MAIN.initTime = 0;
                    initialise(0);
              end
              
          else
                    ACCDAT = sessionStruct.accdat;

                    MOV.fileName = sessionStruct.movF;
                    ACC = sessionStruct.acc;
                    SAMPLE = sessionStruct.samples;
                    timeVec = datevec(sessionStruct.time);

                    MAIN.firstPossSample = sessionStruct.fPoss;
                    MAIN.lastPossSample = sessionStruct.lPoss;
                    MAIN.loadedAcc = 1;
                    MAIN.loadedMovie = 0;
                    MAIN.loadedAnn = sessionStruct.loadedAnn;
                    SCHEME = sessionStruct.scheme;
                    MAIN.firstInit = 0;
                    MAIN.initTime = 0;
                    
                    initialise(0);
              
              
          end            
          sampleSelection(sessionStruct.sIndex)        
          
          
          guidata(hObject,handles);
          colorTags(ACC.I, ACC.endI);
      catch E1
         
         errordlg(strcat('Error importing:',file))
          
      end
    else
        
      MAIN.loadedAcc = 0;
      MAIN.loadedMovie = 0;
        
    end
      
    guidata(hObject,handles);

    
end 
    
   
% --------------------------------------------------------------------
function SessionSave_Callback(hObject, eventdata, handles)
    global MAIN MOV ACC ACCDAT SCHEME SAMPLE
    
    try
        anns = evalin('base', 'annotations');
       
        sessionStruct = struct('accdat', {ACCDAT},'acc', {ACC},...
            'scheme',{SCHEME}, 'movF', {MOV.fileName}, 'samples',SAMPLE,...
            'loadedAnn',{MAIN.loadedAnn},'sIndex', {MAIN.sampleIndex},...
            'timeInit',{MAIN.initTime},'time',{MAIN.vidInitTime},...
            'annotations', {anns}, 'fPoss',{MAIN.firstPossSample}, 'lPoss',...
            {MAIN.lastPossSample}, 'mov', {MOV}, 'accOnly', {MAIN.accOnly});

       % orAccFile = strrep(ACCDAT.fileName,'.mat', '');
       % nowNum = now; nowStr = datestr(nowNum,30);
       % title = ['SESSION_',orAccFile,nowStr];

       [name, path] = uiputfile('*.mat', 'Save session');
       
       if isequal(name,0) || isequal(path,0)
           
       else
           fn = strcat(path,name);
           save(fn, 'sessionStruct');
       end
       
    catch SE
       errordlg('Error saving session')
    end
       
end


% --------------------------------------------------------------------
function session_new_Callback(hObject, eventdata, handles)
    
    
    global ACCDAT MOV MAIN SCHEME
   
    [~, vars, ACCDAT, SCHEME] = newSession;

    if isempty(vars)==0
        
        ACCDAT.fileName = vars.accFilename;
        MAIN.loadedAcc = vars.loadedAcc;
        MAIN.loadedMovie = vars.loadedMovie;
        MAIN.loadedAnn = vars.loadedAnn;
        MAIN.firstInit = 1;
        MAIN.speedOK = 1;
        assignin('base','annotations',vars.anns);
 
        try
  
        if vars.loadedAcc==1 && vars.loadedMovie == 1
            MAIN.VID = vars.VID;
            MOV.fileName = vars.movFileName;
            MAIN.accOnly=0;
            
            %if MAIN.initTime == 1
                guidata(hObject,handles);
                MAIN.iHour = vars.iHour;
                MAIN.iMin = vars.iMin;
                MAIN.iSec = vars.iSec;
                MAIN.iFF= vars.iFF;
                MAIN.initTime = 1;
                initialise(1);

                
         elseif vars.loadedAcc==1 && vars.loadedMovie == 0
                MOV.fileName = '';
                MAIN.accOnly = 1;
                MAIN.initTime = 0;
                
                initialise(0);
                
        end
             
        catch EI
            errordlg('Error occurred during initialisation')
        end
              
    set(handles.SessionSave, 'Enable', 'on');
    set(handles.exportMat, 'Enable', 'on');
    set(handles.exportCsv, 'Enable', 'on');
    
    end
    
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function exportCsv_Callback(hObject, eventdata, handles)

   global ACCDAT

   annotations = evalin('base', 'annotations');
    
   csvIndex = [];
   csvID = []; 
   csvX = [];
   csvY =[];
   csvZ =[];
   csvANN = [];
   y = [];
   m = [];
   d= [];
   h = [];
   mi = [];
   s = [];
   csvGps = [];
   
   for i = 1:ACCDAT.nOfSamples
       ACCDAT.ANN{i}=zeros(size(ACCDAT.Xcell{i}',1),2);    
       
       
       if ~isempty(annotations)
           r = find(annotations(:,1)==i);
       
           for j = 1:size(r,1)
           
               
               ACCDAT.ANN{i}(annotations(r(j),2):annotations(r(j),3),1)=annotations(r(j),4);
           
               if ~isnan(ACCDAT.gpsSpd(1))
                   ACCDAT.ANN{i}(annotations(r(j),2):annotations(r(j),3),2)=annotations(r(j),6);
               end

                      
                
           end
                              
       end
       xs = size(ACCDAT.Xcell{i}',1);
       csvX = [csvX; ACCDAT.Xcell{i}'];
       csvY = [csvY; ACCDAT.Ycell{i}'];
       csvZ = [csvZ; ACCDAT.Zcell{i}'];
       csvIndex = [csvIndex;(0:xs-1)'];
       csvID(end+1:end+xs,1) = ACCDAT.sampleID(i);
       csvGps(end+1:end+xs,1) = ACCDAT.gpsSpd(i);
       csvANN = [csvANN;ACCDAT.ANN{i}];
       y(end+1:end+xs,1) = ACCDAT.sampleYear(i);
       m(end+1:end+xs,1) = ACCDAT.sampleMonth(i);
       d(end+1:end+xs,1) = ACCDAT.sampleDay(i);
       h(end+1:end+xs,1) = ACCDAT.sampleHour(i);
       mi(end+1:end+xs,1) = ACCDAT.sampleMin(i);
       s(end+1:end+xs,1) = ACCDAT.sampleSec(i);
   end
    csvDate = [y,m,d,h,mi,s];

    eM = {csvID, csvDate, csvIndex, csvX,...
        csvY, csvZ, csvGps, csvANN};
    
   [fileN,pathN] = uiputfile({'*.csv'},'Export to CSV');
   
   if isequal(fileN,0)
        
   else
       try
        
           csvName = strcat(pathN,fileN);
    
           csvfile = fopen(csvName,'wt');

           for i=1:size(eM{1},1)
    
               st = datestr(eM{2}(i,:), 'mm/dd/yyyy HH:MM:SS');
               
               if isnan(csvGps(1))
                    fprintf(csvfile,'%3.0f, %s, %1.0f, %f, %f, %f, %1.0f\n', eM{1}(i),st,...
                    eM{3}(i), eM{4}(i),eM{5}(i), eM{6}(i), eM{8}(i,1));
               else
                   fprintf(csvfile,'%3.0f, %s, %1.0f, %f, %f, %f, %f, %1.0f %1.0f\n', eM{1}(i),st,...
                    eM{3}(i), eM{4}(i),eM{5}(i), eM{6}(i), eM{7}(i), eM{8}(i,1), eM{8}(i,2));
               end
                   
           end
            
           fclose(csvfile);
       catch E1
            errordlg('Error writing file. Data not exported', 'Writing Error');
       end
            

   end    

end

% --------------------------------------------------------------------
function pushAnnBox_ClickedCallback(hObject, eventdata, handles)
    global SCHEME ACC
    
    ann = evalin('base', 'annotations');
    
    if isempty(ann)==0
        AnnInfo(SCHEME);
        colorTags(ACC.I, ACC.endI)
    
        guidata(hObject,handles);
    else
        
        errordlg('No annotations found', 'Annotation Info')

    end
    

end

function annListbox_Callback(hObject, eventdata, handles)
    global ACC ACCDAT MAIN SCHEME
   
    %get(handles.figure1,'SelectionType');
    try
        if strcmp(get(handles.figure1,'SelectionType'),'open')
               selected = get(hObject,'Value');
               tag = SCHEME.data{1}(selected);
               %annotations = get(hObject,'String');
               dcVals = dualcursor;
                
               if isnan(ACCDAT.gpsSpd(1))
                    annVal = [MAIN.sampleIndex dcVals(1) dcVals(3) tag 0];
               else
                    annVal = [MAIN.sampleIndex dcVals(1) dcVals(3) tag 0 MAIN.speedOK];
               end


               exportAnn(annVal);

               colorTags(ACC.I, ACC.endI);
        end
    catch E1
        errordlg('Error making annotation')
    end
    
end

function annListbox_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function exportAnn(annVal)
    annMat = evalin('base', 'annotations');
    
    assignin('base','annotations', [annMat;annVal]);
    
    %DEBUG
    %disp('annotation added to workspace');
end

function fillListbox

global SCHEME;

handles = guidata(gcbo);

nOfTags = size(SCHEME.data{3},1);

if nOfTags == 0
    set(handles.annListbox,'String','no labels loaded', 'Value', 1);
    set(handles.annListbox, 'Enable', 'off');
else
    
    SCHEME.list = strcat(num2str(SCHEME.data{1}),' - ', SCHEME.data{2});
    SCHEME.coloredList= cell(nOfTags,1);

    if SCHEME.data{3}(1)>=0
        for i = 1:nOfTags

            r=num2str(dec2hex(round(SCHEME.data{3}(i,1)*255),2));
            g=num2str(dec2hex(round(SCHEME.data{3}(i,2)*255),2));
            b=num2str(dec2hex(round(SCHEME.data{3}(i,3)*255),2));  

            SCHEME.coloredList{i} = strcat('<HTML><FONT COLOR="#',strcat(r,g,b),'">',...
                SCHEME.list{i},'</FONT></HTML>');

        end

    else
        for i = 1:nOfTags
            rr = rand(1);
            rg = rand(1);
            rb = rand(1);
            r = num2str(dec2hex(round(rr*255),2));
            g = num2str(dec2hex(round(rg*255),2));
            b = num2str(dec2hex(round(rb*255),2));
            SCHEME.data{3}(i,1)=rr;
            SCHEME.data{3}(i,2)=rg;
            SCHEME.data{3}(i,3)=rb;

            SCHEME.coloredList{i} = strcat('<HTML><FONT COLOR="#',strcat(r,g,b),'">',...
                SCHEME.list{i},'</FONT></HTML>');
        end

    end

    set(handles.annListbox,'String',SCHEME.coloredList, 'Value', 1);
    set(handles.textAnnFile, 'String', strcat('File: ', SCHEME.fileName));
end
end


% --- Executes on button press in buttonClearCol.
function buttonClearCol_Callback(hObject, eventdata, handles)

delete(findobj('type','patch'));

end

% --------------------------------------------------------------------
function menuQuit_Callback(hObject, eventdata, handles)
    
    closeGUI
  
end

function closeGUI(src,evnt)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)
selection = questdlg('Quit?',...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
    delete(gcf)
   case 'No'
     return
end
end


% --------------------------------------------------------------------
function toggleSynch_ClickedCallback(hObject, eventdata, handles)

end

% --------------------------------------------------------------------
function toggleSynch_OffCallback(hObject, eventdata, handles)

    global SAMPLE MAIN MOV
 
    set(hObject,'Userdata',0);    
    
    choice = questdlg('Apply synchronisation?',...
    'Confirm synchronisation', 'apply', 'discard', 'apply');
    
    switch choice
        case 'apply'
            SAMPLE.movStart(MAIN.sampleIndex) = MOV.fSynch-round(MAIN.Icounter);
            
            if MAIN.bufferOn == 1 
                buffer
            end
            
        case 'discard'
            
    end

    sampleSelection(MAIN.sampleIndex);
              
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function toggleSynch_OnCallback(hObject, eventdata, handles)
    
    global MOV SAMPLE MAIN ACC

    mi = SAMPLE.movStart(MAIN.sampleIndex)-200;
    ma = (SAMPLE.movStart(MAIN.sampleIndex)+round(ACC.endI*MAIN.movSpd))+200;
    
    if mi < 1
        mi=1;
    elseif ma > MOV.nOfFrames
        ma=MOV.nOfFrames;
    end
    
    set(handles.sliderBeh,'value', MOV.I, 'max', ma,...
        'min',mi);
    
    set(hObject,'Userdata',1);
    guidata(hObject,handles);
end

function buttonManageLabs_Callback(hObject, eventdata, handles)
    
    global SCHEME ACC
    
    
    ann = evalin('base', 'annotations');
    
    [~,sch] = manageLabs(SCHEME); 
    
    if ~isempty(sch)
        SCHEME = sch;
        SCHEME.list = cell(1,1);
        fillListbox
        colorTags(ACC.I,ACC.endI)
    end
                
    guidata(hObject,handles);

end


function sliderSpeed_Callback(hObject, eventdata, handles)
global MAIN

MAIN.speed = (1-get(hObject,'Value'))/10;

end

function sliderSpeed_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end



function checkBuffer_Callback(hObject, eventdata, handles)
    global MAIN
    
    if get(handles.checkBuffer,'Value')==get(handles.checkBuffer,'Min')
           MAIN.bufferOn = 0;
           MAIN.BEHMOVIE(1:MAIN.VID.NumberOfFrames) = ...
                struct('cdata', zeros(MAIN.VID.Height, MAIN.VID.Width,3, 'uint8'),...
                'colormap', []);
    else  
        MAIN.bufferOn = 1;
    end
end



function speedOk_CreateFcn(hObject, eventdata, handles)
end

function radioSpeedOK_CreateFcn(hObject, eventdata, handles)
end

function speedOk_SelectionChangeFcn(hObject, eventdata)

global MAIN

handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag')
    case 'radioSpeedOK'
        MAIN.speedOK = 1;
       
    case 'radioSpeedNotOK'
        MAIN.speedOK = 0;
    otherwise
end

guidata(hObject, handles)
     
end



function editGoto_Callback(hObject, eventdata, handles)

global ACCDAT

input = str2double(get(hObject,'String'));

if isnan(input) || input < 1 || input > ACCDAT.nOfSamples
    set(hObject, 'String', 'goto');
end
    
sampleSelState(1)

guidata(hObject,handles)
end


function editGoto_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function sliderScale_Callback(hObject, eventdata, handles)

global ACC

set(handles.accPlot,'xlim', [0 ACC.endI+(ACC.endI*get(hObject,'Value'))]);

if get(handles.checkHold,'Value')==1
    ACC.scale = ACC.endI+(ACC.endI*get(hObject,'Value'));
end

end

function sliderScale_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end


function checkHold_Callback(hObject, eventdata, handles)

global ACC

if get(hObject,'Value')==1
    ACC.scale = ACC.endI+(ACC.endI*get(hObject,'Value'));
end

end
