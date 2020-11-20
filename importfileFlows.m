function LinkCountyFlows = importfileFlows(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  LINKCOUNTYFLOWS = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the numeric data.
%
%  LINKCOUNTYFLOWS = IMPORTFILE(FILE, SHEET) reads from the specified
%  worksheet.
%
%  LINKCOUNTYFLOWS = IMPORTFILE(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  LinkCountyFlows = importfile("C:\Users\mgkolias\Dropbox\DataMining COMP8118\datamining\LinkCountyFlows.xlsx", "Sheet1", [2, 13586]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 18-Nov-2020 16:19:37

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [2, 13586];
end

%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 34);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":AH" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["FID_etrims", "ID_NUMBER", "NBR_TENN_C", "NBR_RT2", "YR_TRFC", "AADT", "SUTrucks", "MUTr", "TotTr", "Shape_Leng", "xStart", "xEnd", "yStart", "yEnd", "FID_timezn", "AREA", "PERIMETER", "TIMEZNP020", "TIMEZONE", "GMT_OFFSET", "SYMBOL", "Shape_Le_1", "dailyAve", "dailyMax", "FID_TN_Counties", "NAME", "STATE_NAME", "STATE_FIPS", "CNTY_FIPS", "FIPS", "AREA_1", "POP2000", "POP2001", "Shape_Length"];
opts.SelectedVariableNames = ["FID_etrims", "ID_NUMBER", "NBR_TENN_C", "NBR_RT2", "YR_TRFC", "AADT", "SUTrucks", "MUTr", "TotTr", "Shape_Leng", "xStart", "xEnd", "yStart", "yEnd", "FID_timezn", "AREA", "PERIMETER", "TIMEZNP020", "TIMEZONE", "GMT_OFFSET", "SYMBOL", "Shape_Le_1", "dailyAve", "dailyMax", "FID_TN_Counties", "NAME", "STATE_NAME", "STATE_FIPS", "CNTY_FIPS", "FIPS", "AREA_1", "POP2000", "POP2001", "Shape_Length"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Import the data
LinkCountyFlows = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":AH" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    LinkCountyFlows = [LinkCountyFlows; tb]; %#ok<AGROW>
end

%% Convert to output type
LinkCountyFlows = table2array(LinkCountyFlows);
end