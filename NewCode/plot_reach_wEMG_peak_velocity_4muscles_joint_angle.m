close all
clear all
clc

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

theta = 0:0.01:2*pi;

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

cd([data_folder mouse_ID '\' data_ID ,'_v4'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 1000;


lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.01, ...
    'SampleRate',Fs_EMG);

radial_pos_all = [];
js_vel_all = [];
js_acc_all = [];
mag_vel_all = [];
max_vel_all = [];

theta_1_all = [];
theta_2_all = [];
wrist_angle_all = [];

EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_a_delt_all = [];
EMG_p_delt_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];
EMG_a_delt_raw_all = [];
EMG_p_delt_raw_all = [];

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

for i = 19 %1:length(index_js_reach) %nTrial
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
        end_time = js_reach(j).end_time/Fs_js;
    
        start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
        end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
        
        start_idx_joint = round(start_idx_js*Fs_joint/Fs_js);
        end_idx_joint = round(end_idx_js*Fs_joint/Fs_js);
        
        start_offset = -0.05;
        end_offset = 0.05;
        
        time_js = start_offset:1/Fs_js:end_offset;
        time_js = time_js*1000;
        time_EMG = start_offset:1/Fs_EMG:end_offset;
        time_EMG = time_EMG*1000;
        time_joint = start_offset:1/Fs_joint:end_offset;
        time_joint = time_joint*1000;
        window_size = length(time_js);
        
        if flag_noise(k) == 1 && length(data(k).elbow_angle)>250 && straightness(j) > 0.9 
                       
            mag_vel = js_reach(j).mag_vel_2(start_idx_js:1*Fs_js);
            [~,loc_max_mag_vel] = max(mag_vel);
            
            analysis_window_js = [loc_max_mag_vel+start_idx_js+start_offset*Fs_js:loc_max_mag_vel+start_idx_js+end_offset*Fs_js];
            analysis_window_EMG = [loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG+start_offset*Fs_EMG:loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG+end_offset*Fs_EMG];
            analysis_window_joint = [round(loc_max_mag_vel*Fs_joint/Fs_js)+start_idx_joint+round(start_offset*Fs_joint)...
                :round(loc_max_mag_vel*Fs_joint/Fs_js)+start_idx_joint+end_offset*Fs_joint];
            %analysis_window_joint = round(analysis_window_joint);
            
            radial_pos_all = [radial_pos_all; js_reach(j).radial_pos_2(analysis_window_js)];
            radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
            js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
            max_vel_all = [max_vel_all; (max(js_vel))];
            js_vel_all = [js_vel_all; js_vel];
            js_acc = gradient(js_vel)*Fs_js;
            js_acc_all = [js_acc_all; js_acc];
            
            traj_x = js_reach(j).traj_x_2(analysis_window_js);
            traj_y = js_reach(j).traj_y_2(analysis_window_js);
            
            shoulder_x = data(k).shoulder_x(analysis_window_joint);
            shoulder_y = data(k).shoulder_y(analysis_window_joint);
            shoulder_z = data(k).shoulder_z(analysis_window_joint);
            shoulder_mat = [shoulder_x -shoulder_y shoulder_z]';

            x_1 = shoulder_x;
            x_1_dot = gradient(x_1)*Fs_joint;
            x_1_ddot = gradient(x_1_dot)*Fs_joint;
            y_1 = shoulder_y;
            y_1_dot = gradient(y_1)*Fs_joint;
            y_1_ddot = gradient(y_1_dot)*Fs_joint;

            elbow_x = data(k).elbow_x(analysis_window_joint);
            elbow_y = data(k).elbow_y(analysis_window_joint);
            elbow_z = data(k).elbow_z(analysis_window_joint);
            elbow_mat = [elbow_x -elbow_y elbow_z]';

            wrist_x = data(k).wrist_x(analysis_window_joint);
            wrist_y = data(k).wrist_y(analysis_window_joint);
            wrist_z = data(k).wrist_z(analysis_window_joint);
            wrist_mat = [wrist_x -wrist_y wrist_z]';

            hand_x = data(k).hand_x(analysis_window_joint);
            hand_y = data(k).hand_y(analysis_window_joint);
            hand_z = data(k).hand_z(analysis_window_joint);

            joystick_x = data(k).joystick_x(analysis_window_joint);
            joystick_y = -data(k).joystick_y(analysis_window_joint);
            joystick_z = data(k).joystick_z(analysis_window_joint);
            
            u = [1;0;0]+shoulder_mat - shoulder_mat;
            v = elbow_mat - shoulder_mat;
            w = wrist_mat - elbow_mat;
            %u = [elbow_mat(1,:)-shoulder_mat(1,:);shoulder_mat(2,:)-shoulder_mat(2,:);elbow_mat(3,:)-shoulder_mat(3,:)];
            %u =  shoulder_ref_mat - shoulder_mat;

            theta_1 = 2*pi-acos(dot(u,v)./(vecnorm(u).*vecnorm(v)));
            theta_1 = theta_1';
            theta_1_dot = gradient(theta_1)*Fs_joint;
            theta_1_ddot = gradient(theta_1_dot)*Fs_joint;
            theta_2 = acos(dot(v,w)./(vecnorm(v).*vecnorm(w)));
            theta_2 = theta_2';
            theta_2_dot = gradient(theta_2)*Fs_joint;
            theta_2_ddot = gradient(theta_2_dot)*Fs_joint;
            
            l_1 = sqrt((data(k).shoulder_y-data(k).elbow_y).^2+(data(k).shoulder_x-data(k).elbow_x).^2+(data(k).shoulder_z-data(k).elbow_z).^2);
            l_1 = mean(l_1(1:100))/1000;
            r_1 = l_1/2;
            l_2 = sqrt((data(k).elbow_y-data(k).wrist_y).^2+(data(k).elbow_x-data(k).wrist_x).^2+(data(k).elbow_z-data(k).wrist_z).^2);
            l_2 = mean(l_2(1:100))/1000;
            r_2 = l_2/2;
            
            g = 9.81;
            m_1 = 0.00022154;
            m_2 = 0.00020154;

            I_1 = 1/12*l_1^2*m_1;
            I_2 = 1/12*l_2^2*m_2;

            Gamma_1 = theta_1_ddot.*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2) + 2*(m_2*r_2*l_1)*cos(theta_2))...
                + theta_2_ddot.*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
                - theta_2_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
                - theta_1_dot.*theta_2_dot.*(2*m_2*r_2*l_1*sin(theta_2))...
                - x_1_ddot.*((m_1*r_1+m_2*r_1)*sin(theta_1)+m_2*r_2*sin(theta_1+theta_2))...
                - y_1_ddot.*((m_1*r_1+m_2*r_1)*cos(theta_1)+m_2*r_2*cos(theta_1+theta_2))...
                + m_1*g*r_1*cos(theta_1) + m_2*g*(l_1*cos(theta_1) + r_2*cos(theta_1+pi-theta_2));

            Gamma_2 = theta_1_ddot.*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
                + theta_2_ddot.*(I_2 + m_2*r_2^2)...
                + theta_1_dot.^2.*(m_2*r_2*l_1*sin(theta_2))...
                + x_1_ddot.*(m_2*r_2*sin(theta_1+theta_2))...
                + y_1_ddot.*(m_2*r_2*cos(theta_1+theta_2))...
                + m_2*g*r_2*cos(theta_1+pi-theta_2);

            theta_1 = rad2deg(theta_1);
            theta_2 = rad2deg(theta_2);
            theta_1_all = [theta_1_all; theta_1'];
            theta_2_all = [theta_2_all; theta_2'];
            wrist_angle_all = [wrist_angle_all; data(k).wrist_angle(analysis_window_joint)'];
            
            mag_vel_all = [mag_vel_all; js_reach(j).mag_vel_2(analysis_window_js)];
            
            shift = 5*Fs_EMG/Fs_js;
            EMG_biceps_temp= abs(EMG_struct(k).biceps_raw);
            EMG_biceps_temp = EMG_biceps_temp([shift:end,1:shift-1]);
            EMG_biceps = conv(EMG_biceps_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
            EMG_biceps = EMG_biceps(analysis_window_EMG);
            EMG_biceps_ds = downsample(EMG_biceps,10);
        
            EMG_triceps_temp= abs(EMG_struct(k).triceps_raw);
            EMG_triceps_temp = EMG_triceps_temp([shift:end,1:shift-1]);
            EMG_triceps = conv(EMG_triceps_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
            EMG_triceps = EMG_triceps(analysis_window_EMG);
            EMG_triceps_ds = downsample(EMG_triceps,10);
            
                  
            [r_bi_tri,lags] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_triceps-mean(EMG_triceps),window_size*Fs_EMG/Fs_js,'coeff');
            r_bi_tri_all = [r_bi_tri_all r_bi_tri];
            [r_bi_a_delt,~] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_a_delt-mean(EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
            r_bi_a_delt_all = [r_bi_a_delt_all r_bi_a_delt];
            [r_bi_p_delt,~] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_p_delt-mean(EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
            r_bi_p_delt_all = [r_bi_p_delt_all r_bi_p_delt];
            [r_tri_a_delt,~] = xcorr(EMG_triceps-mean(EMG_triceps),EMG_a_delt-mean(EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
            r_tri_a_delt_all = [r_tri_a_delt_all r_tri_a_delt];
            [r_tri_p_delt,~] = xcorr(EMG_triceps-mean(EMG_triceps),EMG_p_delt-mean(EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
            r_tri_p_delt_all = [r_tri_p_delt_all r_tri_p_delt];
            [r_a_delt_p_delt,~] = xcorr(EMG_a_delt-mean(EMG_a_delt),EMG_p_delt-mean(EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
            r_a_delt_p_delt_all = [r_a_delt_p_delt_all r_a_delt_p_delt];
            
            [r_bi_js_pos,] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
            [r_tri_js_pos,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
            [r_a_delt_js_pos,] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');
            [r_p_delt_js_pos,] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');
            r_bi_js_pos_all = [r_bi_js_pos_all r_bi_js_pos];
            r_tri_js_pos_all = [r_tri_js_pos_all r_tri_js_pos];
            r_a_delt_js_pos_all = [r_a_delt_js_pos_all r_a_delt_js_pos];
            r_p_delt_js_pos_all = [r_p_delt_js_pos_all r_p_delt_js_pos];
            
            [r_bi_js_vel,lags_js] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_vel-mean(js_vel),window_size,'coeff');
            [r_tri_js_vel,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_vel-mean(js_vel),window_size,'coeff');
            [r_a_delt_js_vel,] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),js_vel-mean(js_vel),window_size,'coeff');
            [r_p_delt_js_vel,] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),js_vel-mean(js_vel),window_size,'coeff');
            r_bi_js_vel_all = [r_bi_js_vel_all r_bi_js_vel];
            r_tri_js_vel_all = [r_tri_js_vel_all r_tri_js_vel];
            r_a_delt_js_vel_all = [r_a_delt_js_vel_all r_a_delt_js_vel];
            r_p_delt_js_vel_all = [r_p_delt_js_vel_all r_p_delt_js_vel];
            
            [r_bi_js_acc,~] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_acc-mean(js_acc),window_size,'coeff');
            [r_tri_js_acc,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_acc-mean(js_acc),window_size,'coeff');
            [r_a_delt_js_acc,] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),js_acc-mean(js_acc),window_size,'coeff');
            [r_p_delt_js_acc,] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),js_acc-mean(js_acc),window_size,'coeff');
            r_bi_js_acc_all = [r_bi_js_acc_all r_bi_js_acc];
            r_tri_js_acc_all = [r_tri_js_acc_all r_tri_js_acc];
            r_a_delt_js_acc_all = [r_a_delt_js_acc_all r_a_delt_js_acc];
            r_p_delt_js_acc_all = [r_p_delt_js_acc_all r_p_delt_js_acc];
            
            [r_bi_theta_1,lags_theta_1] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),theta_1-mean(theta_1),window_size,'coeff');
            [r_tri_theta_1,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),theta_1-mean(theta_1),window_size,'coeff');
            [r_a_delt_theta_1,~] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),theta_1-mean(theta_1),window_size,'coeff');
            [r_p_delt_theta_1,~] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),theta_1-mean(theta_1),window_size,'coeff');
            r_bi_theta_1_all = [r_bi_theta_1_all r_bi_theta_1];
            r_tri_theta_1_all = [r_tri_theta_1_all r_tri_theta_1];
            r_a_delt_theta_1_all = [r_a_delt_theta_1_all r_a_delt_theta_1];
            r_p_delt_theta_1_all = [r_p_delt_theta_1_all r_p_delt_theta_1];
            
            [r_bi_theta_2,lags_theta_2] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),theta_2-mean(theta_2),window_size,'coeff');
            [r_tri_theta_2,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),theta_2-mean(theta_2),window_size,'coeff');
            [r_a_delt_theta_2,~] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),theta_2-mean(theta_2),window_size,'coeff');
            [r_p_delt_theta_2,~] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),theta_2-mean(theta_2),window_size,'coeff');
            r_bi_theta_2_all = [r_bi_theta_2_all r_bi_theta_2];
            r_tri_theta_2_all = [r_tri_theta_2_all r_tri_theta_2];
            r_a_delt_theta_2_all = [r_a_delt_theta_2_all r_a_delt_theta_2];
            r_p_delt_theta_2_all = [r_p_delt_theta_2_all r_p_delt_theta_2];
            
            [r_bi_Gamma_1,lags_Gamma_1] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
            [r_tri_Gamma_1,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
            [r_a_delt_Gamma_1,~] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
            [r_p_delt_Gamma_1,~] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
            r_bi_Gamma_1_all = [r_bi_Gamma_1_all r_bi_Gamma_1];
            r_tri_Gamma_1_all = [r_tri_Gamma_1_all r_tri_Gamma_1];
            r_a_delt_Gamma_1_all = [r_a_delt_Gamma_1_all r_a_delt_Gamma_1];
            r_p_delt_Gamma_1_all = [r_p_delt_Gamma_1_all r_p_delt_Gamma_1];
            
            [r_bi_Gamma_2,lags_Gamma_2] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
            [r_tri_Gamma_2,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
            [r_a_delt_Gamma_2,~] = xcorr(EMG_a_delt_ds-mean(EMG_a_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
            [r_p_delt_Gamma_2,~] = xcorr(EMG_p_delt_ds-mean(EMG_p_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
            r_bi_Gamma_2_all = [r_bi_Gamma_2_all r_bi_Gamma_2];
            r_tri_Gamma_2_all = [r_tri_Gamma_2_all r_tri_Gamma_2];
            r_a_delt_Gamma_2_all = [r_a_delt_Gamma_2_all r_a_delt_Gamma_2];
            r_p_delt_Gamma_2_all = [r_p_delt_Gamma_2_all r_p_delt_Gamma_2];
            
            EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
            EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
            EMG_a_delt_all = [EMG_a_delt_all; EMG_a_delt'];
            EMG_p_delt_all = [EMG_p_delt_all; EMG_p_delt'];
            
            EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(k).biceps_raw(analysis_window_EMG)'];
            EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(k).triceps_raw(analysis_window_EMG)'];
            EMG_a_delt_raw_all = [EMG_a_delt_raw_all; EMG_struct(k).a_delt_raw(analysis_window_EMG)'];
            EMG_p_delt_raw_all = [EMG_p_delt_raw_all; EMG_struct(k).p_delt_raw(analysis_window_EMG)'];
            
            f1 = figure(1);
            movegui(f1,'northwest')
            ax1 = subplot(7,1,1);
            plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax2 = subplot(7,1,2);
            plot1 = plot(time_joint,theta_1,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax3 = subplot(7,1,3);
            plot1 = plot(time_joint,theta_2,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax4 = subplot(7,1,4);
            plot3 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color',[35 140 204]/255);
            plot3.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax5 = subplot(7,1,5);
            plot4 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color',[204 45 52]/255);
            plot4.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax6 = subplot(7,1,6);
            plot5 = plot(time_EMG,EMG_a_delt,'LineWidth',1,'color',[45 49 66]/255);
            plot5.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax7 = subplot(7,1,7);
            plot6 = plot(time_EMG,EMG_p_delt,'LineWidth',1,'color',[247 146 83]/255);
            plot6.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')
            
            f2 = figure(2);
            movegui(f2,'southwest')
            ax1 = subplot(4,1,1);
            plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
            plot1.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax2 = subplot(4,1,2);
            plot1 = plot(time_js,js_vel,'LineWidth',1,'color','k');
            plot1.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax3 = subplot(4,1,3);
            plot3 = plot(time_js,js_acc,'LineWidth',1,'color','k');
            plot3.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax4 = subplot(4,1,4);
            plot4 = plot(time_EMG,EMG_a_delt,'LineWidth',1,'color',[204 45 52]/255);
            plot4.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            linkaxes([ax1 ax2 ax3 ax4],'x')
            
            f3 = figure(3);
            movegui(f3,'south')
            plot(traj_x,traj_y,'color',[45, 49, 66]/255,'LineWidth',1)
            hold on
            plot(js_reach(j).traj_x_2(start_time:target_onset),js_reach(j).traj_y_2(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            xlim([-7 7])
            ylim([-7 7])
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
            plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'--','color','k')
            plot(max_distance*cos(theta),max_distance*sin(theta),'--','color','k')
            plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
            plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
            xlabel('ML (mm)')
            ylabel('AP (mm)')
            axis equal
            
            
            figure(5)
            subplot(2,2,1)
            plot1 = plot(lags_js/Fs_js*1000,r_bi_js_pos,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_js/Fs_js*1000,r_tri_js_pos,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_js/Fs_js*1000,r_a_delt_js_pos,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_js/Fs_js*1000,r_p_delt_js_pos,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(6)
            subplot(2,2,1)
            plot1 = plot(lags_js/Fs_js*1000,r_bi_js_vel,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_js/Fs_js*1000,r_tri_js_vel,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_js/Fs_js*1000,r_a_delt_js_vel,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_js/Fs_js*1000,r_p_delt_js_vel,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(7)
            subplot(2,2,1)
            plot1 = plot(lags_js/Fs_js*1000,r_bi_js_acc,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_js/Fs_js*1000,r_tri_js_acc,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_js/Fs_js*1000,r_a_delt_js_acc,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_js/Fs_js*1000,r_p_delt_js_acc,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(8)
            subplot(2,3,1)
            plot1 = plot(lags/Fs_EMG*1000,r_bi_tri,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('Biceps-Triceps')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,3,2)
            plot1 = plot(lags/Fs_EMG*1000,r_bi_a_delt,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('Biceps-CB')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,3,3)
            plot1 = plot(lags/Fs_EMG*1000,r_bi_p_delt,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('Biceps-AD')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,3,4)
            plot1 = plot(lags/Fs_EMG*1000,r_tri_a_delt,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('Triceps-CB')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,3,5)
            plot1 = plot(lags/Fs_EMG*1000,r_tri_p_delt,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('Triceps-AD')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,3,6)
            plot1 = plot(lags/Fs_EMG*1000,r_a_delt_p_delt,'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            title('CB-AD')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            
            figure(9)
            subplot(2,2,1)
            plot1 = plot(lags_theta_1/Fs_joint*1000,r_bi_theta_1,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            title('Shoulder')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_theta_1/Fs_joint*1000,r_tri_theta_1,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_theta_1/Fs_joint*1000,r_a_delt_theta_1,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_theta_1/Fs_joint*1000,r_p_delt_theta_1,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(10)
            subplot(2,2,1)
            plot1 = plot(lags_theta_2/Fs_joint*1000,r_bi_theta_2,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            title('Elbow')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_theta_2/Fs_joint*1000,r_tri_theta_2,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_theta_2/Fs_joint*1000,r_a_delt_theta_2,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_theta_2/Fs_joint*1000,r_p_delt_theta_2,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(11)
            subplot(2,2,1)
            plot1 = plot(lags_Gamma_1/Fs_joint*1000,r_bi_Gamma_1,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_Gamma_1/Fs_joint*1000,r_tri_Gamma_1,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_Gamma_1/Fs_joint*1000,r_a_delt_Gamma_1,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_Gamma_1/Fs_joint*1000,r_p_delt_Gamma_1,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            figure(12)
            subplot(2,2,1)
            plot1 = plot(lags_Gamma_2/Fs_joint*1000,r_bi_Gamma_2,'LineWidth',1,'color',[35 140 204]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,2)
            plot1 = plot(lags_Gamma_2/Fs_joint*1000,r_tri_Gamma_2,'LineWidth',1,'color',[204 45 52]/255);
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            subplot(2,2,3)
            plot1 = plot(lags_Gamma_2/Fs_joint*1000,r_a_delt_Gamma_2,'LineWidth',1,'color',[45 49 66]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            subplot(2,2,4)
            plot1 = plot(lags_Gamma_2/Fs_joint*1000,r_p_delt_Gamma_2,'LineWidth',1,'color',[247 146 83]/255);
            plot1.Color(4) = 0.5;
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            
            %prompt = 'Move to nex? y/n: ';
            %str = input(prompt,'s');
        end
        
    end
end

y_bi = mean(EMG_biceps_all);
iqr_bi = iqr(EMG_biceps_all); %std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
iqr_tri = iqr(EMG_triceps_all); %std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
y_ad = mean(EMG_a_delt_all);
iqr_ad = iqr(EMG_a_delt_all); %std(EMG_a_delt_all,[],1)./(sqrt(size(EMG_a_delt_all,1)));
se_ad = std(EMG_a_delt_all,[],1)./(sqrt(size(EMG_a_delt_all,1)));
y_pd = mean(EMG_p_delt_all);
iqr_pd = iqr(EMG_p_delt_all); %std(EMG_p_delt_all,[],1)./(sqrt(size(EMG_p_delt_all,1)));
se_pd = std(EMG_p_delt_all,[],1)./(sqrt(size(EMG_p_delt_all,1)));


figure(1)
subplot(7,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'--','color','k','LineWidth',2)
yline(max_distance,'--','color','k','LineWidth',2)
ylabel({'Radial','Postion (mm)'})
subplot(7,1,2)
plot(time_joint,mean(theta_1_all),'LineWidth',2,'color','k')
ylabel({'Shoulder','Angle (deg)'})
subplot(7,1,3)
plot(time_joint,mean(theta_2_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
subplot(7,1,4)
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','k')
ylabel({'Biceps','(z-score)'})
subplot(7,1,7)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','k')
ylabel({'Triceps','(z-score)'})
subplot(7,1,6)
plot(time_EMG,mean(EMG_a_delt_all),'LineWidth',2,'color','k')
ylabel({'CB','(z-score)'})
subplot(7,1,7)
plot(time_EMG,mean(EMG_p_delt_all),'LineWidth',2,'color','k')
ylabel({'AD','(z-score)'})
xlabel('Time (ms)')

% figure(2)
% ax1 = subplot(7,1,1);
% plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
% yline(hold_threshold,'--','color','k','LineWidth',2)
% yline(outer_threshold,'color','g','LineWidth',2)
% yline(max_distance,'color','g','LineWidth',2)
% ylabel('Postion')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax2 = subplot(7,1,2);
% plot(time_js,mean(js_vel_all),'LineWidth',2,'color','k')
% ylabel('Vel')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax3 = subplot(7,1,3);
% plot(time_js,mean(js_acc_all),'LineWidth',2,'color','k')
% ylabel('Acc')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax4 = subplot(7,1,4);
% patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
% hold on
% plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
% ylabel('Biceps')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax5 = subplot(7,1,5);
% patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
% hold on
% plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
% ylabel('Triceps')
% xlabel('Time (sec)')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax6 = subplot(7,1,6);
% patch([time_EMG fliplr(time_EMG)], [y_ad(:)-se_ad(:);  flipud(y_ad(:)+se_ad(:))], 'm', 'FaceAlpha',0.2, 'EdgeColor','none')
% hold on
% plot(time_EMG,mean(EMG_a_delt_all),'LineWidth',2,'color','m')
% ylabel('AD')
% xlabel('Time (sec)')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% ax7 = subplot(7,1,7);
% patch([time_EMG fliplr(time_EMG)], [y_pd(:)-se_pd(:);  flipud(y_pd(:)+se_pd(:))], 'g', 'FaceAlpha',0.2, 'EdgeColor','none')
% hold on
% plot(time_EMG,mean(EMG_p_delt_all),'LineWidth',2,'color','g')
% ylabel('PD')
% xlabel('Time (sec)')
% set(gca,'TickDir','out')
% set(gca,'box','off')
% linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')

figure(4)
ax1 = subplot(7,1,1);
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'--','color','k','LineWidth',2)
yline(max_distance,'--','color','k','LineWidth',2)
ylabel({'Position';'(mm/s)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(7,1,2);
plot(time_joint,mean(theta_1_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(7,1,3);
plot(time_joint,mean(theta_2_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(7,1,4);
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))],[35 140 204]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color',[35 140 204]/255)
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(7,1,5);
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))],[204 45 52]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color',[204 45 52]/255)
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax6 = subplot(7,1,6);
patch([time_EMG fliplr(time_EMG)], [y_ad(:)-se_ad(:);  flipud(y_ad(:)+se_ad(:))],[45 49 66]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_a_delt_all),'LineWidth',2,'color',[45 49 66]/255)
ylabel('CB')
set(gca,'TickDir','out')
set(gca,'box','off')
ax7 = subplot(7,1,7);
patch([time_EMG fliplr(time_EMG)], [y_pd(:)-se_pd(:);  flipud(y_pd(:)+se_pd(:))],[247 146 83]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_p_delt_all),'LineWidth',2,'color',[247 146 83]/255)
ylabel('AD')
xlabel('Time (ms)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')
%
% figure(3)
% subplot(3,1,1)
% plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
% yline(hold_threshold,'--','color','k','LineWidth',2)
% yline(outer_threshold,'color','g','LineWidth',2)
% yline(max_distance,'color','g','LineWidth',2)
% ylabel('Radial Postion (mm)')
% subplot(3,1,2)
% plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
% ylabel('Biceps EMG (V)')
% subplot(3,1,3)
% plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
% ylabel('Triceps EMG (V)')
% xlabel('Time (sec)')
%

figure(5)
subplot(2,2,1)
%title('Position')
plot(lags_js/Fs_js*1000,mean(r_bi_js_pos_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_pos_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,mean(r_a_delt_js_pos_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,mean(r_p_delt_js_pos_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(6)
subplot(2,2,1)
%title('Velocity')
plot(lags_js/Fs_js*1000,mean(r_bi_js_vel_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_vel_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,mean(r_a_delt_js_vel_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,mean(r_p_delt_js_vel_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')


figure(7)
subplot(2,2,1)
%title('Acceleration')
plot(lags_js/Fs_js*1000,mean(r_bi_js_acc_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_acc_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,mean(r_a_delt_js_acc_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,mean(r_p_delt_js_acc_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')


figure(8)
subplot(2,3,1)
plot(lags/Fs_EMG*1000,mean(r_bi_tri_all,2),'LineWidth',2,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,2)
plot(lags/Fs_EMG*1000,mean(r_bi_a_delt_all,2),'LineWidth',2,'color','k');
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,3)
plot(lags/Fs_EMG*1000,mean(r_bi_p_delt_all,2),'LineWidth',2,'color','k');
title('Biceps-AD')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,4)
plot(lags/Fs_EMG*1000,mean(r_tri_a_delt_all,2),'LineWidth',2,'color','k');
title('Triceps-CB')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,5)
plot(lags/Fs_EMG*1000,mean(r_tri_p_delt_all,2),'LineWidth',2,'color','k');
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,6)
plot(lags/Fs_EMG*1000,mean(r_a_delt_p_delt_all,2),'LineWidth',2,'color','k');
title('CB-AD')
set(gca,'TickDir','out')
set(gca,'box','off')

figure(9)
subplot(2,2,1)
%title('Position')
plot(lags_theta_1/Fs_joint*1000,mean(r_bi_theta_1_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_theta_1/Fs_joint*1000,mean(r_tri_theta_1_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_theta_1/Fs_joint*1000,mean(r_a_delt_theta_1_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_theta_1/Fs_joint*1000,mean(r_p_delt_theta_1_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(10)
subplot(2,2,1)
%title('Position')
plot(lags_theta_1/Fs_joint*1000,mean(r_bi_theta_2_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_theta_1/Fs_joint*1000,mean(r_tri_theta_2_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_theta_1/Fs_joint*1000,mean(r_a_delt_theta_2_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_theta_1/Fs_joint*1000,mean(r_p_delt_theta_2_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(11)
subplot(2,2,1)
%title('Position')
plot(lags_Gamma_1/Fs_joint*1000,mean(r_bi_Gamma_1_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_tri_Gamma_1_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_a_delt_Gamma_1_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_p_delt_Gamma_1_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(12)
subplot(2,2,1)
%title('Position')
plot(lags_Gamma_1/Fs_joint*1000,mean(r_bi_Gamma_2_all,2),'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_tri_Gamma_2_all,2),'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_a_delt_Gamma_2_all,2),'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_Gamma_1/Fs_joint*1000,mean(r_p_delt_Gamma_2_all,2),'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')