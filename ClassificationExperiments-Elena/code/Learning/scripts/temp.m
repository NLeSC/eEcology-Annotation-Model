%% Create mock data and calculate feature vectors
n = 100;
devices = repmat(0, 1, n);
indices = 1:n;
datetimes = datenum(2013,10,8,0,0,indices);
x = sin(indices);
y = -sin(indices);
z = cos(indices);
spd = indices;
data = [devices', datetimes', indices', x',y',z', spd'];

windowSize = 10; 
overlap =0.5; 
epsilon=0.1;



v = calcFeatureVectors(data, windowSize, overlap, epsilon)';

%%
sampleIDs = outputStruct.sampleID
datetimes = datenum(outputStruct.year,outputStruct.month,outputStruct.day,outputStruct.hour,outputStruct.min,outputStruct.sec');
%%
tic
trainFraction = 0.8;
[trainSet, testSet] = prepareData(outputStruct, trainFraction, []);
toc
%%
tic
criterion = ''; % infcrit, maxcrit
reject = 0; 
featureSelection = [];
structName = 'base';
treeExperimenter(trainSet, testSet, criterion, 0, 0, [], reject, featureSelection,structName);
toc