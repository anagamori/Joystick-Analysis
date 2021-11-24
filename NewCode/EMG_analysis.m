close all
clear all
clc


data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'F_081921_CT'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '110621';
condition_array = strsplit(data_ID,'_');


cd([data_folder mouse_ID '\' data_ID])
load('test_3')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs = 10000;

bpFilt = designfilt('bandpassfir','FilterOrder',8, ...
    'CutoffFrequency1',200,'CutoffFrequency2',700, ...
    'SampleRate',Fs);

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',30,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

trialDuration = 1.5*Fs;
nTrial = Ch3.length;
trigger = round(Ch3.times*Fs);

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
        EMG_bi_trial = [EMG_bi_trial  EMG_bi_smooth(index:index+trialDuration-1)];
        EMG_tri_trial = [EMG_tri_trial  EMG_tri_smooth(index:index+trialDuration-1)];
        index = index + trialDuration;
    end
    
    
end

figure(1)
subplot(2,1,1)
plot(EMG_bi)
hold on
plot(EMG_bi_filt)
plot(EMG_bi_smooth)
subplot(2,1,2)
plot(EMG_tri)
hold on
plot(EMG_tri_filt)
plot(EMG_tri_smooth)

figure(2)
subplot(2,1,1)
plot(mean(EMG_bi_trial,2))
hold on
subplot(2,1,2)
plot(mean(EMG_tri_trial,2))
hold on