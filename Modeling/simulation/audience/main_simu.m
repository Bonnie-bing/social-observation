
%% 1. load the data
% 1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay
[design,~,~] = xlsread('data_for_cm_all.xlsx');
subs         = unique(design(:,1));
nsub         = length(subs); % number of subjects.
samples      =6000; % number of samplings.
maxT         =750; % max number of trials for each subject.

%% 2. load the parameters
%[par,~,~]=xlsread('para_m1_all.xlsx');
paras = load('m7c2_subwise_para_audience.mat');

%% 3. simulation output
sim_data  = NaN(samples,maxT,18);
sim_data2 = NaN(samples,maxT,19);

%% 4. simulation for each subject: absolute fit methods
for n=1:length(subs)
    clear design_sub
    design_sub = design((design(:,1)==subs(n)) & (design(:,3)~=0),:);
    tn         = size(design_sub,1); % trial number for the current subject.
    for sn =1:samples
        sim_data(sn,1:tn,:)   = abs_fit_m7c2(paras,design_sub,n,sn);
        sim_data2(sn,1:tn,:)  = sim_fit_m7c2(paras,design_sub,n,sn);
    end
    
    % 3. do the average
    if n==1
        mean_sim_data   = squeeze(mean(sim_data(:,1:tn,:),1,'omitnan'));% average across the 1st dimension, i.e., the 'sn' dimension.
        mean_sim_data2  = squeeze(mean(sim_data2(:,1:tn,:),1,'omitnan'));% average across the 1st dimension, i.e., the 'sn' dimension.
        
    else
        mean_sim_data   = [mean_sim_data;squeeze(mean(sim_data(:,1:tn,:),1,'omitnan'))];% average across the 1st dimension, i.e., the 'sn' dimension.
        mean_sim_data2  = [mean_sim_data2;squeeze(mean(sim_data2(:,1:tn,:),1,'omitnan'))];% average across the 1st dimension, i.e., the 'sn' dimension.
    end
end

%% 5. integer the choices
% sim_data:  1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC, 10=choice_sim,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2
% sim_data2: 1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC, 10=choice_sim,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2,19=feed_sim
mean_sim_data(:,19)   = round(mean_sim_data(:,10));% make the choice_sim an integer
mean_sim_data2(:,20)  = round(mean_sim_data2(:,10));% make the choice_sim an integer
mean_sim_data2(:,21)  = NaN;
mean_sim_data2(mean_sim_data2(:,19)>=0,21)=1;
mean_sim_data2(mean_sim_data2(:,19)<0,21)=-1;

%% 6. save data
% sim_data:1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC,10=choice_sim_raw,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2,19=choice_sim
names={'subid',	'block','cond','feedback','choice','trial_perC2','probab','delay','ACC','choice_sim_raw','choice_prob_sim','PE','PE1','PE2','ev1','ev2','evck1','evck2','choice_sim'};
commaheader = [names;repmat({','},1,numel(names))];
commaheader=commaheader(:)';
textheader=cell2mat(commaheader);


fid = fopen('sim_data_m7c2_abs_fit_all.csv','w');
fprintf(fid,'%s\n',textheader);
%write out data to end of file
dlmwrite('sim_data_m7c2_abs_fit_all.csv',mean_sim_data,'-append');
%writematrix(sim_data,'sim_data_m7c2_abs_fit_all.csv','WriteMode','append');

fclose('all');

%sim_data2:1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC,10=choice_sim_raw,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2,19=feed_sim_raw,20=choice_sim,21=feed_sim
names={'subid',	'block','cond','feedback','choice','trial_perC2','probab','delay','ACC','choice_sim_raw','choice_prob_sim','PE','PE1','PE2','ev1','ev2','evck1','evck2','feed_sim_raw','choice_sim','feed_sim'};
commaheader = [names;repmat({','},1,numel(names))];
commaheader=commaheader(:)';
textheader=cell2mat(commaheader);

fid = fopen('sim_data_m7c2_sim_fit_all.csv','w');
fprintf(fid,'%s\n',textheader);
%write out data to end of file
dlmwrite('sim_data_m7c2_sim_fit_all.csv',mean_sim_data2,'-append');
%writematrix(sim_data2,'sim_data_m7c2_sim_fit_all.csv','WriteMode','append');

fclose('all');

%% 7. calculating some overall performance index
% sim_data:1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC,10=choice_sim_raw,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2,19=choice_sim
display(['abs_fit: Overall accuracy is: ',num2str(mean(mean_sim_data(:,5)==mean_sim_data(:,19)))]);
display(['abs_fit: Accuracy for 100% is: ',num2str(mean(mean_sim_data(mean_sim_data(:,7)==1,5)==mean_sim_data(mean_sim_data(:,7)==1,19)))]);
display(['abs_fit: Accuracy for 80% is: ',num2str(mean(mean_sim_data(mean_sim_data(:,7)==2,5)==mean_sim_data(mean_sim_data(:,7)==2,19)))]);
display(['abs_fit: Accuracy for 50% is: ',num2str(mean(mean_sim_data(mean_sim_data(:,7)==3,5)==mean_sim_data(mean_sim_data(:,7)==3,19)))]);

%sim_data2:1=subid,2=block,3=cond,4=feedback,5=choice,6=trial_perC2,7=probab,8=delay,9=ACC,10=choice_sim_raw,11=choice_prob_sim,12=PE,13=PE1,14=PE2,15=ev1,16=ev2,17=evck1,18=evck2,19=feed_sim_raw,20=choice_sim,21=feed_sim
display(['sim_fit: Overall accuracy is: ',num2str(mean(mean_sim_data2(:,5)==mean_sim_data2(:,20)))]);
display(['sim_fit: Accuracy for 100% is: ',num2str(mean(mean_sim_data2(mean_sim_data2(:,7)==1,5)==mean_sim_data2(mean_sim_data2(:,7)==1,20)))]);
display(['sim_fit: Accuracy for 80% is: ',num2str(mean(mean_sim_data2(mean_sim_data2(:,7)==2,5)==mean_sim_data2(mean_sim_data2(:,7)==2,20)))]);
display(['sim_fit: Accuracy for 50% is: ',num2str(mean(mean_sim_data2(mean_sim_data2(:,7)==3,5)==mean_sim_data2(mean_sim_data2(:,7)==3,20)))]);















