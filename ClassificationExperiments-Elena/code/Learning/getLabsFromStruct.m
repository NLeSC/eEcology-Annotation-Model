 %Merijn de Bakker || merijn.debakker@gmail.com

function alldata = getLabsFromStruct(str)

% lf = load(file);
% sn = fieldnames(lf);
% str = lf.(sn{1});

%make alldata
alldata = [];

for i = 1:str.nOfSamples
    id=[];
    sp=[];
    da=[];
    index1=[];
    
    d = datenum([str.year(i) str.month(i) str.day(i) str.hour(i) str.min(i) ...
        str.sec(i)]);
    maxN = max([size(str.accX{i},2),size(str.accY{i},2),size(str.accZ{i},2)]);  
    str.accX{i}(end+1:maxN) = NaN;
    str.accY{i}(end+1:maxN) = NaN;
    str.accZ{i}(end+1:maxN) = NaN;
    
    id(1:maxN,1) = str.sampleID(i);
    da(1:maxN,1) = d;
       
    %sp(1:maxN,1) = str.gpsSpd2D(i);
    sp(1:maxN,1) = str.gpsSpd(i);
    index1 = 0:maxN-1;
 
    alldata = [alldata; id da index1' str.accX{i}' str.accY{i}' str.accZ{i}' sp str.tags{i}];

end

end
    
    
