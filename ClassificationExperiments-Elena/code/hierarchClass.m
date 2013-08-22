%% hierarchClass - hierarchical classification
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% class = hierarchClass(classifiers, data)
%
% INPUT
% classifiers- classifiers is cell array with model structs. The model structs
% contain the individual models and define the hierarchical model using the
% struct variable sc.
% data - N*M matrix containing N unlabelled examples with M
% features. Structure [device, datetime, index, x, y,z,speed]
%
% OUPTPUT
% class- each of the output arguments should be described
% possible class labels*: 
% 1 = stand
% 2 = flap
% 3 = soar
% 4 = walk
% 5 = sit
% 6 = extreme flap
% 7 = float
% 8 = other
%
% % EXAMPLE
% [tracks] = getDataFromEecologyDB('elena', 'Vily_pily12',...
%                               '../data/eecologyqueries.mat', 'sql_gps_acc',...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00');
% [formatted_tracks] = formatDataStructure(tracks);
% j =  1; na = 40; na1 = na - 1;
% [feat_data] = prepareData4FeatExtraction(formatted_tracks, j, na1);
% load ../data/classifiers.mat
% [FTV,INFO] = calcFeatureVectors(feat_data);     
% classifications = hierarchClass(classifiers, FTV);
% 
% SEE ALSO
% applyModel.m
%
% REFERENCES
% "Automatic Classification of Bird Behaviour on the base of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
% *Explanations.docx- July 2013, by W.Bouten
%
% NOTES

function class = hierarchClass(classifiers, data)

nOfSamples = size(data,1);
class = zeros(nOfSamples,1);

for i = 1:nOfSamples
    
    fv = data(i,:);
    
    node = 1;
    endReached = false;

    while ~endReached
        
       classifier = classifiers{node};

       output = applyModel(fv,classifier.model);
       
       r = find(classifier.sc(:,1)==output);
       node = classifier.sc(r,2);         
       
       if node == 0    
           endReached = true;
           label = output;
       end

    end
    
    class(i) = label;
    
end