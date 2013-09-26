% DBAcc_FEBO_new- classification and vizualization of FEBO bird data

%% initializations
clear all,close all, clc

load ../data/classifiers.mat
FTVstor=[];

username = <your-name>;  % put your user name and password here. 
password = <your-passwd>;

set(0, 'DefaultFigureRenderer', 'zbuffer');

IDevice = [355];
starttime = '2010-06-28 00:02:00';
stoptime  = '2010-06-28 18:15:00';

num_meas = 40;
num_features= 58;
num_classes= 7;

IDdate=[IDevice '_' starttime(1:4) starttime(6:7) starttime(9:10) '_' stoptime(1:4) stoptime(6:7) stoptime(9:10)];

%mat-file for storing intermediate results
StorName=['./results/Stor' IDdate '.mat'];

%name datacube
DCubeName= ['./results/Datacube' IDdate];


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

