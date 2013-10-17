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
    formatted_data=input_data;
    formatted_data.datetime=input_data.date_time;
    datavecs = datevec(formatted_data.datetime);
    formatted_data.year=datavecs(:,1);
    formatted_data.month=datavecs(:,2);
    formatted_data.day=datavecs(:,3);
    formatted_data.hour=datavecs(:,4);
    formatted_data.minute=datavecs(:,5);
    formatted_data.second=datavecs(:,6);


