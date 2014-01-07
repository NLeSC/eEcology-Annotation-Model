%merijn de bakker
%03-04-2010
%
%bird-project | FEATURE SERIES
%
%FUNCTION SPLITSET
%randomly splits a given dataset into a trainset and a validationset
%INPUT: a matrix with N-examples and M-features, trainsize (e.g. 0.66)).
%varargin: train-filename (csv), test-filename (csv)
%OUTPUT: train- validationset as a matrix, and if desired as a csv-file. 

function [trainSet, validationSet] = splitset(featureMatrix, validationSize)

trainsetSize = round(validationSize*size(featureMatrix,1));

P = randperm(size(featureMatrix,1));
shuffledFeatureMatrix = featureMatrix(P,:);

trainSet = shuffledFeatureMatrix(1:trainsetSize,:);
validationSet = shuffledFeatureMatrix(trainsetSize+1:end,:);

end