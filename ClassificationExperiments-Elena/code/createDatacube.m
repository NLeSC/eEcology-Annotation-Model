%% createDatacube - generates datacube with raw data and classifications 
%
% author: Elena Ranguelova, NLeSc
% date creation: 23-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% Datacube=createDatacube(inp_data, save_flag, [save_fname])
%
% INPUT
% inp_data- the data structure obtained after classification
% save_flag- Boolean indicating weater Datacube should be saved 
% save_fname- the MAT filename for saving the Datacube (optional)
%
% OUPTPUT
% Datacube- the datacube with relevant data as cell array
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<username>, <password>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% load ../data/classifiers.mat
% [class_data, FTVstor]=classifyAccMeas(formatted_tracks, 40,  classifiers, 58, 7);
% Datacube = createDatacube(class_data,0);
% --OR--
% Datacube = createDatacube(class_data,1,'Datacube.mat');
% 
% SEE ALSO
% classifyAccMeas.m
% DBAcc_Texel/FEBO.m- scripts by W.Bouten (legacy)
%
% REFERENCES
%
% NOTES

function Datacube = createDatacube(inp_data, save_flag, save_fname)

if nargin < 3
    if save_flag  > 0
        error('Please, specify the MAT filename to save the Datacube.');
    else
        save_fname =[];
    end
end

Datacube={}

Datacube{1}=inp_data.device;
Datacube{2}=inp_data.datetime;
Datacube{3}=inp_data.long;
Datacube{4}=inp_data.lat;
Datacube{5}=inp_data.alt;
Datacube{6}=inp_data.ispd;
Datacube{7}=inp_data.predictions;
Datacube{8}=inp_data.data;

if save_flag
    save(save_fname, 'Datacube');
end




