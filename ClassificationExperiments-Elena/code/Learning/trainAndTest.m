function [ errorTest ] = trainAndTest( trainSet, testSet, featureSelection)
% trainAndTest trains a tree using the trainSet and tests it on the test
% set both using only the features in the feature selection which has to be
% supplied as a row vector of column indices. The error rate on the test 
% set is returned. This function was written to be able to train and test
% easily with different sets of features. It is based on the learning.m
% script which is again based on treeExperimenter.
% Author: Christiaan Meijer, NLeSc
% Creation date: 16-01-2014

% Prepare test/train instances and labels
nFeatures = size(trainSet,2)-1;

nTrain = size(trainSet,1);
nTest = size(testSet,1);

%Filter out rows that contain NaN's in selected features
validRows = setdiff(1:nTrain, find(sum(isnan(trainSet(:,featureSelection+1)), 2)));
trainSet = trainSet(validRows, :);
validRows = setdiff(1:nTest, find(sum(isnan(testSet(:,featureSelection+1)), 2)));
testSet = testSet(validRows, :);

trainLabels = trainSet(:,1);
testLabels = testSet(:,1);
trainInstances = trainSet(:,featureSelection+1);
testInstances = testSet(:,featureSelection+1);

% Prepare datasets
%Prepare train dataset
trainDataSet = prdataset(trainInstances,trainLabels);

%Prepare test dataset
testDataSet = prdataset(testInstances,testLabels);

%Dimensionality reduction
components = 7;
[trainDataSet, testDataSet, ~] = ...
    reduceDimensionality(trainDataSet, testDataSet, '', components);

tic
fprintf('Training classifier on %i instances with %i features...\n', nTrain, size(featureSelection,2));
pruning = 0;
crit = 'infcrit';
W = treec(trainDataSet,crit,pruning,testDataSet);

toc
% Evaluate the trained model W using the test data.
%assigned labels trainset

tic
fprintf('Classifying test set of %i instances...\n', nTest);
%testset
T = testDataSet*W;
toc

%error on testset
errorTest = T*testc;
nTestInstances = size(testDataSet, 1);
fprintf('Error was %f, %i of %i test instances were misclassified.\n\n', ...
    errorTest, errorTest * nTestInstances, nTestInstances);

end

