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
mouse_ID = 'Box_4_F_081921_CT_EMG_2'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '110621_60_80_050_0300_010_010_000_360_000_360_000';

condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
load('index_validTrial')
load('index_identified')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));
peak_vel = [];

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
theta = 0:0.01:2*pi;
testTrial = 2;

for j = testTrial %:size(index_validTrial,2) %1:50 %3:32
    n = index_validTrial(1,j);
    k = index_validTrial(2,j);
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
    tangential_vel = (traj_x.*vel_y + traj_y.*vel_x)./(traj_x.^2+traj_y.^2);
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x); % Radius of curvature
    mag_vel = sqrt(vel_x.^2+vel_y.^2); % Magnitude of velocity vector (i.e. radial + tangential velocity)
    radial_acc = sqrt(acc_x.^2+acc_y.^2);
    
    radial_position_2 = sqrt(traj_x_2.^2+traj_y_2.^2); % Radial position
    radial_vel_2 = (traj_x_2.*vel_x_2 + traj_y_2.*vel_y_2)./radial_position_2; % Radial velocity
    tangential_vel_2 = (traj_x_2.*vel_y_2 + traj_y_2.*vel_x_2)./(traj_x_2.^2+traj_y_2.^2);
    
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
    tangential_vel_trial = tangential_vel(trial_start_time:trial_end_time);
    mag_vel_trial = mag_vel(trial_start_time:trial_end_time);
    RoC_trial = RoC(trial_start_time:trial_end_time);
    
    radial_pos_trial_2 = radial_position_2(trial_start_time:trial_end_time);
    radial_vel_trial_2 = radial_vel_2(trial_start_time:trial_end_time);
    tangential_vel_trial_2 = tangential_vel_2(trial_start_time:trial_end_time);
    mag_vel_trial_2 = mag_vel_2(trial_start_time:trial_end_time);
    RoC_trial_2 = RoC_2(trial_start_time:trial_end_time);
    
    % Find local minima in radial velocity and RoC
    [min_vel,loc_vel] = findpeaks(-mag_vel_trial);
    [min_RoC,loc_RoC] = findpeaks(-RoC_trial);
    
    [min_vel_2,loc_vel_2] = findpeaks(-mag_vel_trial_2);
    [min_RoC_2,loc_RoC_2] = findpeaks(-RoC_trial_2);
    
    % Find local minima in RoC that coincided (within 5 ms difference) with local minima in
    % radial velocity
    A = repmat(loc_RoC',[1 length(loc_vel)]);
    [minValue,closestIndex] = min(abs(A-loc_vel),[],1);
    loc_vel(minValue>5) = [];
    closestIndex(minValue>5) = [];
    
    A_2 = repmat(loc_RoC_2',[1 length(loc_vel_2)]);
    [minValue_2,closestIndex_2] = min(abs(A_2-loc_vel_2),[],1);
    loc_vel_2(minValue_2>5) = [];
    closestIndex_2(minValue_2>5) = [];
    
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
        
%         figure()
%         subplot(3,1,1)
%         plot(time,traj_x(trial_start_time:trial_end_time),'LineWidth',1)
%         hold on 
%         plot(time,traj_x_2(trial_start_time:trial_end_time),'LineWidth',1)
%         ylabel('x-position (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
%         hold on
%         subplot(3,1,2)
%         plot(time,traj_y(trial_start_time:trial_end_time),'LineWidth',1)
%         hold on 
%         plot(time,traj_y_2(trial_start_time:trial_end_time),'LineWidth',1)
%         xlabel('Time (s)')
%         ylabel('y-position (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
%         hold on
%         subplot(3,1,3)
%         plot(time,radial_position(trial_start_time:trial_end_time),'LineWidth',1)
%         hold on
%         plot(time,radial_position_2(trial_start_time:trial_end_time),'LineWidth',1)
%         yline(hold_threshold,'--','color','k','LineWidth',1)
%         yline(outer_threshold,'color','g','LineWidth',1)
%         yline(max_distance,'color','g','LineWidth',1)
%         ylabel('radial distance (mm)')
%         set(gca,'TickDir','out');
%         set(gca,'box','off')
        
        time_new = [0:reward_onset+0.5*Fs - (reward_onset-1*Fs)]/Fs;
        figure(2)
        subplot(3,1,1)
        plot(time_new,radial_position(reward_onset-1*Fs:reward_onset+0.5*Fs))
        hold on
        plot(time_new,radial_position_2(reward_onset-1*Fs:reward_onset+0.5*Fs))
        yline(hold_threshold,'--','color','k','LineWidth',1)
        yline(outer_threshold,'color','g','LineWidth',1)
        yline(max_distance,'color','g','LineWidth',1)
        xline(1,'--','color','k')
        ylabel('Radial Position (mm)')    
        set(gca,'TickDir','out');
        set(gca,'box','off')
        subplot(3,1,2)
        plot(time_new,mag_vel(reward_onset-1*Fs:reward_onset+0.5*Fs))
        hold on
        plot(time_new,mag_vel_2(reward_onset-1*Fs:reward_onset+0.5*Fs),'LineWidth',1)
        ylabel('Radial Velocity (mm/s)')
        set(gca,'TickDir','out');
        set(gca,'box','off')

       
    end
end

%%
data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'F_081921_CT'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '110621';
condition_array = strsplit(data_ID,'_');


cd([data_folder mouse_ID '\' data_ID])
load('test_3')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;

bpFilt = designfilt('bandpassfir','FilterOrder',8, ...
    'CutoffFrequency1',200,'CutoffFrequency2',700, ...
    'SampleRate',Fs_EMG);

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

trialDuration = 1.5*Fs_EMG;
nTrial = Ch3.length;
trigger = round(Ch3.times*Fs_EMG);

EMG_bi = bicep.values;
EMG_tri = tricep.values;

EMG_bi_filt = filtfilt(bpFilt,EMG_bi);
EMG_tri_filt = filtfilt(bpFilt,EMG_tri);

EMG_bi_rect = abs(EMG_bi_filt)-mean(abs(EMG_bi_filt));
EMG_tri_rect = abs(EMG_tri_filt)-mean(abs(EMG_tri_filt));

EMG_bi_smooth = filtfilt(lpFilt,EMG_bi_rect);
EMG_tri_smooth = filtfilt(lpFilt,EMG_tri_rect);

EMG_bi_trial = [];
EMG_tri_trial = [];
index = 1;
for i = 1:nTrial
    if i > 1
        if trigger(i) - trigger(i-1) > trialDuration
            EMG_bi_trial = [EMG_bi_trial EMG_bi_smooth(index:index+trialDuration-1)];
            EMG_tri_trial = [EMG_tri_trial  EMG_tri_smooth(index:index+trialDuration-1)];
            index = index + trialDuration;
        else
            missingTrial = i;
        end
    else
        EMG_bi_trial = [EMG_bi_trial EMG_bi_smooth(index:index+trialDuration-1)];
        EMG_tri_trial = [EMG_tri_trial  EMG_tri_smooth(index:index+trialDuration-1)];
        index = index + trialDuration;
    end
    
    
end

time_EMG = [1:1*Fs_EMG+0.5*Fs_EMG]/Fs_EMG;

figure(2)
subplot(3,1,3)
plot(time_EMG,EMG_bi_trial(:,index_identified(testTrial)))
hold on
plot(time_EMG,EMG_tri_trial(:,index_identified(testTrial)))
xlabel('Time (ms)')
ylabel('EMG')
set(gca,'TickDir','out');
set(gca,'box','off')

        
