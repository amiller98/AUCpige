function AUC_report(folderDir)
%% Input Currents

% which number run does each current correspond to
% chronological order please

%% File set up
set(0,'DefaultFigureWindowStyle','docked')

d = struct2cell(dir([fullfile(folderDir),'/*.spe']));
nameList = d(1,:);

file_count = numel(nameList);

%% Information on peaks of interest

energiesOI = [109 197 511 770];

AUCallfiles = [];
AUCerrors = [];
realtimes = [];
livetimes = [];
datetimes = [];

%% Pull Count Rates for Peaks Of Interest
for i=1:file_count
    %clf
    figure('Name',string(nameList(i)));
    file = string(fullfile(folderDir, nameList(i)));
    spectrum = readspe(file);
%% Adjust Energy Calibration for each
    [~, ArXrayLoc] = max(spectrum.counts(80:130));
    [~, NGammaLoc] = max(spectrum.counts(7500:end));

    ArXrayLoc = ArXrayLoc + 80;
    NGammaLoc = NGammaLoc + 7500;

    NGammaEnergy = 2313; %keV
    ArXrayEnergy = 29.55; %keV

    energyCalib = polyfit([NGammaEnergy,ArXrayEnergy],[NGammaLoc, ArXrayLoc],1);

    peaksOI = floor(polyval(energyCalib, energiesOI));
%% proceed
    [AUC, AUCerrorSingle, realtimeSingle, livetimeSingle] = get_AUC(spectrum,peaksOI);

    AUCallfiles = [AUCallfiles ; AUC];
    AUCerrors = [AUCerrors ; AUCerrorSingle];
    realtimes = [realtimes; realtimeSingle];
    livetimes = [livetimes; livetimeSingle];
    datetimes = [datetimes ; spectrum.time];
    title(nameList(i));
end
grid on
%% Continuing Analysis
dataTable = AUCallfiles(:,:);

fileName = nameList;

%% Formatting Output
splitDir = split(folderDir,{'\' '/'});
properFileName = [splitDir{end,1} '_aucPIGERep.xlsx'];
file = string(fullfile(folderDir, properFileName));
header = ["Filename" "real(s)" "live(s)" "datetime" string(energiesOI)];
if isrow(fileName)
    fileName = fileName';
end
writematrix(header,file,'Sheet',1,'Range','A1');
writecell(fileName,file,'Sheet',1,'Range','A2');
writematrix(realtimes,file,'Sheet',1,'Range','B2');
writematrix(livetimes,file,'Sheet',1,'Range','C2');
writematrix(datetimes,file,'Sheet',1,'Range','D2');
writematrix(dataTable,file,'Sheet',1,'Range','E2');

writematrix(["file name" string(energiesOI)],file,'Sheet',2,'Range','D1');
writecell(fileName,file,'Sheet',2,'Range','D2');
writematrix(AUCerrors,file,'Sheet',2,'Range','E2');

end