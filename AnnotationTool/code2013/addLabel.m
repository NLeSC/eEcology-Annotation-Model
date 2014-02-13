function varargout = addLabel(varargin)
% ADDLABEL M-file for addLabel.fig
%      ADDLABEL, by itself, creates a new ADDLABEL or raises the existing
%      singleton*.
%
%      H = ADDLABEL returns the handle to a new ADDLABEL or the handle to
%      the existing singleton*.
%
%      ADDLABEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDLABEL.M with the given input arguments.
%
%      ADDLABEL('Property','Value',...) creates a new ADDLABEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addLabel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addLabel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addLabel

% Last Modified by GUIDE v2.5 29-Jul-2011 15:10:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addLabel_OpeningFcn, ...
                   'gui_OutputFcn',  @addLabel_OutputFcn, ...
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


% --- Executes just before addLabel is made visible.
function addLabel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addLabel (see VARARGIN)

handles.colour = 0;
handles.name = '-1';
handles.nr = -1;
handles.exist = varargin{1};
set(handles.buttonOK,'Enable', 'off');

% Choose default command line output for addLabel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


uiwait(handles.addLabelFig);


% --- Outputs from this function are returned to the command line.
function varargout = addLabel_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;
    varargout{2} = handles;
    delete(hObject)  


function buttonOK_Callback(hObject, eventdata, handles)
    
    handles.flag = 1;
    
    if  length(handles.colour)==1
        handles.colour = rand(1,3);
    end
    
    guidata(hObject,handles);
    uiresume(handles.addLabelFig);


function buttonCancel_Callback(hObject, eventdata, handles)

    handles.flag = 0;
    
    guidata(hObject,handles);
    uiresume(handles.addLabelFig);



function editLabNr_Callback(hObject, eventdata, handles)
    handles.nr = str2double(get(hObject,'String'));
      
    if isnan(handles.nr) || handles.nr<0 || isempty(find(handles.exist==handles.nr))==0
        set(handles.editLabNr, 'String', ' ');
        handles.nr = -1;
    end
    
    guidata(hObject, handles) 
    checkOK(handles)


function editLabNr_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function editName_Callback(hObject, eventdata, handles)
    
    handles.name = get(hObject,'String');
    
   
    guidata(hObject, handles)
    checkOK(handles)

function editName_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function buttonCol_Callback(hObject, eventdata, handles)
    
    handles.colour = uisetcolor;
    
    if size(handles.colour,2)>1
        set(hObject,'BackgroundColor',handles.colour);
    
    %    handles.colour = [num2str(dec2hex(round(handles.colour(1)*255),2)),...
    %        num2str(dec2hex(round(handles.colour(2)*255),2)),...
    %        num2str(dec2hex(round(handles.colour(3)*255),2))];
    end
   checkOK(handles)
   guidata(hObject,handles)
    
    
function checkOK(handles)

guidata(gcbo,handles);
if strcmp(handles.name,'-1')==0 && handles.nr~=-1

    set(handles.buttonOK, 'Enable', 'on');
else
    set(handles.buttonOK, 'Enable', 'off');
end

guidata(gcbo,handles);

    
