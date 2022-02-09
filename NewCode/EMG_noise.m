close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'AN05\'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '020722';

data_name = 'connected';
cd([data_folder mouse_ID '\EMG\' data_ID])
load(data_name)
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',1000,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

hpFilt = designfilt('highpassiir','FilterOrder',8, ...
    'PassbandFrequency',100,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

% trialDuration = 1.5*Fs_EMG;
% nTrial = Ch3.length;
% trigger = round(Ch3.times*Fs_EMG);

EMG_bi = bicep.values-tricep.values(1:length(bicep.values));
EMG_tri = tricep.values(1:length(bicep.values))-bicep.values(1:length(bicep.values));

EMG_bi_filt = filtfilt(lpFilt,EMG_bi);
EMG_tri_filt = filtfilt(lpFilt,EMG_tri);

EMG_bi_filt = filtfilt(hpFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(hpFilt,EMG_tri_filt);

EMG_bi_rect = abs(EMG_bi_filt); %-mean(abs(EMG_bi_filt));
EMG_tri_rect = abs(EMG_tri_filt); %-mean(abs(EMG_tri_filt));

EMG_bi_smooth = filtfilt(lpFilt2,EMG_bi_rect);
EMG_tri_smooth = filtfilt(lpFilt2,EMG_tri_rect);

time = [1:length(EMG_bi)]./Fs_EMG;
figure(1)
subplot(2,1,1)
plot(time,EMG_bi)
hold on
plot(time,EMG_bi_filt)
plot(time,EMG_bi_rect)
plot(time,EMG_bi_smooth)
%ylim([-0.02 0.02])

time = [1:length(EMG_tri)]./Fs_EMG;
subplot(2,1,2)
plot(time,EMG_tri)
hold on
plot(time,EMG_tri_filt)
plot(time,EMG_tri_rect)
plot(time,EMG_tri_smooth)
%ylim([-0.02 0.02])
[x,y] = ginput(2);
[x2,y2] = ginput(2);

EMG_bi_low_noise = EMG_bi_filt(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG))-mean(EMG_bi_filt(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG)));
EMG_tri_low_noise = EMG_tri_filt(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG))-mean(EMG_tri_filt(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG)));

EMG_bi_high_noise = EMG_bi_filt(round(x2(1)*Fs_EMG):round(x2(2)*Fs_EMG))-mean(EMG_bi_filt(round(x2(1)*Fs_EMG):round(x2(2)*Fs_EMG)));
EMG_tri_high_noise = EMG_tri_filt(round(x2(1)*Fs_EMG):round(x2(2)*Fs_EMG))-mean(EMG_tri_filt(round(x2(1)*Fs_EMG):round(x2(2)*Fs_EMG)));


[pxx_bi_low_noise,~] = pwelch(EMG_bi_low_noise,[],[],0:1:5000,Fs_EMG);
[pxx_bi_high_noise,~] = pwelch(EMG_bi_high_noise,[],[],0:1:5000,Fs_EMG);
[pxx_tri_low_noise,f] = pwelch(EMG_tri_low_noise,[],[],0:1:5000,Fs_EMG);
[pxx_tri_high_noise,~] = pwelch(EMG_tri_high_noise,[],[],0:1:5000,Fs_EMG);



%%
figure()
plot(f,pxx_bi_low_noise)
hold on
plot(f,pxx_tri_low_noise)

figure()
plot(f,pxx_bi_high_noise)
hold on
plot(f,pxx_tri_high_noise)

