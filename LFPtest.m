function lfpBool = LFPtest(locName , driveLetter)

locparts = strsplit(locName,'\');

if length(locparts) == 4
    loc2use = strcat(driveLetter,'\S3_AO_MatlabData_S3\',locparts{3},'\',locparts{4});
elseif length(locparts) == 5
    loc2use = strcat(driveLetter,'\S3_AO_MatlabData_S3\',locparts{3},'\',locparts{4},'\',locparts{5});
else
    loc2use = strcat(driveLetter,'\S3_AO_MatlabData_S3\',locparts{4},'\',locparts{5},'\',locparts{6});
end

    
cd(loc2use);

dirTemp = dir('*.txt');

dirTable = struct2table(dirTemp);

fNames = dirTable.name;

if ismember('lfp_no.txt',fNames)
    lfpBool = 0;
    
elseif ismember('lfp_yes.txt',fNames)
    lfpBool = 1;
    
end

% fNindex = round(length(fNames)/2);
% 
% fName2use = fNames{fNindex};
% 
% matInfo = matfile(fName2use);
% mFList = whos(matInfo);
% mFfnames = {mFList.name};
% if ismember('CLFP1',mFfnames);
%     
%     load(fName2use,'CLFP1','CLFP2','CLFP3');
% 
% 
%         
%     if isa(CLFP1,'int16')
%         CLFP1 = double(CLFP1);
%         CLFP2 = double(CLFP2);
%         CLFP3 = double(CLFP3);
%     end
%     
%     grandCV = mean([std(abs(CLFP1))/mean(abs(CLFP1)) ,...
%         std(abs(CLFP2))/mean(abs(CLFP2)) ,...
%         std(abs(CLFP3))/mean(abs(CLFP3))]);
%     
%     if sum([abs(std(CLFP1))/abs(mean(CLFP1)) <= 0.3,...
%             abs(std(CLFP2))/abs(mean(CLFP2)) <= 0.3,...
%             abs(std(CLFP3))/abs(mean(CLFP3)) <= 0.3]) >= 2
%         mostUnderCV = 1;
%     else
%         mostUnderCV = 0;
%     end
%     
%     
% 
%     
%     
%     if grandCV <= 0.3 || mostUnderCV;
%         lfpID = 'NO';
%         lfpBool = 0;
%     else
%         lfpID = 'YES';
%         lfpBool = 1;
%     end
%     
% else
%     lfpID = 'NO';
%     lfpBool = 0;
% end
           