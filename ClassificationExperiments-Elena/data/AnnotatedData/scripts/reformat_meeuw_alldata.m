
%% This script reformats the data in 210911_meeuw_alldata.mat so it can be
% used with PrepareData;
% Author: Christiaan Meijer, NLeSc
% Created: 7-1-2014

% Prepare elements of new structure
data = dataInfo(1:end,:);
[nRows, ~] = size(data);
accX = cell(nRows, 1);
accY = cell(nRows, 1);
accZ = cell(nRows, 1);
tags = cell(nRows, 1);
annotations = zeros(nRows, 6);
sampleIds = zeros(nRows, 1);
year = zeros(nRows, 1);
month = zeros(nRows, 1);
day = zeros(nRows, 1);
hour = zeros(nRows, 1);
min = zeros(nRows, 1);
sec = zeros(nRows, 1);
gpsSpd = zeros(nRows, 1);

% Fill data in elements of new structure
for i = 1:nRows,
    % Get relevant data from the current row of the old structure
    currentRow = data(i, :);
    currentLabelCell = currentRow(8);
    currentLabel = currentLabelCell{1};
    currentGpsSpdCell = currentRow(7);
    currentGpsSpd = currentGpsSpdCell{1};
    currentDateNumCell = currentRow(3);
    currentDateNum = currentDateNumCell{1};
    currentSampleIdCell = currentRow(2);
    currentSampleId = currentSampleIdCell{1};
    currentAccCell = currentRow(1);
    currentAcc = currentAccCell{1};

    % Accerelometer data
    accX{i} = currentAcc(:,1)';
    accY{i} = currentAcc(:,2)';
    accZ{i} = currentAcc(:,3)';

    % Fill tags (annotation per measurement)
    dataPointsPerSegment = size(currentAcc, 1);
    tags{i} = zeros(dataPointsPerSegment, 2);
    tags{i}(:,1) = currentLabel;

    % Annotation substructure
    label = currentLabel;
    sampleId = currentSampleId;
    %1. Sample ID. The series are split up into samples, where a sample consists of frames having the same datetime. Numbers missing mean simply that that annotation label hasn't been used. I don't know where the inconsistent endings come from, i.e. I cannot reproduce it.
    %2. Annotation frame start for the sample (1).
    %3. Annotation frame end for the sample(1).
    %4. Annotation label
    %5. Not in use currently. Concerned gps measure
    %6. Annotation of the speed is likely to be correct. Standard set to 1.
    currentAnnotations = [sampleId, 1, size(currentAcc, 1), label, 0, 1];
    annotations(i,:) = currentAnnotations;
    
    % Other
    sampleIds(i, 1) = currentSampleId;
    gpsSpd(i,1) = currentGpsSpd;

    % Time/Date info
    [year(i),month(i),day(i),hour(i),min(i),sec(i)] = datevec(currentDateNum);

end

% Fill new structure with the elements filled above.
outputStruct = struct('nOfSamples', nRows, ...    
    'sampleID', sampleIds', ...
    'year', year', 'month', month', 'day', day', 'hour', hour', 'min', min', 'sec', sec, ...
    'accX', {accX}, 'accY', {accY}, 'accZ', {accZ}, ...
    'tags', {tags}, 'annotations', {annotations}, 'gpsSpd', gpsSpd);