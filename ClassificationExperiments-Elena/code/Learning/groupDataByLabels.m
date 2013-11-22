%% groupDataByLabels- generates files with groups from annotad data by labels
%
% author: Elena Ranguelova, NLeSc
% date creation: 22-11-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [data_groups, labels]=groupDataByLabels(data,label_index)
%
% INPUT
% data- data matrix as output by getDataFromAnnotStruct function
% label_index -the index in the data where the label info is
%
% OUPTPUT
% data_groups- a chunck of the data each of the output arguments should be described
% labels- a row vector of all possible labels in the annotated data
%
% EXAMPLE
% load ./data/Annotated_data/Test2.mat
% data = getDataFromAnnotStruct(outputStruct)
% [data_groups, labels]=groupDataByLabels(data,8)
% 
% SEE ALSO
% getDataFromAnnotStruct
%
% REFERENCES
% Based on  Merijn de Bakker's code groupD2Label.m  
%
% NOTES
% label_index should be 8 (see Merijn's notes and getDataFromAnnotStruct)

function [data_groups, labels]=groupDataByLabels(data,label_index)


% get the non NaN data    
data = data(~isnan(data(:,label_index)),:);

% get all unique labels present in the data
labels = unique(data(:,label_index));

% for each label create a data chunk
num_labels = length(labels);
data_groups = cell(num_labels,1);

for l=1:num_labels
    
    [row, col] = find(data(:,label_index)==labels(l));
    
    data_group = data(row,:);
        
    data_groups{l} = data_group;
 end
    
  
        
        
    