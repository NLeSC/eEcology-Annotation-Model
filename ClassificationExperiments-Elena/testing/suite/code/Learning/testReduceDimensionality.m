function test_suite = testReduceDimensionality
initTestSuite;

function testreduceDimensionality_normalMapping_trainSetIsSame
% Arrange

dimensionality = 5;
nTrain = 10;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'normal';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = reduceDimensionality(trainSet, testSet, kind);
profile off

% Assert
assertEqual(double(trainSet), double(reducedTrainSet));

function testreduceDimensionality_normalMapping_testSetIsSame
% Arrange

dimensionality = 5;
nTrain = 10;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'normal';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = reduceDimensionality(trainSet, testSet, kind);
profile off

% Assert
assertEqual(double(testSet), double(reducedTestSet));

function testreduceDimensionality_pcaMapping_nTrainSetTheSame
% Arrange

dimensionality = 5;
nTrain = 10;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'pca';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = reduceDimensionality(trainSet, testSet, kind);
profile off

% Assert
assertEqual(size(trainSet,1), size(reducedTrainSet,1));

function testreduceDimensionality_pcaMapping_nTestSetTheSame
% Arrange
dimensionality = 5;
nTrain = 10;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'pca';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = reduceDimensionality(trainSet, testSet, kind);
profile off

% Assert
assertEqual(size(testSet,1), size(reducedTestSet,1));

function testreduceDimensionality_pcaMapping_dimTrainSet12
% Arrange
dimensionality = 50;
targetDimensionality = 12;
nTrain = 20;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'pca';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = ...
    reduceDimensionality(trainSet, testSet, kind, targetDimensionality);
profile off

% Assert
assertEqual(size(reducedTrainSet,2), targetDimensionality);

function testreduceDimensionality_ldaMapping_dimTrainSet12
% Arrange
dimensionality = 50;
targetDimensionality = 4;
nTrain = 20;
nTest = 5;
[trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest);
kind = 'lda';

% Act
profile resume
[ reducedTrainSet, reducedTestSet, mapping ] = ...
    reduceDimensionality(trainSet, testSet, kind, targetDimensionality);
profile off

% Assert
assertEqual(size(reducedTrainSet,2), targetDimensionality);

function [trainSet, testSet] = getDataSets(dimensionality, nTrain, nTest)
trainInstances = rand(nTrain, dimensionality);
testInstances = rand(nTest, dimensionality);
nClasses = 5;
trainLabels = randi(nClasses, nTrain, 1);
testLabels = randi(nClasses, nTest, 1);
trainSet = dataset(trainInstances, trainLabels);
testSet = dataset(testInstances, testLabels);

function setup
cd ../../../../code/Learning/

function teardown
cd ../../testing/suite/code/Learning/


