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

theta_1_dot = gradient(theta_1_all)*Fs_js;
theta_1_ddot = gradient(theta_1_dot)*Fs_js;
theta_2_dot = gradient(theta_2_all)*Fs_js;
theta_2_ddot = gradient(theta_2_dot)*Fs_js;

theta_all = [mean(theta_1_all);mean(theta_1_dot);mean(theta_1_ddot);...
    mean(theta_2_all);mean(theta_2_dot);mean(theta_2_ddot)];

mean_theta_1 = mean(theta_1_all);
mean_angle = mean(mean_theta_1);
p2p = max(mean_theta_1)-min(mean_theta_1);
figure(5)
ax1 = subplot(3,2,1);
plot(time_js,mean_theta_1,'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,p2p*(rescale(theta_all(2,:))-mean(rescale(theta_all(2,:))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,p2p*1.1*(rescale(theta_all(3,:))-mean(rescale(theta_all(3,:))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
yline(mean_angle,'--','color','k')
%legend('Angle','Velocity','Acceleration')
title('Shoulder')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,2,3);
plot(time_js,mean(torque_1_int_all),'color',[46, 64, 82]/255,'LineWidth',1)
hold on 
plot(time_js,mean(torque_1_self_all),'color',[229, 50, 59]/255,'LineWidth',1)
plot(time_js,mean(torque_1_grav_all),'color',[33, 158, 188]/255,'LineWidth',1)
plot(time_js,mean(torque_1_muscle_all),'color',[255, 183, 3]/255,'LineWidth',1)
ylabel({'Torque','(Nm)'})
%legend('Interaction','Net','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(3,2,5);
yyaxis left
plot(time_EMG,mean(EMG_a_delt_all),'color',[45 49 66]/255,'LineWidth',1)
ylabel({'EMG','(z-score)'})
yyaxis right
plot(time_EMG,mean(EMG_p_delt_all),'color',[247 146 83]/255,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'box','off')
mean_theta_2 = mean(theta_2_all);
mean_angle = mean(mean_theta_2);
p2p = max(mean_theta_2)-min(mean_theta_2);
ax3 = subplot(3,2,2);
plot(time_js,mean_theta_2,'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,p2p*(rescale(theta_all(5,:))-mean(rescale(theta_all(5,:))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,p2p*1.1*(rescale(theta_all(6,:))-mean(rescale(theta_all(6,:))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
yline(mean_angle,'--','color','k')
legend('Angle','Velocity','Acceleration')
title('Elbow')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(3,2,4);
plot(time_js,mean(torque_2_int_all),'color',[46, 64, 82]/255,'LineWidth',1)
hold on 
plot(time_js,mean(torque_2_self_all),'color',[229, 50, 59]/255,'LineWidth',1)
plot(time_js,mean(torque_2_grav_all),'color',[33, 158, 188]/255,'LineWidth',1)
plot(time_js,mean(torque_2_muscle_all),'color',[255, 183, 3]/255,'LineWidth',1)
legend('Interaction','Net','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
ax6 = subplot(3,2,6);
yyaxis left
plot(time_EMG,mean(EMG_biceps_all),'color',[35 140 204]/255,'LineWidth',1)
yyaxis right
plot(time_EMG,mean(EMG_triceps_all),'color',[204 45 52]/255,'LineWidth',1)
xlabel('Time (ms)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
