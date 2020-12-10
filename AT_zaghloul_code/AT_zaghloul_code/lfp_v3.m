%%AT V3; changes into a fx that works in a manner I'm better able to
%%understand. example input:
%     lfp_v3(n, 'moveInitiation', 'LFP01');


%%AT v2 created 1/22/20; so far code is coming together, will want to break
%%it up into separate functions sometime soon probably
function [] = lfp_v3(caseNumb, epoch, LFPsource)


dbstop if error

%below is for running the LFP code
% clearvars;
% close all;
clc;

% caseNumb = 11;
% % epoch = 'movePreparation';
% epoch = 'moveInitiation';

% LFPsource = 'LFP01';
% LFPsource = 'LFP02';
% LFPsource = 'LFP03';
% LFPsource = 'CMacro_LFP01';
% LFPsource = 'CMacro_LFP02';
% LFPsource = 'CMacro_LFP03';


if  caseNumb == 1
    caseName = 'case01';
elseif caseNumb == 2
    caseName = 'case02';
elseif caseNumb == 3
    caseName = 'case03';
elseif caseNumb == 4
    caseName = 'case04';
elseif caseNumb == 5
    caseName = 'case05';
elseif caseNumb == 6
    caseName = 'case06';
elseif caseNumb == 7
    caseName = 'case07';
elseif caseNumb == 8
    caseName = 'case08';
elseif caseNumb == 9
    caseName = 'case09';
elseif caseNumb == 10
    caseName = 'case10';
elseif caseNumb == 11
    caseName = 'case11';
elseif caseNumb == 12
    caseName = 'case12';
elseif caseNumb == 13
    caseName = 'case13';
end




if strcmp(LFPsource,'LFP01')
    contact = 'microLead1';
elseif strcmp(LFPsource,'LFP02')
    contact = 'microLead2';
elseif strcmp(LFPsource,'LFP03')
    contact = 'microLead3';
elseif strcmp(LFPsource,'CMacro_LFP01')
    contact = 'macroLead1';
elseif strcmp(LFPsource,'CMacro_LFP02')
    contact = 'macroLead2';
elseif strcmp(LFPsource,'CMacro_LFP03')
    contact = 'macroLead3';
end



% spikeFile = 'spike3';
% clust = 2; %set this to be 1,2, or 3; note that only a few of the spike recordings are multi-cluster

%AT 3/26/20, setting the epoch to look at
if strcmp(epoch, 'movePreparation')
    align_ind1 = 3; %where should epoch start
    align_ind2 = 4; %where should epoch start
elseif strcmp(epoch, 'moveInitiation')
    align_ind1 = 4; %where should epoch start
    align_ind2 = 6; %where should epoch start
end

%%[trialStart_times; upPressed_times; stimDelivered_times; goCue_times; leftUP_times; submitsResponse_times; feedback_times]);
digits(6) %sets vars so they contain 6 digits at most
p = genpath('/Users/andytek/Box/Auditory_task_SNr');
addpath(p);
p = genpath('/Users/andytek/Desktop/git/audTask/MATLABCODE_io');
addpath(p);


% window_event1 = [-2 2];
PSTH_SMOOTH_FACTOR = 55;

if caseNumb == 8 || caseNumb == 9
    SGonly = 1;
else
    SGonly = 0;
end


[caseInfo_table, raw] = import_excelData_auditoryTask_V1(caseNumb);


[inputmatrix, rsp_struct] = import_behavior_io_auditoryTask_V1(caseInfo_table);

surgerySide = caseInfo_table.("Target (R/L STN)");

% AT 3/16/20; BClust were clustered at 2 SD and refined down as much as
% possible; while _V2 were clustered to 3SD and largely left unrefined.

% [Ephys_struct, spike1, spike2, spike3] = import_ephys_io_auditoryTask_V1(caseInfo_table, 'processed_spikes_BClust');
[Ephys_struct, spike1, spike2, spike3] = import_ephys_io_auditoryTask_V1(caseInfo_table, 'processed_spikes_V2');
if caseNumb == 12
    LFPSamplerate = Ephys_struct.lfp.KHz*1000;
else
    LFPSamplerate = Ephys_struct.lfp.sampFreqHz;
end

[lfpMicro1, lfpMacro1, lfpMicro2, lfpMacro2, lfpMicro3, lfpMacro3] = unpack_ephysLFP_io_auditoryTask_V1(caseInfo_table, Ephys_struct);


% % % % %AT 1/19/20 - change spikeX to call up differnt spike files
% % % % spike_timestamp = spike1.spikeDATA.waveforms.posWaveInfo.posLocs;
% % % % % spike_timestamp = spikeDATA.waveforms.negWaveInfo.neglocs;


if caseNumb == 3 || caseNumb == 2 || caseNumb == 1
    rData = rsp_struct.rsp_master_v1;%unpacking, AT
elseif caseNumb == 4
    rData = rsp_struct.rsp_master_v2;%unpacking, AT
else
    rData = rsp_struct.rsp_master_v3;%unpacking, AT
end

inputmatrix = inputmatrix.input_matrix_rndm;%unpacking, AT

lasttrialwewant = length(rData);
trialsperblock = 9;

behavior_timestamp = Ephys_struct.ttlInfo.ttl_up; %.ttl_dn is just 2200 samples after this, otherwise same


%AT 2/15/20, needed to do some processing on the behavior file rData in
%order have the timings reflect time from beginning of each individual
%trial. This is really important! To account for different versions of our
%task, we should use different versions of the below fx!
if caseNumb == 4
    rData = Case04_behavior_adapter(rData);
end

if caseNumb == 3 || caseNumb == 2 || caseNumb == 1
    rData = Case03_behavior_adapter(rData);
end

taskbase_io = behav_file_adapter_V1(rData,inputmatrix);

if caseNumb == 4
    taskbase_io = Case04_AOstart_adapter(taskbase_io, Ephys_struct, 'trialStart'); %this should add output field in taskbase struct which contains the start of each trial in the time of the alphaomega clock.
elseif caseNumb == 3 || caseNumb == 2 || caseNumb == 1
    taskbase_io = Case03_AOstart_adapter(taskbase_io, Ephys_struct, 'trialStart'); %this should add output field in taskbase struct which contains the start of each trial in the time of the alphaomega clock.
else
    taskbase_io = AOstart_adapter_V1(taskbase_io, Ephys_struct, 'trialStart'); %this should add output field in taskbase struct which contains the start of each trial in the time of the alphaomega clock.
end


%AT adding below on 3/20/20 to account for weirdness in the way file was
%saved.
if caseNumb == 1
    taskbase_io.trialStart_AO = taskbase_io.trialStart_AO(14:(end-5));
end


%AT 2/14/20; below are input variables to original fx pulled out
if strcmp(LFPsource,'LFP01')
    LFP_file = lfpMicro1;
elseif strcmp(LFPsource,'LFP02')
    LFP_file = lfpMicro2;
elseif strcmp(LFPsource,'LFP03')
    LFP_file = lfpMicro3;
elseif strcmp(LFPsource,'CMacro_LFP01')
    LFP_file = lfpMacro1;
elseif strcmp(LFPsource,'CMacro_LFP02')
    LFP_file = lfpMacro2;
elseif strcmp(LFPsource,'CMacro_LFP03')
    LFP_file = lfpMacro3;
end
LFP_file = cast(LFP_file,'double');

%below taken from https://www.mathworks.com/help/signal/ug/remove-the-60-hz-hum-from-a-signal.html
%notch filter for 60 Hz noise
d = designfilt('bandstopiir','FilterOrder',2, ...
    'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
    'DesignMethod','butter','SampleRate',LFPSamplerate);

LFP_file = filtfilt(d,LFP_file);

%below is highpass filter
LFP_file = highpass(LFP_file,0.5,LFPSamplerate);


saveFigure = 0;




%option parameters
normalize=1; % set to 1 to plot the data as % change from baseline. set to 0 to plot raw power.

Duration=1.00; % time duration of each event in seconds
Offset=.500;% Offset is the time you want to go back by. ie. Offset=.500; means 500ms BEFORE event began will be start of each trial

% LFPSamplerate=1000;
% LFPSamplerate = 1375; %AT


Buffer=200; waveletwidth=6;
filelength=LFPSamplerate*Duration;
if normalize==1
    Offset_cue = 0; %1/21/20 was 0.375 before
    Duration_cue = 0; %1/21/20 was 0.250 before
end
time=-(Offset-1/LFPSamplerate):1/LFPSamplerate:(-Offset+Duration); % set the time axis
freqs=2.^((8:54)/8); %AT

%set up file output names
%AT 4/26/19 - below are what zag used, will need to replace with whatever
%makes sense

% % label='_targVSdist';
% % percnorm='';if normalize==1; percnorm='_percnorm'; end
% % powerlabel = ['waveletpower_induced&evoked' percnorm label '.mat'];

%% LOOK AT PHASE DATA

tstart=tic;
%     i

%         close all %AT idk why they have this here

%         subj=filenames(i).channelnames{j}(1:6);
%         session=filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j}, 'sess','end')+1);
%         channel = filenames(i).channelnames{j}(regexp(filenames(i).channelnames{j},'\.'):end);



% get the correct trials for low and high conflict
%         targ_correct=find([events.correct]==1 & [events.target]==1 | [events.correct]==2 & [events.target]==0 );
%         dist_correct=find([events.correct]==1 & [events.target]==0 | [events.correct]==2 & [events.target]==1 );
%
%AT so to mimic, I think I index for correct and then incorrect
%trials (I think that 'targ' first statement is participant correctly recalling when they need to, second statement is them correctly not recalling when it is not in target (?); second statement I guess is the inverse of what I just wrote)

%AT uncomment below when using our data
%     [L_IS_correct_structs,  R_IS_correct_structs,  L_SG_correct_structs, R_SG_correct_structs] = io_taskindexing_AT_V1(rsp_struct.rsp_master_v3, inputmatrix.input_matrix_rndm);

% if isfield(rsp_struct, 'rsp_master_v3')
%     [L_IS_correct_structs,  R_IS_correct_structs,  L_SG_correct_structs, R_SG_correct_structs] = io_taskindexing_AT_V1(rsp_struct.rsp_master_v3, inputmatrix);
% elseif isfield(rsp_struct, 'ans')
%     [L_IS_correct_structs,  R_IS_correct_structs,  L_SG_correct_structs, R_SG_correct_structs] = io_taskindexing_AT_V1(rsp_struct.ans, inputmatrix);
% end



%
%         events_low=events(targ_correct);
%         events_high=events(dist_correct);
%         events_joint=[events_low, events_high];
%
% %AT uncomment below when using our data
% events_ISjoint=[L_IS_correct_structs, R_IS_correct_structs];
% events_SGjoint=[L_SG_correct_structs, R_SG_correct_structs];
% events_joint = [events_SGjoint, events_ISjoint]; %unsure if this will be used, but prob

%         % load the EEG data
%         filename=[homeDir subj '/ecogLFPdata_rereferenced/' events(1).eegfile channel];
%         fchan_reref = fopen(filename,'r','l'); %so this opens the specified filename as a read only, below fx do something similar, JT pointed out this is probably so that they can store the file in a text version, which is much more compact than trying to store the 16 bit info for each sampling point
%         LFP_wholerecordings=fread(fchan_reref,inf,'int16');
%         fclose(fchan_reref);
%         LFP_joint=zeros(length(events_joint), Duration*1000+2*Buffer);%note, 'Duration*1000+2*Buffer' equals 4000



%1/21/20, need to ensure we're selecting the appropriate electrode
%
%     if strcmp(LFP, 'LFP01')
%         LFP_wholerecordings_uint16 = Ephys_struct.CLFP_01;
%     elseif strcmp(LFP, 'LFP02')
%         LFP_wholerecordings_uint16 = Ephys_struct.CLFP_02;
%     elseif strcmp(LFP, 'LFP03')
%         LFP_wholerecordings_uint16 = Ephys_struct.CLFP_03;
%     elseif strcmp(LFP, 'CMacro_LFP01')
%         LFP_wholerecordings_uint16 = Ephys_struct.CMacro_LFP_01;
%     elseif strcmp(LFP, 'CMacro_LFP02')
%         LFP_wholerecordings_uint16 = Ephys_struct.CMacro_LFP_02;
%     elseif strcmp(LFP, 'CMacro_LFP03')
%         LFP_wholerecordings_uint16 = Ephys_struct.CMacro_LFP_03;
%     end
%
%

GetPhysioGlobals_io_V1;

global TRIAL_EVENTS; % Numbers in saved raster_info corresponding to the trial events
global RESOLUTION;




switch align_ind1
    case 1
        align_event1_times = 'trialStart_times'; % beginning of trial
    case 2
        align_event1_times = 'upPressed_times'; % this is the last TTL sent during the delay epoch
    case 3
        align_event1_times = 'stimDelivered_times'; % OdorPokeOut
    case 4
        align_event1_times = 'goCue_times'; % WaterPokeIn
    case 5
        align_event1_times = 'leftUP_times'; % GoSignal
    case 6
        align_event1_times = 'submitsResponse_times'; % GoSignal
    case 7
        align_event1_times = 'feedback_times'; % GoSignal
    otherwise
        error('align_ind1 must be -17, 0, 3, 4, or 8');
end

switch align_ind2
    case 1
        align_event2_times = 'trialStart_times'; % beginning of trial
    case 2
        align_event2_times = 'upPressed_times'; % this is the last TTL sent during the delay epoch
    case 3
        align_event2_times = 'stimDelivered_times'; % OdorPokeOut
    case 4
        align_event2_times = 'goCue_times'; % WaterPokeIn
    case 5
        align_event2_times = 'leftUP_times'; % GoSignal
    case 6
        align_event2_times = 'submitsResponse_times'; % GoSignal
    case 7
        align_event2_times = 'feedback_times'; % GoSignal
    otherwise
        error('align_ind1 must be -17, 0, 3, 4, or 8');
end





[choice_trials_L, choice_trials_R, nochoice_trials_L, nochoice_trials_R, choice_trials_L_corrects, choice_trials_R_corrects, nochoice_trials_L_corrects, nochoice_trials_R_corrects ] = io_taskindexing_AT_V2(rData, inputmatrix);


choice_trials_L(1:3) = [];
choice_trials_R(1:3) = [];
nochoice_trials_L(1:3) = [];
nochoice_trials_R(1:3) = [];


choice_trials = choice_trials_L + choice_trials_R; %AT making combined SG index
nochoice_trials = nochoice_trials_L + nochoice_trials_R; %AT making combined SG index

%2/17/19 the point of below is to let us easily plot the just SG trials
if SGonly == 1
    nochoice_trials = choice_trials;
end






%% Look at L, choice (active decision making) trials %%%
% aka L choices made during SG
trial_inds = find((taskbase_io.response == 1) & (choice_trials == 1));
trial_start_times = taskbase_io.events.trialStart(trial_inds)';
% trial_start_times_AO = taskbase_io.trialStart_AO(trial_inds)';
SG_L = struct();
[SG_L] = lfp_epochSorter_V1(SG_L, trial_inds, trial_start_times, taskbase_io, align_event1_times, align_event2_times, Ephys_struct, LFPSamplerate, LFP_file);


%% Look at L, no-choice trials %%%
% aka L choices made during IS

trial_inds = find((taskbase_io.response == 1) & (nochoice_trials == 1));
trial_start_times = taskbase_io.events.trialStart(trial_inds)';
% trial_start_times_AO = taskbase_io.trialStart_AO(trial_inds)';

IS_L = struct();
[IS_L] = lfp_epochSorter_V1(IS_L, trial_inds, trial_start_times, taskbase_io, align_event1_times, align_event2_times, Ephys_struct, LFPSamplerate, LFP_file);



%% Look at R, choice (active decision making) trials %%%
% aka L choices made during SG
trial_inds = find((taskbase_io.response == 2) & (choice_trials == 1));
trial_start_times = taskbase_io.events.trialStart(trial_inds)';
% trial_start_times_AO = taskbase_io.trialStart_AO(trial_inds)';


SG_R = struct();
[SG_R] = lfp_epochSorter_V1(SG_R, trial_inds, trial_start_times, taskbase_io, align_event1_times, align_event2_times, Ephys_struct, LFPSamplerate, LFP_file);


%% Look at R, no-choice trials %%%
% aka R choices made during IS
trial_inds = find((taskbase_io.response == 2) & (nochoice_trials == 1));
trial_start_times = taskbase_io.events.trialStart(trial_inds)';
% trial_start_times_AO = taskbase_io.trialStart_AO(trial_inds)';


IS_R = struct();
[IS_R] = lfp_epochSorter_V1(IS_R, trial_inds, trial_start_times, taskbase_io, align_event1_times, align_event2_times, Ephys_struct, LFPSamplerate, LFP_file);



%
% %quick stacked bar plot
% figure()
% % y = SG_L.delta_pband; SG_L.alpha_pband; SG_L.theta_pband, SG_L.beta_pband, SG_L.lowgamma_pband, SG_L.highgamma_pband
SG_L_stacked = [mean(SG_L.delta_pband), mean(SG_L.alpha_pband), mean(SG_L.theta_pband), mean(SG_L.beta_pband), mean(SG_L.lowgamma_pband), mean(SG_L.highgamma_pband)];
IS_L_stacked = [mean(IS_L.delta_pband), mean(IS_L.alpha_pband), mean(IS_L.theta_pband), mean(IS_L.beta_pband), mean(IS_L.lowgamma_pband), mean(IS_L.highgamma_pband)];
SG_R_stacked = [mean(SG_R.delta_pband), mean(SG_R.alpha_pband), mean(SG_R.theta_pband), mean(SG_R.beta_pband), mean(SG_R.lowgamma_pband), mean(SG_R.highgamma_pband)];
IS_R_stacked = [mean(IS_R.delta_pband), mean(IS_R.alpha_pband), mean(IS_R.theta_pband), mean(IS_R.beta_pband), mean(IS_R.lowgamma_pband), mean(IS_R.highgamma_pband)];

% y = [SG_L_stacked; IS_L_stacked; SG_R_stacked; IS_R_stacked];
% bar(y,'stacked')


figure()
if strcmp(surgerySide, 'L')
    y_combined = vertcat(SG_L_stacked, IS_L_stacked, SG_R_stacked, IS_R_stacked);
    names = {'SG ipsi'; 'IS ipsi'; 'SG contra'; 'IS contra'};
elseif strcmp(surgerySide, 'R')
    y_combined = vertcat(SG_R_stacked, IS_R_stacked,SG_L_stacked, IS_L_stacked);
    names = {'SG ipsi'; 'IS ipsi'; 'SG contra'; 'IS contra'};
end

h = bar(y_combined, 'stacked');
% set(h, {'FaceColor'}, { [.1 .1 1]; [.5 .5 .5]; [.9 .1 .1]});
set(gca, 'xtick', [1:4], 'xticklabel', names)
l = cell(1,5);
l{1} = 'Delta'; l{2} =  'Alpha'; l{3} = 'Theta'; l{4} = 'Beta'; l{5} = 'Low Gamma'; l{6} = 'High Gamma';
% l{1} = 'Significant FR decrease'; l{2} = 'No FR change'; l{3} =  'Significance FR increase';
title(strcat(['Case#: ' mat2str(caseNumb),'  LFP#: ' mat2str(LFPsource),'  Epoch:' mat2str(epoch), '  All bands']))
% if strcmp(subfolder_name, 'MI')
%     legend(h,l, 'Location', 'NorthWest');
% else
legend(h,l, 'Location', 'SouthEast');
% end
xtickangle(45)
box off





figuresdir = fullfile('/Users','andytek','Box','Auditory_task_SNr','Data/generated_analyses','LFP_stackedbars', caseName, contact, epoch);
filename = ('/All bands');

saveas(gcf,strcat(figuresdir, filename), 'jpeg');





%quick stacked bar plot; Excluding delta
% figure()
% % y = SG_L.delta_pband; SG_L.alpha_pband; SG_L.theta_pband, SG_L.beta_pband, SG_L.lowgamma_pband, SG_L.highgamma_pband
SG_L_stacked = [mean(SG_L.alpha_pband), mean(SG_L.theta_pband), mean(SG_L.beta_pband), mean(SG_L.lowgamma_pband), mean(SG_L.highgamma_pband)];
IS_L_stacked = [mean(IS_L.alpha_pband), mean(IS_L.theta_pband), mean(IS_L.beta_pband), mean(IS_L.lowgamma_pband), mean(IS_L.highgamma_pband)];
SG_R_stacked = [mean(SG_R.alpha_pband), mean(SG_R.theta_pband), mean(SG_R.beta_pband), mean(SG_R.lowgamma_pband), mean(SG_R.highgamma_pband)];
IS_R_stacked = [mean(IS_R.alpha_pband), mean(IS_R.theta_pband), mean(IS_R.beta_pband), mean(IS_R.lowgamma_pband), mean(IS_R.highgamma_pband)];

% y = [SG_L_stacked; IS_L_stacked; SG_R_stacked; IS_R_stacked];
% bar(y,'stacked')


figure()
% spacer = [0, 0, 0];
% names = {'Contraversive'; 'Ipsiversive'; 'No Preference'; 'empty'; 'Contraversive'; 'Ipsiversive'; 'No Preference'};

if strcmp(surgerySide, 'L')
    y_combined = vertcat(SG_L_stacked, IS_L_stacked, SG_R_stacked, IS_R_stacked);
    names = {'SG ipsi'; 'IS ipsi'; 'SG contra'; 'IS contra'};
elseif strcmp(surgerySide, 'R')
    y_combined = vertcat(SG_R_stacked, IS_R_stacked,SG_L_stacked, IS_L_stacked);
    names = {'SG ipsi'; 'IS ipsi'; 'SG contra'; 'IS contra'};
end

h = bar(y_combined, 'stacked');
% set(h, {'FaceColor'}, { [.1 .1 1]; [.5 .5 .5]; [.9 .1 .1]});
set(gca, 'xtick', [1:4], 'xticklabel', names)
l = cell(1,5);
l{1} =  'Alpha'; l{2} = 'Theta'; l{3} = 'Beta'; l{4} = 'Low Gamma'; l{5} = 'High Gamma';
% l{1} = 'Significant FR decrease'; l{2} = 'No FR change'; l{3} =  'Significance FR increase';
title(strcat(['Case#: ' mat2str(caseNumb),'  LFP#: ' mat2str(LFPsource),'  Epoch:' mat2str(epoch), '  All bands, except Delta']))
% if strcmp(subfolder_name, 'MI')
%     legend(h,l, 'Location', 'NorthWest');
% else
legend(h,l, 'Location', 'SouthEast');
% end
xtickangle(45)
box off


figuresdir = fullfile('/Users','andytek','Box','Auditory_task_SNr','Data/generated_analyses','LFP_stackedbars', caseName, contact, epoch);
filename = ('/All bands except delta');

saveas(gcf,strcat(figuresdir, filename), 'jpeg');














% %
% % %         LFP_wholerecordings_uint16 = CMacro_LFP_01;
% % %         LFP_wholerecordings_uint16 = CMacro_LFP_02;
% %
% % LFP_wholerecordings = double(LFP_wholerecordings_uint16);
% %
% % conversionfactor = LFPSamplerate /1000;
% %
% % LFP_joint=zeros(length(events_joint), (Duration*1000+2*Buffer)*conversionfactor);%note, 'Duration*1000+2*Buffer' equals 4000
% %
% %
% %
% % %checked that 'trial start' output from the TTLnav fx directly matches the rsp output. So the number of TTL's equals the number of non-error'ed trials.
% % %87 for pt8 by ttl_nav; 87 for pt8 by iotaskindexing
% %
% %
% % %
% % %         for event=1:length(events_joint)
% % %             startindex=events_joint(event).eegoffset-Offset*1000-Buffer; %I believe EEG offset is the timestamp for trial start
% % %             endindex=startindex-1+Duration*1000+2*Buffer;
% % %             LFP_joint(event,:)=LFP_wholerecordings(startindex:endindex);
% % %         end
% % %
% %
% % % %         %AT, below is editted version of above, I think things can be
% % % %         kept pretty constant
% %
% % length_lfp_recording = length(LFP_wholerecordings)/LFPSamplerate;
% %
% % %AT 1/22/20; for the below, if it is rsp version 3 we are ok at the
% % %moment, but need to make some changes if it is something else
% % ioTask_index = io_TTLnavigating_v2(Ephys_struct.ttlInfo);
% % ioTask_index_timestamps = ioTask_index(2,:);
% % ioTask_index_timestamps(ioTask_index_timestamps==0) = []; %Note, these are the time stamps for the TTL corresponding to start of the trial. I think I want to convert everything down to seconds for comparison of TTL to LFP to spikes
% % ioTask_index_timestamps_secs = ioTask_index_timestamps/44000;
% % ioTask_index_timestamps_millisecs = ioTask_index_timestamps_secs * 1000;
% %
% %
% % ttl_LFP_startOffset_secs = Ephys_struct.ttlInfo.ttlTimeBegin - Ephys_struct.lfp.timeStart; %TTL recording time begins after LFP since recording starts a bit before task is ready to inititiate
% % ttl_LFP_startOffset_milliseconds = ttl_LFP_startOffset_secs*1000;
% % ioTask_index_timestamps_millisecs_aligned = ioTask_index_timestamps_millisecs(:) + ttl_LFP_startOffset_milliseconds;
% % %so now, because of the above code, the ttl and LFP signals should be
% % %aligned to one another with these times being in milliseconds
% %
% % for t=1:length(events_joint)
% %     startindex=ioTask_index_timestamps_millisecs_aligned(t)-Offset*1000-Buffer;
% %     %             endindex=startindex-1+Duration*1000+2*Buffer;
% %     %so the above is giving us the windows of lfp data we want to
% %     %group together, in units of milliseconds
% %
% %     startindex_lfp = round(startindex*conversionfactor);
% %     endindex_lfp = startindex_lfp-1+((Duration*1000+2*Buffer)*conversionfactor);
% %     LFP_joint(t,:)=LFP_wholerecordings(startindex_lfp:(endindex_lfp));
% %
% % end
% %
% %
% %
% %
% % % filter out 60 Hz noise
% % LFP_joint=buttfilt(LFP_joint,[59 61], LFPSamplerate, 'stop', 2);
% %
% % %get the phase and power
% % [phaseMat_joint, powerMat_joint]=multiphasevec3(freqs,LFP_joint,LFPSamplerate,waveletwidth);
% % %AT 5/1/19; I think for the below fx, it is important to account
% % %for different between lfp sampling rate and our millisecond
% % %standard. Ultimately we want the last dimension of the
% % %phase/powerMat output equal the number of samples in our 'time'
% % %variable
% % phaseMat_joint = squeeze(phaseMat_joint(:,:,(Buffer*conversionfactor)+1:end-(Buffer*conversionfactor)));
% % powerMat_joint = squeeze(powerMat_joint(:,:,(Buffer*conversionfactor)+1:end-(Buffer*conversionfactor)));
% %
% % % clean the data of artifacts
% % %         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 10, find(freqs>1.9 & freqs<8.1),0);
% % %         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 25, find(freqs>7.9 & freqs<32.1),0);
% % %         [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, 50, find(freqs>31.9 & freqs<108.1),0);
% % %
% % Zthresh = 50; %AT, seems like we're filtering out a lot of data if we go lower than this, unsure what is reasomanable but will follow what Zag did. Note that V2 of artifact hunter also passes through the LFP signal that has not been separated into power/phase. I should remember that this output is 'ordered'
% % [events_joint, powerMat_joint, phaseMat_joint, LFP_joint]=automatedartifacthunter_AT_V2(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, LFP_joint, time, freqs, Zthresh/5, find(freqs>1.9 & freqs<8.1),0);
% % [events_joint, powerMat_joint, phaseMat_joint, LFP_joint]=automatedartifacthunter_AT_V2(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, LFP_joint, time, freqs, Zthresh/2, find(freqs>7.9 & freqs<32.1),0);
% % [events_joint, powerMat_joint, phaseMat_joint, LFP_joint]=automatedartifacthunter_AT_V2(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, LFP_joint, time, freqs, Zthresh, find(freqs>31.9 & freqs<108.1),0);
% %
% %
% % %     Zthresh = 50; %AT, seems like we're filtering out a lot of data if we go lower than this
% % %     [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, Zthresh, find(freqs>1.9 & freqs<8.1),0);
% % %     [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, Zthresh, find(freqs>7.9 & freqs<32.1),0);
% % %     [events_joint, powerMat_joint, phaseMat_joint]=automatedartifacthunter_AT_V1(LFP_wholerecordings, events_joint, powerMat_joint, phaseMat_joint, time, freqs, Zthresh, find(freqs>31.9 & freqs<108.1),0);
% %
% % % reassign the clean data to events.
% % %         [events_SGjoint, events_ISjoint]
% %
% % %
% % %         [~,lowtrials_clean] = intersect([events_joint.mstime],[events_low.mstime]);
% % %         [~,hightrials_clean] = intersect([events_joint.mstime],[events_high.mstime]);
% % %         events_low=events_joint(lowtrials_clean);    powerMat_low=powerMat_joint(lowtrials_clean,:,:);   phaseMat_low=phaseMat_joint(lowtrials_clean,:,:);
% % %         events_high=events_joint(hightrials_clean);  powerMat_high=powerMat_joint(hightrials_clean,:,:); phaseMat_high=phaseMat_joint(hightrials_clean,:,:);
% % %
% %
% %
% % events_ISjoint=[L_IS_correct_structs, R_IS_correct_structs];
% % events_SGjoint=[L_SG_correct_structs, R_SG_correct_structs];
% %
% %
% %
% % [~,events_L_SG_clean] = intersect([events_joint.Wholetrial],[L_SG_correct_structs.Wholetrial]);
% % events_L_SG=events_joint(events_L_SG_clean);    powerMat_L_SG=powerMat_joint(events_L_SG_clean,:,:);   phaseMat_L_SG=phaseMat_joint(events_L_SG_clean,:,:);
% %
% % [~,events_R_SG_clean] = intersect([events_joint.Wholetrial],[R_SG_correct_structs.Wholetrial]);
% % events_R_SG=events_joint(events_R_SG_clean);    powerMat_R_SG=powerMat_joint(events_R_SG_clean,:,:);   phaseMat_R_SG=phaseMat_joint(events_R_SG_clean,:,:);
% %
% % [~,events_L_IS_clean] = intersect([events_joint.Wholetrial],[L_IS_correct_structs.Wholetrial]);
% % events_L_IS=events_joint(events_L_IS_clean);    powerMat_L_IS=powerMat_joint(events_L_IS_clean,:,:);   phaseMat_L_IS=phaseMat_joint(events_L_IS_clean,:,:);
% %
% % [~,events_R_IS_clean] = intersect([events_joint.Wholetrial],[R_IS_correct_structs.Wholetrial]);
% % events_R_IS=events_joint(events_R_IS_clean);    powerMat_R_IS=powerMat_joint(events_R_IS_clean,:,:);   phaseMat_R_IS=phaseMat_joint(events_R_IS_clean,:,:);
% %
% %
% % [~,events_SGjoint_clean] = intersect([events_joint.Wholetrial],[events_SGjoint.Wholetrial]);
% % events_SGjoint=events_joint(events_SGjoint_clean);    powerMat_SG=powerMat_joint(events_SGjoint_clean,:,:);   phaseMat_SG=phaseMat_joint(events_SGjoint_clean,:,:);
% %
% % [~,events_ISjoint_clean] = intersect([events_joint.Wholetrial],[events_ISjoint.Wholetrial]);
% % events_ISjoint=events_joint(events_ISjoint_clean);  powerMat_IS=powerMat_joint(events_ISjoint_clean,:,:);  phaseMat_IS=phaseMat_joint(events_ISjoint_clean,:,:);
% %
% %
% % LFP_L_SGcleaned = LFP_joint(events_L_SG_clean,:);
% % LFP_R_SGcleaned = LFP_joint(events_R_SG_clean,:);
% % LFP_L_IScleaned = LFP_joint(events_L_IS_clean,:);
% % LFP_R_IScleaned = LFP_joint(events_R_IS_clean,:);
% %
% %
% % LFP_joint_SGcleaned = LFP_joint(events_SGjoint_clean,:);
% % LFP_joint_IScleaned = LFP_joint(events_ISjoint_clean,:);
% %
% %
% %
% % %get baseline power and normalize
% % if normalize==1
% %     startindex_cue=(Offset-Offset_cue)*1000;
% %     endindex_cue=startindex_cue+Duration_cue*1000;
% %     powerMat_cue=[powerMat_SG(:,:,startindex_cue:endindex_cue); powerMat_IS(:,:,startindex_cue:endindex_cue)];
% %
% %     powerMean_cue=mean(squeeze(mean( powerMat_cue,3)));
% %     powerSTD_cue=std(squeeze(mean( powerMat_cue,3)));
% %     powerMat_SG=bsxfun(@rdivide,bsxfun(@minus,powerMat_SG,powerMean_cue),powerMean_cue);
% %     powerMat_IS=bsxfun(@rdivide,bsxfun(@minus,powerMat_IS,powerMean_cue),powerMean_cue);
% % end
% % powerMean_SG=squeeze(mean(powerMat_SG,1));
% % powerMean_IS=squeeze(mean(powerMat_IS,1));
% %
% % imagescale=[-.75 .75];
% % figure();
% % pcolor(time, freqs,powerMean_SG); %colorbar;
% % set(gca,'CLim',imagescale);
% % shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
% % title(['Case number ', num2str(PT), ',  SG correct trials mean']);
% % figure();
% % pcolor(time, freqs, powerMean_IS); %colorbar;
% % set(gca,'CLim',imagescale);
% % shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
% % title(['Case number ', num2str(PT), ', IS correct trials mean']);
% % figure();
% % pcolor(time, freqs, powerMean_IS-powerMean_SG); %colorbar;
% % set(gca,'CLim',imagescale);
% % shading interp; set(gca,'YTick',[2 4 8 16 32 64 100]); set(gca,'YScale','log'); ylim([2 107]); set(gcf, 'color', 'w'); colormap jet; box off
% % title(['Case number ', num2str(PT), ', Difference between IS and SG means']);
% %
% %
% %
% %
% %
% %
% %
% % %AT, now we want to do some relatively simple comparisons of coherence
% % %and such
% % x = powerMean_SG;
% % y = powerMean_IS;
% %
% % window = []; %from Matlab regarding this: If you specify window as empty, then mscohere uses a Hamming window such that x and y are divided into eight segments with noverlap overlapping samples.
% % noverlap = []; %from Matlab regarding this: If you specify noverlap as empty, then mscohere uses a number that produces 50% overlap between segments. If the segment length is unspecified, the function sets noverlap to ?N/4.5?, where N is the length of the input and output signals.
% % f = []; %from Matlab regarding this: Number of DFT points, specified as a positive integer. If you specify nfft as empty, then mscohere sets this argument to max(256,2p), where p = ?log2 N? for input signals of length N.
% % fs = LFPSamplerate;
% %
% % figure()
% % [cxy, fc] = mscohere(x,y,window,noverlap,f,fs);
% % plot(fc/pi,cxy)
% %
% % figure()
% % [cxy, fc] = mscohere(mean(x,1), mean(y,1), window, noverlap, f, fs);
% % plot(fc/pi,cxy)
% %
% %
% % %1/21/20 - AT, I'm confused by the output below
% % [a,p] = corrcoef(mean(x,1), mean(y,1));
% %
% %
% % %     sig1 = mean(LFP_joint_SGcleaned,1);
% % %     sig2 = mean(LFP_joint_IScleaned,1);
% % %     Fs = LFPSamplerate;
% % %
% % %
% % %     frequ1 = 7;
% % %     frequ2 = 13;
% % %     sig1_pband = bandpower(sig1,LFPSamplerate,[frequ1 frequ2]);
% % %     sig1_ptot = bandpower(sig1,LFPSamplerate,[1 200]);
% % %     sig1_per_power = 100*(sig1_pband/sig1_ptot);
% % %
% % %     sig2_pband = bandpower(sig2,LFPSamplerate,[frequ1 frequ2]);
% % %     sig2_ptot = bandpower(sig2,LFPSamplerate,[1 200]);
% % %     sig2_per_power = 100*(sig2_pband/sig2_ptot);
% % %
% % %     [h,p] = ranksum(sig1_per_power,sig2_per_power);
% %
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 1;
% % frequ2 = 4;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 4;
% % frequ2 = 8;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 8;
% % frequ2 = 13;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 13;
% % frequ2 = 35;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 35;
% % frequ2 = 80;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% % %below is for taking the power of each trial
% % %range below
% % frequ1 = 80;
% % frequ2 = 200;
% % sig1 = LFP_joint_SGcleaned;
% % sig2 = LFP_joint_IScleaned;
% % Fs = LFPSamplerate;
% %
% % for ii = 1:size(sig1,1)
% %     sig1_pband = bandpower(sig1(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig1_ptot = bandpower(sig1(ii,:),LFPSamplerate,[1 200]);
% %     sig1_per_power(ii) = 100*(sig1_pband/sig1_ptot);
% % end
% %
% % for ii = 1:size(sig2,1)
% %     sig2_pband = bandpower(sig2(ii,:),LFPSamplerate,[frequ1 frequ2]);
% %     sig2_ptot = bandpower(sig2(ii,:),LFPSamplerate,[1 200]);
% %     sig2_per_power(ii) = 100*(sig2_pband/sig2_ptot);
% % end
% %
% % [p,h] = ranksum(sig1_per_power,sig2_per_power);
% %
% % if mean(sig1_per_power) > mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', SG > IS; p =', num2str(p)])
% % elseif mean(sig1_per_power) < mean(sig2_per_power)
% %     disp(['For freq',num2str(frequ1), ' - ', num2str(frequ2), ', IS > SG; p =', num2str(p)])
% % end
% %
% %
% %
% % %%
% % %%
% % %%
% % %%
% %
% % %%below is meant to be an assessment of the un-separated LFP signals
% % [P1,f1] = periodogram(sig1,[],[],Fs,'power');
% % [P2,f2] = periodogram(sig2,[],[],Fs,'power');
% % figure()
% % subplot(2,1,1)
% % plot(f1,P1,'k')
% % grid
% % ylabel('P_1')
% % title('Power Spectrum')
% %
% % subplot(2,1,2)
% % plot(f2,P2,'r')
% % grid
% % ylabel('P_2')
% % xlabel('Frequency (Hz)')
% %
% %
% %
% % figure()
% % subplot(2,1,1)
% % plot(sig1,'g')
% % grid
% % ylabel('SG LFP')
% % title('ave trace')
% %
% % subplot(2,1,2)
% % plot(sig1,'r')
% % grid
% % ylabel('IS LFP')
% % xlabel('ave trace')
% %
% %
% %
% %
% % %         % save everything
% % %         numlow=length(events_low);%
% % %         numhigh=length(events_high);%
% % %         outputDir=[homeDir filenames(i).channelnames{j} '_power/' ]; if ~exist(outputDir,'dir'); mkdir(outputDir); end
% % %         save([outputDir powerlabel], 'powerMean_low','powerMean_high', 'freqs', 'numlow', 'numhigh');
% %
% % toc(tstart)
% % fprintf('\nAll Done\n')
% %
% %
