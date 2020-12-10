function[smoothFR] = smoothFiringRate(spikes,samplerate)
%Kareem sent me this via email on April 8 2013
%smoothFiringRate    get kernel-smoothed firing rate


%jrm   11-27-07  wrote it.
%jrm   12-7-07   fixed units (multiply by samplerate)

kernelWidth = 50; %ms
windSigma = samplerate*kernelWidth/1000;
wind = normpdf(linspace(-samplerate/2,samplerate/2,samplerate),0,windSigma); wind = wind./sum(wind);
smoothFR = conv(spikes,wind);
smoothFR = smoothFR([samplerate/2:end-(samplerate/2)]);


%multiply by samplerate to get instantaneous firing rate at each sample
smoothFR = smoothFR*samplerate;

% smoothFR=[0; diff(smoothFR)]; % uncomment to look at the derivative of the firing rate instead
