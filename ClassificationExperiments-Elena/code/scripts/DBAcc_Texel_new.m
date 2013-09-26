% DBAcc_Texel_new- classification and vizualization of Texel bird data

%% initializations
clear all,close all, clc

load ../data/classifiers.mat
FTVstor=[];

username = <your-name>;  % put your user name and password here. 
password = <your-passwd>;

set(0, 'DefaultFigureRenderer', 'zbuffer');

IDevice = [754];
starttime = '2013-06-08 06:20:00';
stoptime  = '2013-06-08 07:00:00';

num_meas = 60;
num_features= 58;
num_classes= 7;

%filename for kmz file
IDdate=[num2str(IDevice) '_' starttime(1:4) starttime(6:7) starttime(9:10) '_' stoptime(1:4) stoptime(6:7) stoptime(9:10)];
fileName=['./results/S' IDdate '.kmz'];
iconStr = ['http://maps.google.com/','mapfiles/kml/pal2/icon26.png']; 
iconSize = 0.4;
classText='stand flap soar walk sit XFl  float NoCl';
dateTimeFormat = 'yyyy-mm-ddTHH:MM:SSZ';

%mat-file for storing intermediate results
StorName=['./results/Stor' IDdate '.mat'];

%name datacube
DCubeName= ['./results/Datacube' IDdate];
% name annotation file
AnotName= ['./results/Anot' IDdate];
% create png directory
dirName=['./results/' IDdate 'png'];
if ~exist(dirName,'dir')
    mkdir(dirName);
end


%% get the data from the DB
[tracks] = getDataFromEecologyDB(username, password,...
                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
                               IDevice, starttime, stoptime)
%% format the data
[formatted_tracks] = formatDataStructure(tracks);


%% classify the data
[class_data, FTVstor]=classifyAccMeas(formatted_tracks, num_meas, classifiers, ...
                                    num_features, num_classes);

%% create Datacube
Datacube = createDatacube(class_data,1,DCubeName);

%% create Anotations
FTVanot = createAnot(FTVstor,num_features,1,AnotName);


%% Make kmz
 makeKMZanot(class_data, iconStr, iconSize, ...
                          classText, dateTimeFormat, dirName, fileName);