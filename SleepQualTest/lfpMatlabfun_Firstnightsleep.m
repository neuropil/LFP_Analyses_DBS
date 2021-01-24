
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
for fi = 1:3
    
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


%%

TT = timetable(transpose(double(allChan.D0)),'SampleRate',1375,'VariableName',["DO"]);
TT.D1 = transpose(double(allChan.D1));
TT.D2 = transpose(double(allChan.D2));
TT.D3 = transpose(double(allChan.D3));

%%
stackedplot(TT)




%%

pspectrum(TT,"FrequencyLimits",[0 50])
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
for fi = 1:length(fileLIST)
    
    curFile = fileLIST{fi};
    
    % 10
    load(curFile,'CEEG_2___10___EEG_2___10');
    plot(CEEG_2___10___EEG_2___10)
    pause
    close all
    
    ceegD = double(CEEG_2___10___EEG_2___10);
    
    csMean = mean(ceegD);
    csSTD = std(ceegD);
    csThr = csMean + (csSTD*9);
    
    if sum(ceegD > csThr) ~= 0
        continue
    else
        timE = 1;
    end
    
    countT = countT + tmpN;
    
    clear('CEEG_2___10___EEG_2___10');
    
    
    
end
