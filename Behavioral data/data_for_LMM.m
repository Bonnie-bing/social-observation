%% final data description
%1=appearance:0-alone;1-other
%2=trial number
%3=block number
%4=bin number
%5=condition:1-6
%6=choice:1-left;2-right
%7=feedback: 0-incorrect;1-correct
%8=RT
%9=real_correct
%10=sub_id
%11=probability conditions:100%, 80%, 50%
%12=LR:1=left correct;2=right correct
%13=real trial number
%14=trial within each stimuli

%15=raw RT of immediate next trial
%16= RT differences of immediate next trial
%17=raw RT of immediate next trial,only for correct responses
%18=RT differences of immediate next trial,only for correct responses

%19=delay RT, RT of next trial of the same stimulus
%20=delay RT differences,RT differences of next trial of the same stimulus
%21=delay RT, RT of next trial of the same stimulus,only correct responses
%22=delay RT differences,RT differences of next trial of the same stimulus,only correct responses

%23=stay(1) or switch(0)
%24=congruent (1, win-stay or loss-switch) or incongruent (0, win-switch or loss-stay)
%25=reinforcement of the left key in the previous trial (chosen and correct or not chosen and correct:1, otherwise:0)
%26=reinforcement of the correct choice in the previous trial (chosen and correct or not chosen and correct:1, otherwise:0)

%27=number of delay (for effect of WM),NaN for the first trial

%28=total number of choosing the left key (per stimulus) in previous trials (for effect of decision inertia)
%29=total number of reward got for the left key of the current stimulus in previous trials (for effect of RL)
%30=total number of choosing the correct choice (per stimulus) in previous trials (for effect of decision inertia)
%31=total number of reward got for the correct choice of the current stimulus in previous trials (for effect of RL)
%32=total number of choosing the current choice (per stimulus) in previous trials (for effect of decision inertia)
%33=total number of reward got for the current choice of the current stimulus in previous trials (for effect of RL)

%% step0: load and transfer data
path=[pwd,filesep,'raw_data']; %
nTXT=dir(fullfile(path, '*Learning*.txt'));
all_data=[];
for i=1:length(nTXT)
    rData=textread([path '\' nTXT(i).name],'%s');
    [m,n]=size(rData);
    nData=reshape(rData,22,m*n/22);
    nData=nData';
    nData=nData(2:end,3:end);
    [m,n]=size(nData);
    t=0;
    for j=1:m
        if str2num(nData{j,5})==1  %block 1 are practicing trials, excluding them.
            continue;
        else
            t=t+1;
        end
        for k=1:n
            nData3(t,k)=str2num(nData{j,k});
        end
    end
    %% step01: clean data
    nData3(nData3(:,16)~=0,[11,12,13,14])=NaN; %setting time-out responses to NaN
    nData3(nData3(:,6)==2 & nData3(:,7)==5,[11,12,13,14])=NaN; %For condition 5, the valid is set to 0 in every trials for bin2. So data of this part cannot be used for further analysis.
    nData=nData3(:,[3,4,5,6,7,11,12,13,14,1]);
    nData(nData(:,5)<=2,11)=1; %100% condition
    nData(nData(:,5)>2 & nData(:,5)<=4,11)=2; %80% condition
    nData(nData(:,5)>=5,11)=3; %50% condition
    nData(mod(nData(:,5),2)==1,12)=1; %left correct
    nData(mod(nData(:,5),2)==0,12)=2; %right correct
    nData(:,13)=1:length(nData); %real trial number
    nData(:,3)=nData(:,3)-1; %Block number
    nData(:,14)=0; %trial within each stimuli.
    
    %% calculating data
    %calculate immedRT and immedRTdiff
    currRT                     =nData(:,8); % RT of the current trial
    currRT(currRT<=0.1)        =NaN; % set fast resp to NaN
    nextRT                     =[currRT(2:end);NaN]; %RT of the next trial,i.e., immediate RT
    nextRT(150:150:end)        =NaN;%set the RT of the first trial of each block to NaN.the end, i.e., number 750 is already NaN, so it is OK.
    diffRT                     =nextRT-currRT; % immediate RT differences
    nextACC                    =[nData(2:end,9);NaN]; %ACC of the next trial
    nextRT_corr                =nextRT;
    diffRT_corr                =diffRT;
    nextRT_corr(nextACC~=1)    = NaN; %only keep the correct response of the next trial
    diffRT_corr(nextACC~=1)    = NaN; %only keep the correct response of the next trial
    
    %note that for the following four varables, the variable of 'feedback' is the feedback of the previous trial.Also note that we did not
    %distinguish different levels of 'prob' when calculating them.
    nData(:,15)                =nextRT; % immediate RT
    nData(:,16)                =diffRT; % immediate RT differences
    nData(:,17)                =nextRT_corr; % immediate RT, only for correct response
    nData(:,18)                =diffRT_corr; % immediate RT differences, only for correct responses
    clear currRT nextRT diffRT nextACC nextRT_corr diffRT_corr
    for xmx=1:6 % 6 conditions/stimuli. If subjects did not respond on the previous trial, we will not compute the ss, cic, or delay RT.
        nData(nData(:,5)==xmx,14)       =repmat([1:25]',5,1); %trial number within each stimuli.
        tempData                        =nData(nData(:,5)==xmx,:);%get the data for the corresponding stimuli
        for block=1:5
            tempData2                   =tempData(tempData(:,3)==block,:);%get the data for the corresonding block
            currRT                      =tempData2(:,8);%current RT
            currRT(currRT<=0.1)         =NaN; % set fast resp to NaN
            nextRT                      =[currRT(2:end);NaN]; %RT of the next trial,i.e., delayRT
            diffRT                      =nextRT-currRT; % immediate RT differences
            nextACC                    =[tempData2(2:end,9);NaN]; %ACC of the next trial
            nextRT_corr                =nextRT;
            diffRT_corr                =diffRT;
            nextRT_corr(nextACC~=1)    = NaN; %only keep the correct response of the next trial
            diffRT_corr(nextACC~=1)    = NaN; %only keep the correct response of the next trial
            
            curr_choice                = tempData2(:,6);%current choice
            next_choice                = [curr_choice(2:end);NaN];%next choice
            stay_switch                = double(next_choice==curr_choice); % if they are the same, stay(1), else, switch(0).
            stay_switch(isnan(curr_choice) | isnan(next_choice))=NaN; %excluding non-responded trials
            cic                        = stay_switch;
            curr_feed                  = tempData2(:,7);%current feedback
            cic(curr_feed==0)          =1-cic(curr_feed==0);% if previous feedback is loss, transfer stay to 0 and switch to 1.
            cic(isnan(curr_choice) | isnan(next_choice))=NaN; %excluding non-responded trials
            re_choseL                  =double((curr_feed==1 & curr_choice==1) | (curr_feed==0 & curr_choice==2));
            re_choseL(isnan(curr_choice) | isnan(curr_feed))=NaN; %excluding non-responded trials
            curr_cc                    =tempData2(:,12);%correct choice of the current trial:1=L;2=R
            re_choseC                  =double((curr_feed==1 & ((curr_choice==1 & curr_cc==1) | (curr_choice==2 & curr_cc==2))) |...
                (curr_feed==0 & ((curr_choice==1 & curr_cc==2) | (curr_choice==2 & curr_cc==1))));
            re_choseL(isnan(curr_choice) | isnan(curr_feed))=NaN; %excluding non-responded trials
            
            tempData2(:,19)                =nextRT; % delay RT
            tempData2(:,20)                =diffRT; % delay RT differences
            tempData2(:,21)                =nextRT_corr; % delay RT, only for correct response
            tempData2(:,22)                =diffRT_corr; % delay RT differences, only for correct responses
            
            tempData2(:,23)                =stay_switch; % stay or switch
            tempData2(:,24)                =cic; % consistent or inconsistent
            tempData2(:,25)                =[NaN;re_choseL(1:end-1)]; % reinforcing the left key (1=yes,2=no)
            tempData2(:,26)                =[NaN;re_choseC(1:end-1)]; % reinforcing the correct key (1=yes,2=no)
            
            curr_Tr                        = tempData2(:,13);%current trial number;
            prev_Tr                        = [NaN; curr_Tr(1:end-1)];% previous trial number
            tempData2(:,27)                = curr_Tr - prev_Tr - 1; % delay number
            
            for t=2:25 % 25 trials per stim
                tempData2(t,28)=sum(tempData2(1:t-1,6)==1);% total number of choosing the left key
                tempData2(t,29)=sum(tempData2(1:t-1,7)==1 & tempData2(1:t-1,6)==1); % total number of reward got for the left key
                
                tempData2(t,30)=sum((tempData2(1:t-1,6)==1 & tempData2(1:t-1,12)==1) | (tempData2(1:t-1,6)==2 & tempData2(1:t-1,12)==2));% total number of choosing the correct choice
                tempData2(t,31)=sum(tempData2(1:t-1,7)==1 & ((tempData2(1:t-1,6)==1 & tempData2(1:t-1,12)==1) | (tempData2(1:t-1,6)==2 & tempData2(1:t-1,12)==2))); % total number of reward got for the correct choice
                
                tempData2(t,32)=sum(tempData2(1:t-1,6)==tempData2(t,6));% total number of choosing the current choice
                tempData2(t,33)=sum(tempData2(1:t-1,7)==1 & tempData2(1:t-1,6)==tempData2(t,6)); % total number of reward got for the current choice
            end
            
            clear currRT nextRT diffRT nextACC nextRT_corr diffRT_corr stay_switch cic curr_cc re_choseC curr_feed re_choseL re_choseC curr_Tr  prev_Tr
            
            tempData2=tempData2(:,[10,1,13,14,2:9,11,12,15:end]); %change the order
            all_data=[all_data;tempData2];
            clear tempData2
        end
        clear tempData
    end
    
    clear rData nData3 nData
end
%% export data
names={'subid','appearance','real_trial','trial_perC','trial','block','bin','cond','choice','feedback','RT','ACC','prob','LR',...
    'immedRT','immedRTdiff','immedRT_corr','immedRTdiff_corr','delayRT','delayRTdiff','delayRT_corr','delayRTdiff_corr',...
    'stay_switch','con_incon','Re_choseL','Re_choseC','delay','N_choseL','NC_choseL','N_choseC','NC_choseC','N_cur_choice','NC_cur_choice'}; %immedRT are stored in different ways than ss, cc or delayRT
commaheader = [names;repmat({','},1,numel(names))];
commaheader=commaheader(:)';
textheader=cell2mat(commaheader);

%% save data
fid = fopen('all_data.csv','w');
fprintf(fid,'%s\n',textheader);
fclose('all');
%write out data to end of file
dlmwrite('all_data.csv',all_data,'-append');
