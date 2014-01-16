%% learning - script for machine learning using difference algorithms
%
% author: Christiaan Meijer, NLeDc
% co-author: Elena Ranguelova, NLeSc
% date creation: December 2013
% last modification date: 09 January 2014 
% modification details: added new header, loading data and chosing a 
%                       proper model
% -----------------------------------------------------------------------
% SYNTAX
% learning
%
% INPUT
% 
% OUPTPUT
% 
% EXAMPLE
% 
% SEE ALSO
% prepareData, PRTools 5.0 classifiers
%
% REFERENCES
%
% NOTES
% the script should be started from the Leaning/scripts directory

%% load some test data
clc
fname = '../../../data/AnnotatedData/D320_09062010.mat';
load(fname);
disp(['Data from file: ', fname, ' were loaded!'])

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
trainDataSet = prdataset(trainInstances,trainLabels);

%Prepare test dataset
testDataSet = prdataset(testInstances,testLabels);

%Dimensionality reduction
components = 7;
[trainDataSet, testDataSet, mapping] = ...
    reduceDimensionality(trainDataSet, testDataSet, '', components);

%% Train model W using one of the algorithms below.
classifiers{1} = 'treec';
classifiers{2} = 'knn';
classifiers{3} = 'neurc';
classifiers{4} = 'randomforestsc';
classifiers{5} = 'dtc';
classifiers{6} = 'vpc';
classifiers{7} = 'drbmc';
celldisp(classifiers)
index = input('Select a classifier index from the list above: ');

tic
switch index
    case 1
        pruning = 0;
        crit = 'infcrit';
        W = treec(trainDataSet,crit,pruning,testDataSet);
    case 2
        W = knnc(trainDataSet);
    case 3
        nHiddenPerLayer = 5;
        W = neurc(trainDataSet,nHiddenPerLayer);
    case 4
        W = randomforestc(trainDataSet);
    case 5
        W = dtc(trainDataSet);
    case 6
        W = vpc(trainDataSet, 1000);
    case 7
        W = drbmc(trainDataSet);
end
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
