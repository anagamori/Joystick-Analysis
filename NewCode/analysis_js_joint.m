close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
load('hold_still_duration')
load('target_hold_duration')
load('reach_duration')
load('peak_velocity')
load('path_length')
load('straightness')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

mouse_ID_array = strsplit(mouse_ID,'_');

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

cd([data_folder mouse_ID '\EMG\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')


cd([data_folder mouse_ID '\' data_ID])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 200;

radial_pos_all = [];
js_vel_all = [];
js_acc_all = [];
mag_vel_all = [];
max_vel_all = [];

elbow_angle_all = [];
wrist_angle_all = [];

EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_a_delt_all = [];
EMG_p_delt_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];
EMG_a_delt_raw_all = [];
EMG_p_delt_raw_all = [];

r_bi_tri_all = [];
r_bi_a_delt_all = [];
r_bi_p_delt_all = [];
r_tri_a_delt_all = [];
r_tri_p_delt_all = [];
r_a_delt_p_delt_all = [];

r_bi_js_pos_all = [];
r_tri_js_pos_all = [];
r_a_delt_js_pos_all = [];
r_p_delt_js_pos_all = [];
r_bi_js_vel_all = [];
r_tri_js_vel_all = [];
r_a_delt_js_vel_all = [];
r_p_delt_js_vel_all = [];
r_bi_js_acc_all = [];
r_tri_js_acc_all = [];
r_a_delt_js_acc_all = [];
r_p_delt_js_acc_all = [];

r_bi_angle_all = [];
r_tri_angle_all = [];
r_a_delt_angle_all = [];
r_p_delt_angle_all = [];

index_js_reach = 1:length(js_reach)-2;
index_EMG = 1:length(EMG_struct);

for i = 9 %1:length(index_js_reach) %nTrial
    j = index_js_reach(i)
    k = index_EMG(i)
    %if isempty(js_reach(i).reach_flag)
    
    time_js = [1:length(js_reach(j).traj_x)]./Fs_js;
    js_x = js_reach(j).traj_x;
    js_y = js_reach(j).traj_y;
    
    time_joint = [1:length(data(k).Shoulder_x)]./Fs_joint;
    js_x_anipose = data(k).Joystick_x-data(k).Joystick_x(1);
    js_y_anipose = data(k).Joystick_y-data(k).Joystick_y(1);
    js_z_anipose = data(k).Joystick_z-data(k).Joystick_z(1);
    
    f1 = figure(1);
    movegui(f1,'northwest')
    ax1 = subplot(5,1,1);
    plot1 = plot(time_js,js_x,'LineWidth',1,'color','k');
    plot1.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax2 = subplot(5,1,2);
    plot2 = plot(time_js,js_y,'LineWidth',1,'color','k');
    plot2.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax3 = subplot(5,1,3);
    plot3 = plot(time_joint,js_x_anipose,'LineWidth',1,'color',[35 140 204]/255);
    plot3.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax4 = subplot(5,1,4);
    plot4 = plot(time_joint,js_y_anipose,'LineWidth',1,'color',[204 45 52]/255);
    plot4.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax5 = subplot(5,1,5);
    plot5 = plot(time_joint,js_z_anipose,'LineWidth',1,'color',[45 49 66]/255);
    plot5.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    linkaxes([ax1 ax2 ax3 ax4 ax5],'x')
    
    f2 = figure(2);
    movegui(f2,'northeast')
    plot(js_x,js_y,'k','LineWidth',1)
    xlim([-7 7])
    ylim([-7 7])
    set(gca,'TickDir','out')
    set(gca,'box','off')
    hold on
    plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
    plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'--','color','k')
    plot(max_distance*cos(theta),max_distance*sin(theta),'--','color','k')
    plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
    plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
    xlabel('ML (mm)')
    ylabel('AP (mm)')
    axis equal
    
    f2 = figure(2);
    movegui(f2,'northeast')
    plot(js_x,js_y,'k','LineWidth',1)
    xlim([-7 7])
    ylim([-7 7])
    set(gca,'TickDir','out')
    set(gca,'box','off')
    hold on
    plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
    plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'--','color','k')
    plot(max_distance*cos(theta),max_distance*sin(theta),'--','color','k')
    plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
    plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
    xlabel('ML (mm)')
    ylabel('AP (mm)')
    axis equal
    
    f3 = figure(3);
    movegui(f3,'southeast')
    plot(js_z_anipose,js_x_anipose,'k','LineWidth',1)
    xlim([-7 7])
    ylim([-7 7])
    set(gca,'TickDir','out')
    set(gca,'box','off')
    hold on
    plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
    plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'--','color','k')
    plot(max_distance*cos(theta),max_distance*sin(theta),'--','color','k')
    plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
    plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
    xlabel('ML (mm)')
    ylabel('AP (mm)')
    axis equal
             
            
end
