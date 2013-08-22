%% prepareData4FeatExtraction - preparation of data for feature extraction
%
% author: Elena Ranguelova, NLeSc
% date creation: 22-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [feat_data]=prepareData4FeatExtraction(formatted_data, ind, offset)
%
% INPUT
% formatted_data- formatted DB GPS and accelerometer data 
% ind- the index of the data point in the birds' trajectory
% offset - index offset- number of measurements
%
% OUPTPUT
% feat_data- each of the output arguments should be described
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<your-user-name>, <your-password>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% j =  1; na = 40; na1 = na - 1;
% [feat_data] = prepareData4FeatExtraction(formatted_tracks, j, na1);
% 
% SEE ALSO
% getDataFromEecologyDB.m, formatDataStructure.m
% DBAcc_Texel/FEBO.m scripts from W. Bouten (legacy)
%
% REFERENCES

function [feat_data] = prepareData4FeatExtraction(formatted_data, ind, offset)
 
% index limits
start = ind; stop = ind + offset;
limits = start:stop;

% get the relevant data
device = formatted_data.device(limits); 
datetime = formatted_data.datetime(limits);
index = formatted_data.index(limits);
x = formatted_data.x(limits);
y = formatted_data.y(limits);
z = formatted_data.z(limits);
speed = formatted_data.ispd(limits);

% construct data suitable for feature calsulations
feat_data = [device, datetime, index, x, y, z, speed];



