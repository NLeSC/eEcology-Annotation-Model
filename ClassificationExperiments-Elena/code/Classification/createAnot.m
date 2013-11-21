%% createAnot - generates anotations
%
% author: Elena Ranguelova, NLeSc
% date creation: 23-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% FTVAnot=createAnot(FTVstor, num_featurs, save_flag, [save_fname])
%
% INPUT
% FTVstor- computed feature vectors amd raw data
% num_features - number of features
% save_flag- Boolean indicating weather FTVAnot  should be saved 
% save_fname- the MAT filename for saving the Datacube (optional)
%
% OUPTPUT
% FVTAnot- selected annotations
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<your-username-str>, <your-password-str>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% load ../data/classifiers.mat
% [class_data, FTVstor]=classifyAccMeas(formatted_tracks, 40,  classifiers, 58, 7);
% FTVanot = createAnot(FTVstor,58, 0);
% --OR--
% FTVanot = createAnot(FTVstor,58,1,'FTVAnot.mat');
% 
% SEE ALSO
% classifyAccMeas.m, hierarchClass.m
% DBAcc_Texel/FEBO.m- scripts by W.Bouten (legacy)
%
% REFERENCES
%
% NOTES
% IMPORTANT!:  The mapping between class numbers and the annotation labels
% is manually hard-coded in this function
% forthe list of class numbers see hierarchClass.m

function FTVanot=createAnot(FTVstor, num_features, save_flag, save_fname)

if nargin < 4
    if save_flag  > 0
        error('Please, specify the MAT filename to save the FTVanot.');
    else
        save_fname =[];
    end
end

index = num_features + 1;

FTVanot=FTVstor;
FTVanot1(:,index)=(FTVstor(:,index)==5)*1;
FTVanot2(:,index)=(FTVstor(:,index)==1)*2;
FTVanot3(:,index)=(FTVstor(:,index)==4)*3;
FTVanot4(:,index)=(FTVstor(:,index)==0)*4;
FTVanot5(:,index)=(FTVstor(:,index)==2)*5;
FTVanot6(:,index)=(FTVstor(:,index)==6)*6;
FTVanot7(:,index)=(FTVstor(:,index)==7)*7;
FTVanot8(:,index)=(FTVstor(:,index)==8)*8;
FTVanot(:,index)=FTVanot1(:,index)+FTVanot2(:,index)+FTVanot3(:,index)+FTVanot4(:,index)+...
              FTVanot5(:,index)+FTVanot6(:,index)+FTVanot7(:,index)+FTVanot8(:,index);
clear FTVanot1 FTVanot2 FTVanot3 FTVanot4 FTVanot5 FTVanot6 FTVanot7 FTVanot8

if save_flag
    save(save_fname, 'FTVanot');
end




