%% writeAccPNG - generates KMZ file from anotated accelerometer data
%
% author: Elena Ranguelova, NLeSc
% date creation: 23-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% []=writeAccPNG(pngFileName, inp_data, index, classText)
%
% INPUT
% pngFileName - filename (PNG) for saving
% inp_data - anotated accelerometer data
% index- data point index
% classText - classification legend
%
% OUPTPUT
% 
%
% EXAMPLE
% seeDBAcc_Texel_New.m
% 
% SEE ALSO
% DBAcc_Texel_New.m, MakeKMZanot.m (legacy)
%
% REFERENCES
% Any publications or resources used
%
% NOTES
% extra notes


function writeAccPNG(pngFileName, inp_data, index, classText)

DataRec =inp_data.data(index,:);
Month = inp_data.month;
Hour = inp_data.hour;
Min = inp_data.min;
Sec = inp_data.sec;
ISpd = inp_data.ispd;
TSpd = inp_data.tspd;
Class = inp_data.class;


scrsz = get(0,'ScreenSize');
L=length(DataRec);L=3*floor(L/3);
X=DataRec(1:L/3); Y=DataRec(L/3+1:2*L/3); Z=DataRec(2*L/3+1:L);
L=length(Z);
dstr=[num2str(Day(index)),'-',num2str(Month(index))];

if Hour(index) >= 10
   hstr=num2str(Hour(index));
else
   hstr=['0',num2str(Hour(index))];
end
if Min(index) >= 10
   mstr=num2str(Min(index));
else
   mstr=['0',num2str(Min(index))];
end
if Sec(index) >= 10
   sstr=num2str(Sec(index));
else
   sstr=['0',num2str(Sec(index))];
end

set(figure(2), 'Position',[50 50 scrsz(3)/5 scrsz(4)/6]);    axes('fontsize',16);
plot((1:length(X))*0.05,X, 'ro-','LineWidth',2,  'MarkerSize',8); ylim([-1.5 2.5]); grid on
hold on
plot((1:length(Y))*0.05,Y, 'bo-','LineWidth',2,  'MarkerSize',8)
plot((1:length(Z))*0.05,Z, 'go-','LineWidth',2,  'MarkerSize',8)
title(['D',dstr,', T', hstr,':',mstr,':',sstr, ', R',num2str(index),', TSp',num2str(TSpd(index)), ...
     ' ISp',num2str(ISpd(index)), ' m/s, Class=', classText(5*(Class(index)-1)+1:5*(Class(index)-1)+5)],'fontsize',16);
xlabel('time (sec)','fontsize',16); 

drawnow
print ('-dpng', pngFileName,'-r72')
close(figure(2))

