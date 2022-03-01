%--------------------------------------------------------------------------
% plot_js_reach
% Author: Akira Nagamori
% Last update: 2/28/2022
% Descriptions: 
%--------------------------------------------------------------------------

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN07'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '022522_63_79_020_10000_010_016_000_180_000_180_000';
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

idx = 1;

for i = 11:20 %:nTrial
    radial_pos_2 = js_reach(i).radial_pos_2;
    mag_vel_2 = js_reach(i).mag_vel_2;
    RoC_2 = js_reach(i).RoC_2;
    [min_vel_2,loc_min_vel_2] = findpeaks(-mag_vel_2);
    [min_RoC_2,loc_min_RoC_2] = findpeaks(-RoC_2);
    A_2 = repmat(loc_min_RoC_2',[1 length(loc_min_vel_2)]);
    [minValue_2,closestIndex_2] = min(abs(A_2-loc_min_vel_2),[],1);
    loc_min_vel_2(minValue_2>2) = [];
    closestIndex_2(minValue_2>2) = [];
    
    % velocity minimum closest to reward 
    [~,idx_min_vel_2_reward] = min(abs(loc_min_vel_2-1*Fs_js));
    loc_min_vel_2_reward = loc_min_vel_2(idx_min_vel_2_reward);
    
    time_reach = [1:length(js_reach(i).radial_pos_2)]./Fs_js;
    figure(idx)
    ax1 = subplot(3,1,1);
    plot(time_reach,radial_pos_2,'k','LineWidth',1)
    hold on
    plot(time_reach(loc_min_vel_2_reward),radial_pos_2(loc_min_vel_2_reward),'o','color','b','LineWidth',2)
    yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'color','g','LineWidth',2)
    yline(max_distance,'color','g','LineWidth',2)
    ax2 = subplot(3,1,2);
    plot(time_reach,mag_vel_2,'k','LineWidth',1)
    hold on 
    plot(time_reach(loc_min_vel_2),mag_vel_2(loc_min_vel_2),'o','color','r')
    plot(time_reach(loc_min_vel_2_reward),mag_vel_2(loc_min_vel_2_reward),'o','color','b','LineWidth',2)
    ax3 = subplot(3,1,3);
    plot(time_reach,js_reach(i).RoC_2,'k','LineWidth',1)
    hold on 
    plot(time_reach(loc_min_vel_2),RoC_2(loc_min_vel_2),'o','color','r')
    plot(time_reach(loc_min_vel_2_reward),RoC_2(loc_min_vel_2_reward),'o','color','b','LineWidth',2)
    set(gca, 'YScale', 'log')
    linkaxes([ax1 ax2 ax3],'x')
    
    figure(idx+1)
    subplot(2,1,1)
    plot(time_reach,js_reach(i).radial_pos,'k','LineWidth',1)
    hold on
    yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'color','g','LineWidth',2)
    yline(max_distance,'color','g','LineWidth',2)
    subplot(2,1,2)
    plot(time_reach,js_reach(i).mag_vel,'k','LineWidth',1)
    
        
    figure(idx+2)
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
    
    idx = idx + 2;
end

