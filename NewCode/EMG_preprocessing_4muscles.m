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
data_ID = '032222';

data_name = 'data';
cd([data_folder mouse_ID '\EMG\' data_ID])
load(data_name)
% load('baseline_mean')
% load('baseline_sd')
cd(code_folder)

Fs_EMG = 10000;

lpFilt = designfilt('lowpassiir','FilterOrder',4, ...
    'PassbandFrequency',2000,'PassbandRipple',0.2, ...
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

EMG_bi_filt = filtfilt(bsFilt,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt2,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt2,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt2,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt2,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt3,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt3,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt3,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt3,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt4,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt4,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt4,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt4,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt5,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt5,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt5,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt5,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt6,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt6,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt6,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt6,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt7,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt7,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt7,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt7,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt8,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt8,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt8,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt8,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt9,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt9,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt9,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt9,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt10,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt10,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt10,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt10,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt11,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt11,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt11,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt11,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt12,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt12,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt12,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt12,EMG_p_delt_filt);

EMG_bi_filt = filtfilt(bsFilt13,EMG_bi_filt);
EMG_tri_filt = filtfilt(bsFilt13,EMG_tri_filt);
EMG_a_delt_filt = filtfilt(bsFilt13,EMG_a_delt_filt);
EMG_p_delt_filt = filtfilt(bsFilt13,EMG_p_delt_filt);

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

%%
for i = 1:nTrial
    
    
    if i > 1
        if trigger(i) - trigger(i-1) > trialDuration
            
            temp_bi = EMG_bi_smooth(index:index+trialDuration-1);
            temp_tri = EMG_tri_smooth(index:index+trialDuration-1);
            temp_a_delt = EMG_a_delt_smooth(index:index+trialDuration-1);
            temp_p_delt = EMG_p_delt_smooth(index:index+trialDuration-1);
            
            figure()
            subplot(4,1,1)
            plot(temp_bi)
            ylabel('Biceps')
            subplot(4,1,2)
            plot(temp_tri)
            ylabel('Triceps')
            subplot(4,1,3)
            plot(temp_a_delt)
            ylabel('AD')
            subplot(4,1,4)
            plot(temp_p_delt)
            ylabel('PD')
            
            [x,y] = ginput(8);
            baseline_mean = [mean(temp_bi(round(x(1)):round(x(2)))) mean(temp_tri(round(x(3)):round(x(4)))) ...
                mean(temp_a_delt(round(x(5)):round(x(6)))) mean(temp_p_delt(round(x(7)):round(x(8))))];
            baseline_sd = [std(temp_bi(round(x(1)):round(x(2)))) std(temp_tri(round(x(3)):round(x(4)))) ...
                std(temp_a_delt(round(x(5)):round(x(6)))) std(temp_p_delt(round(x(7)):round(x(8))))];
            
            EMG_bi_zscore = (EMG_bi_smooth-baseline_mean(1))./baseline_sd(1);
            EMG_tri_zscore = (EMG_tri_smooth-baseline_mean(2))./baseline_sd(2);
            EMG_a_delt_zscore = (EMG_a_delt_smooth-baseline_mean(3))./baseline_sd(3);
            EMG_p_delt_zscore = (EMG_p_delt_smooth-baseline_mean(4))./baseline_sd(4);
            
            EMG_struct(i).biceps_raw = EMG_bi_filt(index:index+trialDuration-1);
            EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration-1);
            EMG_struct(i).a_delt_raw = EMG_a_delt_filt(index:index+trialDuration-1);
            EMG_struct(i).p_delt_raw = EMG_p_delt_filt(index:index+trialDuration-1);
            EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration-1);
            EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration-1);
            EMG_struct(i).a_delt = EMG_a_delt_smooth(index:index+trialDuration-1);
            EMG_struct(i).p_delt = EMG_p_delt_smooth(index:index+trialDuration-1);
            EMG_struct(i).biceps_zscore = EMG_bi_zscore(index:index+trialDuration-1);
            EMG_struct(i).triceps_zscore = EMG_tri_zscore(index:index+trialDuration-1);
            EMG_struct(i).a_delt_zscore = EMG_a_delt_zscore(index:index+trialDuration-1);
            EMG_struct(i).p_delt_zscore = EMG_p_delt_zscore(index:index+trialDuration-1);
            index = index + trialDuration;
        else
            
            buffer_duration = trigger(i) - trigger(i-1) -0.5*Fs_EMG;
            trialDuration_new = buffer_duration + 0.5*Fs_EMG;
            
            temp_bi = EMG_bi_smooth(index:index+trialDuration_new-1);
            temp_tri = EMG_tri_smooth(index:index+trialDuration_new-1);
            temp_a_delt = EMG_a_delt_smooth(index:index+trialDuration_new-1);
            temp_p_delt = EMG_p_delt_smooth(index:index+trialDuration_new-1);
            
           figure()
            subplot(4,1,1)
            plot(temp_bi)
            ylabel('Biceps')
            subplot(4,1,2)
            plot(temp_tri)
            ylabel('Triceps')
            subplot(4,1,3)
            plot(temp_a_delt)
            ylabel('AD')
            subplot(4,1,4)
            plot(temp_p_delt)
            ylabel('PD')
            
            [x,y] = ginput(8);
             baseline_mean = [mean(temp_bi(round(x(1)):round(x(2)))) mean(temp_tri(round(x(3)):round(x(4)))) ...
                mean(temp_a_delt(round(x(5)):round(x(6)))) mean(temp_p_delt(round(x(7)):round(x(8))))];
            baseline_sd = [std(temp_bi(round(x(1)):round(x(2)))) std(temp_tri(round(x(3)):round(x(4)))) ...
                std(temp_a_delt(round(x(5)):round(x(6)))) std(temp_p_delt(round(x(7)):round(x(8))))];
            
            EMG_bi_zscore = (EMG_bi_smooth-baseline_mean(1))./baseline_sd(1);
            EMG_tri_zscore = (EMG_tri_smooth-baseline_mean(2))./baseline_sd(2);
            EMG_a_delt_zscore = (EMG_a_delt_smooth-baseline_mean(3))./baseline_sd(3);
            EMG_p_delt_zscore = (EMG_p_delt_smooth-baseline_mean(4))./baseline_sd(4);
            
            
            EMG_struct(i).triceps_raw = EMG_bi_filt(index:index+trialDuration_new-1);
            EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration_new-1);      
            EMG_struct(i).a_delt_raw = EMG_a_delt_filt(index:index+trialDuration_new-1);
            EMG_struct(i).p_delt_raw = EMG_p_delt_filt(index:index+trialDuration_new-1);
            EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration_new-1);
            EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration_new-1);
            EMG_struct(i).a_delt = EMG_a_delt_smooth(index:index+trialDuration_new-1);
            EMG_struct(i).p_delt = EMG_p_delt_smooth(index:index+trialDuration_new-1);
            EMG_struct(i).biceps_zscore = EMG_bi_zscore(index:index+trialDuration_new-1);
            EMG_struct(i).triceps_zscore = EMG_tri_zscore(index:index+trialDuration_new-1);
            EMG_struct(i).a_delt_zscore = EMG_a_delt_zscore(index:index+trialDuration_new-1);
            EMG_struct(i).p_delt_zscore = EMG_p_delt_zscore(index:index+trialDuration_new-1);
            
            index = index + trialDuration_new;
        end
    else
        temp_bi = EMG_bi_smooth(index:index+trialDuration-1);
            temp_tri = EMG_tri_smooth(index:index+trialDuration-1);
            temp_a_delt = EMG_a_delt_smooth(index:index+trialDuration-1);
            temp_p_delt = EMG_p_delt_smooth(index:index+trialDuration-1);
            
            figure()
            subplot(4,1,1)
            plot(temp_bi)
            ylabel('Biceps')
            subplot(4,1,2)
            plot(temp_tri)
            ylabel('Triceps')
            subplot(4,1,3)
            plot(temp_a_delt)
            ylabel('AD')
            subplot(4,1,4)
            plot(temp_p_delt)
            ylabel('PD')
            
            [x,y] = ginput(8);
            baseline_mean = [mean(temp_bi(round(x(1)):round(x(2)))) mean(temp_tri(round(x(3)):round(x(4)))) ...
                mean(temp_a_delt(round(x(5)):round(x(6)))) mean(temp_p_delt(round(x(7)):round(x(8))))];
            baseline_sd = [std(temp_bi(round(x(1)):round(x(2)))) std(temp_tri(round(x(3)):round(x(4)))) ...
                std(temp_a_delt(round(x(5)):round(x(6)))) std(temp_p_delt(round(x(7)):round(x(8))))];
            
            EMG_bi_zscore = (EMG_bi_smooth-baseline_mean(1))./baseline_sd(1);
            EMG_tri_zscore = (EMG_tri_smooth-baseline_mean(2))./baseline_sd(2);
            EMG_a_delt_zscore = (EMG_a_delt_smooth-baseline_mean(3))./baseline_sd(3);
            EMG_p_delt_zscore = (EMG_p_delt_smooth-baseline_mean(4))./baseline_sd(4);
            
            
            EMG_struct(i).biceps_raw = EMG_bi_filt(index:index+trialDuration-1);
            EMG_struct(i).triceps_raw = EMG_tri_filt(index:index+trialDuration-1);
            EMG_struct(i).a_delt_raw = EMG_a_delt_filt(index:index+trialDuration-1);
            EMG_struct(i).p_delt_raw = EMG_p_delt_filt(index:index+trialDuration-1);
            EMG_struct(i).biceps = EMG_bi_smooth(index:index+trialDuration-1);
            EMG_struct(i).triceps = EMG_tri_smooth(index:index+trialDuration-1);
            EMG_struct(i).a_delt = EMG_a_delt_smooth(index:index+trialDuration-1);
            EMG_struct(i).p_delt = EMG_p_delt_smooth(index:index+trialDuration-1);
            EMG_struct(i).biceps_zscore = EMG_bi_zscore(index:index+trialDuration-1);
            EMG_struct(i).triceps_zscore = EMG_tri_zscore(index:index+trialDuration-1);
            EMG_struct(i).a_delt_zscore = EMG_a_delt_zscore(index:index+trialDuration-1);
            EMG_struct(i).p_delt_zscore = EMG_p_delt_zscore(index:index+trialDuration-1);
        
        index = index + trialDuration;
    end
    
    
    
    % optional if you suspect any change in noise level throughout recording session
    str = input('Is noise level acceptable','s');
    
    if strcmp(str,'y')
        flag_noise(i) = 1;
    else
        flag_noise(i) = 0;
    end
    close all
    
end

% Save data structure on the same folder as the raw data
cd([data_folder mouse_ID '\EMG\' data_ID])
save([data_name '_processed'],'EMG_struct')
save('flag_noise','flag_noise')
cd(code_folder)