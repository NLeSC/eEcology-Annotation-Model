%% calcFeatureVectors - feature vectors computaion for classifiers
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc, Christiaan
% Meijer, NLeSc
% date creation: 11-2011
% last modification date: 17-12-2013
% modification details: refactored: changed variable names to improve
% readability. 
% -----------------------------------------------------------------------
% SYNTAX
% [FTV, INFO]=calFeatureVectors(data, windowSize, overlap, epsilon)
%
% INPUT
% data- NxM matrix containing unlabelled data. Format:
%       [device,datetime,index,x,y,z,spd]
% windowSize- thesegmentaiton window size
% overlap- the proportion of overlap of the windows (range [0 - 1])
% epsilon- tolerance parameter for the motionlessness feature
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


function [FTV,INFO] = calcFeatureVectors(data,  windowSize, overlap, epsilon)

r1 = find(data(:,3)==0);
r2 = find(diff(data(:,3))~=1)+1;
r = unique(sort([1;r1;r2]));

WM = {};

% windowSize = 20;
% overlap = 0;
% epsilon = 0.3;

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

% % debug display
% disp('calFeatureVectors: after windowing: '), size(windows) 
    
if ~isempty(windows)

    %position features (e.g. pitch, roll, etc.)
    SPRM = cellfun(@calcPosition, windows, 'uniformoutput', false);

    %correlation features
    CM = cellfun(@calcCorrelation, windows, 'uniformoutput', false);

    %motionlessness feature matrix for window set
    MLM = cellfun(@(x) calcMotionlessness(x,epsilon), windows, 'uniformoutput', false);
    
    %fourier transform feature matrix for window set
    FM = cellfun(@calcFrequency, windows, 'uniformoutput', false);

    %wavelet features
    %WAV = wav(WM,3);

    %retrieve the speed from the data
    SPD = {WM{:,8}}';

    %'noise'
    SN = cellfun(@calcNoise, windows, 'uniformoutput', false);

    %ODBA
    ODBA = cellfun(@(x) calcODBA(x,windowSize/2), windows, 'uniformoutput', false);

    FTV = [cell2mat(SPRM), cell2mat(CM), cell2mat(MLM),...
        cell2mat(FM), cell2mat(SPD),cell2mat(SN),cell2mat(ODBA)];
    INFO = [WM(:,1) WM(:,3) WM(:,4) WM(:,5) WM(:,6) WM(:,7) WM(:,8) WM(:,2)];

end

end

function windows = windowing(M, wSize, overlapFraction)

windows = {};
mLength = size(M,1);

if overlapFraction>0
    step = wSize * overlapFraction;
else
    step = wSize;
end

%start position
startPos=1;
%windownr
windowNo=1;

while startPos+wSize<=mLength+1;
             
     [r,~] = find(isnan(M(startPos:startPos+wSize-1,4:6)));
     if ~isempty(r)
         startPos = startPos+step;
         continue
     else
         windows{windowNo,1} = M(startPos:startPos+wSize-1,4:6);
         %label, not used here
         windows{windowNo,2} = NaN;
         windows{windowNo,3} = M(startPos,1);
         windows{windowNo,4} = M(startPos,2);
         windows{windowNo,5} = M(startPos+wSize-1,2);
         windows{windowNo,6} = M(startPos,3);
         windows{windowNo,7} = M(startPos+wSize-1,3);
         windows{windowNo,8} = M(startPos,7); 
         startPos = startPos+step;
         windowNo = windowNo+1;
     end

end

end