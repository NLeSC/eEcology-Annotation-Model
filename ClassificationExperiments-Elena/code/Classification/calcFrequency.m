%% calcFrequency - calculates frequency spectral features
%
% author: Merijn de Bakker, UvA, Elena Ranguelova, NLeSc
% date creation: 11-2011
% last modification date: 22-08-2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% FFTM = calcFrequency(M)
%
% INPUT
% M-  a 3D matrix of X,Y,Z signals of j windows. 
%
% OUPTPUT
% FFTM- a 3D matrix with the spectrum-powers in dB for X,Y,Z signal.
%
% EXAMPLE
% 
% SEE ALSO
% calcFeatureVectors.m
%
% REFERENCES
% FaFoTr.m- original file by M. de Bakker
% "Automatic Classification of Bird Behaiviour on the baes of Accelerometer
% Data", Merijn de Bakker, Bachelor thesis, IBED, UvA, 2011
%
% NOTES
% Preferably, the windows are firstly subjected to a hamming filter in order
% to prevent spectral leakage!

function FFTM = calcFrequency(M)

%init
FM = [];
FFTM = [];
FFTM = {};
nOfWindows = size(M,1);

%fourier parameters
sampleFreq = 20;

signalLength = size(M,1);
fourierSamples = 2^(nextpow2(signalLength));

%fast fourier transform and feature calcultation for X-axis
%FM(:,1,j) = fft(M(:,1,j),fourierSamples);
fftftX = fEnergy(M(:,1), fourierSamples, signalLength, sampleFreq, 4);

%fast fourier transform and feature calcultation for Y-axis
%FM(:,2,j) = fft(M(:,2,j),fourierSamples);
fftftY = fEnergy(M(:,2), fourierSamples, signalLength, sampleFreq, 4);

%fast fourier transform and feature calcultation for Z-axis
%FM(:,3,j) = fft(M(:,3,j),fourierSamples);
fftftZ = fEnergy(M(:,3), fourierSamples, signalLength, sampleFreq, 4);

FFTM = [fftftX,fftftY,fftftZ];
%FFTM(1,:,j) = [fftftX,fftftY,fftftZ];

end

function features = fEnergy(Vector,fourierSamples, signalLength, sampleFreq, nOfBins)
%creates and analyses periodogram, derived from FaFoTr
%INPUT: vector with complex fourier numbers
%OUTPUT: fourier features 

hper = spectrum.periodogram('hamming');
pd = psd(hper,Vector,'Fs', sampleFreq, 'NFFT', length(Vector));
%pd = msspectrum(hper,Vector,'Fs', sampleFreq, 'spectrumtype','onesided');

pdData = pd.Data;
pdFreqs = pd.Frequencies;

%exclude zero frequency component (DC)
[nonzeros,~] = find(pdFreqs>0);
pdData = pdData(nonzeros);
pdFreqs = pdFreqs(nonzeros);

%maximum amplitude and frequency at maximum amplitude
%[maxAmp, maxI] = max(abs(pd.Data(nonzeros)));
[maxAmp, maxI] = max(pdData);
argmaxAmp = pdFreqs(maxI);

sumEnergy = sum(pd.Data);

%energy in the subbands 
binPoint = linspace(0,sampleFreq/2,nOfBins+1);

try
eBin1 = avgpower(pd,[binPoint(1) binPoint(2)]);
catch e1
    eBin1 = NaN;
end
try
eBin2 = avgpower(pd,[binPoint(2) binPoint(3)]);
catch e2
    eBin2 = NaN;
end
try
eBin3 = avgpower(pd,[binPoint(3) binPoint(4)]);
catch e3
    eBin3 = NaN;
end
try
eBin4 = avgpower(pd,[binPoint(4) binPoint(5)-1]);
catch e4
    eBin4 = NaN;
end

% eBin1 = sum(abs(pdData(find(pdFreqs >= binPoints(1) &...
%     pdFreqs <= binPoints(2)-1))));
% eBin2 = sum(abs(pdData(find(pdFreqs >= binPoints(2) &...
%     pdFreqs <= binPoints(3)-1))));
% eBin3 = sum(abs(pdData(find(pdFreqs >= binPoints(3) &...
%     pdFreqs <= binPoints(4)-1))));
% eBin4 = sum(abs(pdData(find(pdFreqs >= binPoints(4) &...
%     pdFreqs <= binPoints(5)))));

%entropy
a=abs(pdData);
b=log(abs(pdData));
b(isinf(b))=0;

entropy = -sum(a.*b);

%OLD CODE...using SIGNAL PROCESSING TOOLBOX seems to be more concise ^^

% nyquistFreq = sampleFreq/2;
% NumUniques = ceil((fourierSamples+1)/2);
% 
% Vector = Vector(1:NumUniques);
% 
% %normalised fft vals
% VectorN = Vector/signalLength;
% 
% %calculate power
% pwr = abs(VectorN);
% 
% if rem(fourierSamples,2)
%     pwr(2:end) = pwr(2:end)*2;
% else
%     pwr(2:end-1) = pwr(2:end-1)*2;
% end
% 
% %transform power to decibels
% energyDB = 20*log10(pwr+eps);
% 
% %use only the nyquist frequencies, here 0Hz to 10Hz
% freq = (0:NumUniques-1)*sampleFreq/fourierSamples;
% 
% %--------------------------------------------------------
% %calculate maximum energy and argmax
% maxAmplitude = min(abs(energyDB));
% argmax = freq((abs(energyDB) == maxAmplitude));
% 
% %calculate sum of energy in frequency-bins
% binRange = floor(length(freq)/nOfBins);
% 
% %sum energy in each bin
% eBin1 = abs(sum(energyDB(1:binRange)));
% eBin2 = abs(sum(energyDB(binRange+1:2*binRange)));
% eBin3 = abs(sum(energyDB(2*binRange+1:3*binRange)));
% eBin4 = abs(sum(energyDB(3*binRange+1:length(energyDB))));
% 
% %mean energy in each bin
% meBin1 = abs(mean(energyDB(1:binRange)));
% meBin2 = abs(mean(energyDB(binRange+1:2*binRange)));
% meBin3 = abs(mean(energyDB(2*binRange+1:3*binRange)));
% meBin4 = abs(mean(energyDB(3*binRange+1:length(energyDB))));


% figure 
% plot(freq, pwr)
% t = title([' maxAmp: ', num2str(maxAmplitude), ' argmax: ',num2str(argmax),...
%     'eb1: ', num2str(eBin1), ' meb1: ', num2str(meBin1)]);
% set(t, 'Fontsize', 8);

features = [maxAmp, argmaxAmp, eBin1, eBin2, eBin3, eBin4, entropy];

end




%-----dump

%freq = (0:(vectorLength/2)-1)*sampleFreq/vectorLength;
%VectorN = VectorN(1:vectorLength/2);
%freq = (1:vectorLength/2)/(vectorLength/2)*nyquistFreq;
%k = 0:length(Vector)-1;
%freqInterval = length(Vector)/sampleFreq;
%freq = k/freqInterval;
%periodoGram = [energyDB';freq];
