close all
clear all
clc

code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode';
data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
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
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

mouse_ID_array = strsplit(mouse_ID,'_');

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

cd([data_folder mouse_ID '\EMG\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

cd([data_folder mouse_ID '\' data_ID ,'_v5'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 1000;


lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.01, ...
    'SampleRate',Fs_EMG);

start_offset = -0.008;
end_offset = 0.005;

time_js = start_offset:1/Fs_js:end_offset;
time_js = time_js*1000;
time_EMG = start_offset:1/Fs_EMG:end_offset;
time_EMG = time_EMG*1000;
time_joint = start_offset:1/Fs_joint:end_offset;
time_joint = time_joint*1000;
window_size = length(time_js);
        
js_pos_all = [];
js_vel_all = [];
js_acc_all = [];
mag_vel_all = [];
max_vel_all = [];

theta_all = zeros(6,window_size);
theta_1_all = [];
theta_2_all = [];

torque_1_int_all = [];
torque_1_self_all = [];
torque_1_grav_all = [];
torque_1_muscle_all = [];
torque_2_int_all = [];
torque_2_self_all = [];
torque_2_grav_all = [];
torque_2_muscle_all = [];

EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_a_delt_all = [];
EMG_p_delt_all = [];
EMG_biceps_ds_all = [];
EMG_triceps_ds_all = [];
EMG_a_delt_ds_all = [];
EMG_p_delt_ds_all = [];

r_bi_tri_all = [];
r_bi_a_delt_all = [];
r_bi_p_delt_all = [];
r_tri_a_delt_all = [];
r_tri_p_delt_all = [];
r_a_delt_p_delt_all = [];

r_bi_js_pos_all = [];
r_tri_js_pos_all = [];
r_a_delt_js_pos_all = [];
r_p_delt_js_pos_all = [];
r_bi_js_vel_all = [];
r_tri_js_vel_all = [];
r_a_delt_js_vel_all = [];
r_p_delt_js_vel_all = [];
r_bi_js_acc_all = [];
r_tri_js_acc_all = [];
r_a_delt_js_acc_all = [];
r_p_delt_js_acc_all = [];

r_bi_theta_1_all = [];
r_tri_theta_1_all = [];
r_a_delt_theta_1_all = [];
r_p_delt_theta_1_all = [];

r_bi_theta_2_all = [];
r_tri_theta_2_all = [];
r_a_delt_theta_2_all = [];
r_p_delt_theta_2_all = [];

r_bi_Gamma_1_all = [];
r_tri_Gamma_1_all = [];
r_a_delt_Gamma_1_all = [];
r_p_delt_Gamma_1_all = [];

r_bi_Gamma_2_all = [];
r_tri_Gamma_2_all = [];
r_a_delt_Gamma_2_all = [];
r_p_delt_Gamma_2_all = [];

index_js_reach = 1:length(js_reach)-2;
index_EMG = 1:length(EMG_struct);

idx = 0;
trialIdx = [18 19 20];

r_bi_torque_2_all = [];
for i = 1:length(index_js_reach) %nTrial
    j = index_js_reach(i);
    k = index_EMG(i);
    %if isempty(js_reach(i).reach_flag)
    if ~isempty(js_reach(j).start_time)
        start_idx_js = js_reach(j).start_time;
        end_idx_js = js_reach(j).end_time;
        target_onset = js_reach(j).target_onset;
        target_offset = js_reach(j).target_offset;
        hold_onset = js_reach(j).hold_onset;
        hold_offset = js_reach(j).hold_offset;
        start_time = js_reach(j).start_time;
        end_time = js_reach(j).end_time;
    
        start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
        end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
        
        start_idx_joint = round(start_idx_js*Fs_joint/Fs_js);
        end_idx_joint = round(end_idx_js*Fs_joint/Fs_js);
        

        
        if flag_noise(k) == 1 && length(data(k).elbow_angle)>250 && straightness(j) > 0.8 
            idx = idx+1;
            mag_vel = js_reach(j).mag_vel(start_idx_js:1*Fs_js);
            [~,loc_max_mag_vel] = max(mag_vel);
            js_pos_temp = js_reach(j).radial_pos;
            js_vel_temp = gradient(js_pos_temp)*Fs_js;
            js_acc_temp = gradient(js_vel_temp)*Fs_js;
            [~,loc_max_acc] = findpeaks(js_acc_temp);
            
            analysis_window_js = [start_time+start_offset*Fs_js:end_time+end_offset*Fs_js];
            analysis_window_EMG = [start_idx_EMG+start_offset*Fs_EMG:end_idx_EMG+end_offset*Fs_EMG];
            %analysis_window_joint = round(analysis_window_joint);
            
            
            radial_pos = js_reach(j).radial_pos(analysis_window_js);
            js_vel = gradient(js_reach(j).radial_pos(analysis_window_js))*Fs_js;           
            js_acc = gradient(js_vel)*Fs_js;
            
            traj_x = js_reach(j).traj_x(analysis_window_js);
            traj_y = js_reach(j).traj_y(analysis_window_js);
            
            % Joint kinematics and kinetics data 
            theta = rad2deg(data(k).theta(:,analysis_window_js)); 
            %theta_all = theta_all + theta;
            
                
%             torque_1_int_all = [torque_1_int_all;data(k).shoulder_torque_int(analysis_window_js)'];
%             torque_1_self_all = [torque_1_self_all;data(k).shoulder_torque_self(analysis_window_js)'];
%             torque_1_grav_all = [torque_1_grav_all;data(k).shoulder_torque_grav(analysis_window_js)'];
%             torque_1_muscle_all =[torque_1_muscle_all;data(k).shoulder_torque_int(analysis_window_js)'+data(k).shoulder_torque_self(analysis_window_js)'+data(k).shoulder_torque_grav(analysis_window_js)'];
%             torque_2_int_all = [torque_2_int_all;data(k).elbow_torque_int(analysis_window_js)'];
%             torque_2_self_all = [torque_2_self_all;data(k).elbow_torque_self(analysis_window_js)'];
%             torque_2_grav_all = [torque_2_grav_all;data(k).elbow_torque_grav(analysis_window_js)'];
%             torque_2_muscle_all = [torque_2_muscle_all;data(k).elbow_torque_int(analysis_window_js)'+data(k).elbow_torque_self(analysis_window_js)'+data(k).elbow_torque_grav(analysis_window_js)'];
            
            torque_1_muscle = data(k).shoulder_torque_int(analysis_window_js)'+data(k).shoulder_torque_self(analysis_window_js)'+data(k).shoulder_torque_grav(analysis_window_js)';
            torque_2_muscle = data(k).elbow_torque_int(analysis_window_js)'+data(k).elbow_torque_self(analysis_window_js)'+data(k).elbow_torque_grav(analysis_window_js)';
            shift = 5*Fs_EMG/Fs_js;
            EMG_biceps_temp= EMG_struct(k).a_delt_zscore;
            EMG_biceps = EMG_biceps_temp([shift:end,1:shift-1]);
            %EMG_biceps = conv(EMG_biceps_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
            EMG_biceps = EMG_biceps(analysis_window_EMG);
            EMG_biceps_ds = downsample(EMG_biceps,10);
            
            
            [r_bi_torque_2,lags] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),torque_1_muscle-mean(torque_1_muscle),50,'coeff');
            r_bi_torque_2_all = [r_bi_torque_2_all;r_bi_torque_2'];
            figure(1)
            plot(lags,r_bi_torque_2)
            hold on 
%             EMG_triceps_temp= abs(EMG_struct(k).triceps_raw);
%             EMG_triceps_temp = EMG_triceps_temp([shift:end,1:shift-1]);
%             EMG_triceps = conv(EMG_triceps_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
%             EMG_triceps = EMG_triceps(analysis_window_EMG);
%             EMG_triceps_ds = downsample(EMG_triceps,10);
%                         
% %             EMG_a_delt_temp= abs(EMG_struct(k).a_delt_raw);
% %             EMG_a_delt_temp = EMG_a_delt_temp([shift:end,1:shift-1]);
% %             EMG_a_delt = conv(EMG_a_delt_temp,gausswin(0.01*Fs_EMG)./sum(gausswin(0.01*Fs_EMG)),'same');
%             EMG_a_delt_temp = EMG_struct(k).a_delt_zscore;
%             EMG_a_delt = EMG_a_delt_temp([shift:end,1:shift-1]);
%             EMG_a_delt = EMG_a_delt(analysis_window_EMG);
%             EMG_a_delt_ds = downsample(EMG_a_delt,10);
%             
%             EMG_p_delt_temp= abs(EMG_struct(k).p_delt_raw);
%             EMG_p_delt_temp = EMG_p_delt_temp([shift:end,1:shift-1]);
%             EMG_p_delt = conv(EMG_p_delt_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
%             EMG_p_delt = EMG_p_delt(analysis_window_EMG);
%             EMG_p_delt_ds = downsample(EMG_p_delt,10);
            
                             
       
        end
        
    end
end

% data_folder = 'D:\JoystickExpts\data\';
% mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';            
% cd([data_folder mouse_ID '\' data_ID])
% save('js_pos_all','js_pos_all')
% save('js_vel_all','js_vel_all')
% save('js_acc_all','js_acc_all')
% save('theta_1_all','theta_1_all')
% save('theta_2_all','theta_2_all')
% save('torque_1_int_all','torque_1_int_all')
% save('torque_1_self_all','torque_1_self_all')
% save('torque_1_grav_all','torque_1_grav_all')
% save('torque_1_muscle_all','torque_1_muscle_all')
% save('torque_2_int_all','torque_2_int_all')
% save('torque_2_self_all','torque_2_self_all')
% save('torque_2_grav_all','torque_2_grav_all')
% save('torque_2_muscle_all','torque_2_muscle_all')
% save('EMG_biceps_all','EMG_biceps_all')
% save('EMG_triceps_all','EMG_triceps_all')
% save('EMG_a_delt_all','EMG_a_delt_all')
% save('EMG_p_delt_all','EMG_p_delt_all')
% save('EMG_biceps_ds_all','EMG_biceps_ds_all')
% save('EMG_triceps_ds_all','EMG_triceps_ds_all')
% save('EMG_a_delt_ds_all','EMG_a_delt_ds_all')
% save('EMG_p_delt_ds_all','EMG_p_delt_ds_all')
% cd(code_folder)



%% Cross-correlation analysis
% mean_EMG_biceps = mean(EMG_biceps_all);
% mean_EMG_triceps = mean(EMG_triceps_all);
% mean_EMG_a_delt = mean(EMG_a_delt_all);
% mean_EMG_p_delt = mean(EMG_p_delt_all);
% 
% mean_EMG_biceps_ds = mean(EMG_biceps_ds_all);
% mean_EMG_triceps_ds = mean(EMG_triceps_ds_all);
% mean_EMG_a_delt_ds = mean(EMG_a_delt_ds_all);
% mean_EMG_p_delt_ds = mean(EMG_p_delt_ds_all);
% 
% [r_bi_tri,lags] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_triceps-mean(mean_EMG_triceps),window_size*Fs_EMG/Fs_js,'coeff');
% [r_bi_a_delt,~] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_a_delt-mean(mean_EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
% [r_bi_p_delt,~] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
% [r_tri_a_delt,~] = xcorr(mean_EMG_triceps-mean(mean_EMG_triceps),mean_EMG_a_delt-mean(mean_EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
% [r_tri_p_delt,~] = xcorr(mean_EMG_triceps-mean(mean_EMG_triceps),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
% [r_a_delt_p_delt,~] = xcorr(mean_EMG_a_delt-mean(mean_EMG_a_delt),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
% 
% [r_bi_js_pos,] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
% [r_tri_js_pos,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
% [r_a_delt_js_pos,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');
% [r_p_delt_js_pos,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');
% 
% 
% [r_bi_js_vel,lags_js] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),js_vel-mean(js_vel),window_size,'coeff');
% [r_tri_js_vel,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),js_vel-mean(js_vel),window_size,'coeff');
% [r_a_delt_js_vel,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),js_vel-mean(js_vel),window_size,'coeff');
% [r_p_delt_js_vel,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),js_vel-mean(js_vel),window_size,'coeff');
% 
% 
% [r_bi_js_acc,~] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),js_acc-mean(js_acc),window_size,'coeff');
% [r_tri_js_acc,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),js_acc-mean(js_acc),window_size,'coeff');
% [r_a_delt_js_acc,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),js_acc-mean(js_acc),window_size,'coeff');
% [r_p_delt_js_acc,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),js_acc-mean(js_acc),window_size,'coeff');
% 
% 
% mean_theta_1 = theta_all(3,:); %mean(theta_1_all);
% [r_bi_theta_1,lags_theta_1] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
% [r_tri_theta_1,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
% [r_a_delt_theta_1,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
% [r_p_delt_theta_1,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
% 
% mean_theta_2 = theta_all(6,:); %mean(theta_2_all);
% [r_bi_theta_2,lags_theta_2] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
% [r_tri_theta_2,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
% [r_a_delt_theta_2,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
% [r_p_delt_theta_2,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
% 
% Gamma_1 = mean(torque_1_muscle_all);
% Gamma_2 = mean(torque_2_muscle_all);
% 
% [r_bi_torque_2,lags_Gamma_1] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
% [r_tri_Gamma_1,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
% [r_a_delt_Gamma_1,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
% [r_p_delt_Gamma_1,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
% 
% 
% [r_bi_Gamma_2,lags_Gamma_2] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
% [r_tri_Gamma_2,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
% [r_a_delt_Gamma_2,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
% [r_p_delt_Gamma_2,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
%             
% figure(6)
% subplot(2,2,1)
% plot(lags_js/Fs_js*1000,r_bi_js_pos,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Position')
% subplot(2,2,2)
% plot(lags_js/Fs_js*1000,r_tri_js_pos,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_js/Fs_js*1000,r_a_delt_js_pos,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_js/Fs_js*1000,r_p_delt_js_pos,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(7)
% subplot(2,2,1)
% plot(lags_js/Fs_js*1000,r_bi_js_vel,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Velocity')
% subplot(2,2,2)
% plot(lags_js/Fs_js*1000,r_tri_js_vel,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_js/Fs_js*1000,r_a_delt_js_vel,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_js/Fs_js*1000,r_p_delt_js_vel,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% 
% figure(8)
% subplot(2,2,1)
% %title('Acceleration')
% plot(lags_js/Fs_js*1000,r_bi_js_acc,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,2)
% plot(lags_js/Fs_js*1000,r_tri_js_acc,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_js/Fs_js*1000,r_a_delt_js_acc,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_js/Fs_js*1000,r_p_delt_js_acc,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% 
% figure(9)
% subplot(2,3,1)
% plot(lags/Fs_EMG*1000,r_bi_tri,'LineWidth',2,'color','k')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,3,2)
% plot(lags/Fs_EMG*1000,r_bi_a_delt,'LineWidth',2,'color','k');
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,3,3)
% plot(lags/Fs_EMG*1000,r_bi_p_delt,'LineWidth',2,'color','k');
% title('Biceps-AD')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,3,4)
% plot(lags/Fs_EMG*1000,r_tri_a_delt,'LineWidth',2,'color','k');
% title('Triceps-CB')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,3,5)
% plot(lags/Fs_EMG*1000,r_tri_p_delt,'LineWidth',2,'color','k');
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,3,6)
% plot(lags/Fs_EMG*1000,r_a_delt_p_delt,'LineWidth',2,'color','k');
% title('CB-AD')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(10)
% subplot(2,2,1)
% plot(lags_theta_1/Fs_joint*1000,r_bi_theta_1,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Shoulder angle')
% subplot(2,2,2)
% plot(lags_theta_1/Fs_joint*1000,r_tri_theta_1,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_theta_1/Fs_joint*1000,r_a_delt_theta_1,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_theta_1/Fs_joint*1000,r_p_delt_theta_1,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(11)
% subplot(2,2,1)
% plot(lags_theta_1/Fs_joint*1000,r_bi_theta_2,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Elbow angle')
% subplot(2,2,2)
% plot(lags_theta_1/Fs_joint*1000,r_tri_theta_2,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_theta_1/Fs_joint*1000,r_a_delt_theta_2,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_theta_1/Fs_joint*1000,r_p_delt_theta_2,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(12)
% subplot(2,2,1)
% plot(lags_Gamma_1/Fs_joint*1000,r_bi_torque_2,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Shoulder torque')
% subplot(2,2,2)
% plot(lags_Gamma_1/Fs_joint*1000,r_tri_Gamma_1,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_Gamma_1/Fs_joint*1000,r_a_delt_Gamma_1,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_Gamma_1/Fs_joint*1000,r_p_delt_Gamma_1,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% 
% figure(13)
% subplot(2,2,1)
% plot(lags_Gamma_1/Fs_joint*1000,r_bi_Gamma_2,'LineWidth',2,'color',[35 140 204]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% title('Elbow torque')
% subplot(2,2,2)
% plot(lags_Gamma_1/Fs_joint*1000,r_tri_Gamma_2,'LineWidth',2,'color',[204 45 52]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,3)
% plot(lags_Gamma_1/Fs_joint*1000,r_a_delt_Gamma_2,'LineWidth',2,'color',[45 49 66]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')
% subplot(2,2,4)
% plot(lags_Gamma_1/Fs_joint*1000,r_p_delt_Gamma_2,'LineWidth',2,'color',[247 146 83]/255)
% set(gca,'TickDir','out')
% set(gca,'box','off')