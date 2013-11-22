%% getDataFromAnnotStruct- creates data array from the annotation structure of AccVidGui
%
% author: Elena Ranguelova, NLeSc
% date creation: 22-11-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [data]=getDataFromAnnotStruct(annot_struct)
%
% INPUT
% annot_struct- annotation structure as outputted by AccVidGui
%
% OUPTPUT
% data- the data matrix containing the relevrant data from the annotation
% structure
%
% EXAMPLE
% load ./data/Annotated_data/D320_08062010.mat
% data = getDataFromAnnotStruct(outputStruct)
%
% SEE ALSO
% AccVidGui- annotation tool developed by Merijn deBakker
%
% REFERENCES
% Based on Merijn's code getLablsFromStruct.m
%
% NOTES
% 

function [data]=getDataFromAnnotStruct(annot_struct)

% initialization 
num_samples = annot_struct.nOfSamples;
%num_tags = size(annot_struct.tags,2);
%data = zeros(num_samples, 7+num_tags);
data = [];

for i = 1:num_samples
    id=[];
    sp=[];
    da=[];
    index1=[];
   
    date = datenum([annot_struct.year(i) annot_struct.month(i) annot_struct.day(i) ...
        annot_struct.hour(i) annot_struct.min(i) annot_struct.sec(i)]);
    maxN = max([size(annot_struct.accX{i},2),size(annot_struct.accY{i},2),size(annot_struct.accZ{i},2)]);  
    annot_struct.accX{i}(end+1:maxN) = NaN;
    annot_struct.accY{i}(end+1:maxN) = NaN;
    annot_struct.accZ{i}(end+1:maxN) = NaN;
    
    id(1:maxN,1) = annot_struct.sampleID(i);
    da(1:maxN,1) = date;
       
    %sp(1:maxN,1) = annot_struct.gpsSpd2D(i);
    sp(1:maxN,1) = annot_struct.gpsSpd(i);
    index1 = 0:maxN-1;
 
    data       = [data; ...
                 id da index1' ...
                 annot_struct.accX{i}' annot_struct.accY{i}' annot_struct.accZ{i}' ...
                 sp annot_struct.tags{i}];

end

end