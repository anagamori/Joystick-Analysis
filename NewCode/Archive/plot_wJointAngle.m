%% traj_reach_identification_v3.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 10/21/21
% Descriptions:
%   Identify rewarded reaches in which bell-shaped velocity profile with a single peak is observed
%--------------------------------------------------------------------------
%%

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_M_012121_CT_video'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '102121_60_80_050_0300_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
load('index_rewarded')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);

Fs = 1000;
% d = fdesign.lowpass('N,F3db',4, 10, 1000);
% hd = design(d, 'butter');

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
         'PassbandFrequency',10,'PassbandRipple',0.2, ...
         'SampleRate',Fs);
     
lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
         'PassbandFrequency',50,'PassbandRipple',0.2, ...
         'SampleRate',Fs);
     
d = fdesign.lowpass('N,F3db',4, 50, 1000);
hd_2 = design(d, 'butter');

index_reward = [];
time_reward = [];
n_reward = 0;

%%
data_folder_video = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data';
code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis';

Fs_video = 200;

filename_cam1 = 'M_012121_CT_102121_v2_4_17-04-00_cam1DLC_resnet_50_JoystickOct23shuffle1_50000';

cd(data_folder_video)
data_cam1 = readmatrix(filename_cam1);
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

%%
sample = data_cam1(:,1);
time_video = [1:length(sample)]./Fs_video;


shoulder_x = data_cam1(:,2);
shoulder_y = data_cam1(:,3);
elbow_x = data_cam1(:,5);
elbow_y = data_cam1(:,6);
wrist_x = data_cam1(:,8);
wrist_y = data_cam1(:,9);

joystick_x = data_cam1(:,14);
joystick_y = data_cam1(:,15);

x1 =  elbow_x-shoulder_x;
y1 =  elbow_y-shoulder_y;
upper_length = sqrt(x1.^2+y1.^2);
x2 =  wrist_x-elbow_x;
y2 =  wrist_y-elbow_y;
fore_length = sqrt(x2.^2+y2.^2);
elbow_angle_cam1 = 180+atan2d(x1.*y2-y1.*x2,x1.*x2+y1.*y2);


%%
% Find trials where reward was given
for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
        time_reward = [time_reward jstruct(i).reward_onset];
        n_reward = n_reward + length(jstruct(i).reward_onset);
    end
end

% Find rewarded trials where inter-trial interval is too short for video recording
flag = [];
for j = 1:n_reward
    if j > 1
        time_diff = time_reward(j) - time_reward(j-1);
        if time_diff>0 && time_diff<2300
            flag = [flag j];
        end
    end
end

% Reward contingency parameters
hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

%%
index_trial = 0;
index_identified = [];
theta = 0:0.01:2*pi;
for j = 7 %1:size(index_validTrial,2) %1:50 %3:32
    n = index_rewarded(1,j);
    k = index_rewarded(2,j);
    % Preprocessing of x- and y-trajectory data
    traj_x = filtfilt(lpFilt,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    traj_y = filtfilt(lpFilt,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    
    traj_x_2 = filtfilt(lpFilt2,jstruct(n).traj_x/100*6.35);
    vel_x_2 = [0 diff(traj_x_2)*Fs];
    acc_x_2 = [0 diff(vel_x_2)*Fs];
    traj_y_2 = filtfilt(lpFilt2,jstruct(n).traj_y/100*6.35);
    vel_y_2 = [0 diff(traj_y_2)*Fs];
    acc_y_2 = [0 diff(vel_y_2)*Fs];
    
    
    % Compute higher-order statistics
    radial_position = sqrt(traj_x.^2+traj_y.^2); % Radial position
    radial_vel = (traj_x.*vel_x + traj_y.*vel_y)./radial_position; % Radial velocity
    
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x); % Radius of curvature
    mag_vel = sqrt(vel_x.^2+vel_y.^2); % Magnitude of velocity vector (i.e. radial + tangential velocity)
    radial_acc = sqrt(acc_x.^2+acc_y.^2);
    
    radial_position_2 = sqrt(traj_x_2.^2+traj_y_2.^2); % Radial position
    radial_vel_2 = (traj_x_2.*vel_x_2 + traj_y_2.*vel_y_2)./radial_position_2; % Radial velocity
    
    RoC_2 = (vel_x_2.^2 + vel_y_2.^2).^(3/2)./abs(vel_x_2.*acc_y_2-vel_y_2.*acc_x_2); % Radius of curvature
    mag_vel_2 = sqrt(vel_x_2.^2+vel_y_2.^2); % Magnitude of velocity vector (i.e. radial + tangential velocity)
    radial_acc_2 = sqrt(acc_x_2.^2+acc_y_2.^2);
    
    %
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    reward_onset = jstruct(n).reward_onset(k);
    % Extract data within a trial
    trial_start_time = onset_js(k)-0.05*Fs;
    trial_end_time = trial_start_time + trial_duration + 0.05*Fs;
    time = [1:(trial_end_time-trial_start_time)+1]/Fs; %[-0.05*Fs:end_time]./Fs;
    time = time*1000;
            
    radial_pos_trial = radial_position(trial_start_time:trial_end_time);
    radial_vel_trial = radial_vel(trial_start_time:trial_end_time);
    mag_vel_trial = mag_vel(trial_start_time:trial_end_time);
    RoC_trial = RoC(trial_start_time:trial_end_time);
    
    radial_pos_trial_2 = radial_position_2(trial_start_time:trial_end_time);
    radial_vel_trial_2 = radial_vel_2(trial_start_time:trial_end_time);
    mag_vel_trial_2 = mag_vel_2(trial_start_time:trial_end_time);
    RoC_trial_2 = RoC_2(trial_start_time:trial_end_time);
    
    % Find velocity peaks
    [max_vel,loc_max_vel] = findpeaks(mag_vel_trial);
    
    
    if plotOpt == 1
        figure(1)
        plot(traj_x(trial_start_time:trial_end_time),traj_y(trial_start_time:trial_end_time),'LineWidth',1)
        xlim([-7 7])
        ylim([-7 7])
        set(gca,'TickDir','out')
        set(gca,'box','off')
        hold on
        plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
        plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
        plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
        axis equal
        
        figure()
        subplot(3,1,1)
        plot(time,traj_x(trial_start_time:trial_end_time),'LineWidth',1)
        hold on 
        plot(time,traj_x_2(trial_start_time:trial_end_time),'LineWidth',1)
        ylabel('x-position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        hold on
        subplot(3,1,2)
        plot(time,traj_y(trial_start_time:trial_end_time),'LineWidth',1)
        hold on 
        plot(time,traj_y_2(trial_start_time:trial_end_time),'LineWidth',1)
        xlabel('Time (s)')
        ylabel('y-position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        hold on
        subplot(3,1,3)
        plot(time,radial_position(trial_start_time:trial_end_time),'LineWidth',1)
        hold on
        plot(time,radial_position_2(trial_start_time:trial_end_time),'LineWidth',1)
        yline(hold_threshold,'--','color','k','LineWidth',1)
        yline(outer_threshold,'color','g','LineWidth',1)
        yline(max_distance,'color','g','LineWidth',1)
        ylabel('radial distance (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        
        figure()
        subplot(3,1,1)
        plot(time,radial_position(trial_start_time:trial_end_time),'LineWidth',1)       
        hold on
        plot(time,radial_position_2(trial_start_time:trial_end_time),'LineWidth',1)
        yline(hold_threshold,'--','color','k','LineWidth',1)
        yline(outer_threshold,'color','g','LineWidth',1)
        yline(max_distance,'color','g','LineWidth',1)
        ylabel('Radial Position (mm)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        subplot(3,1,2)
        plot(time,mag_vel(trial_start_time:trial_end_time),'LineWidth',1)
        hold on 
        plot(time,mag_vel_2(trial_start_time:trial_end_time),'LineWidth',1)
        ylabel('Radial Velocity (mm/s)')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        subplot(3,1,3)
        semilogy(time,RoC(trial_start_time:trial_end_time),'LineWidth',1)
        hold on 
        semilogy(time,RoC_2(trial_start_time:trial_end_time),'LineWidth',1)
        xlabel('Time (ms)')
        ylabel('Raidus of Curvature')
        set(gca,'TickDir','out');
        set(gca,'box','off')
        %
        time_new = [0:reward_onset+1*Fs - (reward_onset-0.5*Fs)]/Fs;
        figure(4)
        subplot(2,1,1)
        yyaxis left
        plot(time_new,radial_position_2(reward_onset-0.5*Fs:reward_onset+1*Fs))
        yyaxis right
        plot(time_video,sqrt(joystick_x.^2+joystick_y.^2))
        xline(0.5,'--','color','k')
        set(gca,'TickDir','out');
        set(gca,'box','off')

        subplot(2,1,2)
        plot(time_video,elbow_angle_cam1)
        set(gca,'TickDir','out');
        set(gca,'box','off')
    end
end

