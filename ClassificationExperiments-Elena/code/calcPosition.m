%% calcPosition - calculates function position features
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% PRM = calcPostition(M)
%
% INPUT
% M- 3D matrix containing X,Y,Z for j windows
%
% OUPTPUT
% PRM- 3D matrix with [mean pitch, std pitch, mean roll, std roll] for ...
% each window
%
% EXAMPLE
% 
% SEE ALSO
% calFeatureVectors.m
%
% REFERENCES
% position.m- original code by M. de Bakker


function PRM = calcPosition(M)

% statistics over window (mean pitch, standDev pitch, mean roll, standDev
% roll)   
x = M(:,1);
y = M(:,2);
z = M(:,3);

pitch_rad = atan(x./sqrt(y.^2+z.^2));
roll_rad = atan(y./sqrt(x.^2+z.^2));
pitch = (pitch_rad*180)/pi;
roll = (roll_rad*180)/pi;

PRM = [mean(pitch),std(pitch),mean(roll),std(roll),calcTrend(roll,3),...
    calcTrend(pitch,3),mean(x),mean(y),mean(z),std(x),std(y),std(z)];

end

function trend = calcTrend(v,n)
    nOfFrames = length(v);
    movAVG = zeros(1,nOfFrames);    
    
    %calc moving average with lag of n
    for i = n:nOfFrames
        avg = 0;
        for j = 0:n-1
            avg = avg+v(i-j);
        end    
        movAVG(i) = (1/n) * avg;
    end
      
   %find 1st order least square fit
   coefs = polyfit(movAVG,1:nOfFrames,1);
    
   trend = coefs(1);
end

%DUMP
% function pd = calcPeakDist(v, type)
% 
% i = 2:length(v)-1;
% 
% if strcmp(type,'max')==1
%    i1 = find(v(i-1)<v(i) & v(i+1)<v(i))+1;
%    v(i)~=i1(1);
%    i2 = find(v(i-1)<v(i) & v(i+1)<v(i) & v(i)~= i1)+1;
%    space = abs((i1(1)-i2(1))-1);
%    
%    
% elseif strcmp(type,'min')==1
%    i1 = find(v(i-1)+0.01>v(i) & v(i+1)+0.01>v(i))+1;
%    i2 = find(v(i-1)+0.1<v(i) & v(i+1)+0.1<v(i) & v(i)~=i1(1))+1;
%    space = abs((i1-i2)-1); 
%     
%    
% elseif strcmp(type,'minmax')==1
%     
%    imax = find(v(i-1)+0.1<v(i) & v(i+1)+0.1<v(i))+1;
%    imin = find(v(i-1)+0.01>v(i) & v(i+1)+0.01>v(i))+1;
%    
%    i = find(v == max(v(v(imax))));
%    i2 = find(v == min(v(v(imin))));
%    
%    diff = abs(max((max(v(v(imax))))-min((v(v(imin))))));
%    space = abs((i(1)-i2(end)))/diff;
%   
% end
% 
% pd = space;
% end




