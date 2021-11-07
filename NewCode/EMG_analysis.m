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

nTrial = Ch3.length;
trigger = round(Ch3.times*Fs-bicep.start*Fs);
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
for i = 1:nTrial
    
    EMG_bi_trial = EMG_bi_smooth(trigger(i)+1-1*Fs:trigger(i)+0.5*Fs);
    EMG_tri_trial = EMG_bi_smooth(trigger(i)+1-1*Fs:trigger(i)+0.5*Fs);
    
    figure(2)
    subplot(2,1,1)
    plot(EMG_bi_trial)
    hold on 
    subplot(2,1,2)
    plot(EMG_tri_trial)
    hold on
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
