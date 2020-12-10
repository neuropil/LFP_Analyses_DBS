function [firingrate_binned, spikes_smooth, event_spiketimes]=spikehisto_GoAntiGo(category, trials_index, events, cluster_class, LFPSamplerate, Offset, Duration,  Binsize, spikecountMean_baseline, spikecountSTD_baseline, align_RT ,zscore, plotthings)
% Written by Zar Zavala March 2015.






%% count spikes for events

if plotthings==1; figure; end
bins=-Offset:Binsize:-Offset+Duration;
bins_phase=-pi:pi/16:pi;
firingrate_binned=zeros(size(trials_index,2), size(bins,2)-1); % create empty vector that will contain the spike count for all bins;
spikes_smooth=zeros(size(trials_index,2), Duration*LFPSamplerate+1);
event_spiketimes=cell(length(trials_index),1);
for i=1:length(trials_index); % iterate through every event in given category (low conflict correct, etc)
%     if ~mod(i,10); fprintf('trial: %d, ',i); end
    event=events(trials_index(i));
    
    if ~align_RT;  % This is in case you want to align them with movement instead of arrows flashing.
        event_start=event.eegoffset/LFPSamplerate-Offset; %     we want to convert to time in s from LFP sample points which 
    else
        event_start=event.eegoffset/LFPSamplerate+double(event.RT)/1000-Offset; 
    end
        event_end=event_start+Duration;                   %   is why we use LFPsamplerate even for the spike data, which is in seconds in cluster class

    
    
    event_spikesindex=find(event_start<cluster_class(:,2)& cluster_class(:,2)<event_end);% gets the index of all spikes near event. index values range from 1 to the length of the recording in seconds* the spike sampling rate (24kHZ)
    
    if ~align_RT; % This is in case you want to align them with movement instead of arrows flashing.
        event_spiketimes{i}=(cluster_class(event_spikesindex,2)-event.eegoffset/LFPSamplerate)';% gets the times of the spikes near event and finds where they are relative to event onset
    else
        event_spiketimes{i}=(cluster_class(event_spikesindex,2)-(event.eegoffset/LFPSamplerate+double(event.RT)/1000))'; 
    end
    
    if~isempty(event_spiketimes{i});
        % bin the spike times and plot all spikes.
        hist=histc(event_spiketimes{i},bins); 
        if ~zscore
            firingrate_binned(i,:)=hist(1:end-1)/Binsize;% the end-1 is because histc creates an extra bin for values that fall right on the end of the sample period.
        else
            firingrate_binned(i,:)=(hist(1:end-1)/Binsize-spikecountMean_baseline)/spikecountSTD_baseline;% This line gets the z score if it's suppose to
        end
        if plotthings==1;
            plot([event_spiketimes{i}; event_spiketimes{i}],[ones(size(event_spiketimes{i}))+(i-1);zeros(size(event_spiketimes{i}))+(i-1)],'k-', 'linewidth', 1); % create rasTer plot
            hold on;
            axis([-Offset (-Offset+Duration) 0 length(trials_index)]);
           % set(gca, 'XTick', [])
        end
        event_spiketimesINDEX=round((event_spiketimes{i}+Offset)*LFPSamplerate)+1; % this converts the time at which the spike fired (from -offset:Duration) into an
        spikes=zeros(Duration*LFPSamplerate+1,1);
        spikes(event_spiketimesINDEX)=1;
        spikes_smooth(i,:)=smoothFiringRate(spikes,LFPSamplerate); % get a non binned spike firing estimate
    end;
end


 


