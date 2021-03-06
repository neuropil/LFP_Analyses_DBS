
mdir = dir('*.mat');
mdir2 = {mdir.name};
fileLIST = mdir2;

matob = matfile('F210110-0001.mat');
varlist = who(matob);
eeglist = varlist(contains(varlist,'CEEG'));

chanNum = 1:16;
chanLab = {'EEG','EEG','LFP','EEG','EEG','EEG','LFP','EEG',...
    'EEG','LFP','EOG','EOG','EMG','EMG','EMG','LFP'};
chanID = {'F3','Fz','D0','A1','C3','Cz','D1','A2','O1','D2',...
    'EOG1','EOG2','Chin1','Chin2','ChinZ','D3'};

labTab = table(chanNum,chanLab,chanID,'VariableNames',{'Number',...
    'Label','ID'});

chanTYPE = {'EEG','LFP','EOG','EMG'};
% Combine first 3 files
allChan = struct;
for fi = 1:10
    
    curFile = fileLIST{fi};
    
    load(curFile,eeglist{:});
    
    for ci = 1:length(chanTYPE)
        curCHAN = chanTYPE{ci};
        % Get channel list
        chanNums = labTab.Number(ismember(labTab.Label,curCHAN));
        chanIDS = labTab.ID(ismember(labTab.Label,curCHAN));
        
        eeglNum1 = cellfun(@(x) strsplit(x,'_'), eeglist,'UniformOutput',false);
        eeglNum2 = cellfun(@(x) str2double(x{3}), eeglNum1, 'UniformOutput', true);
        
        for ni = 1:length(chanNums)
            
            tmpChan = ismember(eeglNum2,chanNums(ni));
            tmpRows = eeglist(tmpChan);
            rawRow = tmpRows{1};
            
            dat1 = eval(rawRow);
            
            if ~isfield(allChan,chanIDS{ni})
                allChan.(chanIDS{ni}) = dat1;
            else
                allChan.(chanIDS{ni}) = [allChan.(chanIDS{ni}) , dat1];
            end
            
        end

    end
    
end

%% LFP Data
lfpfieldNames = {'D0','D1','D2','D3'};
allfieldNames = fieldnames(allChan);
lfpdata = rmfield(allChan, allfieldNames(~ismember(allfieldNames,lfpfieldNames)));

matLFP = zeros(4,length(lfpdata.D0));
for mi = 1:4
    allChan.(lfpfieldNames{mi}) = double(allChan.(lfpfieldNames{mi}));
    matLFP(mi,:) =  allChan.(lfpfieldNames{mi});
end

comGndR = mean(matLFP);
for cgf = 1:4
    allChan.(lfpfieldNames{cgf}) = allChan.(lfpfieldNames{cgf}) - comGndR;
end

%%

TT = timetable(transpose(allChan.D0),'SampleRate',1375,'VariableName',"DO");
TT.D1 = transpose(double(allChan.D1));
TT.D2 = transpose(double(allChan.D2));
TT.D3 = transpose(double(allChan.D3));

%%
stackedplot(TT)

%%

pspectrum(TT,"FrequencyLimits",[0 100])
legend(["D0","D1","D2","D3"])




%%
countT = 0;
for fi = 1:length(fileLIST)
    
    curFile = fileLIST{fi};
    
    
    
    load(curFile,'CDIG_IN_1_TimeBegin');
    
    if ~exist('CDIG_IN_1_TimeBegin','var')
        continue
    else
        tmpN = length(CDIG_IN_1_TimeBegin');
    end
    
    countT = countT + tmpN;
    
    clear('CDIG_IN_1_TimeBegin');
    
    
    
end



%%
wholeFle = [];
for ffi = 33:length(fileLIST)
    curFile = fileLIST{ffi};
    load(curFile,'CEEG_2___10___EEG_2___10');
    ceegD = double(CEEG_2___10___EEG_2___10);
    
    wholeFle = [wholeFle ,ceegD];
    
end

%%
plot(wholeFle)

%%
a = peakseek(wholeFle , 25000, 3500);
d = diff(a);

%%
close all
plot(wholeFle)
hold on
xline(a(10))
xline(a(11))
xline(a(12))
xline(a(13))


%%
a(117) = [];

%%
close all
starTs = 1:2:162;
stopS = 2:2:162;

minSize = 1375*60;

buffer = 4500;

beforeStim = zeros(length(starTs),minSize);
afterStim = zeros(length(starTs),minSize);

for si = 50:length(starTs) - 1
   
    tmpStart1 = a(starTs(si)) - buffer - minSize;
    tmpStart2 = a(starTs(si)) - buffer - 1;
    
    beforeStim(si,:) = wholeFle(tmpStart1:tmpStart2);
    
    tmpStop1 = a(stopS(si)) + buffer;
    tmpStop2 = a(stopS(si)) + buffer + minSize - 1;
    
    afterStim(si,:) = wholeFle(tmpStop1:tmpStop2);

end

meanBF = transpose(mean(beforeStim));
meanAF = transpose(mean(afterStim));

sTTm = timetable(meanBF,'SampleRate',1375,'VariableName',"BF");
sTTm.AF = meanAF;

% stackedplot(sTTm)

figure;
pspectrum(sTTm,"FrequencyLimits",[0 50])
legend(["BeforeStim","AfterStim"])



%%
figure;
pspectrum(sTTm.AF , sTTm.Time , "spectrogram", "FrequencyLimits",[10 40], "MinThreshold",-20)
figure;
pspectrum(sTTm.BF , sTTm.Time , "spectrogram", "FrequencyLimits",[10 40], "MinThreshold",-20)

%%
close all
plot(wholeFle)
hold on
xline(a(117))


%%

for ai = 1:163
    xline(a(ai))
end

%%
[~,locations] = findpeaks(abCee,'MinPeakDistance',100);


%%

firstF = 0;
outT = 0;
stimStart = 33;
testDat = zeros(length(33:length(fileLIST)),1);
countT = 1;
for fi = 33:length(fileLIST)
    
    curFile = fileLIST{fi};
    
    % 10
    load(curFile,'CEEG_2___10___EEG_2___10');
    plot(CEEG_2___10___EEG_2___10)
    
    ceegD = double(CEEG_2___10___EEG_2___10);
    
    csMean = mean(ceegD);
    csSTD = std(ceegD);
    csThr = csMean + (csSTD*4);
    
    % Absolute value
    abCee = abs(ceegD);
    % Convert below threshold to 0
    abCee(ceegD < csThr) = 0;
    % find peaks
    
    [~,locations] = findpeaks(abCee,'MinPeakDistance',100);
    
    testDat(countT) = numel(locations);
    countT = countT + 1;
    
    firstF = fi;
    outT = csThr;
    yline(csThr)
    
    pause
    close all
    
    %     countT = countT + tmpN;
    
    %     clear('CEEG_2___10___EEG_2___10');
    
    
    
end

