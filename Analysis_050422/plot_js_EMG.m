close all
clear all
clc

code_path = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422';

%data_folder = 'D:\JoystickExpts\data\';
data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\';
%mouse_ID = 'Box_4_AN08';
mouse_ID = 'AN08';
data_ID = '050622_47_79_030_10000_200_016_000_180_000_180_000';
condition_array = strsplit(data_ID,'_');
hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;
pltOpt = 1;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd(code_path)


%mouse_ID_array = strsplit(mouse_ID,'_');
%data_folder = 'D:\JoystickExpts\data\';
%mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

save_folder = ['C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Data\' mouse_ID '\EMG\' data_ID];
cd(save_folder)
load('EMG_struct')
cd(code_path)

Fs_js = 1000;
Fs_EMG = 20000;

[b,a] = butter(10,50/(Fs_js/2),'low');

js_trial = 1:length(js_reach);
EMG_trial = 19:length(EMG_struct);
nTrial = length(EMG_trial);
%%
start_offset = 0.05;
% 1, 7, 9, 11, 15
for i = 1:10 %nTrial %1 %:10
    j = js_trial(i);
    k = EMG_trial(i);
    if ~isempty(js_reach(j).end_reach)
        start_time = js_reach(j).start_reach-start_offset*Fs_js;
        end_time = js_reach(j).end_reach;
        start_time_EMG = start_time*Fs_EMG/Fs_js;
        end_time_EMG = end_time*Fs_EMG/Fs_js;
        
        time_js = -start_offset:1/Fs_js:(end_time-start_time-start_offset*Fs_js)/Fs_js;
        time_EMG = -start_offset:1/Fs_EMG:(end_time_EMG-start_time_EMG-start_offset*Fs_EMG)/Fs_EMG;
        
        x = filtfilt(b,a,js_reach(k).x_traj);
        y = filtfilt(b,a,js_reach(k).y_traj);
        
        js_pos = sqrt(x.^2+y.^2);        
        js_vel = gradient(js_pos)*Fs_js;        
        js_acc = gradient(js_vel)*Fs_js;
        
        js_pos = js_pos(start_time:end_time);
        js_vel = js_vel(start_time:end_time);
        js_acc = js_acc(start_time:end_time);
        
        figure(1)
        ax1 =  subplot(6,1,1);
        plot(time_js,js_pos,'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        ax2 = subplot(6,1,2);
        plot(time_EMG,EMG_struct(k).EMG_env(1,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        ax3 = subplot(6,1,3);
        plot(time_EMG,EMG_struct(k).EMG_env(7,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        ax4 = subplot(6,1,4);
        plot(time_EMG,EMG_struct(k).EMG_env(9,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        ax5 = subplot(6,1,5);
        plot(time_EMG,EMG_struct(k).EMG_env(11,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        ax6 = subplot(6,1,6);
        plot(time_EMG,EMG_struct(k).EMG_env(15,start_time_EMG:end_time_EMG),'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        
        EMG_ds = downsample(EMG_struct(k).EMG_env(11,start_time_EMG:end_time_EMG),20);
        [r,lag] = xcorr(EMG_ds-mean(EMG_ds),js_acc-mean(js_acc),'coeff');
        
        figure(1)
        linkaxes([ax1,ax2 ax3,ax4,ax5,ax6],'x')
        
        figure(2)
        plot(lag,r,'color',[45, 49, 66]/255,'LineWidth',1)
        hold on
        
    end
    
end

figure(1)
ax1 =  subplot(6,1,1);
yline(hold_threshold,'--','color','k','LineWidth',1)
yline(outer_threshold,'--','color','k','LineWidth',1)
yline(max_distance,'--','color','k','LineWidth',1)