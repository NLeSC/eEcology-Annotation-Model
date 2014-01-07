%wrapper function for preparing annotated data for classification.
%frac is the fraction for the training set.
%labvec is a vector containing the desired labels in the dataset. an empty
%vector means that all labels will be included to the dataset.

function [trainSet,testSet] = prepareData(annot_struct,frac,labelVector)

%assignin('base', 'files', dataStructs);
data = [];
dataInfo = [];
windowingMode = 'd';
ws=20;
olap = 0;

%for j = 1:length(dataStructs)
    
    %dataStruct = char(dataStructs(j));
    %[~,fname,~] = fileparts(dataStruct);
    
    %retrieve all labelled data from the input
    %alldata = getLabsFromStruct(dataStruct);
    [alldata]=getDataFromAnnotStruct(annot_struct);
    
    %group by label
    %allLabels = groupD2Label(alldata,8,j);
    allLabels = groupD2Label(alldata,8);

    %only add the selected labels to the dataset.
    if isempty(labelVector)
        labels = allLabels;
    else
        [~,pos] = ismember(labelVector,allLabels);
        labels = allLabels(pos(pos~=0));
    end
        

    %calculate the features for each label
    for i = 1:length(labels)
        
        currentLabel = labels(i);
        
        %labDat = evalin('base', strcat('f',num2str(j),'_label_',num2str(thisLab)));
        labDat = evalin('base', strcat('label_',num2str(currentLabel)));

        [ft, info] = makeFeaturesNSpd(labDat, ws, olap,0,8, 'norm', windowingMode);
        %[ft, info] = calcFeatureVectors(labDat, ws, olap,0.3);

        data = [data;ft];
        dataInfo = [dataInfo;info];
        
        %assignin('base', strcat('f',num2str(j),'_fts_', num2str(labels(i))), ft);
        %assignin('base', strcat('f',num2str(j),'_inf_', num2str(labels(i))), info);
        
        assignin('base', strcat('fts_', num2str(labels(i))), ft);
        assignin('base', strcat('inf_', num2str(labels(i))), info)        
       
    end   

%end

[trainSet,testSet] = splitset(data,frac);
% metadata = struct('data',{datestr(today)},'author', {'Elena'},...
%     'files',{dataStructs},'mode',{windowingMode}, 'wSize', {ws}, 'step', {olap},...
%     'filter',{''},'ftSet',{''});
% 
% assignin('base', 'dataFeatures', data);
% assignin('base', 'dataInfo', dataInfo);
% assignin('base', strcat('train_',num2str(frac*100)), train);
% assignin('base', strcat('test_',num2str((1-frac)*100)), test);
% assignin('base', 'IDtrain', permutation(1:size(train,1)));
% assignin('base', 'IDtest', permutation(size(train,1)+1:end));
% assignin('base', 'metaData', metadata);





