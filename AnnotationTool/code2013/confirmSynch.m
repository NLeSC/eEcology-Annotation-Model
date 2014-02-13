function varargout = confirmSynch(varargin)
% CONFIRMSYNCH M-file for confirmSynch.fig
%      CONFIRMSYNCH, by itself, creates a new CONFIRMSYNCH or raises the existing
%      singleton*.
%
%      H = CONFIRMSYNCH returns the handle to a new CONFIRMSYNCH or the handle to
%      the existing singleton*.
%
%      CONFIRMSYNCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIRMSYNCH.M with the given input arguments.
%
%      CONFIRMSYNCH('Property','Value',...) creates a new CONFIRMSYNCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before confirmSynch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to confirmSynch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help confirmSynch

% Last Modified by GUIDE v2.5 17-Jul-2011 10:54:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @confirmSynch_OpeningFcn, ...
                   'gui_OutputFcn',  @confirmSynch_OutputFcn, ...
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


% --- Executes just before confirmSynch is made visible.
function confirmSynch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to confirmSynch (see VARARGIN)

% Choose default command line output for confirmSynch
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes confirmSynch wait for user response (see UIRESUME)
uiwait(handles.figure1);



function varargout = confirmSynch_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
varargout{2} = handles.flag;
delete(hObject)  

function buttonConfirm_Callback(hObject, eventdata, handles)
    handles.flag = 1;

    guidata(hObject,handles);
    uiresume(handles.figure1);
    


function buttonDiscard_Callback(hObject, eventdata, handles)
    handles.flag = 0;
    
    guidata(hObject,handles);
    uiresume(handles.figure1);
    