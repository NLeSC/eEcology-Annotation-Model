%% calcMotionlessness - calculates motionlessness features
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 27-09-2013
% modification details: added new parameter
% -----------------------------------------------------------------------
% SYNTAX
% Mmotionless = calcMotionlessness(M, epsilon)
%
% INPUT
% M- 2D matrix with accelerometer data
% epsilon- tolarance value
%
% OUPTPUT
% Mmotionless- 3D matrix with for each window time of max motionless period
%
% EXAMPLE
% 
% SEE ALSO
% calFeatureVectors.m
%
% REFERENCES
% Adapted from Gyllensten, I.C. (2010) Physical Activity Recognition in
% Daily Life using a triaxial accelerometer. MSc Thesis KTH.
% "Automatic Classification of Bird Behaiviour on the baes of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTES
% Calculates maximum motionless time in a window, based on motion in X
% direction

function Mmotionless = calcMotionlessness(M, epsilon)

nOfFrames = size(M,1);
longl = 1;

for i = 1:nOfFrames-1
    lowi = i;

    while((abs(M(i,1)-M(lowi,1))<epsilon) && (lowi>1))
        lowi = lowi-1;
    end

    if(longl<i-lowi)
        longl = i - lowi;
    end

end

%normalise for length
Mmotionless = longl/nOfFrames;
   
end
   