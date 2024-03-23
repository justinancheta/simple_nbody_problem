function tab = readEphemerisFile(fileName, startLine, endLine)
%
%   ABOUT: Reads in JPL horizon files which are CSV formmated with
%   additional header information
% 
%   INPUTS: 
%           filename    <char>      Character array for file name
%           
%   OPTIONAL INPUTS: 
%
%   OUTPUTS:
%           tab         <table>     Ephemeris data in table format
%
%   SYNTAX:
%           tab = readEphemerisFile('EphemerisData\earth.txt')
%
%   NOTES: 

    if nargin < 2
        startLine = 55;
        endLine   = 17575; 
    end

    lines = {};
    fid = fopen(fileName,'r');
    
    while ~feof(fid)
        lines{end+1} = fgetl(fid);
    end
    
    fclose(fid);
    
    % For each line go through split based on csv and assign to table
    variableNames =  {'JDTDB', 'CalendarDate','X','Y','Z','VX','VY','VZ','LT','RG','RR'};
    for ii = endLine:-1:startLine
        tmp = strsplit(lines{ii},',');
        JDTDB(ii,1) = str2double(tmp{1});
        CDATE{ii,1} = tmp{2};
        EPHEM(ii,:) = str2double(tmp(3:11));
    end
    
    tab = table();
    tab.(variableNames{1})  = JDTDB(startLine:endLine);
    tab.(variableNames{2})  = CDATE(startLine:endLine);
    tab.(variableNames{3})  = EPHEM(startLine:endLine,1);
    tab.(variableNames{4})  = EPHEM(startLine:endLine,2);
    tab.(variableNames{5})  = EPHEM(startLine:endLine,3);
    tab.(variableNames{6})  = EPHEM(startLine:endLine,4);
    tab.(variableNames{7})  = EPHEM(startLine:endLine,5);
    tab.(variableNames{8})  = EPHEM(startLine:endLine,6);
    tab.(variableNames{9})  = EPHEM(startLine:endLine,7);
    tab.(variableNames{10}) = EPHEM(startLine:endLine,8);
    tab.(variableNames{11}) = EPHEM(startLine:endLine,9);

end