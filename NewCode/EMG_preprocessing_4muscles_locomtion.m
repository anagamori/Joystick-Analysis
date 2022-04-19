%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMG_preprocessing.m
% Descriptions:
%   - Covert a mat file exported from spike 2 into data structure
%   containing pre-processed EMG signals
%   - EMG signals are broken into individual trials based on trial duration
%   (each data structure entry corresponds to each trial)
%   - EMG signals are band-pass filtered, rectified and smoothed.
%   - Currently includes z-score normalization based on baseline activity
%   (i.e. activity when animals are not moving or using the muscles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode';
mouse_ID = 'AN06';
data_ID = '032322';

data_name = 'locomotion';
cd([data_folder mouse_ID '\EMG\' data_ID])
load(data_name)
% load('baseline_mean')
% load('baseline_sd')
cd(code_folder)

Fs_EMG = 10000;

lpFilt = designfilt('lowpassiir','FilterOrder',4, ...
    'PassbandFrequency',1000,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

hpFilt = designfilt('highpassiir','FilterOrder',4, ...
    'PassbandFrequency',600,'PassbandRipple',0.2, ...
    'SampleRate',Fs_EMG);

lpFilt2 = designfilt('lowpassiir','FilterOrder',4, ...
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
bsFilt7 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',478,'HalfPowerFrequency2',482, ...       % Design method options
   'SampleRate',Fs_EMG); 
bsFilt8 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',538,'HalfPowerFrequency2',542, ...       % Design method options
   'SampleRate',Fs_EMG); 

bsFilt9 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',253-3,'HalfPowerFrequency2',253+3, ...       % Design method options
   'SampleRate',Fs_EMG); 

bsFilt10 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',327-5,'HalfPowerFrequency2',327+5, ...       % Design method options
   'SampleRate',Fs_EMG); 
bsFilt11 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',380-5,'HalfPowerFrequency2',380+5, ...       % Design method options
   'SampleRate',Fs_EMG); 
bsFilt12 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',440-5,'HalfPowerFrequency2',440+5, ...       % Design method options
   'SampleRate',Fs_EMG);
bsFilt13 = designfilt('bandstopiir','FilterOrder',20, ...
     'HalfPowerFrequency1',506-5,'HalfPowerFrequency2',506+5, ...       % Design method options
   'SampleRate',Fs_EMG);


trialDuration = 1.5*Fs_EMG;
nTrial = BNC1.length;
trigger = round(BNC1.times*Fs_EMG);

EMG_bi = biceps.values;
EMG_tri = triceps.values;
EMG_a_delt = a_delt.values;
EMG_p_delt = p_delt.values;

EMG_bi_filt = filtfilt(lpFilt,EMG_bi);
EMG_tri_filt = filtfilt(lpFilt,EMG_tri);
EMG_a_delt_filt = filtfilt(lpFilt,EMG_a_delt);
EMG_p_delt_filt = filtfilt(lpFilt,EMG_p_delt);

EMG_bi_filt = filtfilt(hpFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(hpFilt,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(hpFilt,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(hpFilt,EMG_p_delt_filt);

% EMG_bi_filt = filtfilt(bsFilt,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt2,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt2,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt2,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt2,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt3,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt3,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt3,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt3,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt4,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt4,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt4,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt4,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt5,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt5,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt5,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt5,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt6,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt6,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt6,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt6,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt7,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt7,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt7,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt7,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt8,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt8,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt8,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt8,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt9,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt9,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt9,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt9,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt10,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt10,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt10,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt10,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt11,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt11,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt11,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt11,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt12,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt12,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt12,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt12,EMG_p_delt_filt);
% 
% EMG_bi_filt = filtfilt(bsFilt13,EMG_bi_filt);
% EMG_tri_filt = filtfilt(bsFilt13,EMG_tri_filt);
% EMG_a_delt_filt = filtfilt(bsFilt13,EMG_a_delt_filt);
% EMG_p_delt_filt = filtfilt(bsFilt13,EMG_p_delt_filt);

%EMG_bi_filt = EMG_bi_filt(1:length(EMG_tri))-EMG_tri_filt;
EMG_bi_rect = abs(EMG_bi_filt);
EMG_tri_rect = abs(EMG_tri_filt);
EMG_a_delt_rect = abs(EMG_a_delt_filt);
EMG_p_delt_rect = abs(EMG_p_delt_filt);

EMG_bi_smooth = filtfilt(lpFilt2,EMG_bi_rect); %-baseline_mean(1))./baseline_sd(1);
EMG_tri_smooth = filtfilt(lpFilt2,EMG_tri_rect); %-baseline_mean(2))./baseline_sd(2);
EMG_a_delt_smooth = filtfilt(lpFilt2,EMG_a_delt_rect); %-baseline_mean(1))./baseline_sd(1);
EMG_p_delt_smooth = filtfilt(lpFilt2,EMG_p_delt_rect);
% EMG_bi_smooth = (filtfilt(lpFilt2,EMG_bi_rect)-baseline_mean(1))./baseline_sd(1);
% EMG_tri_smooth = (filtfilt(lpFilt2,EMG_tri_rect)-baseline_mean(2))./baseline_sd(2);

index = 1;
flag_noise = zeros(1,nTrial);

cutoff =860000;
time = 1:cutoff;
time = time./Fs_EMG;

figure()
subplot(4,1,1)
plot(time,EMG_bi_filt(1:cutoff),'LineWidth',1,'color','k')
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')  
subplot(4,1,2)
plot(time,EMG_tri_filt(1:cutoff),'LineWidth',1,'color','k')
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')  
subplot(4,1,3)
plot(time,EMG_a_delt_filt(1:cutoff),'LineWidth',1,'color','k')
ylabel('AD')
set(gca,'TickDir','out')
set(gca,'box','off')  
subplot(4,1,4)
plot(time,EMG_p_delt_filt(1:cutoff),'LineWidth',1,'color','k')
ylabel('PD')
set(gca,'TickDir','out')
set(gca,'box','off')  

figure()
ax1 = subplot(4,1,1);
plot(time,EMG_bi_smooth(1:cutoff),'LineWidth',1,'color','k')
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')  
ax2 = subplot(4,1,2);
plot(time,EMG_tri_smooth(1:cutoff),'LineWidth',1,'color','k')
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')  
ax3 = subplot(4,1,3);
plot(time,EMG_a_delt_smooth(1:cutoff),'LineWidth',1,'color','k')
ylabel('AD')
set(gca,'TickDir','out')
set(gca,'box','off')  
ax4 = subplot(4,1,4);
plot(time,EMG_p_delt_smooth(1:cutoff),'LineWidth',1,'color','k')
ylabel('PD')
set(gca,'TickDir','out')
set(gca,'box','off')  
linkaxes([ax1 ax2 ax3 ax4],'x')
