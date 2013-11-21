%% calcCorrelation - calculates correlation features
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% CM = calCorrelation(M)
%
% INPUT
% M- is a 3D matrix of X,Y,Z signals of j windows. 
%
% OUPTPUT
% CM- a 3D matrix with correlations between x/y,y/z,x/z.
%
% EXAMPLE
%
% 
% SEE ALSO
% calcFeatureVectors
%
% REFERENCES
% "Automatic Classification of Bird Behaiviour on the baes of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTE 
% Preferably, the windows are firstly subjected to a low-pass filter!


function CM = calcCorrelation(M)

X = M(:,1);
Y = M(:,2);
Z = M(:,3);

xyCorr = corr2(X,Y);
yzCorr = corr2(Y,Z);
xzCorr = corr2(X,Z);
xauto = xcorr(X,4, 'coeff');
yauto = xcorr(Y,4, 'coeff');
zauto = xcorr(Z,4, 'coeff');

CM =  [xyCorr, yzCorr, xzCorr,xauto(6:9)',yauto(6:9)',zauto(6:9)'];

    
