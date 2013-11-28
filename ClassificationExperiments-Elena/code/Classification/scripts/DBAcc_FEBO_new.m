% DBAcc_FEBO_new- classification and vizualization of FEBO bird data

%% initializations
clear all,close all, clc

databaseHost = 'db.e-ecology.sara.nl';
project_path = fullfile('/','home','elena','LifeWatch','eEcology-Annotation-Model','ClassificationExperiments-Elena');
data_path = fullfile(project_path,'data');
results_path = fullfile(project_path,'results');

classifiers_fname = fullfile(data_path,'classifiers.mat');
load(classifiers_fname)
eco_queries =  fullfile(data_path,'eecologyqueries.mat'); 
query_id = 'sql_gps_acc';

% primpt the user for username and password
disp('Login credentials for access to eEcologyDB are needed.');
username = input('Please, enter your user name: ','s');  
password = input('Please, enter your password: ','s');

set(0, 'DefaultFigureRenderer', 'zbuffer');

IDevice = 355;
starttime = '2010-06-28 00:02:00';
stoptime  = '2010-06-28 18:15:00';

%num_meas = 40;
num_features= 58;
num_classes= 7;
windowSize=20;
overlap=0;
epsilon = 0.3;

IDdate=[num2str(IDevice) '_' starttime(1:4) starttime(6:7) starttime(9:10)...
    '_' starttime(12:13) starttime(15:16) starttime(18:19) ...
    '__' stoptime(1:4) stoptime(6:7) stoptime(9:10)...
    '_' stoptime(12:13) stoptime(15:16) stoptime(18:19)];


fileName=[fullfile(results_path, 'S') IDdate '.kmz'];
iconStr = ['http://maps.google.com/','mapfiles/kml/pal2/icon26.png']; 
iconSize = 0.4;
classText='stand flap soar walk sit XFl  float NoCl';
dateTimeFormat = 'yyyy-mm-ddTHH:MM:SSZ';

%mat-file for storing intermediate results
StorName=[fullfile(results_path,'Stor') IDdate '.mat'];

%name datacube
DCubeName= [fullfile(results_path,'Datacube') IDdate];

% name annotation file
AnotName= [fullfile(results_path,'Anot') IDdate];
% create png directory
dirName=[results_path IDdate 'png'];
if ~exist(dirName,'dir')
    mkdir(dirName);
end
%% get the data from the DB

t=clock;

disp('Retrieving data from the DB...');
tic
% [tracks] = getDataFromEecologyDB(username, password,...
%                                eco_queries, query_id,...
%                                IDevice, starttime, stoptime);

connection = connectEecologyDB(databaseHost, username, password);
[tracks] = getAccelerometerData(connection,...
                                 IDevice, starttime, stoptime,...
                                 false);

num_meas = getAccelerometerSize(connection, ...
                                IDevice, starttime, stoptime,...
                                false);
disp('Done.');

toc
%% format the data
disp('Formatting the data...');
tic
[formatted_tracks] = formatDataStructure(tracks);
disp('Done.');
toc

%% classify the data
disp('Classification...');
tic
[class_data, FTVstor, INFO]=classifyAccMeas(formatted_tracks, num_meas, classifiers, ...
                                    num_features, num_classes, windowSize, overlap, epsilon);
disp('Done.');                                
toc
%% create Datacube
disp('Creating Datacube...');
tic
Datacube = createDatacube(class_data,1,DCubeName);
disp('Done.');
toc

%% create Anotations
disp('Creating Annotations...');
tic
FTVanot = createAnot(FTVstor,num_features,1,AnotName);
disp('Done.');                                
toc

%% Make kmz
disp('Creating KMZ file...');
tic
makeKMZanot(class_data, iconStr, iconSize, ...
                          classText, dateTimeFormat, dirName, fileName, true);
disp('Done.');                                
toc


disp('Total elapsed time: ');
etime(clock, t)
