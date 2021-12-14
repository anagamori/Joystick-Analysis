close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN05'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '120621_10_100_001_10000_001_080_000_180_000_180_001';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
nTrial = length(js_reach);

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

theta = 0:0.01:2*pi;
for i = 1:10 %:nTrial
    
    figure()
    plot(js_reach(i).traj_x_2,js_reach(i).traj_y_2)
    hold on
    plot(js_reach(i).traj_x_2(1*Fs_js),js_reach(i).traj_y_2(1*Fs_js),'o','LineWidth',2)
    xlim([-7 7])
    ylim([-7 7])
    set(gca,'TickDir','out')
    set(gca,'box','off')
    hold on
    plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
    plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
    plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
    plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
    plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
    axis equal
    
end

