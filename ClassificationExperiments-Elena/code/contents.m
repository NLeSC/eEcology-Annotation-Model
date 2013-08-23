%% contents.m- contents of the current directory
%
%--------------------------------------------------------------------------
% TEMPLATES
%--------------------------------------------------------------------------
% template.m-function/script header template
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% FUNCTIONS
%--------------------------------------------------------------------------
% getDataFromEecologyDB - getting data from the eEcology UvA DB
% formatDataStructure - formatting the data retrieved from the EcologyDB
% prepareData4FeatExtraction - preparation of data for feature extraction
%
% calcFeatureVectors - feature vectors computaion for classifiers
% calcPosition - calculates function position features
% calcCorrelation - calculates correlation features
% calcMotionlessness - calculates motionlessness features
% calcFrequency - calculates frequency spectral features
%
% applyModel - classification of feature data according to a given model
% hierarchClass - hierarchical classification
%
% classifyAccMeas - classify accelerometer measurements
%--------------------------------------------------------------------------
% SCRIPTS
%--------------------------------------------------------------------------
% addEecologyqueries - example  script for adding an SQL query to a MAT file