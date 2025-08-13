
%% 2024.09.06 note
% Audience preprocessing scripts
% author: Yaner Su 



%% ==================================
% % %% preprocess
% % % location
% % % remove HEOG VEOG
% % % filter 0.1-30Hz
% ==============
% visual check 
% ==============
% % % remove bad channels
% % % rename T8 and M2, channel M2 was named as T8 when recording
% % % interpolation
% ==============
% trigger selected
% discard [65/67 85/87 66/68 86/88] after [25]
% rename them as [99]
% 
%% =============== For time-locked to feedback components ===============
% % % epoch and trials check 
%         for 【time-locked to feedback】and【time-locked to response】seperately
% % % run ICA
% % % remove component
% % % reject trials above 100
% % % re-reference

addpath('\eeglab14_1_1b');

eeglab;close all
%% 
clc;
clear;
close all;

%% 
% location 
% remove HEOG VEOG
% filter 0.1-30Hz
% save 

loadPath = 'D:\data\audience\EEG\rawData\';
savePath = 'D:\data\audience\EEG\1_fliter\';


for subjID = 1:47
    
loadName = strcat('sub', num2str(subjID), '.cnt'); 
saveName = strcat('sub',num2str(subjID), '_fliter.set');
% load
EEG = pop_loadcnt(strcat(loadPath,loadName));

% channel location 
EEG=pop_chanedit(EEG, 'lookup','D:\\MatlabTool\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');

% remove
EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG'});

% filter
EEG = pop_eegfiltnew(EEG, [],0.1,16500,1,[],0);
EEG = pop_eegfiltnew(EEG, [],30,220,0,[],0);

% save
% EEG = pop_saveset( EEG, strcat(savePath, saveName));
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
EEG = eeg_checkset( EEG );

end


%% visual check 
EEG = pop_loadcnt('D:\data\audience\EEG\rawData\sub41.cnt' , 'dataformat', 'auto', 'memmapfile', '');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);

%% rename T8 as M2


loadPath = 'D:\data\audience\EEG\1_fliter\';
savePath = 'D:\data\audience\EEG\2_rename\';

for i = 1:47
    
loadName = strcat('sub',num2str(i), '_fliter.set');
saveName = strcat('sub',num2str(i), '_rename.set');

% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);

% rename 
EEG=pop_chanedit(EEG, 'changefield',{10 'labels' 'M2'},'lookup','D:\\MatlabTool\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');

% save 
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);

end


%% intepolation  

clc
clear
eeglab
loadPath = 'D:\data\audience\EEG\2_rename\';
savePath = 'D:\data\audience\EEG\3_inte\';


subjID = 33

loadName = strcat('sub', num2str(subjID), '_rename.set'); 
saveName = strcat('sub',num2str(subjID), '_inte.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);

eeglab redraw
%%
% intepolation 

% save
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
EEG = eeg_checkset( EEG );

disp(strcat('sub-',num2str(subjID), '-done'));

close all


%% rename mark 
% after [25] and bug interval 

clc;clear;close all
loadPath = '\audience\EEG\3_inte\';
savePath = 'audience\EEG\4_remarked\';

file = dir([loadPath, '*.set']);
[filename,subID,~] = natsortfiles({file.name});
subNum = length(filename);
subID = sort(subID);

charID = [1 13 17 18 22 32];
doubleID =[2 3 4 5 6 7 8 9 10 11 12 14 15 16 19 20 21 23 24 25 26 27 28 29 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47];

for i = 1:length(charID)
    loadName = filename{charID(i)};
    saveName = strcat('sub', num2str(charID(i)), '_remark.set');
    EEG = pop_loadset('filename',loadName, 'filepath',loadPath);
    
    % rename mark after 25 as 99 
    for j = 2:length(EEG.event)-2
        if str2double(EEG.event(j).type) ==25;
            EEG.event(j+1).type = '99';
            EEG.event(j+2).type = '99';
        end
    end
    
%     for j = 2:length(EEG.event)-2
%         if str2double(EEG.event(j).type) <30
%             trials_int(1,j) = j;
%             trials_int(2,j) = EEG.event(j+2).latency- EEG.event(j+1).latency;
%         end
%     end
%     
%     trials = trials_int(:,any(trials_int));
%     
%     for j = 1:length(trials)
%         % remove the repeat mark all
%         if trials(2,j) == 0
%             EEG.event(trials(1,j)+1).type = '99';
%             EEG.event(trials(1,j)+2).type = '99';
%             EEG.event(trials(1,j)+3).type = '99';
%             EEG.event(trials(1,j)+4).type = '99';
%         end
%         
%         % remove the fb mark but keep the resp mark 
%         if trials(2,j) < 160
%             EEG.event(trials(1,j)+2).type = '99';
%         end
%     end
    
    EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
end

%%
for i = 30:length(doubleID)
    loadName = filename{doubleID(i)};
    saveName = strcat('sub', num2str(doubleID(i)), '_remark.set');
    EEG = pop_loadset('filename',loadName, 'filepath',loadPath);
    
    % rename mark after 25 as 99 
    for j = 2:length(EEG.event)-2
        if EEG.event(j).type ==25;
            EEG.event(j+1).type = 99;
            EEG.event(j+2).type = 99;
        end
    end
    
%     for j = 2:length(EEG.event)-2
%         if EEG.event(j).type <30
%             trials_int(1,j) = j;
%             trials_int(2,j) = EEG.event(j+2).latency- EEG.event(j+1).latency;
%         end
%     end
    
%     trials = trials_int(:,any(trials_int));
%     
%     for j = 1:length(trials)
%         % remove the repeat mark all
%         if trials(2,j) == 0
%             EEG.event(trials(1,j)+1).type = '99';
%             EEG.event(trials(1,j)+2).type = '99';
%             EEG.event(trials(1,j)+3).type = '99';
%             EEG.event(trials(1,j)+4).type = '99';
%         end
%         
%         % remove the fb mark but keep the resp mark 
%         if trials(2,j) < 160
%             EEG.event(trials(1,j)+2).type = '99';
%         end
%     end
    
    EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
end

%% ================ Time-locked to Feedback ================================
%% epoch 

% epoch [-0.5 1]
% baseline -0.2
% %% 
clc;
clear;
close all;

%
loadPath = '\audience\EEG\4_remarked\';
savePath = '\audience\EEG\5_epoch\';

% file = dir([loadPath, '*.set']);
% [filename,subID,~] = natsortfiles({file.name});
% subNum = length(filename);
% subID = sort(subID);

for i = 1:47
    
loadName = strcat('sub',num2str(i), '_remark.set');
saveName = strcat('sub',num2str(i), '_epoch.set');

% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);


% epoch and baseline 
EEG = pop_epoch( EEG, {  '31'  '33'  '36'  '38'  '39'  '41'  '43'  '46'  '48'  '49'  '61'  '63'  '66'  '68'  '69'  '81'  '83'  '86'  '88'  '89'  },...
    [-0.5     1], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
EEG = pop_rmbase( EEG, [-200    0]);


% save
% parsave(EEG, saveName{i}, savePath);
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);

end

%% trials check 
loadPath = '\audience\EEG\5_epoch\';
file = dir([loadPath, '*.set']);
[filename,subID,~] = natsortfiles({file.name});
subNum = length(filename);
subID = sort(subID);

for i = 1:length(filename)
    
loadName = filename(i); 
saveName = strcat('sub',num2str(subID(i)), '_epoch.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
remainTrial(i,1) = i;
remainTrial(i,2) = EEG.trials;
end 
csvwrite([loadPath,'remainTrials.csv'],remainTrial);

%% run ICA
clc;
clear;
loadPath = '\audience\EEG\5_epoch\';
savePath = '\audience\EEG\6_runICA\';


parfor subjID = 1:47
     
loadName = strcat('sub', num2str(subjID), '_epoch.set'); 
saveName = strcat('sub',num2str(subjID), '_ICA.set');

% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );

% run ICA
EEG = pop_runica(EEG, 'extended',1,'pca',50,'interupt','on');
EEG = eeg_checkset( EEG );

% save
parsave(EEG, saveName, savePath);
% EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
% EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));

end

%% reject ICA
clc;clear;close all
eeglab;
loadPath = '//audience/EEG/6_runICA/';
savePath = '//audience/EEG/7_rmICA/';

subID = 47
loadName = strcat('sub', num2str(subID), '_ICA.set'); 
saveName = strcat('sub',num2str(subID), '_rjICA.set');
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
eeglab redraw

pop_prop( EEG, 0, [1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19 20], NaN, {'freqrange' [2 50] });

%%

EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
disp(strcat('------ sub', num2str(subID),' done ------'));




%%
% reject epoch above 100??V
clc;clear; 

loadPath = '\audience\EEG\7_rmICA\';
savePath = '\audience\EEG\8_rj100\';
i = 0;
for subjID =1:47
 i = i+1;
loadName = strcat('sub', num2str(subjID), '_rjICA.set'); 
saveName = strcat('sub',num2str(subjID), '_rj100.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );
% origal trials
remainTrial(i,2) = EEG.trials;
% reject 
EEG = pop_eegthresh(EEG,1,[1:62] ,-100,100,-0.2,0.998,0,1);
EEG = eeg_checkset( EEG );

% % save
% EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
% EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));

remainTrial(i,1) = subjID;
remainTrial(i,3) = EEG.trials;

end
xlswrite([savePath,'remainTrials.xlsx'],remainTrial);

%% re-reference to average of M1 and M2
clc;clear; 

loadPath = '/audience/EEG/version5/8_rj100/';
savePath = '/audience/EEG/version5/9_reref/';

for subjID = 1:47;
loadName = strcat('sub', num2str(subjID), '_rj100.set'); 
saveName = strcat('sub',num2str(subjID), '_reref.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );

% average rereference
% add M1
EEG=pop_chanedit(EEG, 'append',2,'changefield',{3 'labels' 'M1'},'lookup','D:\\MatlabTool\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
% average
EEG = pop_reref( EEG, [],'refloc',struct('labels',{'M1'},'type',{''},'theta',{-100.419},'radius',{0.74733},'X',{-10.9602},'Y',{59.6062},'Z',{-59.5984},'sph_theta',{100.419},'sph_phi',{-44.52},'sph_radius',{85},'urchan',{3},'ref',{''},'datachan',{0}));
% M1 M2
EEG = pop_reref( EEG, [10 63] );

% save
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));


end




%% ===================== Time-locked to Response =================================
%% epoch 


% %% 
clc;
clear;
close all;

%
loadPath = '\audience\EEG\4_remarked\';
savePath = '\audience\EEG\ERN\4_epoch\';

% file = dir([loadPath, '*.set']);
% [filename,subID,~] = natsortfiles({file.name});
% subNum = length(filename);
% subID = sort(subID);

for i = 1:47
    
loadName = strcat('sub',num2str(i), '_remark.set');
saveName = strcat('sub',num2str(i), '_epoch.set');

% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);


% epoch and baseline 

EEG = pop_epoch( EEG, {  '30'  '32'  '34'  '35'  '37'  '40'  '42'  '44'  '45'  '47'  '60'  '62'  '64'  '65'  '67'  '80'  '82'  '84' '85' '87'   },...
    [-0.8     0.3], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
EEG = pop_rmbase( EEG, [-800    -700]);


% save
% parsave(EEG, saveName{i}, savePath);
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);

end


%% run ICA
clc;
clear;
 
loadPath = '\audience\EEG\ERN\4_epoch\';
savePath =  '\audience\EEG\ERN\5_runICA\';


parfor subjID = 1:47
     
loadName = strcat('sub', num2str(subjID), '_epoch.set'); 
saveName = strcat('sub',num2str(subjID), '_ICA.set');

% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );

% run ICA
EEG = pop_runica(EEG, 'extended',1,'pca',50,'interupt','on');
EEG = eeg_checkset( EEG );

% save
parsave(EEG, saveName, savePath);
% EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
% EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));

end

%% reject ICA
clc;clear;close all
eeglab;
loadPath = '\audience\EEG\ERN\5_runICA\';
savePath = '\audience\EEG\ERN\6_rjICA\';

subID = 21
loadName = strcat('sub', num2str(subID), '_ICA.set'); 
saveName = strcat('sub',num2str(subID), '_rjICA.set');
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
eeglab redraw

pop_prop( EEG, 0, [1:10 ], NaN, {'freqrange' [2 50] });

%%

EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
disp(strcat('------ sub', num2str(subID),' done ------'));




%%
% reject epoch above 100¦ÌV
clc;clear; 

loadPath = '\audience\EEG\ERN\version5\6_rjICA\';
savePath = '\audience\EEG\ERN\version5\7_rj100\';
i = 0;
for subjID = 2
 i = i+1;
loadName = strcat('sub', num2str(subjID), '_rjICA.set'); 
saveName = strcat('sub',num2str(subjID), '_rj100.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );
% origal trials
remainTrial(i,2) = EEG.trials;
% reject 
EEG = pop_eegthresh(EEG,1,[1:62] ,-100,100,-0.2,0.998,0,1);
EEG = eeg_checkset( EEG );

% save
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));

remainTrial(i,1) = subjID;
remainTrial(i,3) = EEG.trials;

end
xlswrite([savePath,'remainTrials_2.xlsx'],remainTrial);

%% re-reference
clc;clear; 

loadPath = '\audience\EEG\ERN\7_rj100\';
savePath = '\audience\EEG\ERN\8_reref\';
for subjID = 9:47
loadName = strcat('sub', num2str(subjID), '_rj100.set'); 
saveName = strcat('sub',num2str(subjID), '_reref.set');
% load
EEG = pop_loadset('filename',loadName,'filepath',loadPath);
EEG = eeg_checkset( EEG );

% average rereference
% add M1
EEG=pop_chanedit(EEG, 'append',2,'changefield',{3 'labels' 'M1'},'lookup','D:\\MatlabTool\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
% average
EEG = pop_reref( EEG, [],'refloc',struct('labels',{'M1'},'type',{''},'theta',{-100.419},'radius',{0.74733},'X',{-10.9602},'Y',{59.6062},'Z',{-59.5984},'sph_theta',{100.419},'sph_phi',{-44.52},'sph_radius',{85},'urchan',{3},'ref',{''},'datachan',{0}));
% M1 M2
EEG = pop_reref( EEG, [10 63] );

% save
EEG = pop_saveset( EEG, 'filename',saveName,'filepath',savePath);
EEG = eeg_checkset( EEG );

disp(strcat('------ sub', num2str(subjID),' done ------'));


end









