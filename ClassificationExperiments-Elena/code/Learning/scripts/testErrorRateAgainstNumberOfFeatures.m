%%
% Script for training and testing a classifier multiple times using a
% different number of features. Highest correlating features are removed.
% Author: Christiaan Meijer, NLeSc
% Creation date: 15-01-2014

totalFeatures = 1:58;
nTotalFeatures = size(totalFeatures,2);
results = [];
for nFeatures = 1:58
    features = totalFeatures;
    for i = 1:nTotalFeatures - nFeatures        
        features = removeHighestCorrelatingFeature(trainSet(2:end), features);        
    end
    error = trainAndTest(trainSet, testSet, features);    
    results = [results; nFeatures, error];
end
disp(results);
