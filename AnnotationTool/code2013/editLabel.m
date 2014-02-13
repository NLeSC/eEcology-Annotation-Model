function varargout = editLabel(varargin)
% EDITLABEL M-file for editLabel.fig
%      EDITLABEL, by itself, creates a new EDITLABEL or raises the existing
%      singleton*.
%
%      H = EDITLABEL returns the handle to a new EDITLABEL or the handle to
%      the existing singleton*.
%
%      EDITLABEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITLABEL.M with the given input arguments.
%
%      EDITLABEL('Property','Value',...) creates a new EDITLABEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before editLabel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to editLabel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help editLabel

% Last Modified by GUIDE v2.5 29-Jul-2011 14:28:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @editLabel_OpeningFcn, ...
                   'gui_OutputFcn',  @editLabel_OutputFcn, ...
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

% --- Executes just before editLabel is made visible.
function editLabel_OpeningFcn(hObject, eventdata, handles, varargin)

handles.toEdit = varargin{1};
handles.newName = [];
handles.newColour = [];
set(handles.textThisLabel, 'String', strcat('Label:',' ', handles.toEdit));

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

uiwait(handles.editLabelFig);

end
% --- Outputs from this function are returned to the command line.
function varargout = editLabel_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
varargout{2} = handles;
delete(hObject)  
% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in pushColour.
function pushColour_Callback(hObject, eventdata, handles)
    handles.newColour = uisetcolor;
    
    if size(handles.newColour,2)>1
        set(hObject,'BackgroundColor',handles.newColour);
    end
    
    %    handles.colour = [num2str(dec2hex(round(handles.colour(1)*255),2)),...
    %        num2str(dec2hex(round(handles.colour(2)*255),2)),...
    %        num2str(dec2hex(round(handles.colour(3)*255),2))];
   guidata(hObject,handles)
end



function editName_Callback(hObject, eventdata, handles)

handles.newName = get(hObject, 'String');

guidata(hObject,handles)
end

function editName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function buttonOK_Callback(hObject, eventdata, handles)


handles.flag = 0;

guidata(hObject,handles);
uiresume(handles.editLabelFig);

end


function pushCancel_Callback(hObject, eventdata, handles)

handles.newName = [];
handles.newColour = [];
handles.flag = 0;

guidata(hObject,handles);
uiresume(handles.editLabelFig);
end
