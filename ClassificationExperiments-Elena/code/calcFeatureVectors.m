%% calcFeatureVectors - feature vectors computaion for classifiers
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [FTV, INFO]=calFeatureVectors(data)
%
% INPUT
% data- NxM matrix containing unlabelled data. Format:
%       [device,datetime,index,x,y,z,spd]
%
% OUPTPUT
% FTV- NxM matrix containing N vectors with M features
% INFO - cell array containing helpful information about the feature vector
%
% EXAMPLE
% 
% 
% SEE ALSO
% windowing (same file)
%
% REFERENCES
% "Automatic Classification of Bird Behaviour on the base of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTES: 
%   1. Function based on functions makeFeaturesNSpd and windowingNSpd. This 
%   adapted verrsion has no settings for filtering, etc. 
%   2. datetime is assumed to be datenum format.
%   3. This function operates on unlabelled data only.
%   4. ! Important: Model is trained using 2D speed instead of 3D speed.


function [FTV,INFO] = calcFeatureVectors(data)

r1 = find(data(:,3)==0);
r2 = find(diff(data(:,3))~=1)+1;
r = unique(sort([1;r1;r2]));

WM = {};

windowSize = 20;
overlap = 0;

for i=1:length(r)-1
    seriesLength = r(i+1)-r(i);

    %if the number of frames is too small, skip this sample
    if seriesLength<windowSize
        continue
    end

    %make windows. see for variable input (for filtering) the windowing function!
    windows = windowing(data(r(i):r(i+1)-1,:),windowSize,overlap);
 
    WM = [WM;windows];            
end

WM = [WM;windowing(data(r(end):end,:),windowSize,overlap)];
windows = {WM{:,1}}';
    
if ~isempty(windows)

    %position features (e.g. pitch, roll, etc.)
    SPRM = cellfun(@calcPosition, {WM{:,1}}', 'uniformoutput', false);

    %correlation features
    CM = cellfun(@calcCorrelation, {WM{:,1}}', 'uniformoutput', false);

    %motionlessness feature matrix for window set
    MLM = cellfun(@calcMotionlessness, {WM{:,1}}', 'uniformoutput', false);

    %fourier transform feature matrix for window set
    FM = cellfun(@calcFrequency, {WM{:,1}}', 'uniformoutput', false);

    %wavelet features
    %WAV = wav(WM,3);

    %retrieve the speed from the data
    SPD = {WM{:,8}}';

    %'noise'
    SN = cellfun(@calcNoise, {WM{:,1}}', 'uniformoutput', false);

    %ODBA
    ODBA = cellfun(@calcODBA, {WM{:,1}}', 'uniformoutput', false);

    FTV = [cell2mat(SPRM), cell2mat(CM), cell2mat(MLM),...
        cell2mat(FM), cell2mat(SPD),cell2mat(SN),cell2mat(ODBA)];
    INFO = [WM(:,1) WM(:,3) WM(:,4) WM(:,5) WM(:,6) WM(:,7) WM(:,8) WM(:,2)];

end

end

function windows = windowing(M, wSize, oLap)

windows = {};
mLength = size(M,1);

if oLap>0
    step = wSize*oLap;
else
    step = wSize;
end

%start position
i=1;
%windownr
j=1;

while i+wSize<=mLength+1;
             
     [r,~] = find(isnan(M(i:i+wSize-1,4:6)));
     if ~isempty(r)
         i = i+step;
         continue
     else
         windows{j,1} = M(i:i+wSize-1,4:6);
         %label, not used here
         windows{j,2} = NaN;
         windows{j,3} = M(i,1);
         windows{j,4} = M(i,2);
         windows{j,5} = M(i+wSize-1,2);
         windows{j,6} = M(i,3);
         windows{j,7} = M(i+wSize-1,3);
         windows{j,8} = M(i,7); 
         i = i+step;
         j = j+1;
     end

end

end