close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'AN05\'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = 'test';

data_name = 'temp';
cd([data_folder mouse_ID '\EMG\' data_ID])
load(data_name)
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',500,'PassbandRipple',0.2, ...
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

EMG_bi = tri.values(0.8e6:end);
EMG_tri = trap.values(0.8e6:end);

EMG_bi_filt = filtfilt(lpFilt,EMG_bi);
EMG_tri_filt = filtfilt(lpFilt,EMG_tri);

EMG_bi_filt = filtfilt(hpFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(hpFilt,EMG_tri_filt);

EMG_bi_rect = abs(EMG_bi_filt); %-mean(abs(EMG_bi_filt));
EMG_tri_rect = abs(EMG_tri_filt); %-mean(abs(EMG_tri_filt));

EMG_bi_smooth = filtfilt(lpFilt2,EMG_bi_rect);
EMG_tri_smooth = filtfilt(lpFilt2,EMG_tri_rect);

[pxx_bi,~] = pwelch(EMG_bi-mean(EMG_bi),[],[],0:1:5000,Fs_EMG);
[pxx_bi_filt,~] = pwelch(EMG_bi_filt-mean(EMG_bi_filt),[],[],0:1:5000,Fs_EMG);
[pxx_tri,f] = pwelch(EMG_tri-mean(EMG_tri),[],[],0:1:5000,Fs_EMG);
[pxx_tri_filt,~] = pwelch(EMG_tri_filt-mean(EMG_tri_filt),[],[],0:1:5000,Fs_EMG);


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
figure()
plot(f,pxx_bi)
hold on
plot(f,pxx_bi_filt)

figure()
plot(f,pxx_tri)
hold on
plot(f,pxx_tri_filt)

baseline_mean = [mean(EMG_bi_smooth(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG))) mean(EMG_tri_smooth(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG)))];
baseline_sd = [std(EMG_bi_smooth(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG))) std(EMG_tri_smooth(round(x(1)*Fs_EMG):round(x(2)*Fs_EMG)))];

time = [1:length(EMG_bi)]./Fs_EMG;
figure()
subplot(2,1,1)
plot(time,EMG_bi_smooth)
ylim([0 0.02])
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')
time = [1:length(EMG_tri)]./Fs_EMG;

subplot(2,1,2)
plot(time,EMG_tri_smooth)
ylim([0 0.02])
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')
