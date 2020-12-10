%% 4/26/19 starting sandbox
%%
%%
%%
%10/31/19

%Working with keto data, trying to do some simple processing

%lets assume I've loaded in one of the ecog files that JT has nicely
%pre-processed for me already

fs = ECoG_hdr.SamplingRate;
duration = floor(ECoG_hdr.ECoGLength); %rounding down from the total length of recording
t = 0:1/fs:2;

%there's four channels per recording
Ch1 = ECoG_data{1,1};
Ch2 = ECoG_data{1,2};
Ch3 = ECoG_data{1,3};
Ch4 = ECoG_data{1,4};


spectrogram(Ch1,100,80,100,fs,'yaxis')

% s = spectrogram(Ch1);
% 
% spectrogram(Ch1,'yaxis')




%% 5/1


% what does the subfield ?ms? correspond too?
% - mstime and eegoffset time is in the same clock (ie gives you the same
% difference in time without needing to account for sampling frequency)

% 

events_joint(10).mstime - events_joint(1).mstime

events_joint(10).eegoffset - events_joint(1).eegoffset







% ttl_LFP_startOffset = ttlInfo.ttlTimeBegin - lfp.timeStart; %TTL recording time begins after LFP since recording starts a bit before task is ready to inititiate





%%
%4/26/19 - need to create fx that will index the input matrix info into
%something more useable
% errors = zeros(size(input_matrix_rndm));  % left IS

L_IS = zeros(size(input_matrix_rndm));  % left IS
R_IS = zeros(size(input_matrix_rndm));  % right IS
L_SG = zeros(size(input_matrix_rndm));  % left SG
R_SG = zeros(size(input_matrix_rndm));  % right SG 

L_IS_correct = zeros(size(input_matrix_rndm));  %correct left IS
R_IS_correct = zeros(size(input_matrix_rndm));  %correct right IS
L_SG_correct = zeros(size(input_matrix_rndm));  %correct left SG
R_SG_correct = zeros(size(input_matrix_rndm));  %correct right SG 


%SG_IS_index

%AT, there could be a problem with this method of indexxing if there's a
%50/50 trials thats flanking the IS block. At least for PT8 though, this is
%OK

blocksize = 9;

for g = 1:length(input_matrix_rndm)-blocksize
     if input_matrix_rndm(g) == 301 && input_matrix_rndm(g+1) == 301 && input_matrix_rndm(g+2) == 301 && input_matrix_rndm(g+3) == 301 && input_matrix_rndm(g+4) == 301 && input_matrix_rndm(g+5) == 301 && input_matrix_rndm(g+6) == 301 && input_matrix_rndm(g+7) == 301 && input_matrix_rndm(g+8) == 301 
        L_IS(g:(g+(blocksize-1))) = 1;
     elseif input_matrix_rndm(g) == 302 && input_matrix_rndm(g+1) == 302 && input_matrix_rndm(g+2) == 302 && input_matrix_rndm(g+3) == 302 && input_matrix_rndm(g+4) == 302 && input_matrix_rndm(g+5) == 302 && input_matrix_rndm(g+6) == 302 && input_matrix_rndm(g+7) == 302 && input_matrix_rndm(g+8) == 302 
        R_IS(g:(g+(blocksize-1))) = 1;
    end
end


for g = 1:length(input_matrix_rndm)
     if L_IS(g) == 0 && strcmp(rsp_master_v3(g).ERROR, 'GOOD') && rsp_master_v3(g).actual == 1
         L_SG(g) = 1; %this is an index for left SG trials
     elseif R_IS(g) == 0 && strcmp(rsp_master_v3(g).ERROR, 'GOOD') && rsp_master_v3(g).actual == 2
         R_SG(g) = 1; %this is an index for right SG trials
     end
end

for g = 1:length(input_matrix_rndm)
    if L_IS(g) == 1 && rsp_master_v3(g).actual == 1
        L_IS_correct = 1;
    elseif R_IS(g) == 1 && rsp_master_v3(g).actual == 2
        R_IS_correct = 1;
    elseif L_SG(g) == 1 && rsp_master_v3(g).actual == 1
        L_SG_correct = 1;
    elseif R_SG(g) == 1 && rsp_master_v3(g).actual == 2
        R_SG_correct = 1;
    end
end
         
errors = [rsp_master_v3.Response] == 'f';
errors = errors';

for g = 1:length(input_matrix_rndm)
    if errors(g) == 1
        L_IS(g) = 0;
        R_IS(g) = 0;
        L_SG(g) = 0;
        R_SG(g) = 0;
    end
end

L_IS_rsp = struct();
m = 1;
for k = 1:length(rsp_master_v3)
    if L_IS(k) == 1
        L_IS_rsp(m) = rsp_master_v3(k);
        m = m+1;
    end
end
%     L_IS_rsp = [rsp_master_v3(L_IS)]




% % % % % rsp_master_v3(g).Response == rsp_master_v3(g).actual 
if length(input_matrix_rndm) ~= sum(L_IS) + sum(R_IS) + sum(L_SG) + sum(R_SG) + sum(errors)
    disp('ERROR, mismatch in indexing')
end

% IS_correct=find([rsp_master_v3.Response] == 1 & [rsp_master_v3.actual] == 1 & input_matrix_rndm| [rsp_master_v3.Response] == 2 & [rsp_master_v3.actual] == 2);
% SG_correct=find([rsp_master_v3.Response] == 2 & [rsp_master_v3.actual] == 1 | [rsp_master_v3.Response] == 1 & [rsp_master_v3.actual] == 2);
% dist_correct=find([rsp_master_v3.Response] == 'f' & [rsp_master_v3.actual] == 'f';
L_IS_correct_structs = rsp_master_v3(L_IS_correct);
R_IS_correct_structs = rsp_master_v3(R_IS_correct);
L_SG_correct_structs = rsp_master_v3(L_SG_correct);
R_SG_correct_structs = rsp_master_v3(R_SG_correct);
% input_matrix_rndm


%%

% 
% a = find(input_matrix_rndm == 301)
% 
% b = zeros(size(input_matrix_rndm))
% 
% b(a) = 1

