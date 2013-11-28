%% startCheckcode - Matlab script for testing Matlab's code quality
%
% author: Elena Ranguelova & Stefan Verhoeven, NLeSc
% date creation: 14/11/2013
% last modification date: 28/11/2013
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% startCheckcode
%
% INPUT
%
% OUPTPUT
%
% EXAMPLE
%
% SEE ALSO
% subdir, startCheckcode.sh
%
% REFERENCES
%
% NOTES

%dirNames = {fullfile('code'), ...
%            fullfile('code','scripts')};
dirNames =subdir;

    
nDirs = numel(dirNames);

mkdir('code-quality-metrics');
fidLog = fopen(fullfile('code-quality-metrics','checkcode.log'),'wt');
fidComplexity = fopen(fullfile('code-quality-metrics','mccabe-complexity.log'),'wt');


for iDir=1:nDirs

    dirName = dirNames{iDir};
    
    fnames = what(dirName);
    
    addpath(dirName);

    nFiles = numel(fnames.m);
    
    for iFile = 1:nFiles
        
        fname = fnames.m{iFile};
        
        msg = checkcode(fname,'-cyc');
        
        nMsgs = numel(msg);
        
        
        for iMsg=1:nMsgs
            
            if ~isempty(strfind(msg(iMsg).message,'The McCabe complexity'))
                nChars = fprintf(fidComplexity,'%s/%s:%d:%d: E1 %s\n',dirName,fname,msg(iMsg).line,msg(iMsg).column(1),msg(iMsg).message);
            else
                nChars = fprintf(fidLog,'%s/%s:%d:%d: E1 %s\n',dirName,fname,msg(iMsg).line,msg(iMsg).column(1),msg(iMsg).message);
            end
        end
        
    end
    
    rmpath(dirName)
    
    
end
fclose(fidLog);
fclose(fidComplexity);

exit(0)