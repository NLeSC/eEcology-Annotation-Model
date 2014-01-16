function [ featureSelection ] = removeHighestCorrelatingFeature(data, featureSet)
% Takes a list of features as column indices of the data. Intercorrelations 
% of the features of the data are calculated. The feature with the highest
% sum of correlations with other features is removed from the list. The
% list of remaining features is returned.
% Author: Christiaan Meijer, NLeSc
% Creation data: 15-01-2014
features = data(:,featureSet);
c = corrcoef(features);
[~,i] = sort(sum(abs(c),2));

featureSelection = featureSet;
featureSelection(i(end)) = [];
end

