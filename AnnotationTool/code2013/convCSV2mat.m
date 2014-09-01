%function convCSV2mat
%   converts a csv file from bird database to day unique matfiles 
%merijn de bakker || merijn.debakker@gmail.com
%
%created:06-07-2011
%revised:18-07-2011
%
%INPUT: a .csv or .txt file with the following column structure:
%|device,datetime,index,accX,accY,accZ| delimited by comma's. the first
%will not be skipped! datetime format is mm/dd/yyyy HH:MM:SS. Other formats
%return an error
%important: make sure there are no quotation-marks delimiting the field, otherwise...
%change this program accordingly. 
%OUTPUT: for each day in the file, a separate .mat file is assigned to the
%workspace, named A$device$_$day$$month$_$day$$month$
%DEPENDS.: --
%NOTES: it is assumed that the number of days the file contains is less or
%equal to a month. If in practice it appears that files contain more
%samples, this program should be adapted.
%important: make sure there are no quotation-marks delimiting the field,
%otherwise adapt this program accordingly. 

function outp=convCSV2mat(file)

 

%read file
inpFile = fopen(file,'rt');

%check whether gps speed is available
testF = fopen(file);
j=1;
while j<3
    textline = fgetl(testF);
    j=j+1;
end

seps = find(textline == ',');
lS = length(seps);
fclose(testF);

if lS == 5
    sc = textscan(inpFile,'%f %s %f %f %f %f', 'Delimiter',',','CollectOutput',1,...
        'HeaderLines',1,'ReturnOnError',0);
    spdA = 0;
elseif lS == 6
    sc = textscan(inpFile,'%f %s %f %f %f %f %f', 'Delimiter',',','CollectOutput',1,...
        'HeaderLines',1,'ReturnOnError',0);
    spdA = 1;
else
    return
end
fclose(inpFile);

%convert the correct columns to numeric and the date to a datenum
AccM = [sc{1} datevec(sc{2},'yyyy-mm-dd HH:MM:SS') sc{3}];

%check unique days 
[~,mD,~] = unique(AccM(:,4),'legacy');

if (AccM(1,8) == 0)
    ids = find(AccM(:,8)==0);
else
    ids = find(AccM(:,8)==1);
end

offset = 1;

%build the structs
for i=1:length(mD)
   
   id = ids(find(ids >= offset & ids<=mD(i)));
   
   nOfSamples = length(id);
   
   xA = cell(nOfSamples,1);
   yA = cell(nOfSamples,1);
   zA = cell(nOfSamples,1);
   hour = zeros(1,nOfSamples);
   min = zeros(1,nOfSamples);
   sec = zeros(1,nOfSamples);
   
   
   spd(1,1:nOfSamples) = -1;
   
   
   for j = 1:nOfSamples-1       
       
      xA{j,1}(1,:) = AccM(id(j):id(j+1)-1,9);
      yA{j,1}(1,:) = AccM(id(j):id(j+1)-1,10); 
      zA{j,1}(1,:) = AccM(id(j):id(j+1)-1,11); 
      hour(j) = AccM(id(j),5);
      min(j) = AccM(id(j),6);
      sec(j) = AccM(id(j),7);
      
      if spdA
        spd(j) = AccM(id(j),12);
      end
   end
   
   xA{end,1}(1,:) = AccM(id(end):mD(i),9);
   yA{end,1}(1,:) = AccM(id(end):mD(i),10); 
   zA{end,1}(1,:) = AccM(id(end):mD(i),11); 
   hour(end) = AccM(id(end),5);
   min(end) = AccM(id(end),6);
   sec(end) = AccM(id(end),7);
   if spdA
       spd(end) = AccM(id(end),12);
   end
   
   outp = struct('ID',{repmat(AccM(offset,1),1,nOfSamples)}, 'doy',{[]}, 'Stime', {[]},...
       'year', {repmat(AccM(offset,2),1,nOfSamples)},'month', {repmat(AccM(offset,3),1,nOfSamples)},'day',...
       {repmat(AccM(offset,4),1,nOfSamples)}, 'hour', {hour},'min',...
    {min},'sec', {sec},'step', {[]},...
    'TmeSyn', {[]},'mesint',{[]}, 'nrBlocks',{[]},'nrSamp', {[]},'freq', {[]},...
    'accX', {xA}, 'accY', {yA},...
    'accZ', {zA},'Pres', {[]},'Temp', {[]},'time',{[]},...
   'accP', {[]}, 'accT', {[]},'Spd', {spd});
  
  % filename = strcat('A',num2str(AccM(offset,1)),'_',num2str(AccM(offset,4)),...
  %     num2str(AccM(offset,3)),'_',num2str(AccM(offset,4)),...
  %     num2str(AccM(offset,3)));

  %  assignin('base', filename,outp);
   
    offset = mD(i)+1;
 
end
    
end
