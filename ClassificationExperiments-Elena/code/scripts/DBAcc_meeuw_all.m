% DBAcc_meeuw_all- fetching all meeuw data 

%% initializations
clear all,close all, clc

username = 'elena';  % put your user name and password here. 
password = 'Vily_pily12';

% IDevice = [320];
% starttime = '2010-06-08 02:09:36';
% stoptime  = '2010-06-09 09:07:20';

IDevice = [325];
starttime = '2010-06-09 00:13:48';
stoptime  = '2010-06-09 11:01:05';
num_meas = 40;
num_features= 58;
num_classes= 7;

IDdate=[IDevice '_' starttime(1:4) starttime(6:7) starttime(9:10) '_' stoptime(1:4) stoptime(6:7) stoptime(9:10)];

%mat-file for storing intermediate results
StorName=['../../results/Stor' IDdate '.mat'];

%name datacube
DCubeName= ['../../results/Datacube' IDdate];


%% get the data from the DB
[tracks] = getDataFromEecologyDB(username, password,...
                               '../../data/eecologyqueries.mat', 'sql_gps_acc', IDevice, starttime, stoptime)
%% format the data
[formatted_tracks] = formatDataStructure(tracks);


%% classify the data
%[class_data, FTVstor]=classifyAccMeas(formatted_tracks, num_meas, classifiers, num_features, num_classes);

%% create Datacube
%Datacube = createDatacube(class_data,1,DCubeName);

