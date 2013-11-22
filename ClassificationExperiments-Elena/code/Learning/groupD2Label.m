%splitData2Templates(data)
%
%splits the annotated data into separate matrices contain unique labels. The
%matrices are assigned to the workspace, and named: label_[labelID]
%
%merijn de bakker || merijn.debakker@gmail.com
%date created: 21-05-2011 || revised: 21-05-2011
%
%INPUT: a plotData matrix, resulting from e.g. AccVidGui.
%OUTPUT:
%DEPENDS:
%NOTES: the label should be at the 7th column.


%function labels = groupD2Label(data, label,j)
function labels = groupD2Label(data, label)

    
    fmat = [];
    data = data(~isnan(data(:,label)),:);
    labels = unique(data(:,label));
    frameIndex = [];
    
    for i=1:length(labels)
        %disp('---------------label----------------');
        %disp(i);
        labelMat = [];
        [row, col] = find(data(:,label)==labels(i));
        %disp(row)
        frameIndex = 0:size(col,1)-1;
        
        labelMat = data(row,:);
        
        %replace NaN with 0 in the accelerometer data
        %[r,~] = find(isnan(labelMat(:,4:6)));
        %labelMat(r,4:6)=0;
            
        %assignin('base',strcat('f',num2str(j),'_label_',num2str(labels(i))), labelMat);
        assignin('base',strcat('label_',num2str(labels(i))), labelMat);
    end
    
%     if size(varargin,2)==2
%         varargout{1} = fmat;
%     end
%         
        
        
    