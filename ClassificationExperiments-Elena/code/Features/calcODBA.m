%% calcODBA - calculates the Overall Dynamic Body Acceleration feature
%
% author: Merijn de Bakker, UvA,Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 27-09-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [ODBA]=calcODBA(M,w)
%
% INPUT
% M- 3-D matrix with accelerometer data (frames are rows)
% w- window size
%
% OUPTPUT
% ODBA- Overal Dynamic Body Accelerationd
%
% EXAMPLE
% 
% SEE ALSO
% calFeatureVectors.m
%
% REFERENCES
% Gleiss et al. (2011) Convergent evolution in locomotory
% patterns of flying and swimming animals. Nature Communications (DOI:10.1038)
% "Automatic Classification of Bird Behaiviour on the baes of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011

function ODBA = calcODBA(M,w)


x = M(:,1);
y = M(:,2);
z = M(:,3);

v = ones(1,w)/w;

%filter the data as a moving average
ODBA = sum(abs(x-conv(x,v,'same')))+ ...
    sum(abs(y-conv(y,v,'same')))+...
    sum(abs(z-conv(z,v,'same')));
end