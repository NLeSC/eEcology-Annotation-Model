% function dualcursor
%
% 
% Original version by Scott Hirsch
% shirsch@mathworks.com
% Copyright 2002-2009 The MathWorks, Inc. 
%
% Adapted by Merijn de Bakker
% merijn.debakker@gmail.com
% for suiting the purposes of accVidGui.

function val = dualcursor(state,deltalabelpos,marker_color,datalabelformatfcnh,axh)
%function val = dualcursor(state,deltalabelpos,handles)
    
if nargin<4 || isempty(datalabelformatfcnh)    
    datalabelformatfcnh = @local_maketextstring;    
end;

if nargout
    if nargin==0    %Use current axis
        h = gca;
    else
        h = state;
        if strcmp(get(h,'Type'),'line');
            h = get(h,'Parent');
        end;
    end;
    cursors = findobj(h,'Tag','Cursor');
    if length(cursors)==2       %Should be empty (no cursors), or length=2
        for ii=1:2
            cn = getappdata(cursors(ii),'CursorNumber');
            ind = (cn-1)*2+1:cn*2;      %Index into val
            val(ind) = getappdata(cursors(ii),'Coordinates');
            
        end;
    else
        val = [];
        warning('I could not find any cursors');
    end;
    return
elseif nargin<5 || isempty(axh)    
    axh = gca;
end;



if (nargin==0 & nargout==0) | isempty(state)  %Switch state.  Check current state
    dots = findobj(axh,'Type','line','Tag','Cursor');  %See if there are any cursors
    if isempty(dots)    %None found.  Turn cursors on
        state = 'on';
        
    else
        state = 'off';
    end;
end;

%Check if the first argument is numeric.  The user is specifying
%  the initial x-coordinates of the markers
if nargin>=1 & isnumeric(state) %First input is x coordinates of markers
    x_init = state(:);

    %error check
    if length(x_init)~=2
        error('First input must be 2 element vector of x coordinates');
    end;
    state = 'on';       %Turn on data cursors.
else        %Default position = 1/3, 2/3 x axis limits
    %    xl = xlim;              %X Limits.  this is the letter L, not the number 1
    if strcmp(get(axh,'Type'),'figure') ||  strcmp(get(axh,'Type'),'uipanel') || strcmp(get(axh,'Type'),'root');    %user clicked on the axis itself; do nothing
        return
    end;


    xl = xlim(axh);
    lim = localObjbounds(axh);  % Problem using objbounds with hggroup objects, so I have a simple version of my own
    lim = lim(1:2);         %x values only
    xl(isinf(xl)) = lim(isinf(xl));
    width = diff(xl);     %Axis width
    x_init = xl(1)+[1/3 2/3]*width;
    

end;

% Get handle to figure just once
hFig = ancestor(axh,'figure');


switch state
    case 'on'
        
        dualcursor('off',[],[],[],axh);

        if nargin<2 | isempty(deltalabelpos)
            deltalabelpos = [.65 -.08;.9 -.08];         
            %[x1 y1; x2 y2]
        end;
        
        if nargin >= 3 ,
        
            colors = 'bgrcmyk';
            markers = '+o*.xsdv^><ph';
            for ii=1:length(marker_color)
                col_ind = strfind(colors,marker_color(ii));
                if ~isempty(col_ind)        %It's a color
                    color = marker_color(ii);
                else                        %Try a marker instead
                    mark_ind = strfind(markers,marker_color(ii));
                    if ~isempty(mark_ind)
                        marker = marker_color(ii);
                    end;
                end;
            end;
        end;

        %Handle default marker and color
        if ~exist('color','var'), color = 'r'; end; %set default
        if ~exist('marker','var'), marker = 'o'; end; %set default

        lineh = local_findlines(axh);

        if isempty(lineh)
            x1 = 0;
            y1 = 0;
        else
            
            set(lineh,'ButtonDownFcn', ...
                'setappdata(get(gco,''Parent''),''SelectedLine'',gco);dualcursor(''selectline'',[],[],[],get(gco,''Parent''))');

            %set erasemode to xor.  This speeds things up a ton with large data sets
            %             erasemode = get(lineh,'EraseMode');
            %             set(lineh,'EraseMode','xor');

            lineh = min(lineh);           %Lets just use one line.  This was probably added first
            setappdata(axh,'SelectedLine',lineh); %The currently selected line.

            %Why the last line?  Because it is the first one added
            xl = get(lineh,'XData');
            yl = get(lineh,'YData');
        end;

        %Find nearest value on the line
        [xv1,yv1] = local_nearest(x_init(1),xl,yl);
        [xv2,yv2] = local_nearest(x_init(2),xl,yl);

        %Build the string for the data label
        textstring1 = feval(datalabelformatfcnh,xv1,yv1);
        textstring2 = feval(datalabelformatfcnh,xv2,yv2);

        %Add the data label
        th1 = text(xv1,yv1,textstring1,'FontSize',8,'Tag','CursorText','Parent',axh);
        th2 = text(xv2,yv2,textstring2,'FontSize',8,'Tag','CursorText','Parent',axh);

        %For R13 or higher (MATLAB 6.5), use a background color on the text string
        v=ver('MATLAB');
        v=str2num(v.Version(1:3));
        if v>=6.5
            set(th1,'BackgroundColor',[0.93 0.93 0.93]);
            set(th2,'BackgroundColor',[0.93 0.93 0.93]);
        end;

        yl = ylim(axh);
        lim = localObjbounds(axh);
        lim = lim(3:4);     %y values only
        yl(isinf(yl)) = lim(isinf(yl));

        %Add the cursors
        ph1 = line([xv1 xv1 xv1],[yl(1) yv1 yl(2)], ...
            'Color',color, ...
            'Marker',marker, ...
            'Tag','Cursor', ...
            'UserData',[lineh th1], ...
            'LineStyle','-', ...
            'Parent',axh);
        ph2 = line([xv2 xv2 xv2],[yl(1) yv2 yl(2)], ...
            'Color',color, ...
            'Marker',marker, ...
            'Tag','Cursor', ...
            'UserData',[lineh th2], ...
            'LineStyle','-', ...
            'Parent',axh);

        %Add context menu to the cursors
%         cmenu = uicontextmenu('Parent',get(axh,'Parent'));
        cmenu = uicontextmenu('Parent',hFig);
        set([ph1 ph2],'UIContextMenu',cmenu);

        % Define the context menu items
        annMenu1 = uimenu(cmenu, 'Label', 'Annotate region', ...
            'Callback', 'dualcursor(''AnnotateReg'', [], [], [], get(gco, ''Parent''))');
        annMenu1 = uimenu(cmenu, 'Label', 'Analyse region', ...
            'Callback', 'dualcursor(''AnalyseReg'', [], [], [], get(gco,''Parent''))');
        annMenu1 = uimenu(cmenu, 'Label', 'Make figure of region', ...
            'Callback', 'dualcursor(''exportfig'',[],[],[],get(gco,''Parent''))');

        setappdata(th1,'Coordinates',[xv1 yv1]);
        setappdata(ph1,'Coordinates',[xv1 yv1]);
        setappdata(th2,'Coordinates',[xv2 yv2]);
        setappdata(ph2,'Coordinates',[xv2 yv2]);
        setappdata(th1,'CursorNumber',1);
        setappdata(ph1,'CursorNumber',1);
        setappdata(th2,'CursorNumber',2);
        setappdata(ph2,'CursorNumber',2);
        setappdata(th1,'FormatFcnH',datalabelformatfcnh);
        setappdata(th2,'FormatFcnH',datalabelformatfcnh);
        setappdata(th1,'Offset',[0 0]);     %Offset for the text label from the data value
        setappdata(th2,'Offset',[0 0]);     %Offset for the text label from the data value

        %     mh = uicontextmenu('Tag','DeleteObject', ...
        %         'Callback','ud = get(gco,''UserData'');delete([gco ud(2)]);');
        %     set([th1 th2],'UIContextMenu',mh);

        set(th1,'UserData',[lineh ph1]);     %Store handle to line
        set(th2,'UserData',[lineh ph2]);     %Store handle to line

        %Calculate Difference
        dx = xv2 - xv1;
        dy = yv2 - yv1;

        %Set Application Data.
        
        setappdata(axh,'Marker',marker);
        setappdata(axh,'Color',color);

        set(hFig,'WindowButtonDownFcn','dualcursor(''down'',[],[],[],get(gco,''Parent''))')
        set(hFig,'DoubleBuffer','on');       %eliminate flicker

    case 'down'      % Execute the WindowButtonDownFcn
        htype = get(gco,'Type');
        tag = get(gco,'Tag');
        marker = getappdata(axh,'Marker');
        color  = getappdata(axh,'Color');

        %If it's a movable object (Cursor, CursorText label, or Cursor Delta Text
        %label), make it movable.
        if strcmp(tag,'CursorText') | strcmp(tag,'Cursor') | strcmp(tag,'CursorDeltaText')
            set(gco,'EraseMode','xor')
            set(gcf,'WindowButtonMotionFcn','dualcursor(''move'',[],[],[],get(gco,''Parent''))', ...
                'WindowButtonUpFcn','dualcursor(''up'',[],[],[],get(gco,''Parent''))');
        end;

        if strcmp(tag,'Cursor') %If clicked on a cursor
            %Label the cursor we are moving.  Add a text label just above the plot
            CursorNumber = getappdata(gco,'CursorNumber');
            cnstr = num2str(CursorNumber);

            xl = xlim(axh);
            lim = localObjbounds(axh);
            lim = lim(1:2);     %x values only
            xl(isinf(xl)) = lim(isinf(xl));
            %             yl = lim(3:4);


            xv = getappdata(gco,'Coordinates');
            xv = xv(1);

            %Convert to normalized
            xn = (xv - xl(1))/(xl(2) - xl(1));
            yn = 1.05;

            CNh = text(xn,yn,cnstr, ...
                'Units','Normalized', ...
                'HorizontalAlignment','center', ...
                'Parent',axh);      %dx

            %For R13 or higher (MATLAB 6.5), use a background color on the text string
            v=ver('MATLAB');
            v=str2num(v.Version);
            if v>=6.5
                set(CNh,'BackgroundColor','y');
            end;
            setappdata(gco,'CNh',CNh);

        end

    case 'move'          % Execute the WindowButtonMotionFcn
        htype = get(gco,'Type');
        tag = get(gco,'Tag');
        if ~isempty(gco)

            %Special (simple) case - just repositioning the delta labels
            if strcmp(tag,'CursorDeltaText')    %The cursor delta labels.
                cp = get(axh,'CurrentPoint');
                pt = cp(1,[1 2]);

                %Put into normalized units
                ax = axis;
                lim = localObjbounds(axh);
                ax(isinf(ax)) = lim(isinf(ax));

                pt(1) = (pt(1) - ax(1))/(ax(2)-ax(1));
                pt(2) = (pt(2) - ax(3))/(ax(4)-ax(3));

                set(gco,'Position', [pt 0])
                drawnow
                return
            end;

            %Is this the cursor or the text
            if strcmp(tag,'CursorText')             %The text
                th = gco;
                handles = get(gco,'UserData');
                ph = handles(2);
                slide = 0;      %Don't slide along line; just reposition text
            else                                    %The marker
                ph = gco;
                handles = get(gco,'UserData');
                th = handles(2);
                slide = 1;      %Slide along line to next data point
            end;

            offset = getappdata(th,'Offset');       %Offset from data value

            cp = get(axh,'CurrentPoint');
            pt = cp(1,[1 2]);

            %Constrain to Line
            lh = getappdata(get(th,'Parent'),'SelectedLine');
            %             lh = handles(1);        %Line

            x = cp(1,1);       %first xy values
            y = cp(1,2);       %first xy values

            if slide            %Move to new data value
                xl = get(lh,'XData');
                yl = get(lh,'YData');


                %Get nearest value
                [xv,yv]=local_nearest(x,xl,yl);


                %If we are moving a cursor, must move the cursor number label, too
                if strcmp(tag,'Cursor')
                    %Move the Cursor Number label, too
                    CNh = getappdata(gco,'CNh');
                    pos = get(CNh,'Position');
                    xlm = xlim(axh);
                    lim = localObjbounds(axh);
                    lim = lim(1:2);     %x values only
                    xlm(isinf(xlm)) = lim(isinf(xlm));
                    xn = (xv - xlm(1))/(xlm(2)-xlm(1));
                    set(CNh,'Position',[xn pos(2:3)])
                end;

                yl = ylim(axh);
                lim = localObjbounds(get(lh,'Parent'));
                lim = lim(3:4);     %y values only
                yl(isinf(yl)) = lim(isinf(yl));
                datalabelformatfcnh = getappdata(th,'FormatFcnH');

                textstring = feval(datalabelformatfcnh,xv,yv);
                set(th,'Position', [xv yv 0] + [offset 0],'String',textstring)
                set(ph,'XData',[xv xv xv],'YData',[yl(1) yv yl(2)]);

                setappdata(ph,'Coordinates',[xv yv]);
                setappdata(th,'Coordinates',[xv yv]);

                %Update delta calculation
                cursors = findobj(axh,'Tag','Cursor');
                cn1 = getappdata(cursors(1),'CursorNumber');
                if cn1==2   %Switch order
                    temp = cursors(1);
                    cursors(1) = cursors(2);
                    cursors(2) = temp;
                end;


              %  deltah = getappdata(axh,'Delta_Handle');    %Handle to cursors

                %Positions of two dualcursors
                xy1 = getappdata(cursors(1),'Coordinates');
                xy2 = getappdata(cursors(2),'Coordinates');


                %Calculate Difference
                dx = xy2(1) - xy1(1);
                dy = xy2(2) - xy1(2);


            else                %Just move text around.
                set(th,'Position', [x y 0])
            end;
            drawnow
        end;

    case 'up'           % Execute the WindowButtonUpFcn
        htype = get(gco,'Type');
        tag = get(gco,'Tag');
        if strcmp(tag,'CursorText') | strcmp(tag,'Cursor') | strcmp(tag,'CursorDeltaText');
            set(gco,'EraseMode','Normal')
            set(gcf,'WindowButtonMotionFcn','')

            if strcmp(tag,'CursorText') %If the text label, record it's relative position
                cp = get(axh,'CurrentPoint');
                pt = cp(1,[1 2]);

                coords = getappdata(gco,'Coordinates');
                offset(1) = pt(1) - coords(1);
                offset = pt - coords;
                setappdata(gco,'Offset',offset);
            end;


            if strcmp(tag,'Cursor')        %Delete the temporary cursor number label
                CNh = getappdata(gco,'CNh');
                delete(CNh);
            end;
        end;
        
    case 'selectline'          % User selected a new line to be active
        %Make the selected line bold
        lh = getappdata(axh,'SelectedLine');
        lw = get(lh,'LineWidth');
        set(lh,'LineWidth',5*lw);
        drawnow

        %Update the cursors
        dualcursor('update',deltalabelpos,marker_color,datalabelformatfcnh,axh);

        %Put the line back the way you found it!
        set(lh,'LineWidth',lw);

    case 'update'               %Update the cursor value
        %Find the position of the existing cursors

        cursors = findobj(axh,'Tag','Cursor');
        cd1 = getappdata(cursors(1),'Coordinates');
        cd2 = getappdata(cursors(2),'Coordinates');
        cn1 = getappdata(cursors(1),'CursorNumber');
        cn2 = getappdata(cursors(2),'CursorNumber');
        clear x
        x(cn1) = cd1(1);        %x value of cursor number cn1
        x(cn2) = cd2(1);        %x value of cursor number cn2

        lh = getappdata(axh,'SelectedLine');

        handles = get(cursors(cn1),'UserData');
        th1 = handles(2);
        handles = get(cursors(cn2),'UserData');
        th2 = handles(2);

        offset1 = getappdata(th1,'Offset');       %Offset from data value
        offset2 = getappdata(th2,'Offset');       %Offset from data value

        ylm = ylim(axh);
        lim = localObjbounds(get(lh,'Parent'));
        lim = lim(3:4);     %y values only
        ylm(isinf(ylm)) = lim(isinf(ylm));

        xl = get(lh,'XData');
        yl = get(lh,'YData');

        %Get nearest value
        [xv1,yv1]=local_nearest(x(1),xl,yl);
        [xv2,yv2]=local_nearest(x(2),xl,yl);

        datalabelformatfcnh = getappdata(th1,'FormatFcnH');

        textstring1 = feval(datalabelformatfcnh,xv1,yv1);
        textstring2 = feval(datalabelformatfcnh,xv2,yv2);
        set(th1,'Position', [xv1 yv1 0] + [offset1 0],'String',textstring1)
        set(th2,'Position', [xv2 yv2 0] + [offset2 0],'String',textstring2)
        set(cursors(cn1),'XData',[xv1 xv1 xv1],'YData',[ylm(1) yv1 ylm(2)]);
        set(cursors(cn2),'XData',[xv2 xv2 xv2],'YData',[ylm(1) yv2 ylm(2)]);
        %Update delta calculation
        %deltah = getappdata(axh,'Delta_Handle');    %Handle to delta calculation

        %                 %Positions of two dualcursors
        xy1 = getappdata(cursors(1),'Coordinates');
        xy2 = getappdata(cursors(2),'Coordinates');

        %Calculate Difference
        dx = xv2 - xv1;
        dy = yv2 - yv1;
        
    case 'AnnotateReg'     %annotate region
             
        [ha, tag1, tag2] = Annotate('dualcursor', ...
            'dualcursor([],[],[],get(gco,''Parent''))');
        uiwait(gcf);
        
        [val,xd,yd] = local_extractregion(axh);      
            
        
        if length(xd)==1
            xd = xd{1};
            yd = yd{1};
        end;
       
        cursors.xd = xd;
        cursors.yd = yd;
        
        range = cursors.xd{1};       
        assignin('base','cursors',cursors);
        
        if str2double(tag1)~=99 && str2double(tag2)~=99
            annVal = [range(1) range(end) str2double(tag1) str2double(tag2)];
            exportAnnotation(axh,annVal)
        end
        %disp('Labels assigned');

    case 'AnalyseReg'
        
        analyseError = ...
            errordlg(['Not yet implemented' ],...
            ['error']);
            
    case 'exportfig'    
        [val,xd,yd,hgS] = local_extractregion(axh);
               
        fh = figure;
        ax = axes;
        plot(1:length(xd{1}),yd{1},'r',1:length(xd{1}),yd{2},'b',...
            1:length(xd{1}),yd{3}, 'g');
        xlim([1,length(xd{1})]);
        ylim([-2.5 3]);
        
%         ax = axes;
%         struct2handle(hgS,ax);
% 
%         newhandles(1) = title('');
%         newhandles(2) = xlabel('Sample');
%         newhandles(3) = ylabel('Acceleration');
% 
%         props = {'Title','xlabel','ylabel'}
%         vals = get(axh,props)
%         handles = [vals{:}];
%         str = get(handles,'String');
        
     
        
    %    set(newhandles,{'String'},str)
        
        %t = title(['NR: ', vnr, ' DEVICE: ',dev, ' DATE: ', date, ...
        %    ' INSTANT.-SPEED: ',mSpeed, ' TRAJECT-SPEED: ', tSpeed ]);
        % t = title(['TAG 1: ', tag1, 'TAG 2: ', tag2]);
        % set(t, 'Fontsize', 5);

    case 'off'   % Unset the WindowButton...Fcns
        % set(get(axh,'Parent'),'WindowButtonDownFcn','','WindowButtonUpFcn','')
        set(hFig,'WindowButtonDownFcn','','WindowButtonUpFcn','')

        h1 = findobj(axh,'Tag','CursorText');       %All text
        h2 = findobj(axh,'Tag','Cursor');           %The cursors
        h3 = findobj(axh,'Tag','CursorDeltaText');           %The cursors

        lineh = local_findlines(axh);
        set(lineh,'ButtonDownFcn','');

        %         erasemode = getappdata(axh,'OriginalEraseMode');
        %         if isempty(erasemode), erasemode = 'normal'; end;   %handles first time
        %         set(local_findlines(axh),'EraseMode',erasemode);

        delete([h1;h2;h3]);

end %switch/case on action
end

function exportAnnotation(axh,annVal)
        % Get cursor coordinates
        %cursordata = dualcursor(axh);
        %ANNMAT(end+1,:) = annVal
        % Push the data into the base workspace.
        annMat = evalin('base', 'annotations');
        assignin('base','annotations', [annMat;annVal]);
        disp('annotation added to workspace');
end

function [xv,yv]=local_nearest(x,xl,yl)

if sum(isfinite(xl))==1
    fin = find(isfinite(xl));
    xv = xl(fin);
    yv = yl(fin);
else
    %Normalize axes
    xlmin = min(xl);
    xlmax = max(xl);
    xln = (xl - xlmin)./(xlmax - xlmin);
    xn = (x - xlmin)./(xlmax - xlmin);


    %Find nearest x value only.
    c = abs(xln - xn);

    [junk,ind] = min(c);

    %Nearest value on the line
    xv = xl(ind);
    yv = yl(ind);
end;
end

function textstring = local_maketextstring(xv,yv)
textstring = {['x = ' num2str(xv,'%2g')];
    ['y = ' num2str(yv,'%2.2g')]};
end

function [val,xd,yd,hgS] = local_extractregion(axh)
val = dualcursor(axh);

lineh = local_findlines(axh);

Nl = length(lineh);

hgS = handle2struct(lineh);       

xd = get(lineh,'XData');
yd = get(lineh,'YData');

x1ind = zeros(Nl,1);
x2ind = zeros(Nl,1);

if Nl==1
    xd= {xd};
    yd = {yd};
end;


for ii = 1:Nl
    x1ind(ii) = max(find(xd{ii}<=val(1)));
    x2ind(ii) = max(find(xd{ii}<=val(3)));

    xd{ii} = xd{ii}(x1ind(ii):x2ind(ii));
    yd{ii} = yd{ii}(x1ind(ii):x2ind(ii));

    hgS(ii).properties.XData = xd{ii};
    hgS(ii).properties.YData = yd{ii};

end;
end

function lineh = local_findlines(axh);
lineh = findobj(axh,'Type','line');        %Find a line to add cursor to
dots = findobj(axh,'Type','line','Tag','Cursor');  %Ignore existing cursors
lineh = setdiff(lineh,dots);

xdtemp = get(lineh,'XData');
linehtemp = lineh;
lineh=[];
if ~iscell(xdtemp)      
    xdtemp = {xdtemp};
end;

for ii=1:length(xdtemp);
    if length(xdtemp{ii})>2
        lineh = [lineh; linehtemp(ii)];
    end;
end;
end

function lim = localObjbounds(axh);

kids = get(axh,'Children');
xmin = Inf; xmax = -Inf;
ymin = Inf; ymax = -Inf;
for ii=1:length(kids)
    try % Pass through if can't get data.  hopefully we hit at least one
        xd = get(kids(ii),'XData');
        xmin = min([xmin min(xd(:))]);
        xmax = max([xmax max(xd(:))]);

        yd = get(kids(ii),'YData');
        ymin = min([ymin min(yd(:))]);
        ymax = max([ymax max(yd(:))]);
    end
end
% Nuclear option, in case things went really bad
xmin(xmin==Inf) = 0;  xmax(xmax==-Inf) = 1;
ymin(ymin==Inf) = 0;  ymax(ymax==-Inf) = 1;

lim = [xmin xmax ymin ymax];
end
