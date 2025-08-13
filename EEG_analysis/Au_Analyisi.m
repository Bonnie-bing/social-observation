%% Note
% Audience analysis scripts
% author: Yaner Su 

%%
clear all; clc; close all 

%%  ================ Time-locked to Feedback ============================

% sub 32 and 35 33 was excluded due to rejecting too many trials
AudienceSub = [2 3 6 8 9 11 14 15 17 18 21 23 24 27 28 31 37 42 43 44 46 47];
AloneSub = [1 4 5 7 10 12 13 16 19 20 22 25 26 29 30 34 36 38 39 40 41 45];

% 24 conditions
% between: social context(audience/alone)
% within: 
%   vaildity(deterministic/probabilistic/chance)
%   feedback(positive/negative)
%   bins(bin1/bin2)
% 
% %
% CondDet = {'31';'61';'41';'81'}; %% PoDet1, PoDet2, NeDet1, NeDet2
% CondPro = {'33','39';'63','69';'43','49';'83','89'};%% PoPro1, PoPro2, NePro1, NePro2
% CondCha = {'36','38';'66','68';'46','48';'86','88'};%% PoCha1, PoCha2, NeCha1, NeCha2

% valid only 
CondDet = {'31';'61';'41';'81'}; %% PoDet1, PoDet2, NeDet1, NeDet2
CondPro = {'33';'63';'43';'83'};%% PoPro1, PoPro2, NePro1, NePro2
CondCha = {'36','38';'66','68';'46','48';'86','88'};%% PoCha1, PoCha2, NeCha1, NeCha2
         
loadPath = '\audience\EEG\FRN\1_reref\'; %% filepath 
savePath = '\audience\EEG\FRN\2_ERP\'; 


%%
% ==== Alone =============================================
% ---- Det Pro Cha ----
% ---- positive bin1, positive bin2, negative bin1, negative bin2--------
for i = 1 :length(AloneSub) % each subject
%     for i = 8
    loadName = strcat('sub',num2str(AloneSub(i)),'_com_reref.set'); 
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
%     lowpass 7H for plot
    EEG = pop_eegfiltnew(EEG, [],7,826,0,[],0);

    for j = 1:length(CondDet) % each condition: positive-bin1 and
             
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100  0]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlDet(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AloneTrial.Det(i,j) = EEG_new.trials;
        
        %Pro 
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100     0]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlPro(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AloneTrial.Pro(i,j) = EEG_new.trials;
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100     0]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlCha(i,j,:,:) = squeeze(mean(EEG_new.data,3));    
        AloneTrial.Cha(i,j) = EEG_new.trials;
    end 
end

%%

% ==== Audience =============================================
% ---- Det Pro Cha ----
% ---- positive bin1, positive bin2, negative bin1, negative bin2-------

for i = 1:length(AudienceSub)
    
    loadName = strcat('sub',num2str(AudienceSub(i)),'_com_reref.set');    
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
%     lowpass 7H for plot
    EEG = pop_eegfiltnew(EEG, [],7,826,0,[],0);
    
    for j = 1:length(CondDet)
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100     0]); %%
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuDet(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Det(i,j) = EEG_new.trials;
        
        % Pro
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100     0]); %% 
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuPro(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Pro(i,j) = EEG_new.trials;
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.2  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-100     0]); % chan*times*trials
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuCha(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Cha(i,j) = EEG_new.trials;
    end 
end
%%

% difference wave 
% negative - positive (3-1,4-2)

% == audience=====

for i = 1:size(EEG_AuDet,1);% subj
    for k = 1:size(EEG_AuDet,3); % channel
        % Det
        EEG_AuDet_diff(i,1,k,:) = EEG_AuDet(i,3,k,:) - EEG_AuDet(i,1,k,:);
        EEG_AuDet_diff(i,2,k,:) = EEG_AuDet(i,4,k,:) - EEG_AuDet(i,2,k,:);
        % Pro
        EEG_AuPro_diff(i,1,k,:) = EEG_AuPro(i,3,k,:) - EEG_AuPro(i,1,k,:);
        EEG_AuPro_diff(i,2,k,:) = EEG_AuPro(i,4,k,:) - EEG_AuPro(i,2,k,:);
        % Cha
        EEG_AuCha_diff(i,1,k,:) = EEG_AuCha(i,3,k,:) - EEG_AuCha(i,1,k,:);
        EEG_AuCha_diff(i,2,k,:) = EEG_AuCha(i,4,k,:) - EEG_AuCha(i,2,k,:);
        
    end
end



% == alone =====

for i = 1:size(EEG_AlDet,1);% subj
    for k = 1:size(EEG_AlDet,3); % channel
        % Det
        EEG_AlDet_diff(i,1,k,:) = EEG_AlDet(i,3,k,:) - EEG_AlDet(i,1,k,:);
        EEG_AlDet_diff(i,2,k,:) = EEG_AlDet(i,4,k,:) - EEG_AlDet(i,2,k,:);
        % Pro
        EEG_AlPro_diff(i,1,k,:) = EEG_AlPro(i,3,k,:) - EEG_AlPro(i,1,k,:);
        EEG_AlPro_diff(i,2,k,:) = EEG_AlPro(i,4,k,:) - EEG_AlPro(i,2,k,:);
        % Cha
        EEG_AlCha_diff(i,1,k,:) = EEG_AlCha(i,3,k,:) - EEG_AlCha(i,1,k,:);
        EEG_AlCha_diff(i,2,k,:) = EEG_AlCha(i,4,k,:) - EEG_AlCha(i,2,k,:);
    end
end

% 
% cond: 
% 1-4,5:6:    Det-> posi_1, posi_2, nega_1, nega_2, Det (nega-posi)_1, (nega-posi)_2
% 7-10,11:12: Pro
% 13-16,17:18: Chance

CondName = {'PoDet1', 'PoDet2', 'NeDet1', 'NeDet2','Det Nega-posti 1','Det Nega-posti 2',...
               'PoPro1', 'PoPro2', 'NePro1', 'NePro2','Pro Nega-posti 1','Pro Nega-posti 2',...
               'PoCha1', 'PoCha2', 'NeCha1', 'NeCha2','Cha Nega-posti 1','Cha Nega-posti 2'};

EEG_Au(:,1:4,:,:)   = EEG_AuDet;
EEG_Au(:,5:6,:,:)   = EEG_AuDet_diff;
EEG_Au(:,7:10,:,:)   = EEG_AuPro;
EEG_Au(:,11:12,:,:)   = EEG_AuPro_diff;
EEG_Au(:,13:16,:,:)  = EEG_AuCha;
EEG_Au(:,17:18,:,:) = EEG_AuCha_diff;

EEG_Al(:,1:4,:,:)   = EEG_AlDet;
EEG_Al(:,5:6,:,:)   = EEG_AlDet_diff;
EEG_Al(:,7:10,:,:)   = EEG_AlPro;
EEG_Al(:,11:12,:,:)   = EEG_AlPro_diff;
EEG_Al(:,13:16,:,:)  = EEG_AlCha;
EEG_Al(:,17:18,:,:) = EEG_AlCha_diff;
% 
% EEG_all(:,1:18,:,:) = EEG_Au;
% EEG_all(:,19:36,:,:) = EEG_Al;

clear g i j k 
save([savePath,'audience_group_ERP_7Hz_S44.mat']);



%% combine two bins 

EEG_AuDetBin(:,1,:,:) = squeeze(mean(EEG_AuDet(:,[1 2],:,:),2));
EEG_AuDetBin(:,2,:,:) = squeeze(mean(EEG_AuDet(:,[3 4],:,:),2));
EEG_AuProBin(:,1,:,:) = squeeze(mean(EEG_AuPro(:,[1 2],:,:),2));
EEG_AuProBin(:,2,:,:) = squeeze(mean(EEG_AuPro(:,[3 4],:,:),2));
EEG_AuChaBin(:,1,:,:) = squeeze(mean(EEG_AuCha(:,[1 2],:,:),2));
EEG_AuChaBin(:,2,:,:) = squeeze(mean(EEG_AuCha(:,[3 4],:,:),2));

EEG_AuBin(:,1:2,:,:) = EEG_AuDetBin;
EEG_AuBin(:,3:4,:,:) = EEG_AuProBin;
EEG_AuBin(:,5:6,:,:) = EEG_AuChaBin;



EEG_AlDetBin(:,1,:,:) = squeeze(mean(EEG_AlDet(:,[1 2],:,:),2));
EEG_AlDetBin(:,2,:,:) = squeeze(mean(EEG_AlDet(:,[3 4],:,:),2));
EEG_AlProBin(:,1,:,:) = squeeze(mean(EEG_AlPro(:,[1 2],:,:),2));
EEG_AlProBin(:,2,:,:) = squeeze(mean(EEG_AlPro(:,[3 4],:,:),2));
EEG_AlChaBin(:,1,:,:) = squeeze(mean(EEG_AlCha(:,[1 2],:,:),2));
EEG_AlChaBin(:,2,:,:) = squeeze(mean(EEG_AlCha(:,[3 4],:,:),2));

EEG_AlBin(:,1:2,:,:) = EEG_AlDetBin;
EEG_AlBin(:,3:4,:,:) = EEG_AlProBin;
EEG_AlBin(:,5:6,:,:) = EEG_AlChaBin;


save('audience_Group_ERP_S45.mat','EEG_AlDet','EEG_AlPro','EEG_AlCha','EEG_AuDet','EEG_AuPro','EEG_AuCha')


%% +++++++++++++++++++++ Time-locked to Response +++++++++++++++++++++++++++++++++


% sub 32, 35 was excluded due to rejecting too many trials
% sub 1, 3, 4, 5, 6, 7, 8 were excluded due to RT mark 
AudienceSub = [2 9 11 14 15 17 18 21 23 24 27 28 31 37 42 43 44 46 47];
AloneSub = [10 12 13 16 19 20 22 25 26 29 30 33 34 36 38 39 40 41 45];



% 24 conditions
% between: social context(audience/alone)
% within: 
%   vaildity(deterministic/probabilistic/chance)
%   feedback(positive/negative)
%   bins(bin1/bin2)

%
CondDet = {'30';'60';'40';'80'}; %% CorDet1, CorDet2, IncDet1, IncDet2
CondPro = {'32','34';'62','64';'42','44';'82','84'};%% CorPro1, CorPro2, IncPro1, IncPro2
CondCha = {'35','37';'65','67';'45','47';'85','87'};%% CorCha1, CorCha2, IncCha1, IncCha2

         
loadPath = '\Audience\EEG\ERN\8_reref\'; %% filepath 
savePath = '\Audience\EEG\ERN\9_ERN\'; 
%%
% ==== Alone =============================================
% ---- Det Pro Cha ----
% ---- correct bin1, correct bin2, error bin1, error bin2--------
for i = 1:length(AloneSub) % each subject
    
    loadName = strcat('sub',num2str(AloneSub(i)),'_reref.set'); 
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
    % lowpass 7H for plot
%     EEG = pop_eegfiltnew(EEG, [],7,826,0,[],0);

    for j = 1:length(CondDet) % each condition: correct-bin1 and ……
        
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlDet(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AloneTrial.Det(i,j) = EEG_new.trials;
        
        %Pro 
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlPro(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AloneTrial.Pro(i,j) = EEG_new.trials;
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); %% baseline correction for EEG_new
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AlCha(i,j,:,:) = squeeze(mean(EEG_new.data,3));    
        AloneTrial.Cha(i,j) = EEG_new.trials;
    end 
    
    disp(strcat('sub-',num2str(AloneSub(i)),'-was-done'));
    
end


% ==== Audience =============================================
% ---- Det Pro Cha ----
% ---- correct bin1, correct bin2, error bin1, error bin2--------

for i = 1:length(AudienceSub)
    
    loadName = strcat('sub',num2str(AudienceSub(i)),'_reref.set');    
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
    % lowpass 7H for plot
%     EEG = pop_eegfiltnew(EEG, [],7,826,0,[],0);
    
    for j = 1:length(CondDet)
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); %%
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuDet(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Det(i,j) = EEG_new.trials;
        
        % Pro
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); %% 
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuPro(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Pro(i,j) = EEG_new.trials;
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.8  0.3], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes'); 
        EEG_new = pop_rmbase( EEG_new, [-800  -700]); % chan*times*trials
        % average arcoss trials
        % subj*cond*chan*times
        EEG_AuCha(i,j,:,:) = squeeze(mean(EEG_new.data,3)); 
        AuTrial.Cha(i,j) = EEG_new.trials;
    end 
end


%% difference wave 
% negative - positive (3-1,4-2) error - correct
% ---- correct bin1, correct bin2, error bin1, error bin2--------
% == audience=====

for i = 1:size(EEG_AuDet,1)% subj
    for k = 1:size(EEG_AuDet,3) % channel
        % Det
        EEG_AuDet_diff(i,1,k,:) = EEG_AuDet(i,3,k,:) - EEG_AuDet(i,1,k,:);
        EEG_AuDet_diff(i,2,k,:) = EEG_AuDet(i,4,k,:) - EEG_AuDet(i,2,k,:);
        % Pro
        EEG_AuPro_diff(i,1,k,:) = EEG_AuPro(i,3,k,:) - EEG_AuPro(i,1,k,:);
        EEG_AuPro_diff(i,2,k,:) = EEG_AuPro(i,4,k,:) - EEG_AuPro(i,2,k,:);
        % Cha
        EEG_AuCha_diff(i,1,k,:) = EEG_AuCha(i,3,k,:) - EEG_AuCha(i,1,k,:);
        EEG_AuCha_diff(i,2,k,:) = EEG_AuCha(i,4,k,:) - EEG_AuCha(i,2,k,:);
        
    end
end



% == alone =====

for i = 1:size(EEG_AlDet,1)% subj
    for k = 1:size(EEG_AlDet,3) % channel
        % Det
        EEG_AlDet_diff(i,1,k,:) = EEG_AlDet(i,3,k,:) - EEG_AlDet(i,1,k,:);
        EEG_AlDet_diff(i,2,k,:) = EEG_AlDet(i,4,k,:) - EEG_AlDet(i,2,k,:);
        % Pro
        EEG_AlPro_diff(i,1,k,:) = EEG_AlPro(i,3,k,:) - EEG_AlPro(i,1,k,:);
        EEG_AlPro_diff(i,2,k,:) = EEG_AlPro(i,4,k,:) - EEG_AlPro(i,2,k,:);
        % Cha
        EEG_AlCha_diff(i,1,k,:) = EEG_AlCha(i,3,k,:) - EEG_AlCha(i,1,k,:);
        EEG_AlCha_diff(i,2,k,:) = EEG_AlCha(i,4,k,:) - EEG_AlCha(i,2,k,:);
    end
end

%% 
% cond: 
% 1-4,5:6:    Det-> cor_1, cor_2, err_1, err_2, Det (nega-posi)_1, (nega-posi)_2
% 7-10,11:12: Pro
% 13-16,17:18: Chance

CondName = {'CorDet1', 'CorDet2', 'ErrDet1', 'ErrDet2','Det ERN-CRN 1','Det ERN-CRN 2',...
               'CorPro1', 'CorPro2', 'ErrPro1', 'ErrPro2','Pro Nega-posti 1','Pro ERN-CRN 2',...
               'CorCha1', 'CorCha2', 'ErrCha1', 'ErrCha2','Cha ERN-CRN 1','Cha ERN-CRN 2'};

EEG_Au(:,1:4,:,:)   = EEG_AuDet;
EEG_Au(:,5:6,:,:)   = EEG_AuDet_diff;
EEG_Au(:,7:10,:,:)   = EEG_AuPro;
EEG_Au(:,11:12,:,:)   = EEG_AuPro_diff;
EEG_Au(:,13:16,:,:)  = EEG_AuCha;
EEG_Au(:,17:18,:,:) = EEG_AuCha_diff;

EEG_Al(:,1:4,:,:)   = EEG_AlDet;
EEG_Al(:,5:6,:,:)   = EEG_AlDet_diff;
EEG_Al(:,7:10,:,:)   = EEG_AlPro;
EEG_Al(:,11:12,:,:)   = EEG_AlPro_diff;
EEG_Al(:,13:16,:,:)  = EEG_AlCha;
EEG_Al(:,17:18,:,:) = EEG_AlCha_diff;
% 
% EEG_all(:,1:18,:,:) = EEG_Au;
% EEG_all(:,19:36,:,:) = EEG_Al;

clear g i j k 
save([savePath,'audience_group_ERN_S38.mat']);


%% **************************************** Time-frequency locked to Feedback *************************************************

% single subject 

filename = '\Audience\EEG\FRN\9_reref\sub3_reref.set'; 
EEG = pop_loadset(filename);
x = squeeze(EEG.data(19,:,:)); 
xtimes=EEG.times/1000;  % from in -ms to in -s 
t=EEG.times/1000;
f=1:1:30;  
Fs = EEG.srate;
winsize = 0.150; 

[S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize); 
P_AlDet=squeeze(mean(P,3)); 


t_pre_idx=find((t>=-0.3)&(t<=-0.2));

for i=1:size(P_AlDet,1) 
    temp_data=squeeze(P_AlDet(i,:));
    BC_AlDet(i,:)=temp_data-mean(temp_data(t_pre_idx)); 
end


figure;  
subplot(211); imagesc(t,f,P_AlDet); 
axis xy; 
hold on;  axis xy; colorbar;
xlabel('Time (ms)','fontsize',12); ylabel('Frequency (Hz)','fontsize',12); 
title('TFR (without baseline correction)','fontsize',15);
subplot(212); imagesc(t,f,BC_AlDet); axis xy; 
hold on;  axis xy; colorbar; 
caxis([-1 1]);
xlabel('Time (ms)','fontsize',12); ylabel('Frequency (Hz)','fontsize',12); 
title('Baseline-corrected TFR','fontsize',15);



%% time-frequency analysis of several subjects
clc;clear;
%%
AudienceSub = [2 3 6 8 9 11 14 15 17 18 21 23 24 27 28 31 37 42 43 44 46 47];
AloneSub =      [1 4 5 7 10 12 13 16 19 20 22 25 26 29 30 34 36 38 39 40 41 45];


% valid only 
CondDet = {'31';'61';'41';'81'}; %% PoDet1, PoDet2, NeDet1, NeDet2
CondPro = {'33';'63';'43';'83'};%% PoPro1, PoPro2, NePro1, NePro2
CondCha = {'36','38';'66','68';'46','48';'86','88'};%% PoCha1, PoCha2, NeCha1, NeCha2



loadPath = '\Audience\EEG\FRN\9_reref\'; %% filepath 
savePath = '\Audience\EEG\FRN\10_ERP\'; 




% Alone
for i=1:length(AloneSub)
    
    loadName = strcat('sub',num2str(AloneSub(i)),'_reref.set');
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
    for j = 1:length(CondDet) % for each conditions
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); %% baseline correction for EEG_new
        
        % for each channel
        for nchan=1:EEG_new.nbchan
            x = squeeze(EEG_new.data(nchan,:,:)); % data * epoch
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; % 2ms
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            % subj*cond*chan*fre*time
            P_Al(i,j,nchan,:,:)=squeeze(mean(P,3));  % power
            
        end
        
        clear EEG_new 
        
        % Pro
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); %%
        
        for nchan=1:EEG_new.nbchan
            x = squeeze(EEG_new.data(nchan,:,:));
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; 
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            % power
            P_Al(i,j+4,nchan,:,:)=squeeze(mean(P,3));
            

        end
        
        clear EEG_new
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); 
        
        for nchan=1:EEG_new.nbchan
            x = squeeze(EEG_new.data(nchan,:,:));
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; % 2ms
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            % power
            P_Al(i,j+8,nchan,:,:)=squeeze(mean(P,3));


        end
        
        clear EEG_new
        
    end
end

% baseline corrected for each subj*cond*chan*fre
t_pre_idx=find((t>=-0.3)&(t<=-0.2));
for i=1:size(P_Al,1)
    for j=1:size(P_Al,2)
        for k=1:size(P_Al,3)
            for g = 1:size(P_Al,4)
            temp_data=squeeze(P_Al(i,j,k,g,:));
            BC_Al(i,j,k,g,:)=temp_data-mean(temp_data(t_pre_idx)); 
            end
        end
    end
end

save([savePath,'audience_group_TF_AI_S44.mat']);

%%
AudienceSub = [2 3 6 8 9 11 14 15 17 18 21 23 24 27 28 31 37 42 43 44 46 47];
AloneSub =      [1 4 5 7 10 12 13 16 19 20 22 25 26 29 30 34 36 38 39 40 41 45];


% valid only 
CondDet = {'31';'61';'41';'81'}; %% PoDet1, PoDet2, NeDet1, NeDet2
CondPro = {'33';'63';'43';'83'};%% PoPro1, PoPro2, NePro1, NePro2
CondCha = {'36','38';'66','68';'46','48';'86','88'};%% PoCha1, PoCha2, NeCha1, NeCha2



loadPath = '\Audience\EEG\FRN\9_reref\'; %% filepath 
savePath = '\Audience\EEG\FRN\10_ERP\'; 



% Audience
for i=1:length(AudienceSub)
    
    loadName = strcat('sub',num2str(AudienceSub(i)),'_reref.set');
    EEG = pop_loadset('filename',loadName,'filepath',loadPath);  %% load the data into EEG
    
    for j = 1:length(CondDet) % for each conditions
        % Det
        EEG_new = pop_epoch( EEG, CondDet(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); %% baseline correction for EEG_new
        
        % for each channel 
        for nchan=19 %1:EEG_new.nbchan;
            x = squeeze(EEG_new.data(nchan,:,:)); % data * epoch
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; % 2ms
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            % subj*cond*chan*fre*time
            
            % power
            P_Au(i,j,nchan,:,:)=squeeze(mean(P,3));

        end
        
        clear EEG_new 
        
        % Pro
        EEG_new = pop_epoch( EEG, CondPro(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); 
        
        for nchan=19 %1:EEG_new.nbchan;
            x = squeeze(EEG_new.data(nchan,:,:));
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; % 2ms
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            
            % power 
            P_Au(i,j+4,nchan,:,:)=squeeze(mean(P,3));
%             
                   

        end
        
        clear EEG_new 
        
        % Cha
        EEG_new = pop_epoch( EEG, CondCha(j,:), [-0.5  1], 'newname', 'datasets pruned with ICA', 'epochinfo', 'yes');
        EEG_new = pop_rmbase( EEG_new, [-100  0]); 
        
        for nchan=19 % 1:EEG_new.nbchan;
            x = squeeze(EEG_new.data(nchan,:,:));
            xtimes=EEG_new.times/1000;
            t=EEG_new.times/1000; % 2ms
            f=1:1:30;
            Fs = EEG_new.srate;
            winsize = 0.200;
            [S, P, F, U] = sub_stft(x, xtimes, t, f, Fs, winsize);
            
            % power
            P_Au(i,j+8,nchan,:,:)=squeeze(mean(P,3));
            

        end
        
        clear EEG_new 
        
    end
end



save([savePath,'audience_group_TF_Au_S44.mat']);



