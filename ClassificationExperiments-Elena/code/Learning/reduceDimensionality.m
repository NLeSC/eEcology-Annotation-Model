function [ reducedTrainSet, reducedTestSet, mapping ] ...
    = reduceDimensionality( trainSet, testSet, kind, varargin)

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

