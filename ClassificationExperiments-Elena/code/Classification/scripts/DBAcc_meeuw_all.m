% DBAcc_meeuw_all- fetching all meeuw data 

%% initializations
clear all,close all, clc

databaseHost = 'db.e-ecology.sara.nl';
project_path = fullfile('/','home','elena','LifeWatch','eEcology-Annotation-Model','ClassificationExperiments-Elena');
data_path = fullfile(project_path,'data');
results_path = fullfile(project_path,'results');

classifiers_fname = fullfile(data_path,'classifiers.mat');
load(classifiers_fname);
eco_queries =  fullfile(data_path,'eecologyqueries.mat'); 
query_id = 'sql_gps_acc';

% prompt the user for username and password
disp('Login credentials for access to eEcologyDB are needed.');
username = input('Please, enter your user name: ','s');  
password = input('Please, enter your password: ','s');

% IDevice = [320];
% starttime = '2010-06-08 02:09:36';
% stoptime  = '2010-06-09 09:07:20';

IDevice = [325];
starttime = '2010-06-09 00:13:48';
stoptime  = '2010-06-09 11:01:05';

%num_meas = 60;
num_features= 58;
num_classes= 7;
windowSize=20;
overlap=10;
epsilon = 0.3;

IDdate=[IDevice '_' starttime(1:4) starttime(6:7) starttime(9:10) '_' stoptime(1:4) stoptime(6:7) stoptime(9:10)];

%mat-file for storing intermediate results
StorName=[fullfile(results_path,'Stor') IDdate '.mat'];

%name datacube
DCubeName= [fullfile(results_path,'Datacube') IDdate];

%% get the data from the DB
% [tracks] = getDataFromEecologyDB(username, password,...
%                               eco_queries, query_id, IDevice, starttime, stoptime)
connection = connectEecologyDB(databaseHost, username, password);
[tracks] = getAccelerometerData(connection,...
                                 IDevice, starttime, stoptime,...
                                 false);

num_meas = getAccelerometerSize(connection, ...
                                IDevice, starttime, stoptime,...
                                false);


%% format the data
[formatted_tracks] = formatDataStructure(tracks);


%% classify the data
[class_data, FTVstor, INFO]=classifyAccMeas(formatted_tracks, num_meas, classifiers,...
    num_features, num_classes, windowSize, overlap, epsilon);

%% create Datacube
Datacube = createDatacube(class_data,1,DCubeName);

