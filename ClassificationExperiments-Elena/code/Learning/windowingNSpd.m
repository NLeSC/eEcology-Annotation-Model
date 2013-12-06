%merijn de bakker
%16-03-2010
%
%function WINDOWING(MATRIX, WINDOW SIZE, OVERLAP)
%sliding windowing over a time series. input a 2D matrix, window size
%(wSize) and an overlap (oLap) as a share of the window (typically 0.5).
%outputs a 3D matrix (:,:,windownr). auxilliary arguments: 
%('hamming'),('lowpass'),('bandpass'),('bandpass','hamming')
%Matlab built-in 'butter' uses 3db cut-off
%
%
%
%structure of M: [device,samplenr,index,x,y,z,speed,label,speedOK]


function  windows = ...
    windowingNSpd(M, wSize, oLap, perSample, varargin)
%[windows,devices,sampleStart,sampleEnd,indexStart,indexEnd,labels]

if oLap>0
    step = wSize*oLap;
else
    step = wSize;
end
mLength = size(M,1);

%LOWPASS 
%   cut-off frequencies above 9 Hz (=18/20)
cutOff = 0.45;
%   butterworth order
order  = 4;

%BANDPASS cut-off frequencies
cutOffLow = 0.1;
cutOffHigh = 0.9;

windows = [];

labels = [];
%start position
i=1;
%windownr
j=1;

if length(varargin) == 1
    if strcmp(varargin(1), 'hamming')
        ham = hamming(wSize,'periodic');
        
        if perSample==0
        %make windows
            while i+wSize<=mLength+1
                x = M(i:i+wSize-1,4).*ham;
                y = M(i:i+wSize-1,5).*ham;
                z = M(i:i+wSize-1,6).*ham;
                             
                windows{j,1} = [x,y,z];
                windows{j,2} = M(i,8);
                windows{j,3} = M(i,1);
                windows{j,4} = M(i,2);
                windows{j,5} = M(i+wSize-1,2);
                windows{j,6} = M(i,3);
                windows{j,7} = M(i+wSize-1,3);
                windows{j,8} = M(i,7);
                
                i = i+step;
                j = j+1;
            end
            
        elseif perSample ==1
            
            windows = {};
            id = find(diff(M(:,3))~=1)+1;
            
            windows{1,1} = M(1:id(1)-1,4:6);
            windows{1,2} = M(id(1)-1,8);
            windows{1,3} = M(id(1)-1,1);
            windows{1,4} = M(1,2);
            windows{1,5} = M(id(1)-1,2);
            windows{1,6} = M(1,3);
            windows{1,7} = M(id(1)-1,3);
            windows{1,8} = M(1,7);
            
            for i = 2:length(id)
                windows{i,1} = M(id(i-1):id(i)-1,4:6);
                windows{i,2} = M(id(i)-1,8);                
                windows{i,3} = M(id(i)-1,1);
                windows{i,4} = M(id(i-1),2);
                windows{i,5} = M(id(i),2);
                windows{i,6} = M(id(i-1),3);
                windows{i,7} = M(id(i),3);
                windows{i,8} = M(i,7);
            end
            
            windows{end+1,1} = M(id(end):end,4:6);
            windows{end,2} = M(id(end),8);
            windows{end,3} = M(id(end),1);
            windows{end,4} = M(id(end),2);
            windows{end,5} = M(end,2);
            windows{end,6} = M(id(end),3);
            windows{end,7} = M(end,3);
            windows{end,8} = M(end,7);
            
            for i =size(windows,1)
                
                wL = size(windows{i,1},1);
                
                ham = hamming(wL,'periodic');
                windows{i,1}(:,1) = windows{i,1}(:,1).*ham;
                windows{i,1}(:,2) = windows{i,1}(:,2).*ham;
                windows{i,1}(:,3) = windows{i,1}(:,3).*ham;
            end
                        
        end
                   
    elseif strcmp(varargin(1), 'lowpass')
        
        [b,a] = butter(order,cutOff,'low');
        
        if perSample == 0
            while i+wSize<=mLength+1
                
                [r,~] = find(isnan(M(i:i+wSize-1,4:6)));
                if ~isempty(r)
                    i = i+step;
                    %j = j+1;
                    continue
                else
                    windows{j,1} = filter(b,a,M(i:i+wSize-1,4:6));
                    windows{j,2} = M(i,8);
                    windows{j,3} = M(i,1);
                    windows{j,4} = M(i,2);
                    windows{j,5} = M(i+wSize-1,2);
                    windows{j,6} = M(i,3);
                    windows{j,7} = M(i+wSize-1,3);
                    windows{j,8} = M(i,7);
                    i = i+step;
                    j = j+1;
                end
            end            
        
        
        elseif perSample ==1
            
            windows = {};
         
            id = find(diff(M(:,3))~=1)+1;
            
            if ~isempty(id)   
                windows{1,1} = M(1:id(1)-1,4:6);
                windows{1,2} = M(id(1)-1,8);
                windows{1,3} = M(id(1)-1,1);
                windows{1,4} = M(1,2);
                windows{1,5} = M(id(1)-1,2);
                windows{1,6} = M(1,3);
                windows{1,7} = M(id(1)-1,3);
                windows{1,8} = M(1,7);

                for i = 2:length(id)
                    windows{i,1}=M(id(i-1):id(i)-1,4:6);
                    windows{i,2}=M(id(i)-1,8);                
                    windows{i,3} = M(id(i)-1,1);
                    windows{i,4} = M(id(i-1),2);
                    windows{i,5} = M(id(i),2);
                    windows{i,6} = M(id(i-1),3);
                    windows{i,7} = M(id(i),3);
                    windows{i,8} = M(id(i),7);
                end

                windows{end+1,1} = M(id(end):end,4:6);
                windows{end,2} = M(id(end),8);
                windows{end,3} = M(id(end),1);
                windows{end,4} = M(id(end),2);
                windows{end,5} = M(end,2);
                windows{end,6} = M(id(end),3);
                windows{end,7} = M(end,3);
                windows{end,8} = M(id(end),7);
                
                for i =size(windows,1)
                
                    wL = size(windows{i,1},1);

                    windows{i,1}(:,1) = filter(b,a,windows{i,1}(:,1));
                    windows{i,1}(:,2) = filter(b,a,windows{i,1}(:,2));
                    windows{i,1}(:,3) = filter(b,a,windows{i,1}(:,3));
                end
            
            else
                windows = [];
            end
                    
        end
                        
        
    else strcmp(varargin(1), 'bandpass')
        %H = fdesign.bandpass)
        [b,a] = butter(order,[cutOffLow,cutOffHigh],'stop');
        
        while i+wSize<=mLength+1
            windows{j,1} = filter(b,a,M(i:i+wSize-1,4:6));
            windows{j,2} = M(i,8);
            windows{j,3} = M(i,1);
            windows{j,4} = M(i,2);
            windows{j,5} = M(i+wSize-1,2);
            windows{j,6} = M(i,3);
            windows{j,7} = M(i+wSize-1,3);
            windows{j,8} = M(i,7);
            i = i+step;
            j = j+1;
        end            
    end
 
%case with bandpass-filter and hamming window (fft purpose)
elseif length(varargin) == 2
    
        if strcmp(varargin(1), 'band')
            ham = hamming(wSize);
            [b,a] = butter(order,[cutOffLow,cutOffHigh],'bandpass');
        
            while i+wSize<=mLength+1
                filtered = filter(b,a,M(i:i+wSize-1,4:6));
    
                xf = filtered(:,1).*ham;
                yf = filtered(:,2).*ham;
                zf = filtered(:,3).*ham;

                windows{j,1} = [xf,yf,zf];
                windows{j,2} = M(i,8);
                windows{j,3} = M(i,1);
                windows{j,4} = M(i,2);
                windows{j,5} = M(i+wSize-1,2);
                windows{j,6} = M(i,3);
                windows{j,7} = M(i+wSize-1,3);
                windows{j,8} = M(i,7);

                i = i+step;
                j = j+1;
            end
        
        
        elseif strcmp(varargin(1), 'low')
            ham = hamming(wSize);
            [b,a] = butter(order,cutOff,'low');
            
            while i+wSize<=mLength+1
               
               filtered = filter(b,a,M(i:i+wSize-1,4:6));
    
                xf = filtered(:,1).*ham;
                yf = filtered(:,2).*ham;
                zf = filtered(:,3).*ham;

                windows{j,1} = [xf,yf,zf];
                windows{j,2} = M(i,8);
                windows{j,3} = M(i,1);
                windows{j,4} = M(i,2);
                windows{j,5} = M(i+wSize-1,2);
                windows{j,6} = M(i,3);
                windows{j,7} = M(i+wSize-1,3);
                windows{j,8} = M(i,7);

                i = i+step;
                j = j+1;
  
            end
        end

%case without filtering
else isempty(varargin);
    windows = {};
    
    if perSample == 0;
        
        while i+wSize<=mLength+1;
             
             [r,~] = find(isnan(M(i:i+wSize-1,4:6)));
             if ~isempty(r)
                 i = i+step;
                 %j = j+1;
                 continue
             else
                 windows{j,1} = M(i:i+wSize-1,4:6);
                 windows{j,2} = M(i,8);
                 windows{j,3} = M(i,1);
                 windows{j,4} = M(i,2);
                 windows{j,5} = M(i+wSize-1,2);
                 windows{j,6} = M(i,3);
                 windows{j,7} = M(i+wSize-1,3);
                 windows{j,8} = M(i,7); 
                 i = i+step;
                 j = j+1;
             end
%              labels(j) = M(i,7);
%              devices(j) = M(i,1);
%              sampleStart(j) = M(i,2);
%              sampleEnd(j) = M(i+wSize-1,2);
%              indexStart(j) = M(i,3);
%              indexEnd(j) = M(i+wSize-1,3);
             
        end
    
    
     elseif perSample ==1
                    
            id = find(diff(M(:,3))~=1)+1;
            
            windows{1,1} = M(1:id(1)-1,4:6);
            windows{1,2} = M(id(1)-1,8);
            windows{1,3} = M(id(1)-1,1);
            windows{1,4} = M(1,2);
            windows{1,5} = M(id(1)-1,2);
            windows{1,6} = M(1,3);
            windows{1,7} = M(id(1)-1,3);
            windows{1,8} = M(id(1)-1,7);

            for i = 2:length(id)
                windows{i,1}=M(id(i-1):id(i)-1,4:6);
                windows{i,2}=M(id(i)-1,8);                
                windows{i,3} = M(id(i)-1,1);
                windows{i,4} = M(id(i-1),2);
                windows{i,5} = M(id(i),2);
                windows{i,6} = M(id(i-1),3);
                windows{i,7} = M(id(i),3);
                windows{i,8} = M(id(i)-1,7);
            end
            
            windows{end+1,1} = M(id(end):end,4:6);
            windows{end,2} = M(id(end),8);
            windows{end,3} = M(id(end),1);
            windows{end,4} = M(id(end),2);
            windows{end,5} = M(end,2);
            windows{end,6} = M(id(end),3);
            windows{end,7} = M(end,3);
            windows{end,8} = M(id(end),7);
    end
end

