%AT on 5/1/19, goal is to leave V0 as the unaltered reference code, this is
%from the Zag paper




function [events_all_clean, powerMat_all_clean, phaseMat_all_clean]=automatedartifacthunter_AT_V0(filename, events_all, powerMat_all, phaseMat_all, time, freqs, Zthresh, freq_indexes, plotdata)
% This is my first attempt at automating the artifact finding process. Feel
% free to improve this later. STD threshold is the zscore above which any
% trial will be cut

% plotdata=1; % plot a before and after spectragram. 
% Zthresh=10; % get rid of any trial with any time period that has a z-score greater then 10
% freq_indexes=find(freqs>1.9 & freqs<8.1); % frequency range used to find artifacts

%sort events and make copy of original
[~, order]=sort([events_all.mstime]);  % I sort it for ploting reasons. I want to see adjacent artifacts if they exists.
events_all=events_all(order); powerMat_all=powerMat_all(order,:,:); phaseMat_all=phaseMat_all(order,:,:);
events_all_clean=events_all; powerMat_all_clean=powerMat_all; phaseMat_all_clean=phaseMat_all; % make copies of the original data
if length(events_all)~=size(powerMat_all,1); keyboard; end; % events all should correspond to the the power given to this function. Make sure it is the case.

%z-score normalize data
powerMean_cue=mean(squeeze(mean( powerMat_all,3)));
powerSTD_cue=std(squeeze(mean( powerMat_all,3)));
powerMat_allnorm=bsxfun(@rdivide,bsxfun(@minus,powerMat_all,powerMean_cue),powerSTD_cue);
freqMat_all=squeeze(mean(powerMat_allnorm(:,freq_indexes,:),2));

if plotdata==1; 
    %% plot each trial's wavelet power at a given frequency
    figure('Position', [100, 500, 2000, 800]); 
    axes('position',[.035 .375 .22 .6]); imagesc(time, 1:length(events_all), freqMat_all); axis xy; colorbar; colormap jet 
    title(sprintf('%s :Wavelet power: %i - %i Hz',filename, round(freqs(freq_indexes(1))),round(freqs(freq_indexes(end)))));
    trialsMean_all=mean(freqMat_all); trialsSTD_all=std(freqMat_all);
    axes('position',[.035 .05 .19 .275]);  shadedErrorBar(time, trialsMean_all,trialsSTD_all/sqrt(size(freqMat_all,1)),{'k', 'linewidth', 3}); hold on;
    axes('position',[.265 .375 .22 .6]);  pcolor(time, freqs, shiftdim(mean(powerMat_allnorm,1),1)); axis xy; colorbar; colormap jet; shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log');
end

%loop through data repeatedly until there are no more outliers
badtrials=find(max(abs(freqMat_all),[],2)>Zthresh);
while ~isempty(badtrials)
    events_all_clean(badtrials)=[]; 
    powerMat_all_clean(badtrials,:,:)=[];
    phaseMat_all_clean(badtrials,:,:)=[]; 
    %% renormalize data
    powerMean_cue=mean(squeeze(mean( powerMat_all_clean,3)));
    powerSTD_cue=std(squeeze(mean( powerMat_all_clean,3)));
    powerMat_all_cleannorm=bsxfun(@rdivide,bsxfun(@minus,powerMat_all_clean,powerMean_cue),powerSTD_cue);
    freqMat_all_clean=squeeze(mean(powerMat_all_cleannorm(:,freq_indexes,:),2));
    badtrials=find(max(abs(freqMat_all_clean),[],2)>Zthresh);
end

% plot the new clean data
if plotdata==1; 
    powerMean_cue=mean(squeeze(mean( powerMat_all_clean,3)));
    powerSTD_cue=std(squeeze(mean( powerMat_all_clean,3)));
    powerMat_all_cleannorm=bsxfun(@rdivide,bsxfun(@minus,powerMat_all_clean,powerMean_cue),powerSTD_cue);
    freqMat_all_clean=squeeze(mean(powerMat_all_cleannorm(:,freq_indexes,:),2));
    %% plot each trial's wavelet power at a given frequency
    axes('position',[.535 .375 .22 .6]); imagesc(time, 1:length(events_all_clean), freqMat_all_clean); axis xy; colorbar; colormap jet 
    title(sprintf('%s :Wavelet power: %i - %i Hz',filename, round(freqs(freq_indexes(1))),round(freqs(freq_indexes(end)))));
    trialsMean_all_clean=mean(freqMat_all_clean); trialsSTD_all_clean=std(freqMat_all_clean);
    axes('position',[.535 .05 .19 .275]);  shadedErrorBar(time, trialsMean_all_clean,trialsSTD_all_clean/sqrt(size(freqMat_all_clean,1)),{'k', 'linewidth', 3}); hold on;
    axes('position',[.785 .375 .22 .6]);  pcolor(time, freqs, shiftdim(mean(powerMat_all_cleannorm,1),1)); axis xy; colorbar; colormap jet; shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log');
end

