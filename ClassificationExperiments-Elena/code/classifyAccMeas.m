%% classifyAccMeas - classify accelerometer measurements
%
% author: Elena Ranguelova, NLeSc
% date creation: 23-08-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% [out_data, FTVstor]=classifyAccMeas(inp_data, num_meas,  classifiers,...
%                               num_features, num_classes)
%
% INPUT
% inp_data- formatted data sreuctureretrieved from the DB
% num_meas- number of accelerometer measurements (in 1 sec.?)
% classifiers - classifiers is cell array with model structures.
% num_features  - number of features
% num_classes - number of recognisable classes (behavoiurs)
%
% OUPTPUT
% out_data- relevant measurements and their classification
% FTVstor-  feature vectors store(?)
%
% EXAMPLE
% [tracks] = getDataFromEecologyDB(<your-username-str>, <your-password-str>,...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% load ../data/classifiers.mat
% [out_data, FTVstor]=classifyAccMeas(formatted_tracks, 40,  classifiers, 58, 7);
% 
% SEE ALSO
% calcFeatureVectors.m, hierarchClass.m, formatDataStructrure.m,
% prepareData4FeatExtraction.m
% DBAcc_Texel/FEBO.m- scripts by W.Bouten (legacy)
%
% REFERENCES
%
% NOTES
% the classifiers are stored for now in  ../data/classifiers.mat

function [out_data, FTVstor]=classifyAccMeas(inp_data, num_meas,  classifiers, ...
                                    num_features, num_classes)
% initializations
out_data =[];
FTVstor =[];
FTV = []; INFO =[];

%  get the length of the tracks
len_long  = length(inp_data.long);
len_ind = length(inp_data.index);

number = num_meas - 1;
j = 1;

for i = 2:len_long - 1
    % assignmens in all cases
    out_data.device(j)=inp_data.device(i);
    out_data.datetime(j)=inp_data.datetime(i);
    out_data.index(j)=j;
    out_data.ispd(j)=inp_data.ispd(i);
    out_data.tspd(j)=inp_data.tspd(i);
    out_data.long(j)=inp_data.long(i);
    out_data.lat(j)=inp_data.lat(i);
    out_data.alt(j)=inp_data.alt(i);
    out_data.year(j)=inp_data.year(i); 
    out_data.month(j)=inp_data.month(i); 
    out_data.day(j)=inp_data.day(i); 
    out_data.hour(j)=inp_data.hour(i); 
    out_data.min(j)=inp_data.minute(i); 
    out_data.sec(j)=inp_data.second(i);
    out_data.time(j)=datenum(out_data.year(j),out_data.month(j),...
                             out_data.day(j),out_data.hour(j),...
                             out_data.min(j),out_data.sec(j))-735235;
    % check for availability of 1 second of accelerometer measurements
    if (~isnan(inp_data.index(i))==1) && ((i+number) <= len_ind)
         if (inp_data.index(i)==1) && (inp_data.index(i+number)==num_meas) & ...
                 (sum(isnan(inp_data.x(i:i+number)))+...
                 sum(isnan(inp_data.y(i:i+number)))+...
                 sum(isnan(inp_data.z(i:i+number)))<1)
            
            data = prepareData4FeatExtraction(inp_data, i, number);
            [FTV,INFO] = calcFeatureVectors(data);
           
            dum = hierarchClass(classifiers, FTV);
           
            out_data.data(j,:)=[inp_data.x(i:i+number)' ...
                                inp_data.y(i:i+number)' ...
                                inp_data.z(i:i+number)' ];
            out_data.predictions(j)=dum(1);
            out_data.class(j)=out_data.predictions(j);
            FTVstor=[FTVstor; FTV(1,:) ...
             out_data.class(j) ...
             out_data.lat(j) out_data.long(j) ...
             out_data.time(j) j ...
             out_data.ispd(j) out_data.tspd(j)];
            
         elseif inp_data.index(i)==0
            out_data.class(j)=num_classes + 1;
            out_data.predictions(j)=num_classes + 1;
            out_data.data(j,:)=zeros(1,3*num_meas);
            FTV(1,1:num_features)=NaN;
            FTVstor=[FTVstor; FTV(1,:) ...
             out_data.class(j) ...
             out_data.lat(j) out_data.long(j) ...
             out_data.time(j) j ...
             out_data.ispd(j) out_data.tspd(j)];            
          end
    else
        out_data.class(j)=num_classes + 1;
        out_data.predictions(j)=num_classes + 1;
        out_data.data(j,:)=zeros(1,3*num_meas);
        FTV(1,1:num_features)=NaN;
        FTVstor=[FTVstor; FTV(1,:) ...
         out_data.class(j) ...
         out_data.lat(j) out_data.long(j) ...
         out_data.time(j) j ...
         out_data.ispd(j) out_data.tspd(j)];
    end   
%     FTVstor=[FTVstor; FTV(1,:) ...
%              out_data.class(j) ...
%              out_data.lat(j) out_data.long(j) ...
%              out_data.time(j) j ...
%              out_data.ispd(j) out_data.tspd(j)];
    
    j=j+1;
end