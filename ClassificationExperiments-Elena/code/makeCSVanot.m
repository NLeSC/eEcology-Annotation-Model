%% makeCSVanot - function to generate CSV file with annotations
%
% author: Stefan Verhoeven, NLeSc
% date creation: 28-10-2013
% last modification date:
% modification details:
% -----------------------------------------------------------------------
% SYNTAX
% []=makeCSVanot(inp_data, ...
%                classText, dateTimeFormat, fileName)
%
% INPUT
% inp_data- anotated data as output by the classification
% classText- the classification legend string
% dateTimeFormat- the format for the date and time to be displayed
% fileName - the filename of the csv file
%
% OUPTPUT
% device,datetime,class\n
%
% EXAMPLE
% see classificator.m
%
% SEE ALSO
%
% REFERENCES
% Any publications or resources used
%
% NOTES
% extra notes

function []= makeCSVanot(inp_data, ...
                         classText, dateTimeFormat, fileName)

nrows = length(inp_data.device);
% TODO dateTimes are printed as 2 instead of 2010-06-28T07:54:51Z
dateTimes = datestr(inp_data.datetime, dateTimeFormat);

fid = fopen(fileName, 'wt');
fprintf(fid, 'id,datetime,class\n');
for row=1:nrows
    fprintf(fid, '%d,%s,%s\n', inp_data.device(row), dateTimes(row), classText(5*(inp_data.class(row)-1)+1:5*(inp_data.class(row)-1)+5));
end
fclose(fid);
