%% Script for machine learning using different algorithms.
%
% The dataset that was used for the very few results is (probably)
% D320_08062010.mat.
%
% 
% Author: Christiaan Meijer, NLeSc
% Created: December 2013
%
%
%
%

%% prepare the data
% set the seed for the random generator
rng(0);
tic
trainFraction = 0.8;
[trainSet, testSet] = prepareData(outputStruct, trainFraction, []);
toc

%% Prepare test/train instances and labels
nFeatures = size(trainSet,2)-1;
featureSelection = 2:nFeatures+1;
nTrain = size(trainSet,1);
nTest = size(testSet,1);

%Filter out rows that contain NaN's in selected features
validRows = setdiff(1:nTrain, find(sum(isnan(trainSet(:,featureSelection)), 2)));
trainSet = trainSet(validRows, :);
validRows = setdiff(1:nTest, find(sum(isnan(testSet(:,featureSelection)), 2)));
testSet = testSet(validRows, :);

trainLabels = trainSet(:,1);
testLabels = testSet(:,1);
trainInstances = trainSet(:,featureSelection);
testInstances = testSet(:,featureSelection);

%% Prepare datasets
%Prepare train dataset
trainDataSet = dataset(trainInstances,trainLabels);

%Prepare test dataset
testDataSet = dataset(testInstances,testLabels);

%Dimensionality reduction
components = 7;
[trainDataSet, testDataSet, mapping] = ...
    reduceDimensionality(trainDataSet, testDataSet, '', components);

%% Train model W using one of the algorithms below.
%% tree classifier (8 errors)
tic
pruning = 0;
crit = 'infcrit';
W = treec(trainDataSet,crit,pruning,testDataSet);
toc
%% knn (12 errors)
tic
W = knnc(trainDataSet);
toc
%% neural network with backpropagation (need neural network toolkit to work)
tic
nHiddenPerLayer = 5;
W = neurc (trainDataSet,nHiddenPerLayer);
toc
%% random forest (8 errors)
tic
W = randomforestc(trainDataSet);
toc
%% Verzakov tree (terrible performance)
tic
W = dtc(trainDataSet);
toc
%% Voted Perceptron (seems broken, assigns all instances the same class)
tic
W = vpc(trainDataSet, 1000);
toc
%% Discriminitive Restricted Boltzmann Machine 
% (seems broken, assigns almost all instances the same class)
tic
W = drbmc(trainDataSet);
toc

%% Evaluate the trained model W using the test data.
%assigned labels trainset
tic
trainClasses = labeld(trainDataSet*W);

%testset
T = testDataSet*W;
toc

%assigned labels testset
classes = T*labeld;

%error on testset
errorTest = T*testc;

%confusion matrix testset
confM = confmat(T)

W
disp(strcat('Test error: ', num2str(errorTest)));
nTestInstances = size(testDataSet, 1);
disp(strcat('Test errors:' , num2str(errorTest * nTestInstances), ' of ', num2str(nTestInstances)));
