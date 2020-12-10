close all; clear all;
% homeDir = '/Volumes/shares/FRNU/dataworking/dbs/SeqMemdata/'\;
homeDir = 'Users/andytek/Desktop/SeqMemRawdata/';

filenames=filenames_SequenceMem('macroSTN');% must set to 'ALL', or 'ALLSTN', or 'macroSTN', or 'microSTN', or 'Frontal', or 'Lateral'

%option parameters
normalize=1; % set to 1 to plot the data as % change from baseline. set to 0 to plot raw power. 

Duration=2.000; % time duration of each event in seconds
Offset=.500;% Offset is the time you want to go back by. ie. Offset=.500; means 500ms BEFORE event began will be start of each trial

LFPSamplerate=1000;
Buffer=1000; waveletwidth=6;
filelength=LFPSamplerate*Duration;
if normalize==1
    Offset_cue=.375;
    Duration_cue=0.250;
end
time=-(Offset-1/LFPSamplerate):1/LFPSamplerate:(-Offset+Duration); % set the time axis
freqs=2.^((8:54)/8); 

%set up file output names
label='_targVSdist';
percnorm='';if normalize==1; percnorm='_percnorm'; end
powerlabel = ['waveletpower_induced&evoked' percnorm label '.mat']; 

%% LOOK AT PHASE DATA

tstart=tic;
for i=1:length(filenames)
    i
   for j=1:length(filenames(i).channelnames)
        close all
       
        subj=filenames(i).channelnames{j}(1:6);
        session=filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j}, 'sess','end')+1);
        channel=filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j},'\.'):end)

        %load Events.mat
        load([homeDir subj '/behavioral/session_' session '/events.mat']);
        
        % get the correct trials for low and high conflict
        targ_correct=find([events.correct]==1 & [events.target]==1 | [events.correct]==2 & [events.target]==0 ); 
        dist_correct=find([events.correct]==1 & [events.target]==0 | [events.correct]==2 & [events.target]==1 ); 
        events_low=events(targ_correct);
        events_high=events(dist_correct);
        events_joint=[events_low, events_high];
    
        % load the EEG data         
        filename=[homeDir subj '/ecogLFPdata_rereferenced/' events(1).eegfile channel];
        fchan_reref = fopen(filename,'r','l');
        LFP_wholerecordings=fread(fchan_reref,inf,'int16');
        fclose(fchan_reref);
        LFP_joint=zeros(length(events_joint), Duration*1000+2*Buffer);
        for event=1:length(events_joint)
            startindex=events_joint(event).eegoffset-Offset*1000-Buffer;
            endindex=startindex-1+Duration*1000+2*Buffer;
            LFP_joint(event,:)=LFP_wholerecordings(startindex:endindex);
        end
        % filter out 60 Hz noise
        LFP_joint=buttfilt(LFP_joint,[59 61], LFPSamplerate, 'stop', 2);
        
        %get the phase and power
        [phaseMat_joint, powerMat_joint]=multiphasevec3(freqs,LFP_joint,LFPSamplerate,waveletwidth);
        phaseMat_joint = squeeze(phaseMat_joint(:,:,Buffer+1:end-Buffer));
        powerMat_joint = squeeze(powerMat_joint(:,:,Buffer+1:end-Buffer));
        
        % clean the data of artifacts
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(filenames(i).channelnames{j}, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 10, find(freqs>1.9 & freqs<8.1),0);
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(filenames(i).channelnames{j}, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 25, find(freqs>7.9 & freqs<32.1),0);
        [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(filenames(i).channelnames{j}, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 50, find(freqs>31.9 & freqs<108.1),0); 
 
        % reassign the clean data to events. 
        [~,lowtrials_clean] = intersect([events_joint.mstime],[events_low.mstime]);
        [~,hightrials_clean] = intersect([events_joint.mstime],[events_high.mstime]);
        events_low=events_joint(lowtrials_clean);    powerMat_low=powerMat_joint(lowtrials_clean,:,:);   phaseMat_low=phaseMat_joint(lowtrials_clean,:,:);
        events_high=events_joint(hightrials_clean);  powerMat_high=powerMat_joint(hightrials_clean,:,:); phaseMat_high=phaseMat_joint(hightrials_clean,:,:);

        %get baseline power and normalize
        if normalize==1
            startindex_cue=(Offset-Offset_cue)*1000;
            endindex_cue=startindex_cue+Duration_cue*1000;
            powerMat_cue=[powerMat_low(:,:,startindex_cue:endindex_cue); powerMat_high(:,:,startindex_cue:endindex_cue)];
            
            powerMean_cue=mean(squeeze(mean( powerMat_cue,3)));
            powerSTD_cue=std(squeeze(mean( powerMat_cue,3)));
            powerMat_low=bsxfun(@rdivide,bsxfun(@minus,powerMat_low,powerMean_cue),powerMean_cue);
            powerMat_high=bsxfun(@rdivide,bsxfun(@minus,powerMat_high,powerMean_cue),powerMean_cue);
        end
        powerMean_low=squeeze(mean(powerMat_low,1));
        powerMean_high=squeeze(mean(powerMat_high,1));
       
        imagescale=[-.75 .75]; 
        figure;
        pcolor(time, freqs,powerMean_low); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title('target trials mean');
        figure;
        pcolor(time, freqs, powerMean_high); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title('distract trials mean');
        figure;
        pcolor(time, freqs, powerMean_high-powerMean_low); %colorbar; 
        set(gca,'CLim',imagescale); 
        shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
        title('distract - target mean');

%         % save everything
%         numlow=length(events_low);% 
%         numhigh=length(events_high);% 
%         outputDir=[homeDir filenames(i).channelnames{j} '_power/' ]; if ~exist(outputDir,'dir'); mkdir(outputDir); end 
%         save([outputDir powerlabel], 'powerMean_low','powerMean_high', 'freqs', 'numlow', 'numhigh');
    end
end
toc(tstart)
fprintf('\nAll Done\n')

