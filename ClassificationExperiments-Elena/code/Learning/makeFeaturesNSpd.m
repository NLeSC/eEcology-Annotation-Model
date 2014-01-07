%merijn de bakker || merijn.debakker@gmail.com
%17-03-2010 | revised: 30-05-2011
%
%
%FUNCTION MAKEFEATURES
%calculates features for a given input matrix. mind the assumptions!
%INPUT: matrix with data, variable argument list with features.
% assumes input as follows: [device, samplenr, index, X, Y, Z,spd,label,spdLab].
%or, in the case of outputstructs [device,dateT, index,X,Y,Z,spd,label,spdLab]
%v1 = labelPos: position of label,(0 if unlabelled)
%v2 = 'norm' or 'scale' depending of whether data should be normalised ...
% to zero-mean and 1 std, or scaled to values between -1 and 1.
%v3 = 'c' for continuous windowing. 'd' for per sample windowing
%
%
%
%OUTPUT: matrix with for every device and dateTime features:
% device,dateTime, windowIndex, ft1,...,ft
%



function [featureMatrix,infoMatrix]  = makeFeaturesNSpd(M, windowSize,overlap,...
    perSample,varargin)


%M = M(:,2:end);


r1 = find(M(:,3)==0); %Find rows with a start index.
r2 = find(diff(M(:,3))~=1)+1; %Find rows with index that doesn't increment the last row's by 1.
r = unique(sort([1;r1;r2]));
%nOfMeasurements = size(r)
%windowSize = 20;
%overlap = 0.5;
nOfWindows = 0;
epsilon = 0.3;

featureMatrix = [];
infoMatrix = [];

SPRMtotal = [];
CMtotal = [];
MLMtotal = [];
FMtotal = [];
WMtotal = [];

windowingMode = varargin{3};
index = 0;

switch windowingMode

    case 'd'
        WM = {};
        for i=1:length(r)-1
            seriesLength = r(i+1)-r(i);
           
            %if the number of frames is to small, skip this sample
            if seriesLength<windowSize
                continue
            end

            windows = windowingNSpd(M(r(i):r(i+1)-1,:),windowSize,overlap,perSample);
           
            nOfS = size(windows,1);
            
            WM = [WM;windows];
            
        end
        
        windows = windowingNSpd(M(r(end):end,:),windowSize,overlap,perSample);
         
        WM = [WM;windows];
        
    case 'c'
        

        if size(M,1)< windowSize
             disp('too few frames in sample');

        end

        %make windows
        WM = windowingNSpd(M(1:end,:),windowSize,overlap,perSample);

        nOfWindows = nOfWindows + size(WM,1);
end


windows = {WM{:,1}}';

% % debug display
% disp('makeFeaturesNSpd: after windowingNSpd: '), size(windows)

    if ~isempty(WM)

        addpath ../Features
        %create pitch/roll feature matrix for window set
        %SPRM = position(WM);
        SPRM = cellfun(@calcPosition, windows, 'uniformoutput', false);        
        
        %correlation features
        %CM = correlation(WM);
        CM = cellfun(@calcCorrelation, windows, 'uniformoutput', false);

        %motionlessness feature matrix for window set
        %MLM = motionlessness(WM,0.3);
        MLM = cellfun(@(x) calcMotionlessness(x,epsilon), windows, 'uniformoutput', false);

        %fourier transform feature matrix for window set
        %FM = FaFoTr(WM);
        FM = cellfun(@calcFrequency, windows, 'uniformoutput', false);

        %wavelet features
        %WAV = wav(WM,3);

        %retrieve the speed from the data
%         for j = 1:size(WM,1)
%             SPD{j,1} = WM{j,8};
%         end
        SPD = {WM{:,8}}';

        %'signal to noise'
        %SN = siToNo(WM);
        SN = cellfun(@calcNoise, windows, 'uniformoutput', false);
        
        %ODBA
        %ODBA = calcODBA(WM,20);
        ODBA = cellfun(@(x) calcODBA(x,windowSize/2), windows, 'uniformoutput', false);
        rmpath ../Features

    % 
    %     featureMatrix = [WM{:,2}, SPRM, CM, MLM, FM, SPD];
    %     infoMatrix = [WM{:,3:8}, WM{:,2}];
   
    
    for j=1:size(MLM,1)
        index=index+1;
        % if no extra parameter is given for the position of the label,
        % just store the deviceNr and Timestamp, or label=0 if libsvm is...
        % used.     

        featureMatrix(index,:) = [WM{j,2},SPRM{j,:},CM{j,:},...
            MLM{j,:},FM{j,:},SPD{j,:},SN{j,:}, ODBA{j,:}];

        %[data,device startTime endTime startIndex endIndex Speed, Label]
        infoMatrix{index,1} = WM{j,1};
        infoMatrix{index,2} = WM{j,3};
        infoMatrix{index,3} = WM{j,4};
        infoMatrix{index,4} = WM{j,5};
        infoMatrix{index,5} = WM{j,6};
        infoMatrix{index,6} = WM{j,7};
        infoMatrix{index,7} = WM{j,8};
        infoMatrix{index,8} = WM{j,2};
        
        %infoMatrix{index,7}= [WM{j,3},WM{j,4},WM{j,5},WM{j,6},...
        %WM{j,7},WM{j,8}, WM{j,2},WM{j,1}];
    

    end
    
end










