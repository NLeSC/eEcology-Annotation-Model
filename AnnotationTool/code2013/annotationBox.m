function varargout = annotationBox(varargin)
% ANNOTATIONBOX M-file for annotationBox.fig
%      ANNOTATIONBOX, by itself, creates a new ANNOTATIONBOX or raises the existing
%      singleton*.
%
%      H = ANNOTATIONBOX returns the handle to a new ANNOTATIONBOX or the handle to
%      the existing singleton*.
%
%      ANNOTATIONBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONBOX.M with the given input arguments.
%
%      ANNOTATIONBOX('Property','Value',...) creates a new ANNOTATIONBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotationBox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotationBox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotationBox

% Last Modified by GUIDE v2.5 10-Jul-2011 15:56:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotationBox_OpeningFcn, ...
                   'gui_OutputFcn',  @annotationBox_OutputFcn, ...
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


% --- Executes just before annotationBox is made visible.
function annotationBox_OpeningFcn(hObject, eventdata, handles, varargin)

global SCHEME MAIN MOV ACC ACCDAT dualcursor
avgH = guidata(accVidGui);

handles.output = hObject;

guidata(hObject, handles);

nOfTags = size(SCHEME.data{3},1);

SCHEME = varargin{1};
MAIN = varargin{2};
MOV = varargin{3};
ACC = varargin{4};
ACCDAT = varargin{5};
dualcursor = varargin{6};

SCHEME.list = strcat(num2str(SCHEME.data{1}),' - ', SCHEME.data{2});
SCHEME.coloredList= cell(nOfTags,1);

if SCHEME.data{3}(1)>=0
    for i = 1:nOfTags

        r=num2str(dec2hex(round(SCHEME.data{3}(i,1)*255),2));
        g=num2str(dec2hex(round(SCHEME.data{3}(i,2)*255),2));
        b=num2str(dec2hex(round(SCHEME.data{3}(i,3)*255),2));  
        hexcolor = strcat(r,g,b);
        
       
        SCHEME.coloredList{i} = strcat('<HTML><FONT COLOR="#',hexcolor,'">',...
            SCHEME.list{i},'</FONT></HTML>');
        
    end
    
else
    for i = 1:nOfTags
        rr = rand(1);
        rg = rand(1);
        rb = rand(1);
        r = num2str(dec2hex(round(rand(1)*255),2));
        g = num2str(dec2hex(round(rand(1)*255),2));
        b = num2str(dec2hex(round(rand(1)*255),2));
        SCHEME.data{3}(i,1)=rr;
        SCHEME.data{3}(i,1)=rg;
        SCHEME.data{3}(i,1)=rb;
        hexcolor = strcat(r,g,b);
        
        SCHEME.coloredList{i} = strcat('<HTML><FONT COLOR="#',hexcolor,'">',...
            SCHEME.list{i},'</FONT></HTML>');
    end
    
end
   
set(handles.annList,'String',SCHEME.coloredList, 'Value', 1);
set(handles.annFile, 'String', strcat('File: ', SCHEME.fileName));







function varargout = annotationBox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in annList.
function annList_Callback(hObject, eventdata, handles)
global SCHEME MAIN MOV ACC ACCDAT dualcursor

if strcmp(get(handles.annotationBox,'SelectionType'),'open')
       selected = get(hObject,'Value');
       %annotations = get(hObject,'String');
       label = selected;
       vals = dualcursor
       
       
       colorTags(ACC.I, ACC.endI);
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function annList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonClose.
function buttonClose_Callback(hObject, eventdata, handles)
delete(handles.annotationBox);
