% clfp khz = 1.375
% cmacro khz = 1.375


%% resave files

madir = dir('*.mat');
madirn = {madir.name};

files2s = {'CLFP_01','CLFP_02','CLFP_03','CLFP_04',...
    'CMacro_LFP_01','CMacro_LFP_02','CMacro_LFP_03',...
    'CMacro_LFP_04'};

for mi = 1:length(madirn)
    
    tm = madirn{mi};
    tmat = matfile(tm);
    
    load(tmat.Properties.Source,files2s{:})
    
    saveLOC = 'C:\Users\johna\Desktop\testSleepLFP\reducedfiles\';
    saveNAME = [saveLOC , tm];
    
    save(saveNAME,files2s{:})
    
    clearvars(files2s{:})
    
end

%% Load and plot

madir2 = dir('*.mat');
madirn2 = {madir2.name};

for mi2 = 1:length(madirn2)
    
    tm2 = madirn2{mi2};
    load(tm2,files2s{:})
    t = tiledlayout(4,1);
    t.TileSpacing = 'compact';
    t.Padding = 'compact';
    for i = 1:4
        
        tempLFP = eval(['CLFP_0',num2str(i)]);
        
        % Trim file
        clfpt = tempLFP(round(length(tempLFP)/2):end);
        
        % Tile 1
        nexttile
        plot(clfpt)
        
        % Detrend
        dclfp = double(clfpt);
        dtc = detrend(dclfp);
        
        % Notch filter
        d = designfilt('bandstopiir','FilterOrder',2, ...
            'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
            'DesignMethod','butter','SampleRate',1375);
        
        dtcN = filter(d,dtc);
        
        [y1 , b1] = bandpass(dtcN,[2 100],1375);
        
        pspectrum(y1 ,1375)
        xlim([0 80])
        title(['CLFP',num2str(i)])
        ylabel('psec');
    end
    lfpSl = 'C:\Users\johna\Desktop\testSleepLFP\reducedfiles\lfpFigs\';
    lfpS2 = [lfpSl , tm2 , 'fig.png'];
    saveas(gcf,lfpS2);
    
    
end











