%metadata for accVidGui


function varargout = about(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @about_OpeningFcn, ...
                   'gui_OutputFcn',  @about_OutputFcn, ...
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


% --- Executes just before about is made visible.
function about_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to about (see VARARGIN)

set(handles.versionMeta, 'String', '09-07-2011');
set(handles.editMeta, 'String', 'Merijn de Bakker');
set(handles.contactMeta, 'String', 'merijn.debakker@gmail.com');

% Choose default command line output for about
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes about wait for user response (see UIRESUME)
% uiwait(handles.aboutFigure);


% --- Outputs from this function are returned to the command line.
function varargout = about_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
delete(handles.aboutFigure);


function docButton_Callback(hObject, eventdata, handles)

winopen('050711_uvaBits-annTool_manual.pdf')


function webButton_Callback(hObject, eventdata, handles)
    h=(actxcontrol('Mozilla.Browser.1',[10,10,400,400],gcf));
    Navigate2(h, 'http://www.uva-bits.nl');
