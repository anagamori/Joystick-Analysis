%% create_js_reach.m
%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 1/9/21
% Descriptions:
%--------------------------------------------------------------------------
%%

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));
peak_vel = [];

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);

index_reward = [];
time_reward = [];
n_reward = 0;
index_validTrial = [];

% Find trials where reward was given
for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
        time_reward = [time_reward jstruct(i).reward_onset];
        n_reward = n_reward + length(jstruct(i).reward_onset);
    end
end

% Find rewarded trials where inter-trial interval is too short for video recording
flag_overlap = zeros(1,n_reward);
flag_video = zeros(1,n_reward);
for j = 1:n_reward
    if j > 1
        time_diff = time_reward(j) - time_reward(j-1);
        if time_diff>0 && time_diff<1500
            flag_overlap(j) = 1;
        end
        if time_diff>0 && time_diff<2300
            flag_video(j) = 1;
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
zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);  

%%
reach_duration = [];
n_successful_trial = 0;
index_identified = [];
index_rewarded = [];
theta = 0:0.01:2*pi;
for j = 1:length(index_reward) %1:50 %3:32
    n = index_reward(j);
    
    % Preprocessing of x- and y-trajectory data
    traj_x = filtfilt(lpFilt,jstruct(n).traj_x/100*6.35);
    vel_x = gradient(traj_x)*Fs; %[0 diff(traj_x)*Fs];
    acc_x = gradient(vel_x)*Fs; %[0 diff(vel_x)*Fs];
    traj_y = filtfilt(lpFilt,jstruct(n).traj_y/100*6.35);
    vel_y = gradient(traj_y)*Fs;
    acc_y = gradient(vel_x)*Fs;
    
    traj_x_2 = filtfilt(lpFilt2,jstruct(n).traj_x/100*6.35);
    vel_x_2 = gradient(traj_x_2)*Fs;
    acc_x_2 = gradient(vel_x_2)*Fs;
    traj_y_2 = filtfilt(lpFilt2,jstruct(n).traj_y/100*6.35);
    vel_y_2 = gradient(traj_y_2)*Fs;
    acc_y_2 = gradient(vel_y_2)*Fs;
    % Compute higher-order statistics
    radial_position = sqrt(traj_x.^2+traj_y.^2); % Radial position
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x); % Radius of curvature
    mag_vel = sqrt(vel_x.^2+vel_y.^2); % Magnitude of velocity vector (i.e. radial + tangential velocity)
    
    radial_position_2 = sqrt(traj_x_2.^2+traj_y_2.^2); % Radial position
    RoC_2 = (vel_x_2.^2 + vel_y_2.^2).^(3/2)./abs(vel_x_2.*acc_y_2-vel_y_2.*acc_x_2); % Radius of curvature
    mag_vel_2 = sqrt(vel_x_2.^2+vel_y_2.^2); % Magnitude of velocity vector (i.e. radial + tangential velocity)
    
    %
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    % Loop through rewarded trials in which joystick contact occurred
    for k = 1:length(js_reward)
        n_successful_trial = n_successful_trial+ 1;
        js_reach(n_successful_trial).flag_overlap = flag_overlap(n_successful_trial);
        js_reach(n_successful_trial).flag_video = flag_video(n_successful_trial);
        
        % Extract data within a trial
        recording_start_time = onset_reward(k)-1*Fs;
        recording_end_time = onset_reward(k)+0.5*Fs-1;       
        
        % store data into structure
        if recording_end_time > length(traj_x)
            js_reach(n_successful_trial).traj_x = traj_x(recording_start_time:end);
            js_reach(n_successful_trial).traj_y = traj_y(recording_start_time:end);
            js_reach(n_successful_trial).radial_pos = radial_position(recording_start_time:end);
            js_reach(n_successful_trial).mag_vel = mag_vel(recording_start_time:end);
            js_reach(n_successful_trial).RoC = RoC(recording_start_time:end);

            js_reach(n_successful_trial).traj_x_2 = traj_x_2(recording_start_time:end);
            js_reach(n_successful_trial).traj_y_2 = traj_y_2(recording_start_time:end);
            js_reach(n_successful_trial).radial_pos_2 = radial_position_2(recording_start_time:end);
            js_reach(n_successful_trial).mag_vel_2 = mag_vel_2(recording_start_time:end);
            js_reach(n_successful_trial).RoC_2 = RoC_2(recording_start_time:end);
        elseif recording_start_time < 0
            js_reach(n_successful_trial).traj_x = traj_x(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).traj_y = traj_y(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).radial_pos = radial_position(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).mag_vel = mag_vel(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).RoC = RoC(onset_reward(k):recording_end_time);

            js_reach(n_successful_trial).traj_x_2 = traj_x_2(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).traj_y_2 = traj_y_2(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).radial_pos_2 = radial_position_2(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).mag_vel_2 = mag_vel_2(onset_reward(k):recording_end_time);
            js_reach(n_successful_trial).RoC_2 = RoC_2(onset_reward(k):recording_end_time);
        else
            js_reach(n_successful_trial).traj_x = traj_x(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).traj_y = traj_y(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).radial_pos = radial_position(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).mag_vel = mag_vel(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).RoC = RoC(recording_start_time:recording_end_time);

            js_reach(n_successful_trial).traj_x_2 = traj_x_2(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).traj_y_2 = traj_y_2(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).radial_pos_2 = radial_position_2(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).mag_vel_2 = mag_vel_2(recording_start_time:recording_end_time);
            js_reach(n_successful_trial).RoC_2 = RoC_2(recording_start_time:recording_end_time);
        end
    
        
    end
end

cd([data_folder mouse_ID '\' data_ID])
save('js_reach','js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
