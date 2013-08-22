%% calcMotionlessness - calculates motionlessness features
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% Mmotionless = calcMotionlessness(M)
%
% INPUT
% M- 3D matrix with windows, tolarance value epsilon
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
%
% NOTES
% Calculates maximum motionless time in a window, based on motion in X
% direction

function Mmotionless = calcMotionlessness(M)

epsilon = 0.3;
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
   