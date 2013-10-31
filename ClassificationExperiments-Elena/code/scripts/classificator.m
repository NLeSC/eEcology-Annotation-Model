function classificator(dbUsername, dbPassword, dbName, databaseHost, TrackerIdentifier, startTime, stopTime, data_path)
% classification and vizualization of a track for adding to script wrapper
%
% INPUT
% dbUsername is a string for connecting to the database
% dbPassword is a string for connecting to the database
% dbName is a string
% databaseHost is a string hostname of the database
% TrackerIdentifier is a tracker indentifiers, eg '800'.
% startTime is a string in ISO8601 time format, eg. '2013-07-01T00:00:00'
% stopTime is a string in ISO8601 time format, eg. '2013-07-01T00:00:00'
% data_path is string of a directory where classifiers.mat and eecologyqueries.mat reside
%
% Command to compile:
% mcc -mv -R -nodisplay -I googlearth -I openearth/io/postgresql -I openearth -I openearth/general -I openearth/general/io_fun -I code code/scripts/classificator.m
%
% Usage:
% ./run_classificator.sh /opt/matlab2009b '****' '****' eecology db.e-ecology.sara.nl 800 2010-07-01T00:00:00 2010-09-01T00:00:00 /data/classifiers

TrackerIdentifier = str2double(TrackerIdentifier);

results_path = '';

classifiers_fname = fullfile(data_path,'classifiers.mat');
load(classifiers_fname);

num_meas = 40;
num_features= 58;
num_classes= 7;
windowSize=20;
overlap=0;
epsilon = 0.3;

%filename for kmz file
IDdate=[num2str(TrackerIdentifier) '_' startTime(1:4) startTime(6:7) startTime(9:10)...
    '_' startTime(12:13) startTime(15:16) startTime(18:19) ...
    '__' stopTime(1:4) stopTime(6:7) stopTime(9:10)...
    '_' stopTime(12:13) stopTime(15:16) stopTime(18:19)];

fileName=[fullfile(results_path, 'S') IDdate '.kmz'];
fileCSVName=[fullfile(results_path, 'S') IDdate '.csv'];
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
dirName=[results_path IDdate '.png'];
%% get the data from the DB
t=clock;
disp('Retrieving data from the DB...');
tic
% TODO pass dbName, databaseHost so script can be used against other databases
[tracks] = getDataFromEecologyDB(dbUsername, dbPassword,...
                                 TrackerIdentifier, startTime, stopTime);
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
            classText, dateTimeFormat, dirName, fileName);
disp('Done.');
toc

disp('Creating CSV file...');
tic
makeCSVanot(class_data, ...
            classText, dateTimeFormat,  fileCSVName);
disp('Done.');
toc


disp('Cleaning up...');
delete(strcat(AnotName, '.mat'));
delete(strcat(DCubeName, '.mat'));
disp('Done.');

disp('Total elapsed time: ');
etime(clock, t)