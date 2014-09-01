% function newSession 
%   belongs to accVidGui.m
%   creates a new session, loads and checks the input files and
%   synchronises if desired.
% 
% author: merijn de bakker. e-mail: merijn.debakker@gmail.com
%
% created: 08-07-2011
% revised: 08-07-2011
%
% INPUT: --
% OUTPUT: --
% DEPENDS: accVidGui.m, accVidGui.fig,...
% NOTES: --


function varargout = newSession(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @newSession_OpeningFcn, ...
                   'gui_OutputFcn',  @newSession_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before newSession is made visible.
function newSession_OpeningFcn(hObject, eventdata, handles, varargin)
global VARS SCHEME;
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newSession (see VARARGIN)
handles.flag = 1;
VARS.loadedAcc = 0;
VARS.loadedMovie = 0;
VARS.loadedAnn = 0;
SCHEME = {};
% Choose default command line output for newSession
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.editXs,'UserData', 0)
set(handles.editXo,'UserData', 0)
set(handles.editYo,'UserData', 0)
set(handles.editYs,'UserData', 0)
set(handles.editZo,'UserData', 0)
set(handles.editZs,'UserData', 0)

uiwait(handles.sessionGUI);
end
% UIWAIT makes newSession wait for user response (see UIRESUME)
% uiwait(handles.sessionGUI);

function varargout = newSession_OutputFcn(hObject, eventdata, handles) 

global VARS ACCDAT SCHEME

if handles.flag == 2
    varargout{1} = handles.output;
    varargout{2} = VARS;
    varargout{3} = ACCDAT;
    varargout{4} = SCHEME;
    delete(hObject)
    
elseif handles.flag == 1
    varargout{1} = handles.output;
    varargout{2} = [];
    varargout{3} = [];
    varargout{4} = [];
    delete(hObject)
end
    
end

function openAcc_Callback(hObject, eventdata, handles)
    global VARS ACCDAT SCHEME
    
    [filename,path] = uigetfile({'*.mat';'*.csv'},'load acceleration data');
    
    
    if isequal(filename,0)
       VARS.loadedAcc=0;
    else
        % ------------ by Elena Ranguelova, 31.07.2014--------------
        if verLessThan('MATLAB','7.11') 
            [~,~,ext,~] = fileparts(filename); 
        else
            [~,~,ext] = fileparts(filename);
        end
        %----------------------------------------------------------
        try
            
            VARS.accFilename = strcat(path,filename);
            
            if strcmp(ext, '.csv')==1
                accStruct=convCSV2mat(VARS.accFilename);
            else
                lf = load(VARS.accFilename);
                sn = fieldnames(lf);
                accStruct = lf.(sn{1});
            end
           
            %lf = load(VARS.accFilename);
            %sn = fieldnames(lf);
            %accStruct = lf.(sn{1});
          
            ACCDAT.sampleID = accStruct.ID';
            ACCDAT.nOfSamples = size(ACCDAT.sampleID,1);
            ACCDAT.sampleYear = accStruct.year';
            ACCDAT.sampleMonth = accStruct.month';
            ACCDAT.sampleDay = accStruct.day';
            ACCDAT.sampleHour = accStruct.hour';
            ACCDAT.sampleMin = accStruct.min';
            ACCDAT.sampleSec = accStruct.sec';
            ACCDAT.Xcell = accStruct.accX';
            ACCDAT.Ycell = accStruct.accY';
            ACCDAT.Zcell = accStruct.accZ';
            ACCDAT.Pcell = accStruct.accP';
            ACCDAT.Tcell = accStruct.accT';
            ACCDAT.sampleTime = {};
            ACCDAT.sampleTime = zeros(ACCDAT.nOfSamples,1);          
            
            if isfield(accStruct, 'Spd') && accStruct.Spd(1)~=-1
                ACCDAT.gpsSpd = accStruct.Spd';
                
            else
                ACCDAT.gpsSpd(1:ACCDAT.nOfSamples,1) = NaN;
                
            end
            
            for i = 1:ACCDAT.nOfSamples        
                 ACCDAT.sampleTime(i) = datenum([ACCDAT.sampleYear(i) ...
                    ACCDAT.sampleMonth(i) accStruct.day(i) ACCDAT.sampleHour(i) ...
                    ACCDAT.sampleMin(i) ACCDAT.sampleSec(i)]);
            end

            VARS.anns = [];
            %loading existing annotated data
            if isfield(accStruct, 'tags')
                set(handles.buttonAnnscheme, 'Enable', 'off');
                anns = [];
                allLabs = [];
                for i = 1:size(accStruct.tags,2)
                    thisSample = accStruct.tags{i}(:,1);
                    
                    [b,~,n] = unique(thisSample);
                    c =~isnan(b);
                    labs = b(c);
                    allLabs = [allLabs; labs];
                    
                    for j = 1:length(labs)
                        r = find(thisSample(:,1)==labs(j));
                        id = find(diff(r)~=1)+1;
                        
                        if isempty(id)
                            anns = [anns; i, r(1),r(end),labs(j), 0 ];
                        else
                            anns = [anns; i, r(1),r(id(1)-1), labs(j),0];
                            
                            for k = 2:length(id)
                               
                                anns=[anns; i, r(id(k-1)), r(id(k)),labs(j),0];
                                
                            end
                            
                            anns=[anns; i, r(id(end)), r(end),labs(j),0];
                        end
                    end
                           
                end
                
                VARS.anns = anns; 
                [allLabs, ~, ~] = unique(allLabs);
                names=cell(size(allLabs,1),1);
                names(1:size(allLabs,1),1) = cellstr('unknown');
                colors(1:size(allLabs,1),1:3) = -1;
                VARS.loadedAnn = 1;
                SCHEME.data = {allLabs names colors};
                SCHEME.fileName = 'annotations loaded from existing struct';
            end
                
            VARS.loadedAcc= 1;
            s = ['Loaded data-file: ' VARS.accFilename];
            % ------------ by Elena Ranguelova, 31.07.2014--------------
            if length(s)<45       
                set(handles.accFileText, 'String', s)
            else                
                if verLessThan('MATLAB','7.11') x
                     [~,name,ext,~] = fileparts(s); 
                else
                     [~,name,ext] = fileparts(s);
                end     
                set(handles.accFileText, 'String', strcat(name,ext))
            end
            %----------------------------------------------------------   

            %VARS.accData = accStruct;
            clear('accStruct')
            
       catch E1
           % ------------ by Elena Ranguelova, 31.07.2014--------------
            errordlg('error loading acc. data file','File Error')
            %-----------------------------------------------------------
           
            VARS.loadedAcc = 0;
       end
        
    end
    
    
%   if (get(handles.checkboxSetTime,'Value')==get(handles.checkboxSetTime,'Max')) && (...            
%         VARS.loadedMovie == 0 || VARS.loadedAcc == 0 || strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%             strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1)
%         
%         set(handles.buttonOK, 'Enable', 'off');
%   elseif VARS.loadedMovie == 0 || VARS.loadedAcc == 0 
%         set(handles.buttonOK, 'Enable', 'off');
%   else
%         set(handles.buttonOK, 'Enable', 'on');
%       
%   end
  
  guidata(hObject,handles);
  checkButtonState
end


function openMov_Callback(hObject, eventdata, handles)

   global VARS;
    
   [filename,path] = uigetfile({'*.avi';'*.mj2';'*.mpg';'*.wmv';...
       '*.asf';'*.asx'},'load movie');
   
   if isequal(filename,0)
       VARS.loadedMovie=0;
   else
       try
           VARS.movFileName = strcat(path,filename);
           % ------------ by Elena Ranguelova, 31.07.2014--------------
           if verLessThan('MATLAB','7.11')
                VARS.VID = mmreader(VARS.movFileName);
           else
                VARS.VID = VideoReader(VARS.movFileName);
           end     
           %------------------------------------------------------------
           s = ['Loaded movie: ' VARS.movFileName];

           % ------------ by Elena Ranguelova, 31.07.2014--------------
           if length(s)<45       
               set(handles.movieFileText, 'String', s)
           else                
               if verLessThan('MATLAB','7.11') x
                    [~,name,ext,~] = fileparts(s); 
               else
                    [~,name,ext] = fileparts(s);
               end     
               set(handles.movieFileText, 'String', strcat(name,ext))
           end
           %----------------------------------------------------------   

           %MOV.fileName = s;

           if VARS.VID.FrameRate~=25
       %        errordlg('Wrong framerate');
               str = ['fps: ', num2str(VARS.VID.FrameRate)];
               set(handles.fpsError, 'String', str,'ForegroundColor',[1,0,0]);
       %        VARS.loadedMovie = 0;
                VARS.loadedMovie = 1;
           else
               set(handles.fpsError, 'String', 'fps: 25','ForegroundColor',[0,1,0]);  
               VARS.loadedMovie = 1;
           end
       
       catch E1
           % ------------ by Elena Ranguelova, 31.07.2014--------------
           errordlg('Error loading movie file', 'File Error');
           %-----------------------------------------------------------
           VARS.loadedMovie = 0;
       end
      
   end
   
%     if (get(handles.checkboxSetTime,'Value')==get(handles.checkboxSetTime,'Max')) && (...            
%         VARS.loadedMovie == 0 || VARS.loadedAcc == 0 || strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%             strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1)
%         
%         set(handles.buttonOK, 'Enable', 'off');
%     elseif VARS.loadedMovie == 0 || VARS.loadedAcc == 0 
%         set(handles.buttonOK, 'Enable', 'off');
%     else
%         set(handles.buttonOK, 'Enable', 'on');
%     end

    
    guidata(hObject,handles);
    checkButtonState
end



function buttonAnnscheme_Callback(hObject, eventdata, handles)
    
   global VARS;
   global SCHEME;
   VARS.loadedAnn=0;
   [filename,path] = uigetfile({'*.txt'},'load annotation scheme');
   
   if isequal(filename,0)
       VARS.loadedAnn=0;
   else
       try
           SCHEME.fileName = strcat(path,filename);
           inpFile = fopen(SCHEME.fileName,'rt');
           
           sc = textscan(inpFile,'%f %s %f %f %f', 'Delimiter',' ','CollectOutput',1,...
               'CommentStyle','//','ReturnOnError',0);
           fclose(inpFile);

           SCHEME.data = {sc{1} sc{2} sc{3}};

            % ------------ by Elena Ranguelova, 31.07.2014--------------
            if length(SCHEME.fileName)<45       
               set(handles.textAnn, 'String', SCHEME.fileName);
            else                
               set(handles.textAnn, 'String', filename);
            end
            %---------------------------------------------------------- 
            
           
       catch E1
           % ------------ by Elena Ranguelova, 31.07.2014--------------
           errordlg('Error reading scheme file', 'File Error');
           %-----------------------------------------------------------
           VARS.loadedAnn = 0;
       end
           VARS.loadedAnn = 1;
   end
       
       
    guidata(hObject,handles);
    checkButtonState
end

function checkButtonState

global VARS

handles = guidata(gcbo);
setTimeState = get(handles.checkboxSetTime,'Value');
setCalState = get(handles.checkDataCal,'Value');

if VARS.loadedAcc == 0 && VARS.loadedMovie == 0 
    set(handles.editHH, 'Enable', 'on');
    set(handles.editMM, 'Enable', 'on');
    set(handles.editSS, 'Enable', 'on');
    set(handles.editFF, 'Enable', 'on');
    set(handles.checkboxSetTime, 'Enable', 'on');
    
    set(handles.buttonOK, 'Enable', 'off');
    
elseif VARS.loadedAcc == 1 && VARS.loadedMovie == 0;
    set(handles.checkboxSetTime, 'Enable', 'off');
    set(handles.editHH, 'Enable', 'off');
    set(handles.editMM, 'Enable', 'off');
    set(handles.editSS, 'Enable', 'off');
    set(handles.editFF, 'Enable', 'off'); 
    
    set(handles.buttonOK, 'Enable', 'on');

elseif VARS.loadedAcc == 0 && VARS.loadedMovie == 1;
    set(handles.checkboxSetTime, 'Enable', 'on');
    set(handles.buttonOK, 'Enable', 'off');
    set(handles.buttonAnnscheme, 'Enable', 'on');
    
elseif VARS.loadedAcc == 1 && VARS.loadedMovie == 1
    set(handles.editHH, 'Enable', 'on');
    set(handles.editMM, 'Enable', 'on');
    set(handles.editSS, 'Enable', 'on');
    set(handles.editFF, 'Enable', 'on');
    
    set(handles.checkboxSetTime, 'Enable', 'on');
    if setTimeState == get(handles.checkboxSetTime,'Max') && (strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
            strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1)
    
        set(handles.buttonOK, 'Enable', 'off');
    else
        set(handles.buttonOK, 'Enable', 'on');
    end
           
end
     
guidata(gcbo,handles)
end

function checkboxSetTime_Callback(hObject, eventdata, handles)
    global VARS;
    
    if (get(hObject,'Value')==get(hObject,'Max'))

       if strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
          strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1 || VARS.loadedMovie == 0 || VARS.loadedAcc == 0
    
          set(handles.editHH, 'Enable', 'on');
          set(handles.editMM, 'Enable', 'on');
          set(handles.editSS, 'Enable', 'on');
          set(handles.editFF, 'Enable', 'on');
          set(handles.buttonOK,'Enable','off');
       end
       
       
   
    else

        set(handles.editHH, 'Enable', 'off');
        set(handles.editMM, 'Enable', 'off');
        set(handles.editSS, 'Enable', 'off');
        set(handles.editFF, 'Enable', 'off'); 
    
       if VARS.loadedMovie == 0 || VARS.loadedAcc == 0
            set(handles.buttonOK,'Enable','off');
       else
            set(handles.buttonOK,'Enable','on');
       end
       
       
       
    end
      
    guidata(hObject,handles);
end

function editHH_Callback(hObject, eventdata, handles)

global VARS;

hourstr = str2double(get(hObject,'String'));

if isnan(hourstr) || hourstr>23 || hourstr<0
    set(handles.editHH,'String', 'HH');
else
    set(handles.editHH,'UserData', hourstr);
end

% if strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%         strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1 || VARS.loadedMovie == 0 || VARS.loadedAcc == 0
%     
%     set(handles.buttonOK,'Enable','off');
% else
%     set(handles.buttonOK,'Enable','on');
% end

guidata(gcf,handles);
checkButtonState
end

% --- Executes during object creation, after setting all properties.
function editHH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(gcf,'BackgroundColor','white');
end

end

function editMM_Callback(hObject, eventdata, handles)
global VARS;

minstr = str2double(get(hObject,'String'));

if isnan(minstr) || minstr>59 || minstr<0
    set(handles.editMM,'String', 'MM');
else
    set(handles.editMM,'UserData', minstr);
end


% if strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%         strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1 || VARS.loadedMovie == 0 || VARS.loadedAcc == 0
%     
%     set(handles.buttonOK,'Enable','off');
% else
%     set(handles.buttonOK,'Enable','on');
% end

guidata(gcf,handles);
checkButtonState
end

function editMM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function editSS_Callback(hObject, eventdata, handles)
global VARS;

secstr = str2double(get(hObject,'String'));

if isnan(secstr) || secstr>59 || secstr<0
    set(handles.editSS,'String', 'SS');
else
    set(handles.editSS,'UserData', secstr);
    
end
% 
% if strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%         strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1 || VARS.loadedMovie == 0 || VARS.loadedAcc == 0
%     
%     set(handles.buttonOK,'Enable','off');
% else
%     set(handles.buttonOK,'Enable','on');
% end

guidata(gcf,handles);
checkButtonState
end

function editSS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editFF_Callback(hObject, eventdata, handles)
global VARS;

ffstr = str2double(get(hObject,'String'));

if isnan(ffstr) || ffstr>99 || ffstr<0
    set(handles.editFF,'String', 'FF');
else
    set(handles.editFF,'UserData', ffstr);
end

% 
% if strcmp(get(handles.editHH, 'String'),'HH')==1 || strcmp(get(handles.editMM, 'String'),'MM')==1 ||...
%         strcmp(get(handles.editSS, 'String'),'SS')==1 || strcmp(get(handles.editFF, 'String'),'FF')==1 || VARS.loadedMovie == 0 || VARS.loadedAcc == 0
%     
%     set(handles.buttonOK,'Enable','off');
% else
%     set(handles.buttonOK,'Enable','on');
% end

guidata(gcf,handles);
checkButtonState
end


function editFF_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function buttonOK_Callback(hObject, eventdata, handles)

global VARS ACCDAT;

if (get(handles.checkboxSetTime,'Value')==get(handles.checkboxSetTime,'Max'))       
       
   VARS.iHour = get(handles.editHH,'UserData');
   VARS.iMin = get(handles.editMM,'UserData');
   VARS.iSec = get(handles.editSS,'UserData');
   
   if isempty(get(handles.editFF,'UserData'))
       VARS.iFF =0;
   else
       VARS.iFF = get(handles.editFF,'UserData'); 
   end
   VARS.initTime = 1;
else
   VARS.iHour = NaN;
   VARS.iMin = NaN;
   VARS.iSec = NaN;
   VARS.iFF = NaN;
   VARS.initTime = 0;
end

if get(handles.checkDataCal,'Value') == get(handles.checkDataCal, 'Max')
   ACCDAT.cal = 1;
   ACCDAT.calPars = [];
else
   ACCDAT.cal = 0;
   
   ACCDAT.calPars = [get(handles.editXo, 'userData'),get(handles.editXs, 'userData'),...
       get(handles.editYo, 'userData'),get(handles.editYs, 'userData'),...
       get(handles.editZo, 'userData'),get(handles.editZs, 'userData')];
end

   
handles.flag = 2;
guidata(hObject, handles);
uiresume();

end

function buttonCancel_Callback(hObject, eventdata, handles)

handles.flag = 1;
guidata(hObject,handles);
uiresume();

end


function dataCalField(state)

handles = guidata(gcbo);

set(handles.editXo, 'Enable', state);
set(handles.editXs, 'Enable', state);
set(handles.editYo, 'Enable', state);
set(handles.editYs, 'Enable', state);
set(handles.editZo, 'Enable', state);
set(handles.editZs, 'Enable', state);

guidata(gcbo,handles)


end


function checkDataCal_Callback(hObject, eventdata, handles)

if get(handles.checkDataCal,'Value') == get(handles.checkDataCal, 'Max')
    dataCalField('off');
    
else
    dataCalField('on');
end

checkButtonState
guidata(hObject,handles);

end



function editXo_Callback(hObject, eventdata, handles)

Xo = str2double(get(hObject,'String'));

if isnan(Xo) 
    set(handles.editXo,'String', 'Xo');
    set(handles.editXo,'Userdata', NaN);
else
    set(handles.editXo,'UserData', Xo);
end

end

function editXo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editXs_Callback(hObject, eventdata, handles)

Xs = str2double(get(hObject,'String'));

if isnan(Xs) 
    set(handles.editXs,'String', 'Xs');
    set(handles.editXs,'UserData', NaN);
else
    set(handles.editXs,'UserData', Xs);
end

end

function editXs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editYo_Callback(hObject, eventdata, handles)


Yo = str2double(get(hObject,'String'));

if isnan(Yo)
    set(handles.editYo,'String', 'Yo');
    set(handles.editYo,'UserData', NaN);
else
    set(handles.editYo,'UserData', Yo);
end

end

function editYo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editYs_Callback(hObject, eventdata, handles)


Ys = str2double(get(hObject,'String'));

if isnan(Ys)
    set(handles.editYs,'String', 'Ys');
    set(handles.editYs,'UserData', NaN);
else
    set(handles.editYs,'UserData', Ys);
end


end


function editYs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editZo_Callback(hObject, eventdata, handles)


Zo = str2double(get(hObject,'String'));

if isnan(Zo)
    set(handles.editZo,'String', 'Zo');
    set(handles.editZo,'UserData', NaN);
else
    set(handles.editZo,'UserData', Zo);
end

end

function editZo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function editZs_Callback(hObject, eventdata, handles)


Zs = str2double(get(hObject,'String'));

if isnan(Zs)
    set(handles.editZs,'String', 'Zs');
    set(handles.editZs,'UserData', NaN);
else
    set(handles.editZs,'UserData', Zs);
end

end


function editZs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


end
