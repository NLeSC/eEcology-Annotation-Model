 %Merijn de Bakker || merijn.debakker@gmail.com

function explainTree(Matrix, ftList, nodeCount,nodeID,name)

%this is a binary tree
nOfRules = size(Matrix,1);
ruleN = 0;
ruleOff = 0;
als = char('if');
dan = char('then');
groter = char('>=');
kleiner = char('<');
regel = char('rule');
anders = char('else');
semic = char(': ');
klasse = char('class: ');
labels = 1:size(nodeCount,2);

%[filename,path] = uiputfile({'*.txt'},'export rules');
%sch.fileName = strcat(path,filename);
%file = fopen(sch.fileName,'wt+');

file = fopen(strcat(pwd,'\',name),'wt+');

for i = 1:2:nOfRules
    
    if Matrix(i,2) == 0
        ruleN  = ruleN+1;
        ruleOff = ruleOff+1;
        continue
    end

    
    ruleN = ruleN+1;
    thresh = Matrix(i,3);
    ifS = Matrix(i,4);
    ifG = Matrix(i+1,4);
    Matrix(i,2);
    ft = char(ftList(Matrix(i,2)));
    passes = ['passes: ',num2str(nodeCount(ruleN,:))];
    
    if Matrix(ifG*2,2)==0 && Matrix(ifS*2,2)~=0
        class = Matrix(ifG*2,4);
        
        fprintf(file, '%g %s %s %s %.2f %s %s %g %s %s %g %s \n', ruleN, als, ft,...
            groter, thresh, dan, klasse, class, anders, regel, ifS, passes);
    
    elseif Matrix(ifS*2,2)==0 && Matrix(ifG*2,2)~=0
        class = Matrix(ifS*2,4);
        
        fprintf(file, '%g %s %s %s %.2f %s %s %g %s %s %g %s \n', ruleN, als, ft,...
            kleiner, thresh, dan, klasse, class, anders, regel, ifG, passes);
      
    elseif Matrix(ifS*2,2)==0 && Matrix(ifG*2,2)==0
        classS = Matrix(ifS*2,4);
        classG = Matrix(ifG*2,4);
        fprintf(file, '%g %s %s %s %.2f %s %s %g %s %s %g %s \n', ruleN, als, ft,...
            kleiner, thresh, dan, klasse, classS, anders, klasse, classG, passes);
    end
        
    if Matrix(ifS*2,2)~=0 && Matrix(ifG*2,2)~=0
        fprintf(file, '%g %s %s %s %.2f %s %s %g %s %s %g %s \n', ruleN, als, ft,...
            groter, thresh, dan, regel, ifG, anders, regel, ifS, passes);
        
    end
    
    
end

%make table of node passes
fprintf(file, '\n\n\n%s\n\n', 'NUMBER OF NODE PASSES PER LABEL');

fprintf(file, '\t%s\t', 'LABEL');

for j = 1:length(labels)
    fprintf(file, '%s%g%s\t','|', labels(j), '|') ;  
end

fprintf(file, '\n%s\n', 'NODE');

for i = 1:ruleN
    fprintf(file, '%d\t\t', i);
    for j = 1:length(labels)
        fprintf(file, '%d\t',nodeCount(nodeID(i),j));  
    end
    fprintf(file, '\n');
end
     

fclose(file);



