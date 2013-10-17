%% makeKMZanot - function to generate KMZ files with anotations
%
% author: Elena Ranguelova, NLeSc
% date creation: 23-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% []=makeKMZanot(inp_data, iconStr, iconSize, ...
%                classText, dateTimeFormat, dirName, fileName)
%
% INPUT
% inp_data- anotated data as output by the classification
% iconStr- string with value the location of the icon to be used
% iconSize- the size of the icon
% classText- the classification legend string
% dateTimeFormat- the format for the date and time to be displayed
% dirName- the directory name to save the PNG files
% fileName - the filename of the kmz file
%
% OUPTPUT
%
% EXAMPLE
% see DBAcc_Texel_New.m
%
% SEE ALSO
% DBAcc_Texel_New.m, MakeKMZanot.m (legacy)
% writeAccPNG.m
%
% REFERENCES
% Any publications or resources used
%
% NOTES
% extra notes

function []= makeKMZanot(inp_data, iconStr, iconSize, ...
                         classText, dateTimeFormat, dirName, fileName)

% initializations
kmlStr ='';
behaviorclass=0;

Year = inp_data.year;
Month = inp_data.month;
Day = inp_data.day;
Hour = inp_data.hour;
Min = inp_data.min;
Sec = inp_data.sec;
ISpd = inp_data.ispd;
TSpd = inp_data.tspd;
Class = inp_data.class;
Device = inp_data.device;
Long =inp_data.long;
Lat = inp_data.lat;
Alt = inp_data.alt;

%Set colour table
stand= 'ff0000ff';
flap= 'ff00ffff';
soar= 'ff9900ff';
walk= 'ffccccff';
sit= 'ff00ff00';
Xfl= 'ffffff00';
float= 'ffff0000';
NoCl= '83000000';

%%%Set time
numTime = datenum(Year,Month,Day,Hour,Min,Sec);
time=datenum(Year,Month,Day,Hour,Min,Sec)-735235;

Ix = find(Year<1900|Year>2015);
numTime(Ix)=NaN;
clear Ix;

kmlStr = [kmlStr,ge_plot(Long,...
                Lat,...
                 'lineColor','ff00ffff',...
                 'lineWidth',1)];



for j=2:length(Long)-1
    % set time stamp
    tNumPrev = datenum(numTime(j-1));
    tNumNow = datenum(numTime(j));
    tNumNext = datenum(numTime(j+1));
    if isnan(tNumPrev)&&~isnan(tNumNow)
        tStart = datestr(tNumNow+datenum([0,0,0,-1,0,0]),dateTimeFormat);
    elseif ~isnan(tNumPrev)&&~isnan(tNumNow)
        tStart = datestr(mean([tNumPrev;tNumNow]),dateTimeFormat);
    else
        clear tNumPrev
        clear tNumNow
        clear tNumNext
        clear tStart
        clear tStop
        continue
    end

    if isnan(tNumNext)&&~isnan(tNumNow)
        tStop = datestr(tNumNow+datenum([0,0,0,+1,0,0]),dateTimeFormat);
    elseif ~isnan(tNumNext)&&~isnan(tNumNow)
        tStop = datestr(mean([tNumNext;tNumNow]),dateTimeFormat);
    else
        clear tNumPrev
        clear tNumNow
        clear tNumNext
        clear tStart
        clear tStop
        continue
    end

    switch Class(j)
        case 1
            behaviorclass= stand;
        case 2
            behaviorclass= flap;
        case 3
            behaviorclass= soar;
        case 4
            behaviorclass= walk;
        case 5
            behaviorclass= sit;
        case 6
            behaviorclass= Xfl;
        case 7
            behaviorclass= float;
        otherwise
            behaviorclass= NoCl;
    end;


     extraData = {'UTM time',datestr(tNumNow,0);...
                 'sensor ID',num2str(Device(j));...
                 'sensor time',num2str(time(j),8);...
                 'long lat',[num2str(Long(j))...
                 '  ' num2str(Lat(j))];...
                 'altitude [m]',num2str(Alt(j));...
                 'T-P Speed [m/s]',[num2str(TSpd(j)) '  ' num2str(ISpd(j))];...
                 'Class', classText(5*(Class(j)-1)+1:5*(Class(j)-1)+5);...
                 'record index',num2str(j)};

        bgColor = {'#D0D0D0';'#F0F0F0'};
        htmlStr = ['<TABLE border="0px">',char(10)];
        clear pngFileName
        if isnan(Class(j))==0
            pngFileName = [dirName '/accelero',num2str(j,'%04d'),'B.png'];
            writeAccPNG(pngFileName, inp_data, j, classText);
            htmlStr = [htmlStr,'<TR><TD colspan="2"><img src="',pngFileName,'"></TD></TR>',char(10)];

        end
        for iRow = 1:size(extraData,1)
            htmlStr = [htmlStr,'<TR bgcolor="',bgColor{1+mod(iRow,2),1},'"><TD>',extraData{iRow,1},'</TD>',...
                '<TD>',extraData{iRow,2},'</TD></TR>',char(10)];
        end
        htmlStr = [htmlStr,'</TABLE>'];


       if Alt(j)>2
         kmlStr = [kmlStr,ge_point(Long(j),...
                  Lat(j),...
                  Alt(j),...
                  'iconURL',iconStr,...
                  'altitudeMode','absolute',...
                  'extrude',1,...
                  'name','',...
                  'iconColor', behaviorclass,...
                  'iconScale',iconSize,...
                  'description',htmlStr,...
                  'timeSpanStart',tStart,...
                  'timeSpanStop',tStop)];
        else
         kmlStr = [kmlStr,ge_point(Long(j),...
                  Lat(j),...
                  10,...
                  'iconURL',iconStr,...
                  'altitudeMode','clampToGround',...
                  'extrude',1,...
                  'name','',...
                  'iconColor', behaviorclass,...
                  'iconScale',iconSize,...
                  'description',htmlStr,...
                  'timeSpanStart',tStart,...
                  'timeSpanStop',tStop)];
        end

end;

% Save
kml_all = [ge_folder('points', kmlStr)];
% Create kml
newfilename = fileName(1:(end-4));
newfilename = strcat(fileName,'.kml');
ge_output(newfilename,kml_all);
% Create kmz = kml + dir with pngs
zip(fileName, {newfilename, dirName});


