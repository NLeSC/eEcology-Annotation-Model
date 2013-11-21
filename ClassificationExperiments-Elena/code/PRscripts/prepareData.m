%wrapper function for preparing annotated data for classification.
%frac is the fraction for the training set.
%labvec is a vector containing the desired labels in the dataset. an empty
%vector means that all labels will be included to the dataset.

function prepareData(dataStructs,frac,labvec)

assignin('base', 'files', dataStructs);
data = [];
dataInfo = [];
windowingMode = 'd';
ws=20;
olap = 0;

for j = 1:length(dataStructs)
    
    dataStruct = char(dataStructs(j));
    [~,fname,~] = fileparts(dataStruct);
    
    %retrieve all labelled data from the input
    alldata = getLabsFromStruct(dataStruct);

    %group by label
    allLabels = groupD2Label(alldata,8,j);

    %only add the selected labels to the dataset.
    if isempty(labvec)
        labels = allLabels;
    else
        [~,pos] = ismember(labvec,allLabels);
        labels = allLabels(pos(pos~=0));
    end
        

    %calculate the features for each label
    for i = 1:length(labels)
        
        thisLab = labels(i);
        
        labDat = evalin('base', strcat('f',num2str(j),'_label_',num2str(thisLab)));

        [ft, info] = makeFeaturesNSpd(labDat, ws, olap,0,8, 'norm', windowingMode);

        data = [data;ft];
        dataInfo = [dataInfo;info];
        
        assignin('base', strcat('f',num2str(j),'_fts_', num2str(labels(i))), ft);
        assignin('base', strcat('f',num2str(j),'_inf_', num2str(labels(i))), info);
       
    end   

end

[train,test,permutation] = splitset(data,frac);
metadata = struct('data',{datestr(today)},'author', {'merijn'},...
    'files',{dataStructs},'mode',{windowingMode}, 'wSize', {ws}, 'step', {olap},...
    'filter',{''},'ftSet',{''});

assignin('base', 'dataFeatures', data);
assignin('base', 'dataInfo', dataInfo);
assignin('base', strcat('train_',num2str(frac*100)), train);
assignin('base', strcat('test_',num2str((1-frac)*100)), test);
assignin('base', 'IDtrain', permutation(1:size(train,1)));
assignin('base', 'IDtest', permutation(size(train,1)+1:end));
assignin('base', 'metaData', metadata);





