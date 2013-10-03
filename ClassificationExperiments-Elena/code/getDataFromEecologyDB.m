%% getDataFromEecologyDB - getting data from the eEcology UvA DB
% Getting the accelerometer, GPS, speed etc. data from the DB
%
% author: Elena Ranguelova, NLeSc
% date creation: 16.08.2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [data] = getDataFromEecologyDB(username, password, ...
%                                querystorefname, queryid, ...
%                                device, starttime, stoptime)
%
% INPUT
% username, password- the string credentials for logging to the eEcology DB
% querystorefname- filename where common queries are stored as parametreised 
%                  strings (currenlty it's in ../data/eecologyqueries.mat)
% queryid- a query idenifier- variable name under which the query was
%          stored in the querystorefname
% device - device ID for which the data are to be  retrieved
% starttime and stoptime- define the time strip of interest. 
%                         Strings of format 'yyy-mm-dd hh:mm:ss'
%
% OUPTPUT
% data- the output data structure retrieved from the DB
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<your-user-name>, <your-password>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00')
%
% SEE ALSO
% DBAcc_Texel/FEBO.m scripts from W. Bouten (legacy)
%
% REFERENCES

function [data] = getDataFromEecologyDB(username, password, ...
                                        querystorefname, queryid, ...
                                        device, starttime, stoptime)

%% Paramters
IDevice = num2str(device);    
start = strcat('''',starttime,''''); 
stop = strcat('''',stoptime,'''');
load(querystorefname, queryid);

 %% Connect to the DB using jdbc
 connection = database('eecology', username, password,...
                       'org.postgresql.Driver', ...
           'jdbc:postgresql://db.e-ecology.sara.nl:5432/eecology?ssl=true');  
 % set db preferences    
 setdbprefs('DataReturnFormat','structure');    
    
%% Generate/load query  
sql_query = sprintf(eval(queryid), IDevice, start, stop, IDevice, start, stop);
  
%% Execute the query  
cursor = exec(connection,sql_query);

% this fetch command actually transfers the data from database table to matlab
cursor = fetch(cursor);

%% Get the data from the cursor
data = cursor.Data;
%cursor.message;

%% Close the database connection
close(connection); 

