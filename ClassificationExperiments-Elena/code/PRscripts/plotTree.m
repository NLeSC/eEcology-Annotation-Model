%function plotTree
%   plotting a tree resulting from PRtools treemap function
%
%merijn de bakker || merijn.debakker@gmail.com
%created: 11-06-2011 | modified: --
%
%INPUT: a 'info' matrix (result from treemap). note that this not available
%in the original prtool. treemap has been modified for outputting the 'info
% matrix
%OUTPUT: a figure with the tree. next to the nodes is the feature and the
%threshold value. lefts branch <= threshold, right branch > threshold. Leaf
%nodes are the classes.
%DEPENDS: --
%NOTES: --

function plotTree(Matrix, NNodes, ftList,name)

nOfNodes = Matrix(end,1);

%ftns = evalin('base','ftLabels');
%find start and endnode
%startNode = Matrix(1,1);
%[endNodes,~,~] = unique(Matrix(find(Matrix(:,2)==0),1), 'first');

nodes = zeros(1,nOfNodes);
features = zeros(nOfNodes,1);
thresholds = zeros(nOfNodes,1);

features(1) = Matrix(1,2);
thresholds(1) = Matrix(1,3);

%convert the nodes to the format Matlab desires in treeplot
for i = 1:size(Matrix,1)
    
    thisNode = Matrix(i,4);
    
    if Matrix(i,4) == 1 || Matrix(i,2)==0           
        
        continue
    end
    
    [index,~] = find(Matrix(:,4)==thisNode & Matrix(:,2)~=0);
    parent = Matrix(index,1);

    if Matrix(find(Matrix(:,1)==thisNode,1,'first'),2)==0
        
        features(thisNode) = Matrix(find(Matrix(:,1)==thisNode,1,...
             'first'),4);  
    else
  
        features(thisNode) = Matrix(find(Matrix(:,1)==thisNode,1,'first'),2);
        thresholds(thisNode) = Matrix(find(Matrix(:,1)==thisNode,1,'first'),3);
        
    end    
    
    nodes(thisNode) = parent;
end

figure
hold on

axis off;
nodespec = ['b','o'];
edgespec = ['b'];
treeplot(nodes, nodespec, edgespec);

[x,y] = treelayout(nodes);

x = x';
y = y';
[endNodes,~] = find(thresholds==0);
realNodes = setdiff(1:length(nodes),endNodes);
realnodeID = 1:length(realNodes);
endnodeID = length(realNodes)+1:length(features);
name1 = cellstr(num2str(features));
realID = cellstr(num2str(realnodeID'));
endID = cellstr(num2str(endnodeID'));

name2 = cellstr(num2str(thresholds,2));
counts = cellstr(num2str(NNodes));

%while (thresholds(i+4)~=0 || thresholds(i+5)~=0)

    %if abs(x(i) - x(i+1))>0.01 && abs(y(i) - y(i+1))>0.02
        text(x(realNodes,1)+0.01, y(realNodes,1), strcat('ID:',realID,'FT:',name1(realNodes)), 'VerticalAlignment',...
            'bottom','HorizontalAlignment','left', 'Fontsize', 6)
        %text(x(:,1)-0.02, y(:,1)-0.09, '<=', 'VerticalAlignment','bottom','HorizontalAlignment','right')
        %text(x(:,1)+0.02, y(:,1)-0.09, '>', 'VerticalAlignment','bottom','HorizontalAlignment','right')
        text(x(realNodes,1), y(realNodes,1)-0.015, name2(realNodes), 'VerticalAlignment',...
            'bottom','HorizontalAlignment','left','Fontsize', 6)
%        text(x(i,1), y(i,1)-0.03, strcat('(',counts(i,:),')'), 'VerticalAlignment',...
%            'bottom','HorizontalAlignment','left','Fontsize', 6)
    %end
    
%    i=i+1;
%end

%draw endnodes
% for j=1:length(thresholds)
%     if thresholds(j) == 0
%         text(x(j,1), y(j,1)-0.02, name1(j), 'VerticalAlignment',...
%             'bottom','HorizontalAlignment','center', 'Fontsize', 6)
%     end
% end

text(x(endNodes,1), y(endNodes,1)-0.04, name1(endNodes), 'VerticalAlignment',...
             'bottom','HorizontalAlignment','center', 'Fontsize', 7)
text(x(endNodes,1), y(endNodes,1)-0.07, endID, 'VerticalAlignment',...
     'bottom','HorizontalAlignment','center', 'Fontsize', 6)
 
pos = 0.11;

for i = 1:size(NNodes,2)
    
    text(x(endNodes,1), y(endNodes,1)-pos, num2str(NNodes(endNodes,i)),'VerticalAlignment',...
             'bottom','HorizontalAlignment','center', 'Fontsize', 6);
    pos = pos+0.015;
end


%make a file that explains the tree and enumerates the passes through nodes
if strcmp(name,'')==0
    explainTree(Matrix,ftList, NNodes,[realNodes';endNodes],name)
end





