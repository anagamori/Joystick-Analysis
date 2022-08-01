close all
clear all
clc

data_folder = 'F:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN10';
data_ID = '071922_47_79_010_32767_200_031_000_180_000_180_000';
condition_array = strsplit(data_ID,'_');

pltOpt = 1;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\Analysis_050422')

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
target_duration = str2double(condition_array{4});
trial_duration = str2double(condition_array{5});
angle_min = str2double(condition_array{8});
angle_max = str2double(condition_array{9});
reach_threshold = 31/100*6.35;

theta = 0:0.01:2*pi;

hold_duration_trial_success = [];
target_duration_trial_success = [];
path_length_success = [];
straightness_success = [];
reach_duration_trial_success = [];
peak_speed_success = [];

target_duration_trial_fail = [];
path_length_fail = [];
straightness_fail = [];
reach_duration_trial_fail = [];
peak_speed_fail = [];

Fs = 1000;
[b,a] = butter(10,50/(Fs/2),'low');

for i = 1:length(js_reach)
    if js_reach(i).reward_flag == 1
        
        x_filt = filtfilt(b,a,js_reach(i).x_traj);
        y_filt = filtfilt(b,a,js_reach(i).y_traj);   
        vel_x = gradient(x_filt)*Fs; 
        acc_x = gradient(vel_x)*Fs; 
        vel_y = gradient(y_filt)*Fs;
        acc_y = gradient(vel_y)*Fs;
        RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
        js_pos = sqrt(x_filt.^2+y_filt.^2);
        js_vel = gradient(js_pos)*Fs;
        js_acc = gradient(js_vel)*Fs;
        js_speed = sqrt(vel_x.^2+vel_y.^2);
        angle_js = atan2d(y_filt,x_filt);
        angle_js = angle_js + (angle_js < 0)*360;
        
        time_trial = [1:length(x_filt)]/Fs;
        figure(6)
        subplot(2,1,1)
        plot(time_trial,js_pos,'color',[45 49 66]/255,'LineWidth',1)
        hold on           
        %plot(time_trial(start_reach:end_reach),js_pos(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',1)
        yline(hold_threshold,'--','color','k','LineWidth',1)
        yline(outer_threshold,'--','color','k','LineWidth',1)
        yline(max_distance,'--','color','k','LineWidth',1)       
        set(gca,'TickDir','out')
        set(gca,'box','off')
        subplot(2,1,2)
        plot(time_trial,js_vel,'color',[45 49 66]/255,'LineWidth',1)
        hold on 
        %plot(time_trial(start_reach:end_reach),js_vel(start_reach:end_reach),'color',[255,147,79]/255,'LineWidth',1) 
        ylim([-50 250])
        
%         x = input('');
%         close(6)
     
    end
end
