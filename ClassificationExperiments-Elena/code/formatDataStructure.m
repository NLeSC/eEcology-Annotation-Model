%% formatDataStructure - formatting the data retrieved from the EcologyDB
%
% author: Elena Ranguelova, NLeSc
% date creation: 22.08.2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [formatted_data]=formatDataStructure(input_data)
%
% INPUT
% input_data- the data structure as retrieved from the DB (using query like
%             the 'sql_gps_acc' from '../data/eecologyqueries.mat')
%
% OUPTPUT
% formatted_data- the input data structure formatted (to default double)
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<your-user-name>, <your-password>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% 
% SEE ALSO
% getDataFromEecologyDB.m
% DBAcc_Texel/FEBO.m scripts from W. Bouten (legacy)
%
% REFERENCES

function [formatted_data] = formatDataStructure(input_data)

% format or copy each the field of the structure
    formatted_data.device=input_data.device_info_serial;
    formatted_data.datetime=datenum(input_data.date_time);
    formatted_data.index=input_data.index;
    formatted_data.year=input_data.year;
    formatted_data.month=input_data.month;
    formatted_data.day=input_data.day;
    formatted_data.hour=input_data.hour;
    formatted_data.minute=input_data.minute;
    formatted_data.second=input_data.second;
    formatted_data.long=input_data.longitude;
    formatted_data.lat=input_data.latitude;
    formatted_data.alt=input_data.altitude;
    formatted_data.x=input_data.x_cal;
    formatted_data.y=input_data.y_cal;
    formatted_data.z=input_data.z_cal;
    formatted_data.ispd=input_data.speed;
    formatted_data.tspd=input_data.tspeed;


