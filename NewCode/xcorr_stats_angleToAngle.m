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

nIteration = 100;
nTrial = size(js_pos_all,1);
combinations = nchoosek(1:nTrial,2);

r_theta_1_2_all = [];
r_triceps_theta_1_all = [];
r_a_delt_theta_1_all = [];
r_p_delt_theta_1_all = [];
r_biceps_theta_2_all = [];
r_triceps_theta_2_all = [];
r_a_delt_theta_2_all = [];
r_p_delt_theta_2_all = [];

s = RandStream('mlfg6331_64'); 
for i = 1:nIteration
    idx_sample = datasample(s,1:nTrial,5,'Replace',true);
    
    theta_1 = mean(gradient(gradient(theta_1_all(idx_sample,:))*Fs_js)*Fs_js);
    theta_2 = mean(gradient(gradient(theta_2_all(idx_sample,:))*Fs_js)*Fs_js);
    EMG_biceps = mean(EMG_biceps_ds_all(idx_sample,:));
    EMG_triceps = mean(EMG_triceps_ds_all(idx_sample,:));
    EMG_a_delt = mean(EMG_a_delt_ds_all(idx_sample,:));
    EMG_p_delt = mean(EMG_p_delt_ds_all(idx_sample,:));
    
    [r_theta_1_2,lags] = xcorr(theta_1-mean(theta_1),theta_2-mean(theta_2),window_size,'coeff');
    r_theta_1_2_all = [r_theta_1_2_all;r_theta_1_2];
  
    
end

%% Compute random cross-correlogram 
r_theta_1_2_rand_all = [];
r_triceps_theta_1_rand_all = [];
r_a_delt_theta_1_rand_all = [];
r_p_delt_theta_1_rand_all = [];
r_biceps_theta_2_rand_all = [];
r_triceps_theta_2_rand_all = [];
r_a_delt_theta_2_rand_all = [];
r_p_delt_theta_2_rand_all = [];

for j = 1:size(combinations,1)
    [r_biceps_theta_1_rand,~] = xcorr(theta_1_all(combinations(j,1),:)-mean(theta_1_all(combinations(j,1),:)),...
        theta_2_all(combinations(j,2),:)-mean(theta_2_all(combinations(j,2),:)),window_size,'coeff');
    r_theta_1_2_rand_all= [r_theta_1_2_rand_all;r_biceps_theta_1_rand];
  
end

 %% Compute mean and se
y_theta_1_2 = mean(r_theta_1_2_all);
se_theta_1_2 = std(r_theta_1_2_all,[],1)./(sqrt(size(r_theta_1_2_all,1)));
y_theta_1_2_rand = mean(r_theta_1_2_rand_all);
se_theta_1_2_rand = std(r_theta_1_2_rand_all,[],1)./(sqrt(size(r_theta_1_2_rand_all,1)));

%% Plot muscle torque at shoulder 
figure(1)
subplot(3,1,1:2)
patch([lags fliplr(lags)], [y_theta_1_2(:)-se_theta_1_2(:);  flipud(y_theta_1_2(:)+se_theta_1_2(:))],[45 49 66]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
hold on
plot(lags,mean(r_theta_1_2_all),'LineWidth',2,'color',[35 140 204]/255)
patch([lags fliplr(lags)], [y_theta_1_2_rand(:)-se_theta_1_2_rand(:);  flipud(y_theta_1_2_rand(:)+se_theta_1_2_rand(:))],[0 0 0]/255, 'FaceAlpha',0.5, 'EdgeColor','none')
plot(lags,mean(r_theta_1_2_rand_all),'LineWidth',2,'color',[0 0 0]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

r_theta_1_2_all_fz = atanh(r_theta_1_2_all);
r_theta_1_2_rand_all_fz = atanh(r_theta_1_2_rand_all);
mean_r_theta_1_2_rand_all_fz= mean(r_theta_1_2_rand_all_fz);
sd_r_theta_1_2_rand_all_fz = std(r_theta_1_2_rand_all_fz,[],1);
r_biceps_theta_1_all_z = (r_theta_1_2_all_fz- mean_r_theta_1_2_rand_all_fz)./sd_r_theta_1_2_rand_all_fz;
for k = 1:size(r_theta_1_2,2)
    [~,p(k)] = ttest2(r_theta_1_2_all_fz(:,k),r_theta_1_2_rand_all_fz(:,k),'Vartype','unequal');
end
p = p*size(r_theta_1_2,2);
p(p>0.1) = 0.1;
figure(1)
subplot(3,1,3)
plot(lags,p,'color','k','LineWidth',1)
hold on 
yline(0.05,'--','color','k','LineWidth',1)
set(gca,'TickDir','out')
set(gca,'box','off')





