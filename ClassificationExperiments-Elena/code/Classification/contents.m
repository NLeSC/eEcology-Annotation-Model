%% contents.m- contents of the current directory
%
%--------------------------------------------------------------------------
%% TEMPLATES
%--------------------------------------------------------------------------
% template.m-function/script header template
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%% FUNCTIONS
%--------------------------------------------------------------------------
% getDataFromEecologyDB - getting data from the eEcology UvA DB
% formatDataStructure - formatting the data retrieved from the EcologyDB
% prepareData4FeatExtraction - preparation of data for feature extraction
%
% applyModel - classification of feature data according to a given model
% hierarchClass - hierarchical classification
%
% classifyAccMeas - classify accelerometer measurements
%
% createDatacube - generates datacube with raw data and classifications 
% createAnot - generates anotations
% makeKMZanot - function to generate KMZ files with anotations
%
% writeAccPNG - generates KMZ file from anotated accelerometer data
%
% dtc_e - the PRTools dtc- decision tree classifier with small enhanecement
% tree_mapc_e - the PRTools tree_map- map a dataset by binary decision tree 
%               with small enhanecement
%--------------------------------------------------------------------------
%% SCRIPTS (in /scripts directory)
%--------------------------------------------------------------------------
% addEecologyqueries - example  script for adding an SQL query to a MAT file
% DBAcc_Texel_new- classification and vizualization of Texel bird data
% DBAcc_FEBO_new- classification and vizualization of FEBO bird data
% DBAcc_meeuw_all- classification of the meeuw data obtained from the DB