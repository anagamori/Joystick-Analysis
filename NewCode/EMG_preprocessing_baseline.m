close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'AN04\'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '031822';

data_name = 'baseline';
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

bsFilt = designfilt('bandstopiir','FilterOrder',20, ...
         'HalfPowerFrequency1',118,'HalfPowerFrequency2',122, ...       % Design method options
       'SampleRate',Fs_EMG);    
bsFilt2 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',178,'HalfPowerFrequency2',182, ...       % Design method options
   'SampleRate',Fs_EMG);    
bsFilt3 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',238,'HalfPowerFrequency2',242, ...       % Design method options
   'SampleRate',Fs_EMG);   
bsFilt4 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',298,'HalfPowerFrequency2',302, ...       % Design method options
   'SampleRate',Fs_EMG); 
bsFilt5 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',358,'HalfPowerFrequency2',362, ...       % Design method options
   'SampleRate',Fs_EMG);
bsFilt6 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',418,'HalfPowerFrequency2',422, ...       % Design method options
   'SampleRate',Fs_EMG); 

% trialDuration = 1.5*Fs_EMG;
% nTrial = Ch3.length;
% trigger = round(Ch3.times*Fs_EMG);

EMG_bi = biceps.values;
EMG_tri = triceps.values;


EMG_bi_filt = filtfilt(lpFilt,EMG_bi);
EMG_tri_filt = filtfilt(lpFilt,EMG_tri);

EMG_bi_filt = filtfilt(hpFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(hpFilt,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt2,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt2,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt3,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt3,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt4,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt4,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt5,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt5,EMG_tri_filt);

EMG_bi_filt = filtfilt(bsFilt6,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt6,EMG_tri_filt);

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
ylim([-50 50])

time = [1:length(EMG_tri)]./Fs_EMG;
subplot(2,1,2)
plot(time,EMG_tri)
hold on 
plot(time,EMG_tri_filt)
plot(time,EMG_tri_rect)
plot(time,EMG_tri_smooth)
ylim([-50 50])
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
%ylim([0 0.02])
ylabel('Biceps')
set(gca,'TickDir','out')
       set(gca,'box','off')
       time = [1:length(EMG_tri)]./Fs_EMG;

subplot(2,1,2)
plot(time,EMG_tri_smooth)
%ylim([0 0.02])
ylabel('Triceps')
set(gca,'TickDir','out')
       set(gca,'box','off')

cd([data_folder mouse_ID '\EMG\' data_ID])
save('baseline_mean','baseline_mean')
save('baseline_sd','baseline_sd')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')