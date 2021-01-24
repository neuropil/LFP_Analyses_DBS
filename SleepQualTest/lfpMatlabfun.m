% Task 1
% [c,lags] = xcorr(harp.Signal,wanc.Signal);
% 
% stem(lags,c)
% 
% harpDelay = finddelay(harp.Signal,wanc.Signal)


% timetable

% syncronize

% timerange

% stackedplot

% pspectrum
% pspectrum(quakes,"FrequencyLimits",[0 1])
% [p , f] = pspectrum(quakes)
% semilogx(f,p)
% semilogx(f,db(p,"power"))
% pspectrum(quakes.WANC,quakes.Time,"spectrogram")
% pspectrum(quakes.WANC , quakes.Time , "spectrogram", "FrequencyLimits",[2 10])
% pspectrum(quakes.WANC , quakes.Time , "spectrogram", "FrequencyLimits", [2 10] , "MinThreshold",-50)
% cwt(quakes.WANC , 1/0.02 ,"FrequencyLimits",[2 10])
% caxis([0 2])

% lowWANC = lowpass(quakes(:,"WANC"),0.1,"Steepness",0.95);

% [p,f,t] = pspectrum(quakes.WANC,quakes.Time,"spectrogram","FrequencyLimits",[2 10],"MinThreshold",-50)



% pwr = db(psum,"power");
% plot(t,pwr)