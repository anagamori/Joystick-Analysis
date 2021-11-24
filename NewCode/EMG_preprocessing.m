close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'AN01'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '112321';

data_name = 'data';
cd([data_folder mouse_ID '\' data_ID])
load(data_name)
load('baseline_mean')
load('baseline_sd')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',500,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

hpFilt = designfilt('highpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

trialDuration = 1.5*Fs_EMG;
nTrial = Ch3.length;
trigger = round(Ch3.times*Fs_EMG);

EMG_bi = bicep.values;
EMG_tri = tricep.values;

EMG_bi_filt = filtfilt(lpFilt,EMG_bi);
EMG_tri_filt = filtfilt(lpFilt,EMG_tri);

EMG_bi_filt = filtfilt(hpFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(hpFilt,EMG_tri_filt);

EMG_bi_rect = abs(EMG_bi_filt); %-mean(abs(EMG_bi_filt));
EMG_tri_rect = abs(EMG_tri_filt); %-mean(abs(EMG_tri_filt));

EMG_bi_smooth = filtfilt(lpFilt2,EMG_bi_rect); %-baseline_mean(1))./baseline_sd(1);
EMG_tri_smooth = filtfilt(lpFilt2,EMG_tri_rect); %baseline_mean(2))./baseline_sd(2);

index = 1;
for i = 1:nTrial
    if i > 1
        if trigger(i) - trigger(i-1) > trialDuration
            EMG_struct(i).biceps_raw = EMG_bi_filt(index:index+trialDuration-1);
            EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration-1);    
            EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration-1);
            EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration-1);         
            index = index + trialDuration;
        else
            
            buffer_duration = trigger(i) - trigger(i-1) -0.5*Fs_EMG;
            trialDuration_new = buffer_duration + 0.5*Fs_EMG;
            EMG_struct(i).biceps_raw = EMG_bi_filt(index:index+trialDuration_new-1);
            EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration_new-1);    
            EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration_new-1);
            EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration_new-1); 
            index = index + trialDuration_new;
        end
    else
        EMG_struct(i).biceps_raw = EMG_bi_filt(index:index+trialDuration-1);
        EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration-1);    
        EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration-1);
        EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration-1);
        index = index + trialDuration;
    end

    figure(1)
    subplot(2,1,1)
    plot(EMG_struct(i).biceps)
    hold on 
    subplot(2,1,2)
    plot(EMG_struct(i).triceps)
    hold on 
    
    index_long(i) = index;
end

cd([data_folder mouse_ID '\' data_ID])
save([data_name '_processed'],'EMG_struct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')