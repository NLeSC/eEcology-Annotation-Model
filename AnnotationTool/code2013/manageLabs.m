function varargout = manageLabs(varargin)
% MANAGELABS M-file for manageLabs.fig
%      MANAGELABS, by itself, creates a new MANAGELABS or raises the existing
%      singleton*.
%
%      H = MANAGELABS returns the handle to a new MANAGELABS or the handle to
%      the existing singleton*.
%
%      MANAGELABS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGELABS.M with the given input arguments.
%
%      MANAGELABS('Property','Value',...) creates a new MANAGELABS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manageLabs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manageLabs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manageLabs

% Last Modified by GUIDE v2.5 29-Jul-2011 12:05:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manageLabs_OpeningFcn, ...
                   'gui_OutputFcn',  @manageLabs_OutputFcn, ...
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


% --- Executes just before manageLabs is made visible.
function manageLabs_OpeningFcn(hObject, eventdata, handles, varargin)

global sch

sch = varargin{1};

set(handles.listboxPresentLabels,'String',sch.list, 'Value', 1);
sch.dataCop = sch.data;
sch.deleted = [];
handles.selected = [];
sch.addedLabs = cell(1,3);
sch.changed = [];
handles.output = hObject;

guidata(hObject, handles);

uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manageLabs_OutputFcn(hObject, eventdata, handles) 
global sch

if handles.flag ==1
    varargout{1} = handles.output;
    varargout{2} = sch;
elseif handles.flag == 0
    varargout{1} = handles.output;
    varargout{2} = [];
end
    
delete(hObject)

function listboxPresentLabels_Callback(hObject, eventdata, handles)
global sch

if ~isempty(sch.list)
    list = cellstr(get(hObject, 'String'));
    handles.selected = get(hObject,'Value');
end

guidata(hObject,handles)


function listboxPresentLabels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function buttonAdd_Callback(hObject, eventdata, handles)
    global sch
    
    [~,addHandles] = addLabel(sch.dataCop{1});
    %[~,addHandles] = addLabel(sch.data{1});

    if addHandles.flag == 1
        sch.list{end+1,:} = strcat(num2str(addHandles.nr), ' -', addHandles.name);
        
        if ~isempty(find(cellfun('isempty',sch.list)))
            sch.list = sch.list(find(cellfun('isempty',sch.list))+1:end);
        end
      
        set(handles.listboxPresentLabels,'String',sch.list, 'Value', 1);
        
        sch.dataCop{1}(end+1,:) = addHandles.nr;
        sch.dataCop{2}(end+1,:) = cellstr(addHandles.name);           
        sch.dataCop{3}(end+1,:) = addHandles.colour; 
%         sch.addedLabs{end+1,1} = addHandles.nr;
%         sch.addedLabs{end,2} = cellstr(addHandles.name);
%         sch.addedLabs{end,3} = addHandles.colour;

    end
    
    guidata(hObject,handles)
    

function buttonRemove_Callback(hObject, eventdata, handles)
    global sch
    
    if ~isempty(handles.selected)
        sch.list(handles.selected) = [];
        sch.deleted(end+1) = handles.selected;
        set(handles.listboxPresentLabels,'String',sch.list, 'Value', 1);
                
        sch.dataCop{1}(handles.selected,:) = [];
        sch.dataCop{2}(handles.selected,:) = [];
        sch.dataCop{3}(handles.selected,:) = [];
        
        handles.selected = [];
        guidata(hObject,handles);
    end

function buttonOkUpd_Callback(hObject, eventdata, handles)
    
    global sch
    
 %   try
        
        if strcmp(sch.fileName, '')==1
            [filename,path] = uiputfile({'*.txt'},'make new annotation file');
            sch.fileName = strcat(path,filename);
            labelFile = fopen(sch.fileName,'wt+');
        
        else
            labelFile = fopen(sch.fileName);
        end  
        
        
        ortext = cell(1,1);
        j=1;
        
        textline = fgetl(labelFile);
        while ischar(textline)
            
            if ~isempty(textline) && textline(1)=='/' 
                textline = textline(4:end);
            end
            
            if ~isempty(textline)
                ortext{j,:} = cellstr(textline);
            end
            
            textline = fgetl(labelFile);
            j=j+1;    
                       
        end
        
        fclose(labelFile);       

        labelFile = fopen(sch.fileName, 'wt');
        comment = '//';
        
        if ~isempty(ortext) 
            for i=1:size(ortext,1)     
               
                st = char(ortext{i,:});
                fprintf(labelFile,'%s %s\n', comment, st);
    
            end
        end
        
        fprintf(labelFile, '\n%s %s %s', comment, 'Scheme changed: ', datestr(now));
        
        for i=1:size(sch.dataCop{1},1);
                st = char(sch.dataCop{2}(i));
                fprintf(labelFile, '\n%-2.0f%s %1.2f %1.2f %1.2f',sch.dataCop{1}(i), ...
                    st, sch.dataCop{3}(i,1),sch.dataCop{3}(i,2),...
                    sch.dataCop{3}(i,3));
         end
%        
%         fclose(labelFile);
%         if size(sch.addedLabs(:,1),1)>0
%             if strcmp(sch.fileName, '')==1
%                 [filename,path] = uiputfile({'*.txt'},'make new annotation file');
%                 sch.fileName = strcat(path,filename);
%             end
% 
%             labelFile = fopen(sch.fileName, 'at');
%             for i = 2:size(sch.addedLabs,1)
% 
%                 st = char(sch.addedLabs{i,2});
% 
%                 fprintf(labelFile, '\n%-2.0f%s %1.2f %1.2f %1.2f',sch.addedLabs{i,1}, ...
%                     st, sch.addedLabs{i,3}(1),sch.addedLabs{i,3}(2),...
%                     sch.addedLabs{i,3}(3));
% 
%             end
%             fclose(labelFile);
%         end
% 
%         if ~isempty(sch.deleted)
%             labelFile = fopen(sch.fileName,'rt');
%             sc = textscan(labelFile,'%f %s %f %f %f', 'Delimiter',' ','CollectOutput',1,...
%                  'CommentStyle','//','ReturnOnError',0, 'MultipleDelimsAsOne',1,...
%                  'EndOfLine', '\n');
%             toDel = sc{1};
%             fclose(labelFile); 
% 
%             for i = 1:length(sch.deleted)
%                indS = find(toDel==sch.deleted(i));
%                sc{1}(indS,:) = [];
%                sc{2}(indS,:) = [];
%                sc{3}(indS,:) = [];
%             end
% 
%             labelFile = fopen(sch.fileName,'wt');
%             for i=1:size(sc{1},1)
% 
%                 st = char(sc{2}(i));
% 
%                 fprintf(labelFile,'%-2.0f%s %1.2f %1.2f %1.2f\n', sc{1}(i),st,...
%                 sc{3}(i,1), sc{3}(i,2),sc{3}(i,3));
% 
% 
%             end
%             fclose(labelFile);
%         end
%         
%         if ~isempty(sch.changed)
%         
%             labelFile = fopen(sch.fileName,'wt');
%             
%             for i=1:size(sch.data{1},1)
% 
%                 st = char(sch.data{2}(i));
% 
%                 fprintf(labelFile,'%-2.0f%s %1.2f %1.2f %1.2f\n', sch.data{1}(i),st,...
%                 sch.data{3}(i,1), sch.data{3}(i,2),sch.data{3}(i,3));
% 
% 
%             end
%             fclose(labelFile);
%         
%         
%         end
        
        changeScheme
%      catch WE
%          choice = questdlg('Error while updating file. File not updated! Apply changes without updating the file?',...
%              'reading/writing error', 'apply', 'discard', 'apply');
%          switch choice
%              case 'apply'
%                  changeScheme
%                  handles.flag = 1; 
%              case 'discard'
%                  handles.flag = 0;
%          end
%      end
    
    handles.flag = 1;
    guidata(hObject,handles);
    uiresume();
    
    
    
function changeScheme
    global sch
    
    ann = evalin('base','annotations');
      
    if ~isempty(sch.deleted)
        if ~isempty(ann)
            
            for i = 1:length(sch.deleted)
                r = sch.data{1}(sch.deleted(i),:);
                dr = find(ann(:,4)==r);
                ann(dr,:) = [];

            end         
        end
    end
    assignin('base','annotations',ann);
    
    sch.data = sch.dataCop;
%     if size(sch.addedLabs,1)>1
%         for i=2:size(sch.addedLabs,1);
%             sch.data{1}(end+1,:) = sch.addedLabs{i,1};
%             sch.data{2}(end+1,:) = cellstr(sch.addedLabs{i,2});           
%             sch.data{3}(end+1,:) = sch.addedLabs{i,3};         
%         end
%         
%         if ~isempty(find(cellfun('isempty',sch.data{2})))
%             sch.data{2} = sch.data{2}(find(cellfun('isempty',sch.data{2}))+1:end);
%         end
% 
%     end
%     
%     ann = evalin('base','annotations');
%     
%     
%         for i = 1:length(sch.deleted)
%            
%            dr = find(ann(:,4)==(sch.data{1} == sch.deleted(i)));
%            ann(dr,:) = [];
%         end
%     end
      
    sch.deleted = [];
    sch.addedLabs = [];
    sch.list = [];
    
 
function buttonDiscard_Callback(hObject, eventdata, handles)
   handles.flag = 0;
   guidata(hObject,handles);
   uiresume();

function buttonOKnotUpd_Callback(hObject, eventdata, handles)

    changeScheme
    handles.flag = 1;
    guidata(hObject,handles);
    uiresume();
    



function pushEditLab_Callback(hObject, eventdata, handles)
global sch


if ~isempty(handles.selected)
    selectedLab = handles.selected;
    [~, editHandles] = editLabel(sch.list(handles.selected));
    
    if ~isempty(editHandles.newName)
        sch.dataCop{2}(selectedLab,:) = cellstr(editHandles.newName);
    end
    if ~isempty(editHandles.newColour)
        sch.dataCop{3}(selectedLab,:) = editHandles.newColour;
        
    end
    
    if ~isempty(editHandles.newName) || ~isempty(editHandles.newColour)
            sch.changed(end+1) = sch.data{1}(selectedLab,:); 
    end
    
    if ~isempty(editHandles.newName)
        sch.list{selectedLab,:} = strcat(num2str(sch.data{1}(selectedLab,:)), ' -', editHandles.newName);
        set(handles.listboxPresentLabels,'String',sch.list, 'Value', 1);
    end
    
end
    
guidata(hObject,handles)
    
    
