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
mouse_ID = 'Box_4_AN05'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '010922_60_80_030_10000_010_010_000_180_000_180_001';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

Fs = 1000;

nTrial = 3;

%%
lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

radial_pos_new = filtfilt(lpFilt,js_reach(nTrial).radial_pos_2);

%%
time = -0.2+1/Fs:1/Fs:0.2;
trial_start_time =  1*Fs-0.2*Fs+1;
trial_end_time = 1*Fs + 0.2*Fs;
radial_pos_trial = js_reach(nTrial).radial_pos(trial_start_time:trial_end_time);
mag_vel_trial = js_reach(nTrial).mag_vel(trial_start_time:trial_end_time);
RoC_trial = js_reach(nTrial).RoC(trial_start_time:trial_end_time);

[min_vel,loc_vel] = findpeaks(-mag_vel_trial);
[min_RoC,loc_RoC] = findpeaks(-RoC_trial);
A = repmat(loc_RoC',[1 length(loc_vel)]);
[minValue,closestIndex] = min(abs(A-loc_vel),[],1);
loc_vel(minValue>5) = [];
closestIndex(minValue>5) = [];

radial_pos_2_trial = js_reach(nTrial).radial_pos_2(trial_start_time:trial_end_time);
mag_vel_2_trial = js_reach(nTrial).mag_vel_2(trial_start_time:trial_end_time);
RoC_2_trial = js_reach(nTrial).RoC_2(trial_start_time:trial_end_time);

[min_vel_2,loc_vel_2] = findpeaks(-mag_vel_2_trial);
[min_RoC_2,loc_RoC_2] = findpeaks(-RoC_2_trial);
A_2 = repmat(loc_RoC_2',[1 length(loc_vel_2)]);
[minValue_2,closestIndex_2] = min(abs(A_2-loc_vel_2),[],1);
loc_vel_2(minValue_2>5) = [];
closestIndex_2(minValue_2>5) = [];

figure(1)
plot(time,radial_pos_trial,'b','LineWidth',1)
hold on
plot(time(loc_vel),radial_pos_trial(loc_vel),'o','color','b','LineWidth',1)
plot(time,radial_pos_2_trial,'r','LineWidth',1)
hold on
plot(time(loc_vel_2),radial_pos_2_trial(loc_vel_2),'o','color','r','LineWidth',1)
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)

%% 
% Find time point of conincident local minima in low-pvelocity and RoC in which
% radial position (raw data) was in the target region
loc_min_vel_taregt = loc_vel(radial_pos_2_trial(loc_vel)>outer_threshold&radial_pos_2_trial(loc_vel)<max_distance);
loc_min_vel_hold = loc_vel_2(radial_pos_2_trial(loc_vel_2)<hold_threshold);
loc_min_vel_hold(loc_min_vel_hold>loc_min_vel_taregt) = [];

reach_start_idx = loc_min_vel_hold(end);
reach_end_idx = loc_min_vel_taregt(1)+0.05*Fs;
time_reach = [0:reach_end_idx-reach_start_idx]./Fs;

figure(2)
plot(time_reach,radial_pos_trial(reach_start_idx:reach_end_idx),'b','LineWidth',1)
hold on
plot(time_reach,radial_pos_2_trial(reach_start_idx:reach_end_idx),'r','LineWidth',1)
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
