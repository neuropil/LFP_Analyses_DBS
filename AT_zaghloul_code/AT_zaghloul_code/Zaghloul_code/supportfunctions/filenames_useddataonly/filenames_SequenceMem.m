function [filenames]=filenames_SequenceMem(STNFrontalLateral) 
% STNFrontalLateral='ALL'; % must set to 'ALL', or 'ALLSTN', or 'macroSTN', or 'microSTN', or 'Frontal', or 'Lateral'

% Only channels actually located within the STN borders are shown. 
% Corrupted LFP and ECOG channels are also excluded

clear filenames
filenames(1).stem = 'DBS029/analysis_LFP/sess0_C.'; filenames(1).channelnames= {                                          '501-502'; '502-503'; '503-504'; '504-505'           };%RT 
filenames(2).stem = 'DBS029/analysis_LFP/sess1_C.'; filenames(2).channelnames= {'001';               '004';               '501-502'; '502-503'; '503-504'; '504-505'; '505-506'};%LT 
filenames(3).stem = 'DBS031/analysis_LFP/sess0_C.'; filenames(3).channelnames= {                     '004';        '006'}; %LT % no ecog for this subject's first session
filenames(4).stem = 'DBS031/analysis_LFP/sess1_C.'; filenames(4).channelnames= {                     '004';               '501-502'; '502-503'; '503-504'; '504-505'; '505-506'};%RT 
filenames(5).stem = 'DBS032/analysis_LFP/sess0_C.'; filenames(5).channelnames= {'001'; '002'; '003'; '004';        '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'};%LT 
filenames(6).stem = 'DBS032/analysis_LFP/sess1_C.'; filenames(6).channelnames= {'001';        '003';                      '501-502'; '502-503'; '503-504'; '504-505'; '505-506'};%RT 
filenames(7).stem = 'DBS033/analysis_LFP/sess0_C.'; filenames(7).channelnames= {'001';        '003';               '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506';                                                        '512-513'; '513-514'};%RT 
filenames(8).stem = 'DBS033/analysis_LFP/sess1_C.'; filenames(8).channelnames= {'001';        '003'; '004';               '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(9).stem = 'DBS035/analysis_LFP/sess0_C.'; filenames(9).channelnames= {'001'; '002'; '003';        '005'; '006'; '501-502'; '502-503'; '503-504';                                             '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(10).stem= 'DBS036/analysis_LFP/sess0_C.'; filenames(10).channelnames={       '002'       ;        '004-005';      '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(11).stem= 'DBS036/analysis_LFP/sess1_C.'; filenames(11).channelnames={       '002'       ; '004'; '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(12).stem= 'DBS037/analysis_LFP/sess1_C.'; filenames(12).channelnames={                                                     '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(13).stem= 'DBS037/analysis_LFP/sess3_C.'; filenames(13).channelnames={'001'; '002'; '003'; '004'; '005'; '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(14).stem= 'DBS038/analysis_LFP/sess0_C.'; filenames(14).channelnames={                    '004';  '005';                   '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(15).stem= 'DBS038/analysis_LFP/sess1_C.'; filenames(15).channelnames={                    '004';  '005'; '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(16).stem= 'DBS039/analysis_LFP/sess0_C.'; filenames(16).channelnames={                            '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(17).stem= 'DBS040/analysis_LFP/sess0_C.'; filenames(17).channelnames={       '002';               '004-005';      '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(18).stem= 'DBS040/analysis_LFP/sess1_C.'; filenames(18).channelnames={'001'; '002'; '003';        '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(19).stem= 'DBS041/analysis_LFP/sess0_C.'; filenames(19).channelnames={                     '004'; '005'; '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(20).stem= 'DBS041/analysis_LFP/sess1_C.'; filenames(20).channelnames={'001'; '002'; '003';        '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513';          };%LT 
filenames(21).stem= 'DBS042/analysis_LFP/sess0_C.'; filenames(21).channelnames={       '002'; '003';        '005';        '501-502'; '502-503'; '503-504'; '504-505'           ; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(22).stem= 'DBS042/analysis_LFP/sess1_C.'; filenames(22).channelnames={'001';        '003'; '004';        '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509';            '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(23).stem= 'DBS043/analysis_LFP/sess0_C.'; filenames(23).channelnames={'001';               '004'; '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(24).stem= 'DBS043/analysis_LFP/sess1_C.'; filenames(24).channelnames={'001'; '002'; '003';        '005'; '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(25).stem= 'DBS044/analysis_LFP/sess0_C.'; filenames(25).channelnames={                     '004';                          '502-503'; '503-504'; '504-505'; '505-506'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513';            '513-514'};%LT 
filenames(26).stem= 'DBS045/analysis_LFP/sess0_C.'; filenames(26).channelnames={'001'; '002'; '003'; '004'; '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(27).stem= 'DBS045/analysis_LFP/sess1_C.'; filenames(27).channelnames={'001';                                    '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(28).stem= 'DBS046/analysis_LFP/sess0_C.'; filenames(28).channelnames={'001'; '002';        '004';        '006'; '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 
filenames(29).stem= 'DBS047/analysis_LFP/sess0_C.'; filenames(29).channelnames={                     '004'; '005'; '006'};%LT % no ecog for this subject
filenames(30).stem= 'DBS047/analysis_LFP/sess1_C.'; filenames(30).channelnames={'001';               '004'; '005'       };%RT % no ecog for this subject
filenames(31).stem= 'DBS048/analysis_LFP/sess0_C.'; filenames(31).channelnames={'001'; '002'; '003'; '004'; '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%LT 
filenames(32).stem= 'DBS048/analysis_LFP/sess1_C.'; filenames(32).channelnames={              '003';        '005';        '501-502'; '502-503'; '503-504'; '504-505'; '505-506'; '507-508'; '508-509'; '509-510'; '510-511'; '511-512'; '512-513'; '513-514'};%RT 


% get rid of the channels not selected
filenames(cellfun('isempty',{filenames.channelnames}))=[]
possiblechannelsmacroSTN='004005006004-5005-6004-6';
possiblechannelsmicroSTN='001002003001-2002-3001-3';
possiblechannelsfrontal ='501-502502-503503-504504-505505-506';
possiblechannelslateral ='507-508508-509509-510510-511511-512512-513513-514';
if regexp('ALLALLSTNmacroSTNmicroSTNFrontalLateral',STNFrontalLateral)
    for i=1:length(filenames);
        channelstoremove=[];
        for j=1:length(filenames(i).channelnames)
            if   strcmp(STNFrontalLateral, 'ALLSTN')     & regexp([possiblechannelsfrontal possiblechannelslateral],filenames(i).channelnames{j})
            	channelstoremove=[channelstoremove j];
            elseif strcmp(STNFrontalLateral, 'macroSTN') & regexp([possiblechannelsmicroSTN possiblechannelsfrontal possiblechannelslateral],filenames(i).channelnames{j})
                channelstoremove=[channelstoremove j];
            elseif strcmp(STNFrontalLateral, 'microSTN') & regexp([possiblechannelsmacroSTN possiblechannelsfrontal possiblechannelslateral],filenames(i).channelnames{j})
                channelstoremove=[channelstoremove j];
            elseif strcmp(STNFrontalLateral, 'Frontal')  & regexp([possiblechannelsmicroSTN possiblechannelsmacroSTN possiblechannelslateral],filenames(i).channelnames{j})
                channelstoremove=[channelstoremove j];
            elseif strcmp(STNFrontalLateral, 'Lateral')  & regexp([possiblechannelsmicroSTN possiblechannelsmacroSTN possiblechannelsfrontal],filenames(i).channelnames{j})
                channelstoremove=[channelstoremove j];
            else
                filenames(i).channelnames{j}=[filenames(i).stem filenames(i).channelnames{j}];
            end
        end
        filenames(i).channelnames(channelstoremove)=[];
    end
else
    error('ZAR: STNFrontalLateral must be set to "ALL", "macroSTN", "microSTN", "Frontal", or "Lateral"')
end

filenames(cellfun('isempty',{filenames.channelnames}))=[]


