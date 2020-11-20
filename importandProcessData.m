% requires that the public and private parking lots are already in the
% postgres database
% requires the 00* files with raw gps data!!



%% Private Parking Lost
clear all;
datasource = "datamining";
username = "postgres";
password = "postgres";
conn = database(datasource,username,password);

% import data
n=17;
tic;
 str="DROP TABLE if exists Transearch2012Table;";
    execute(conn,str{1});
    
    
    str=["CREATE TABLE Transearch2012Table "...
"(OBJECTID double precision, year1 double precision,  "...
 "Origin_region double precision, destination_region double precision, "... 
 "SCTG3 double precision, Equipment text, Trade_Type text,  "...
" Mode1 double precision, Tons double precision, Units double precision,  "...
 "Value1 double precision, Average_Miles double precision,  "...
 "First_NOde double precision, Lat_Node double precision,  "...
 "From_FIPS double precision, To_FIPS double precision, Entry_Road text, Exit_Road text);"]';

    execute(conn,[str{1} str{2} str{3} str{4} str{5} str{6} str{7} str{8}]);

for i=[1:n]
    disp(['Importing ' num2str(i-1) ' dataset out of ' num2str(n-1)]);
   
    if i<11
        str=["COPY Transearch2012Table (OBJECTID, year1, "...
            "Origin_region, destination_region, "...
            "SCTG3, Equipment, Trade_Type, Mode1," ...
            "Tons, Units, Value1, Average_Miles, First_Node, "...
            "Lat_Node, From_FIPS, To_FIPS, Entry_Road, Exit_Road) "...
            "FROM 'C:\datamining\Transearch2012.00" num2str(i-1) "' DELIMITERS ',' CSV HEADER;"];
    else
        str=["COPY Transearch2012Table (OBJECTID, year1, "...
            "Origin_region, destination_region, "...
            "SCTG3, Equipment, Trade_Type, Mode1," ...
            "Tons, Units, Value1, Average_Miles, First_Node, "...
            "Lat_Node, From_FIPS, To_FIPS, Entry_Road, Exit_Road) "...
            "FROM 'C:\datamining\Transearch2012.0" num2str(i-1) "' DELIMITERS ',' CSV HEADER;"];
    end
    
    execute(conn,[str{1} str{2} str{3} str{4} str{5} str{6} str{7} str{8}]);
    
end

p="DROP TABLE IF EXISTS productions;";execute(conn,p);	  
p="create table productions as (select * from  Transearch2012Table where origin_region>47000 and origin_region<48000 AND mode1>=4 and mode1<=7);";
execute(conn,[p{1}]);

p="DROP TABLE IF EXISTS attractions;";execute(conn,p);	  
p="create table attractions as (select * from  Transearch2012Table where destination_region>47000 and destination_region<48000 AND mode1>=4 and mode1<=7);";
execute(conn,[p{1}]);

%% create productions and attractions
currentFolder = pwd;

delete 'C:\temp\productions.csv';
p="COPY productions TO 'C:\temp\productions.csv' DELIMITER ',' CSV HEADER;";execute(conn,p);
str=[pwd '\productions.csv'];

movefile('C:\temp\productions.csv', str);

delete 'C:\temp\attractions.csv';
p="COPY attractions TO 'C:\temp\attractions.csv' DELIMITER ',' CSV HEADER;";execute(conn,p);
str=[pwd '\attractions.csv'];
movefile('C:\temp\attractions.csv', str);

%% create subtotals productions and attractions by origin or destination and sctg3 code
p="DROP TABLE IF EXISTS productionsSubtotals;";execute(conn,p);	  
execute(conn,[p{1}]);

str=["create table productionsSubtotals as SELECT " ...
    "origin_region, sctg3, " ...
    " SUM(tons) as subTons, " ...
    " SUM(units) as subUnits, " ...
    " SUM(value1) as subValue, " ...
    " SUM(average_miles) as subAveMiles " ...
"FROM productions GROUP BY origin_region,sctg3 ORDER BY origin_region, sctg3;"];

execute(conn,[str{1} str{2} str{3} str{4} str{5} str{6} str{7}]);

delete 'C:\temp\productionSub.csv';
p="COPY productionsSubtotals TO 'C:\temp\productionSub.csv' DELIMITER ',' CSV HEADER;";execute(conn,p);
str=[pwd '\productionSub.csv'];
movefile('C:\temp\productionSub.csv', str);

p="DROP TABLE IF EXISTS attractionsSubtotals;";execute(conn,p);	  
execute(conn,[p{1}]);

str=["create table attractionsSubtotals as SELECT " ...
    " destination_region, sctg3, " ...
    " SUM(tons) as subTons, " ...
    " SUM(units) as subUnits, " ...
    " SUM(value1) as subValue, " ...
    " SUM(average_miles) as subAveMiles " ...
"FROM attractions GROUP BY destination_region,sctg3 ORDER BY destination_region, sctg3;"];

execute(conn,[str{1} str{2} str{3} str{4} str{5} str{6} str{7}]);

delete 'C:\temp\attractionsSubtotals.csv';

p="COPY attractionsSubtotals TO 'C:\temp\attractionsSub.csv' DELIMITER ',' CSV HEADER;";execute(conn,p);
str=[pwd '\attractionsSub.csv'];
movefile('C:\temp\attractionsSub.csv', str);

clearvars
attractionsSub = importfileAttractionsSub( 'C:\Users\mgkolias\Dropbox\DataMining COMP8118\datamining\attractionsSub.csv');

productionSub = importfileProductionsSub('C:\Users\mgkolias\Dropbox\DataMining COMP8118\datamining\productionSub.csv' );

save commFlowsSubTotals
currentFolder = pwd;
str=[pwd '\LinkCountyFlows.xlsx'];

LinkCountyFlows = importfileFlows(str, 'Sheet1');
% FID_etrims, county code i.e., fips, GPS average, ETRIMS truck flow
LinkCountyFlows=[LinkCountyFlows(:,1)  LinkCountyFlows(:,30)  LinkCountyFlows(:,23)  LinkCountyFlows(:,9)] ;

countyIDs=unique(LinkCountyFlows(:,2));
for i=1:length(countyIDs)
    t=find(LinkCountyFlows(:,2)==countyIDs(i));
    for j=1:length(t)
       LinkCountyFlows(t(j),5)= LinkCountyFlows(t(j),3) /sum(LinkCountyFlows(t,3));        
    end   
end
save FullDataSet attractionsSub productionSub LinkCountyFlows countyIDs

clearvars; load FullDataSet

% unique sctg3 for productions
sctgUNIQUE=unique([productionSub(:,2);attractionsSub(:,2)]);
for i=1:length(LinkCountyFlows(:,1))
    % find which sctg3 productions belong to this fips
    t=find(LinkCountyFlows(i,2)==productionSub(:,1));
    productionSubSCTG=productionSub(t,:);
    for j=1:length(productionSubSCTG)
        if isempty(productionSubSCTG(j,2)==sctgUNIQUE)==0
            r=find(sctgUNIQUE==productionSubSCTG(j,2));
            produLinksTons(i,r)=LinkCountyFlows(i,end)*productionSubSCTG(j,3);
            produLinksUnits(i,r)=LinkCountyFlows(i,end)*productionSubSCTG(j,4);
            produLinksValue(i,r)=LinkCountyFlows(i,end)*productionSubSCTG(j,5);
            produLinksMiles(i,r)=LinkCountyFlows(i,end)*productionSubSCTG(j,6);
        end
    end
end

sctgA=unique(attractionsSub(:,2));
for i=1:length(LinkCountyFlows(:,1))
    % find which sctg3 productions belong to this fips
    t=find(LinkCountyFlows(i,2)==attractionsSub(:,1));
    attractionsSubSCTG=attractionsSub(t,:);
    for j=1:length(attractionsSubSCTG)
        if isempty(attractionsSubSCTG(j,2)==sctgUNIQUE)==0
            r=find(sctgUNIQUE==attractionsSubSCTG(j,2));
            attrLinksTons(i,r)=LinkCountyFlows(i,end)*attractionsSubSCTG(j,3);
            attrLinksUnits(i,r)=LinkCountyFlows(i,end)*attractionsSubSCTG(j,4);
            attrLinksValue(i,r)=LinkCountyFlows(i,end)*attractionsSubSCTG(j,5);
            attrLinksMiles(i,r)=LinkCountyFlows(i,end)*attractionsSubSCTG(j,6);
        end
    end
end


save FullDataSet

clearvars;
load FullDataSet

% X=[(produLinksTons+attrLinksTons)/max(max((produLinksTons+attrLinksTons))) ...
%  (attrLinksValue+produLinksValue)/max(max((attrLinksValue+produLinksValue)))];
 X=[(produLinksTons+attrLinksTons) ...
  (attrLinksValue+produLinksValue)];
Y=[LinkCountyFlows(:,3)];

% beta = mvregress(X,Y);
% mdl = stepwiselm(X,Y);
% B = ridge(Y,X,-5:1:5);
save FullDataSet

% Prepare final table R for. Used as input for Regression Learner App
truckLowerBound=50;
truckUpperBound=8000;
X=X((Y>truckLowerBound & Y<=truckUpperBound ),:);
Y=Y((Y>truckLowerBound & Y<=truckUpperBound),:);
R=[Y X];
