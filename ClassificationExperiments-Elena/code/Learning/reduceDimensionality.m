function [ reducedTrainSet, reducedTestSet, mapping ] ...
    = reduceDimensionality( trainSet, testSet, kind, varargin)
% Reduces the dimensionality of the instances by means of PCA or LDA.
% Author: Christiaan Meijer, NLeSc
% Creation date: ??-01-2014

if (size(varargin) >= 1)
        targetDimensionality = varargin{1};
    else 
        targetDimensionality = inf;
end
    
if (strcmp(kind, 'pca'))    
    [mapping, frac] = pca(trainSet, targetDimensionality);    
    reducedTrainSet = trainSet * mapping;
    reducedTestSet = testSet * mapping;    
elseif (strcmp(kind, 'lda'))    
    mapping = fisherm(trainSet, targetDimensionality);    
    reducedTrainSet = trainSet * mapping;
    reducedTestSet = testSet * mapping;    
else
reducedTrainSet = trainSet;
reducedTestSet = testSet;
mapping = [];
end

end

