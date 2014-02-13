% function Annotate 
%   belongs to accVidGui.m
% GUI for analysing and annotating UvA FlySafe movies and sensor-data.
% 
% author: merijn de bakker. e-mail: merijn.debakker@gmail.com
%
% created: 23-04-2011
% revised: 10-05-2011
%
% INPUT: --
% OUTPUT: --
% DEPENDS: accVidGui.m, accVidGui.fig,...
% dualcursor.m (modified version of S. Hirsch), Annotate.fig
% NOTES: --


function varargout = Annotate(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Annotate_OpeningFcn, ...
                   'gui_OutputFcn',  @Annotate_OutputFcn, ...
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

function Annotate_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

handles.dualcursor = [];

dualcursorInput = find(strcmp(varargin, 'dualcursor'));
if ~isempty(dualcursorInput)
    handles.dualCursor = varargin{dualcursorInput+1};
end

handles.flag = 1;

guidata(hObject, handles);


uiwait(handles.annotateGUI);


function varargout = Annotate_OutputFcn(hObject, eventdata, handles) 

if handles.flag == 2
    varargout{1} = handles.output;
    varargout{2} = handles.tag1;
    varargout{3} = handles.tag2;
    delete(hObject)
    
elseif handles.flag == 1
    
    varargout{1} = handles.output;
    varargout{2} = '99';
    varargout{3} = '99';
    delete(hObject)  
    
end

function edit1_Callback(hObject, eventdata, handles)
        
    tag1 = str2double(get(hObject, 'String'));
    
    guidata(hObject, handles);     
      
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
    
    tag2 = str2double(get(hObject, 'String'));
    
    guidata(hObject, handles);

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton1_Callback(hObject, eventdata, handles)
       
    handles.tag1 = get(handles.edit1, 'String');
    handles.tag2 = get(handles.edit2, 'String');

    if strcmp(handles.tag1,'tag 1')==1
        handles.tag1 = NaN;
    end
    
    if strcmp(handles.tag2,'tag 2')==1
        handles.tag2 = NaN;
    end
    handles.flag = 2;
    
    guidata(hObject, handles);
    
    uiresume();
       
function buttonDiscard_Callback(hObject, eventdata, handles)
    handles.flag = 1;
    guidata(hObject,handles);
    uiresume();
    
    
   

    
       
