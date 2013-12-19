%function for doing experiments with the labelled bird data, using PRTools'
%classification tree. 
%
%method: 1 vs all.
%
%Merijn de Bakker || merijn.debakker@gmail.com
%
%INPUT: %[trainset,testset,criterium,pruning,cv,featureselection,reject,featureList
%,name for the outputstruct]
%OUTPUT: a struct containing (meta)data and results
%
%pruning
    % Computation of a decision tree classifier out of a dataset A using 
    % a binary splitting criterion CRIT:
    %   INFCRIT  -  information gain
    %   MAXCRIT  -  purity (default)
    %   FISHCRIT -  Fisher criterion
    % 
    % Pruning is defined by prune:
    %   PRUNE = -1 pessimistic pruning as defined by Quinlan. 
    %   PRUNE = -2 testset pruning using the dataset T, or, if not
    %              supplied, an artificially generated testset of 5 x size of
    %              the training set based on parzen density estimates.
    %              see PARZENML and GENDATP.
    %   PRUNE = 0 no pruning (default).
    %   PRUNE > 0 early pruning, e.g. prune = 3
    %   PRUNE = 10 causes heavy pruning.
    % 
    % If CRIT or PRUNE are set to NaN they are optimised by REGOPTC.
%
%ftSelection
%  METHOD  - 'forward' : selection by featself (default)
% 	        - 'float'   : selection by featselp
% 	        - 'backward': selection by featselb
% 	        - 'b&b'     : branch and bound selection by featselo
% 	        - 'ind'     : individual
% 	        - 'lr'      : plus-l-takeaway-r selection by featsellr
%           - 'sparse'  : use sparse untrained classifier CRIT
%
%

function  [errorTest,confM] = treeExperimenter(trainSet,testSet,crit, pruning, crossValidation, ft, reject,featureSelection,structName)

if isempty(featureSelection)
    nFeatures = size(trainSet,2)-1;
    featureSelection = 2:nFeatures+1;
else    
    featureSelection = featureSelection+1;
end    

    %Prepare train dataset
    trainInstances = trainSet(:,featureSelection);    
    trainLabels = trainSet(:,1);
    trainDataSet = dataset(trainInstances,trainLabels);

    %Prepare test dataset
    testInstances = testSet(:,featureSelection);
    testLabels = testSet(:,1);
    testDataSet = dataset(testInstances,testLabels);

    %add noise in order to avoid error (see
    %http://prsdstudio.com/index.php/forums/viewthread/90/)
    %summary: add noise to prevent 2 instances with different labels have
    %identical features.
    %train = data+randn(nOfI,nOfFt)*1e-8;
 
    %crit = 'infcrit';

        if crossValidation== 0

            %[train,testdata, Itrain, Itest] = gendat(data,0.66);
           
            
            if strcmp(char(ft),'')==0
                [Wft,R] = FEATSELF(trainDataSet,treec([],crit,pruning),0,10);
                trainDataSet = trainDataSet*Wft;
                testDataSet = testDataSet*Wft;
                %train the tree
                W = treec(trainDataSet,crit,pruning,testDataSet);
            else
                W = treec(trainDataSet,crit,pruning,testDataSet); 
                R = NaN;
                Wft = NaN;
              
            end
            
            if reject==1
                W = rejectc(trainDataSet, W, 0.1);  
                NNtest = NaN;
                NNtrain = NaN;
                treeInfo = NaN;
            else
                [~,~,NNtrain, treeInfo] = tree_map(trainDataSet,W);
                [~,~,NNtest,~] = tree_map(testDataSet,W); 
            end
            
            
            %assigned labels trainset
            trainClasses = labeld(trainDataSet*W);
            
            %testset
            T = testDataSet*W;
            
            %assigned labels testset
            classes = T*labeld;
            
            %error on testset
            errorTest = T*testc;

            %confusion matrix testset
            confmat(T)
            confM = confmat(T);
            
       elseif crossValidation~=0

            [errorTest,CERR,NLAB_OUT] =...
                crossval(data,treec([],crit,pruning),crossValidation);
            %[errorTest,CERR,NLAB_OUT] =...
            %    crossval(data,SVC([],'r',1),cv);
            
           
            %errorTestT=errorTest;
            
            W = NaN;
            classes = NaN;
            trainClasses =NaN;
            treeInfo = NaN;
            confM = NaN;
            confMT=confM;
            Wft = NaN;
            R = NaN;
            NNtest = NaN;
            NNtrain = NaN;
        end
    
resultStruct = struct('classP','multiclass', 'classN', 'multiclass',...
    'settings',[pruning, crossValidation, ft],'criterium', {crit}, ...
    'traindata', trainDataSet, 'testdata', testDataSet,'mapping',W, ...
    'testLabs', classes, 'trainLabs', trainClasses, 'treeInfo',treeInfo, ...
    'confM', confM, 'errorTest', errorTest, 'Wft', Wft, 'Rft', R,...
    'NNtrain', NNtrain, 'NNtest', NNtest,'features',featureSelection-1);
name = strcat('multiclass_results');
assignin('base',structName, resultStruct);

 



