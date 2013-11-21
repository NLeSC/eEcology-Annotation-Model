%% calcNoise - calculates the noise content feature
%
% author: Merijn de Bakker, UvA,Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 27-09-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [noise]=calNoise(M)
%
% INPUT
% M- 3-D matrix with accelerometer data (frames are rows)
%
% OUPTPUT
% noise- measure forthe noise in the signal
%
% EXAMPLE
% 
% SEE ALSO
% calFeatureVectors.m
%
% REFERENCES
% "Automatic Classification of Bird Behaiviour on the baes of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTES

function noise = calcNoise(M)

nOfPoints = size(M,1);

result = zeros(1,3);
resultDDif = zeros(1,3);

for h = 1:3

    sns = zeros(nOfPoints,1);
    signal = M(:,h);

    
    for i = 2:nOfPoints-1

        %linear interpolations
        yi = interp1(1:2,[signal(i-1),signal(i+1)],1:0.5:2);

        sns(i) = (signal(i)-yi(2))^2;
    end

    result(h) = sum(sns);

    %calculate standard deviation or mean of the 'discrete dx/dt'
    diffS = abs(diff(signal));
    resultDDif(h) = mean(diffS);
end

noise = [result,sum(result), resultDDif] ;
    
end
