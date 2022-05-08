close all
clear all
clc

code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode';
data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_202320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

theta_plot = 0:0.01:2*pi;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
load('hold_still_duration')
load('target_hold_duration')
load('reach_duration')
load('peak_velocity')
load('path_length')
load('straightness')
load('js_pos_all')
load('js_vel_all')
load('js_acc_all')
load('theta_1_all')
load('theta_2_all')
load('torque_1_int_all')
load('torque_1_self_all')
load('torque_1_grav_all')
load('torque_1_muscle_all')
load('torque_2_int_all')
load('torque_2_self_all')
load('torque_2_grav_all')
load('torque_2_muscle_all')
load('EMG_biceps_all')
load('EMG_triceps_all')
load('EMG_a_delt_all')
load('EMG_p_delt_all')
load('EMG_biceps_ds_all')
load('EMG_triceps_ds_all')
load('EMG_a_delt_ds_all')
load('EMG_p_delt_ds_all')
cd(code_folder)

start_offset = -0.008;
end_offset = 0.1;

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 1000;

time_js = start_offset:1/Fs_js:end_offset;
time_js = time_js*1000;
time_EMG = start_offset:1/Fs_EMG:end_offset;
time_EMG = time_EMG*1000;
time_joint = start_offset:1/Fs_joint:end_offset;
time_joint = time_joint*1000;
window_size = length(time_js);

nIteration = 20;
nTrial = size(js_pos_all,1);
combinations = nchoosek(1:nTrial,2);

r_biceps_triceps_all = [];
r_biceps_a_delt_all = [];
r_biceps_p_delt_all = [];
r_triceps_a_delt_all = [];
r_triceps_p_delt_all = [];
r_a_delt_p_delt_all = [];
r_biceps_triceps_all_temp = [];
r_biceps_a_delt_all_temp = [];
r_biceps_p_delt_all_temp = [];
r_triceps_a_delt_all_temp = [];
r_triceps_p_delt_all_temp = [];
r_a_delt_p_delt_all_temp = [];

s = RandStream('mlfg6331_64'); 
for i = 1:nIteration
    idx_sample = datasample(s,1:nTrial,5,'Replace',true);
    
   
    EMG_biceps = mean(EMG_biceps_ds_all(idx_sample,:));
    EMG_triceps = mean(EMG_biceps_ds_all(idx_sample,:));
    EMG_a_delt = mean(EMG_a_delt_ds_all(idx_sample,:));
    EMG_p_delt = mean(EMG_p_delt_ds_all(idx_sample,:));
    

    [r_biceps_triceps,lags] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_triceps-mean(EMG_triceps),window_size,'coeff');
    [r_biceps_a_delt,~] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_a_delt-mean(EMG_a_delt),window_size,'coeff');
    [r_biceps_p_delt,~] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_p_delt-mean(EMG_p_delt),window_size,'coeff');
    [r_triceps_a_delt,~] = xcorr(EMG_triceps-mean(EMG_triceps),EMG_a_delt-mean(EMG_a_delt),window_size,'coeff');    
    [r_triceps_p_delt,~] = xcorr(EMG_triceps-mean(EMG_triceps),EMG_p_delt-mean(EMG_p_delt),window_size,'coeff');      
    [r_a_delt_p_delt,~] = xcorr(EMG_a_delt-mean(EMG_a_delt),EMG_p_delt-mean(EMG_p_delt),window_size,'coeff');
 
    r_biceps_triceps_all = [r_biceps_triceps_all;r_biceps_triceps];
    r_biceps_a_delt_all = [r_biceps_a_delt_all;r_biceps_a_delt];
    r_biceps_p_delt_all = [r_biceps_p_delt_all;r_biceps_p_delt];
    r_triceps_a_delt_all = [r_triceps_a_delt_all;r_triceps_a_delt];   
    r_triceps_p_delt_all = [r_triceps_p_delt_all;r_triceps_p_delt];   
    r_a_delt_p_delt_all = [r_a_delt_p_delt_all;r_a_delt_p_delt];
    
    
  
end

 %% Compute mean and se
y_biceps_triceps_1 = mean(r_biceps_triceps_all);
se_biceps_triceps_1 = std(r_biceps_triceps_all,[],1)./(sqrt(size(r_biceps_triceps_all,1)));
y_biceps_a_delt_1 = mean(r_biceps_a_delt_all);
se_biceps_a_delt_1 = std(r_biceps_a_delt_all,[],1)./(sqrt(size(r_biceps_a_delt_all,1)));
y_biceps_p_delt_1 = mean(r_biceps_p_delt_all);
se_biceps_p_delt_1 = std(r_biceps_p_delt_all,[],1)./(sqrt(size(r_biceps_p_delt_all,1)));
y_triceps_a_delt_1 = mean(r_triceps_a_delt_all);
se_triceps_a_delt_1 = std(r_triceps_a_delt_all,[],1)./(sqrt(size(r_triceps_a_delt_all,1)));
y_triceps_p_delt_1 = mean(r_triceps_p_delt_all);
se_triceps_p_delt_1 = std(r_triceps_p_delt_all,[],1)./(sqrt(size(r_triceps_p_delt_all,1)));
y_a_delt_p_delt_1 = mean(r_a_delt_p_delt_all);
se_a_delt_p_delt_1 = std(r_a_delt_p_delt_all,[],1)./(sqrt(size(r_a_delt_p_delt_all,1)));

%% Plot muscle torque at shoulder 
figure(1)
subplot(3,1,1:2)
patch([lags fliplr(lags)], [y_biceps_triceps_1(:)-se_biceps_triceps_1(:);  flipud(y_biceps_triceps_1(:)+se_biceps_triceps_1(:))],[35 140 204]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
hold on
plot(lags,mean(r_biceps_triceps_all),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
ylabel('Correlation')

r_biceps_triceps_all_fz = atanh(r_biceps_triceps_all);
for k = 1:size(r_biceps_triceps,2)
    [~,p(k)] = ttest(r_biceps_triceps_all_fz(:,k));
end
p = p*size(r_biceps_triceps,2);
p(p>0.1) = 0.1;
figure(1)
subplot(3,1,3)
plot(lags,p,'color','k','LineWidth',1)
hold on 
yline(0.05,'--','color','k','LineWidth',1)
ylabel({'Corrected','p-value'})
set(gca,'TickDir','out')
set(gca,'box','off')

% figure(2)
% subplot(3,1,1:2)
% patch([lags fliplr(lags)], [y_biceps_a_delt_1(:)-se_biceps_a_delt_1(:);  flipud(y_biceps_a_delt_1(:)+se_biceps_a_delt_1(:))],[35 140 204]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% hold on
% plot(lags,mean(r_biceps_a_delt_all),'LineWidth',2,'color',[35 140 204]/255)
% patch([lags fliplr(lags)], [y_biceps_a_delt_rand_1(:)-se_biceps_a_delt_rand_1(:);  flipud(y_biceps_a_delt_rand_1(:)+se_biceps_a_delt_rand_1(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% plot(lags,mean(r_biceps_a_delt_rand_all),'LineWidth',2,'color',[0 0 0]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ylabel('Correlation')
% 
% r_biceps_a_delt_all_fz = atanh(r_biceps_a_delt_all);
% r_biceps_trices_rand_all_fz = atanh(r_biceps_a_delt_rand_all);
% mean_r_biceps_a_delt_rand_all_fz= mean(r_biceps_trices_rand_all_fz);
% sd_r_biceps_a_delt_rand_all_fz = std(r_biceps_trices_rand_all_fz,[],1);
% r_biceps_a_delt_all_z = (r_biceps_a_delt_all_fz- mean_r_biceps_a_delt_rand_all_fz)./sd_r_biceps_a_delt_rand_all_fz;
% for k = 1:size(r_biceps_a_delt,2)
%     [~,p(k)] = ttest2(r_biceps_a_delt_all_fz(:,k),r_biceps_trices_rand_all_fz(:,k),'Vartype','unequal');
% end
% p = p*size(r_biceps_a_delt,2);
% p(p>0.1) = 0.1;
% subplot(3,1,3)
% plot(lags,p,'color','k','LineWidth',1)
% hold on 
% yline(0.05,'--','color','k','LineWidth',1)
% ylabel({'Corrected','p-value'})
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(3)
% subplot(3,1,1:2)
% patch([lags fliplr(lags)], [y_biceps_p_delt_1(:)-se_biceps_p_delt_1(:);  flipud(y_biceps_p_delt_1(:)+se_biceps_p_delt_1(:))],[35 140 204]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% hold on
% plot(lags,mean(r_biceps_p_delt_all),'LineWidth',2,'color',[35 140 204]/255)
% patch([lags fliplr(lags)], [y_biceps_p_delt_rand_1(:)-se_biceps_p_delt_rand_1(:);  flipud(y_biceps_p_delt_rand_1(:)+se_biceps_p_delt_rand_1(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% plot(lags,mean(r_biceps_p_delt_rand_all),'LineWidth',2,'color',[0 0 0]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ylabel('Correlation')
% 
% r_biceps_p_delt_all_fz = atanh(r_biceps_p_delt_all);
% r_biceps_trices_rand_all_fz = atanh(r_biceps_p_delt_rand_all);
% mean_r_biceps_p_delt_rand_all_fz= mean(r_biceps_trices_rand_all_fz);
% sd_r_biceps_p_delt_rand_all_fz = std(r_biceps_trices_rand_all_fz,[],1);
% r_biceps_p_delt_all_z = (r_biceps_p_delt_all_fz- mean_r_biceps_p_delt_rand_all_fz)./sd_r_biceps_p_delt_rand_all_fz;
% for k = 1:size(r_biceps_p_delt,2)
%     [~,p(k)] = ttest2(r_biceps_p_delt_all_fz(:,k),r_biceps_trices_rand_all_fz(:,k),'Vartype','unequal');
% end
% p = p*size(r_biceps_p_delt,2);
% p(p>0.1) = 0.1;
% subplot(3,1,3)
% plot(lags,p,'color','k','LineWidth',1)
% hold on 
% yline(0.05,'--','color','k','LineWidth',1)
% ylabel({'Corrected','p-value'})
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% %%
% % Muscle toruqe at shoulder and p_delt
% figure(4)
% subplot(3,1,1:2)
% patch([lags fliplr(lags)], [y_triceps_a_delt_1(:)-se_triceps_a_delt_1(:);  flipud(y_triceps_a_delt_1(:)+se_triceps_a_delt_1(:))],[204,45,53]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% hold on
% plot(lags,mean(r_triceps_a_delt_all),'LineWidth',2,'color',[204,45,53]/255)
% patch([lags fliplr(lags)], [y_triceps_a_delt_rand_1(:)-se_triceps_a_delt_rand_1(:);  flipud(y_triceps_a_delt_rand_1(:)+se_triceps_a_delt_rand_1(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% plot(lags,mean(r_triceps_a_delt_rand_all),'LineWidth',2,'color',[0 0 0]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ylabel('Correlation')
% 
% r_triceps_a_delt_all_fz = atanh(r_triceps_a_delt_all);
% r_triceps_a_delt_rand_all_fz = atanh(r_triceps_a_delt_rand_all);
% mean_r_triceps_a_delt_rand_all_fz= mean(r_triceps_a_delt_rand_all_fz);
% sd_r_triceps_a_delt_rand_all_fz = std(r_triceps_a_delt_rand_all_fz,[],1);
% r_triceps_a_delt_all_z = (r_triceps_a_delt_all_fz- mean_r_triceps_a_delt_rand_all_fz)./sd_r_triceps_a_delt_rand_all_fz;
% for k = 1:size(r_triceps_a_delt,2)
%     [~,p(k)] = ttest2(r_triceps_a_delt_all_fz(:,k),r_triceps_a_delt_rand_all_fz(:,k),'Vartype','unequal');
% end
% p = p*size(r_triceps_a_delt,2);
% p(p>0.1) = 0.1;
% subplot(3,1,3)
% plot(lags,p,'color','k','LineWidth',1)
% hold on 
% yline(0.05,'--','color','k','LineWidth',1)
% ylabel({'Corrected','p-value'})
% ylabel({'Corrected','p-value'})
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(5)
% subplot(3,1,1:2)
% patch([lags fliplr(lags)], [y_triceps_p_delt_1(:)-se_triceps_p_delt_1(:);  flipud(y_triceps_p_delt_1(:)+se_triceps_p_delt_1(:))],[204,45,53]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% hold on
% plot(lags,mean(r_triceps_p_delt_all),'LineWidth',2,'color',[204,45,53]/255)
% patch([lags fliplr(lags)], [y_triceps_p_delt_rand_1(:)-se_triceps_p_delt_rand_1(:);  flipud(y_triceps_p_delt_rand_1(:)+se_triceps_p_delt_rand_1(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% plot(lags,mean(r_triceps_p_delt_rand_all),'LineWidth',2,'color',[0 0 0]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ylabel('Correlation')
% 
% r_triceps_p_delt_all_fz = atanh(r_triceps_p_delt_all);
% r_triceps_p_delt_rand_all_fz = atanh(r_triceps_p_delt_rand_all);
% mean_r_triceps_p_delt_rand_all_fz= mean(r_triceps_p_delt_rand_all_fz);
% sd_r_triceps_p_delt_rand_all_fz = std(r_triceps_p_delt_rand_all_fz,[],1);
% r_triceps_p_delt_all_z = (r_triceps_p_delt_all_fz- mean_r_triceps_p_delt_rand_all_fz)./sd_r_triceps_p_delt_rand_all_fz;
% for k = 1:size(r_triceps_p_delt,2)
%     [~,p(k)] = ttest2(r_triceps_p_delt_all_fz(:,k),r_triceps_p_delt_rand_all_fz(:,k),'Vartype','unequal');
% end
% p = p*size(r_triceps_p_delt,2);
% p(p>0.1) = 0.1;
% subplot(3,1,3)
% plot(lags,p,'color','k','LineWidth',1)
% hold on 
% yline(0.05,'--','color','k','LineWidth',1)
% ylabel({'Corrected','p-value'})
% ylabel({'Corrected','p-value'})
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% %%
% % Muscle toruqe at shoulder and CB
% figure(6)
% subplot(3,1,1:2)
% patch([lags fliplr(lags)], [y_a_delt_p_delt_1(:)-se_a_delt_p_delt_1(:);  flipud(y_a_delt_p_delt_1(:)+se_a_delt_p_delt_1(:))],[45 49 66]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% hold on
% plot(lags,mean(r_a_delt_p_delt_all),'LineWidth',2,'color',[45 49 66]/255)
% patch([lags fliplr(lags)], [y_a_delt_p_delt_rand_1(:)-se_a_delt_p_delt_rand_1(:);  flipud(y_a_delt_p_delt_rand_1(:)+se_a_delt_p_delt_rand_1(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
% plot(lags,mean(r_a_delt_p_delt_rand_all),'LineWidth',2,'color',[0 0 0]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ylabel('Correlation')
% 
% r_a_delt_p_delt_all_fz = atanh(r_a_delt_p_delt_all);
% r_a_delt_p_delt_rand_all_fz = atanh(r_a_delt_p_delt_rand_all);
% mean_r_a_delt_p_delt_rand_all_fz= mean(r_a_delt_p_delt_rand_all_fz);
% sd_r_a_delt_p_delt_rand_all_fz = std(r_a_delt_p_delt_rand_all_fz,[],1);
% r_a_delt_p_delt_all_z = (r_a_delt_p_delt_all_fz- mean_r_a_delt_p_delt_rand_all_fz)./sd_r_a_delt_p_delt_rand_all_fz;
% for k = 1:size(r_a_delt_p_delt,2)
%     [~,p(k)] = ttest2(r_a_delt_p_delt_all_fz(:,k),r_a_delt_p_delt_rand_all_fz(:,k),'Vartype','unequal');
% end
% p = p*size(r_a_delt_p_delt,2);
% p(p>0.1) = 0.1;
% subplot(3,1,3)
% plot(lags,p,'color','k','LineWidth',1)
% hold on 
% yline(0.05,'--','color','k','LineWidth',1)
% ylabel({'Corrected','p-value'})
% set(gca,'TickDir','out')
% set(gca,'box','off')




