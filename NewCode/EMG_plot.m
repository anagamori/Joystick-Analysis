close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '032522_63_79_020_10000_020_016_030_150_030_150_000';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

% cd([data_folder mouse_ID '\' data_ID])
% load('js_reach')
% load('hold_still_duration')
% load('target_hold_duration')
% load('reach_duration')
% load('peak_velocity')
% load('path_length')
% cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

mouse_ID_array = strsplit(mouse_ID,'_');

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

cd([data_folder mouse_ID '\EMG\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;

EMG_bi_all = [];
EMG_tri_all = [];
EMG_a_delt_all = [];
EMG_p_delt_all = [];
for i = 1:length(EMG_struct)
   EMG_bi_all = [EMG_bi_all EMG_struct(i).biceps_zscore];
   EMG_tri_all = [EMG_tri_all EMG_struct(i).triceps_zscore];
   EMG_a_delt_all = [EMG_a_delt_all EMG_struct(i).a_delt_zscore];
   EMG_p_delt_all = [EMG_p_delt_all EMG_struct(i).p_delt_zscore]; 
    
 
end

time = 1:size(EMG_bi_all,1);
time = time./Fs_EMG;
figure(1)
subplot(4,1,1)
plot(time,mean(EMG_bi_all,2),'k','LineWidth',1)
ylabel('Channel 1 (mV)')
subplot(4,1,2)
plot(time,mean(EMG_tri_all,2),'k','LineWidth',1)
ylabel('Channel 2 (mV)')
subplot(4,1,3)
plot(time,mean(EMG_a_delt_all,2),'k','LineWidth',1)
ylabel('Channel 3 (mV)')
subplot(4,1,4)
plot(time,mean(EMG_p_delt_all,2),'k','LineWidth',1)
xlabel('Time (sec)')
ylabel('Channel 4 (mV)')