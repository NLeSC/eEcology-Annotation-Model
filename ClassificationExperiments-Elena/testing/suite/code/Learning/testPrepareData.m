function test_suite = testPrepareData
initTestSuite;

function testprepareData_allTrainSet_noTestSet
% Arrange
expected = 0;
testData = getTestDataFor4Windows;

% Act
profile resume
[trainSet, testSet] = prepareData(testData, 1, []);
profile off

% Assert
assertEqual(expected, size(testSet, 1));

function testprepareData_noTrainSet_noTrainSet
% Arrange
expected = 0;
testData = getTestDataFor4Windows;

% Act
profile resume
[trainSet, testSet] = prepareData(testData, 0, []);
profile off

% Assert
assertEqual(expected, size(trainSet, 1));

function testprepareData_for4Windows_returns4Instances
% Arrange
expected = 3;
testData = getTestDataFor4WindowsOfWhich1Conflicting();

% Act
profile resume
[trainSet, testSet] = prepareData(testData, 1, []);
profile off

% Assert
assertEqual(expected, size(trainSet, 1));

function testprepareData_for3ValidAnd1ConflictingWindow_returns3
% Arrange
expected = 3;
testData = getTestDataFor4WindowsOfWhich1Conflicting();

% Act
profile resume
[trainSet, testSet] = prepareData(testData, 1, []);
profile off

% Assert
assertEqual(expected, size(trainSet, 1));

function testData = getTestDataFor4Windows
tags = cell(2, 1);
tags{1} = getTags(40, 1);
tags{2} = getTags(40, 2);
testData = getTestDataWithTags(tags);

function testData = getTestDataFor4WindowsOfWhich1Conflicting
tags = cell(2, 1);
tags{1} = getTags(40, 1);
tags{2} = [getTags(30, 2) ; getTags(10,3)]; % conflicting: windowsize is 20
testData = getTestDataWithTags(tags);

function testData = getTestDataWithTags(tags)
nOfSamples = 2;
sampleIds = [1;1];
year = [2013;2013];
month = [1;1];
day = [2;2];
hour = [5;5];
min = [3;43];
sec = [5;15];
accX = getAccData(nOfSamples, 40);
accY = getAccData(nOfSamples, 40);
accZ = getAccData(nOfSamples, 40);
annotations = zeros(nOfSamples, 6);
gpsSpd = zeros(nOfSamples, 1);
testData = struct('nOfSamples', nOfSamples, ...    
    'sampleID', sampleIds', ...
    'year', year', 'month', month', 'day', day', 'hour', hour', 'min', min', 'sec', sec, ...
    'accX', {accX}, 'accY', {accY}, 'accZ', {accZ}, ...
    'tags', {tags}, 'annotations', {annotations}, 'gpsSpd', gpsSpd);

function tags = getTags(n, tag)
tags = ones(n, 1) .* tag;

function accData = getAccData(nOfSamples, nMeasurementsPerSample)
accData = cell(nOfSamples, 1);
for i = 1:nOfSamples
    accData{i} = zeros(1, nMeasurementsPerSample);
end

function setup
cd ../../../../code/Learning/

function teardown
cd ../../testing/suite/code/Learning/


