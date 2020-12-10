%Note, errors on like 36 for pt 10 as of 4/25/19


close all; 
clear all;

% homeDir = '/Volumes/shares/FRNU/dataworking/dbs/SeqMemdata/';
% Written by Zar Zavala Dec 2017
homeDir = 'Users/andytek/Desktop/SeqMemRawdata/';


STNs=filenames_SequenceMem_spiking;
STNs(cellfun('isempty',{STNs.sessions}))=[];

LFPSamplerate=1000; %1502.40385532379; 
Duration=2.000; % time duration in s
Offset=.500;% Offset is the time you want to go back by. ie. Offset=.100; means 100ms BEFORE event began
time=-(Offset-1/LFPSamplerate):1/LFPSamplerate:(-Offset+Duration); % set the time axis
Binsize=.050; %how wide (in seconds) do you want each bin to be. 
convBuffer=.250; % this is the buffer I will use for the convolution data. I will drop this buffer before saving the data. 
Offset=Offset+convBuffer; 
Duration=Duration+2*convBuffer; 

%% 
tstart=tic;
for patient=1:length(STNs);
    for sess=1:length(STNs(patient).sessions)
patient 
        close all; 
        subj=STNs(patient).sessions(sess).subj;
        T_date = STNs(patient).sessions(sess).T_date;
        traj=STNs(patient).sessions(sess).traj;
        dataFile = STNs(patient).sessions(sess).dataFile;
        session=STNs(patient).sessions(sess).session;
        recordedevents=STNs(patient).sessions(sess).recordedevents;
        micElec_selected=STNs(patient).sessions(sess).micElec_selected;

        %get spike data
        cluster_class=csvread([homeDir subj '/spikingdata/' [subj '_' T_date traj '_' dataFile] '/chan_' num2str(micElec_selected) '/' subj '_' T_date traj '_' dataFile '.00' num2str(micElec_selected) '_plexon.txt']);
        if STNs(patient).sessions(sess).cluster_selected 
            cluster_selected=STNs(patient).sessions(sess).cluster_selected;
            cluster_class=cluster_class(find(cluster_class(:,1)==cluster_selected),:); % This is in case you only want to look at one cluster
        else
            cluster_selected=123; % this is for when I save the file.
        end

        %load Events.mat
        load([homeDir subj '/behavioral/session_' session '/events.mat']);

        % get the correct trials for low and high conflict
        targ_correct=find([events.correct]==1 & [events.target]==1 | [events.correct]==2 & [events.target]==0 ); 
        dist_correct=find([events.correct]==1 & [events.target]==0 | [events.correct]==2 & [events.target]==1 ); 
        
        %get spike count average for orientation cue for all response trials.  Will be used to calculate Z scores later
        [binnedFR_targ, spikes_smooth_targ, event_spiketimes_targ]   =spikehisto_GoAntiGo('Target', targ_correct, events, cluster_class, LFPSamplerate,Offset, Duration, Binsize, [], [], 0, 0,  1); 
        [binnedFR_dist, spikes_smooth_dist, event_spiketimes_dist]   =spikehisto_GoAntiGo('Distract', dist_correct, events, cluster_class, LFPSamplerate,Offset, Duration, Binsize, [], [], 0, 0, 1); 

        spikeMat_low_withbuffer=spikes_smooth_targ(:,(convBuffer*LFPSamplerate+1):(end-convBuffer*LFPSamplerate-1)); 
        spikeMat_high_withbuffer=spikes_smooth_dist(:,(convBuffer*LFPSamplerate+1):(end-convBuffer*LFPSamplerate-1)); 
   
        figure; plot(time, mean(spikeMat_low_withbuffer),'b')
        hold on; plot(time, mean(spikeMat_high_withbuffer),'r')
   
%         %save smoothed spiking data
%         label='_sortspikeswithbuffer_targVSdist'
%         outputDir=[homeDir subj '/analysis_sortspikes/'];if ~exist(outputDir); mkdir(outputDir); end
%         save([outputDir 'sess' session '_C.00' num2str(micElec_selected) label '.mat'],'spikeMat_low_withbuffer', 'spikeMat_high_withbuffer');
    end
end