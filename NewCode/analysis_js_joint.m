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
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

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


cd([data_folder mouse_ID '\' data_ID '_v2'])
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


theta = 0:0.01:2*pi;

for i = 29 %1:length(index_js_reach) %nTrial
    j = index_js_reach(i)
    k = index_EMG(i)
    %if isempty(js_reach(i).reach_flag)
    
    target_onset = js_reach(j).target_onset;
    target_offset = js_reach(j).target_offset;
    hold_onset = js_reach(j).hold_onset;
    hold_offset = js_reach(j).hold_offset;
    start_time = js_reach(j).start_time;
    end_time = js_reach(j).end_time/Fs_js;
    
    time_js = [1:end_time*Fs_js]./Fs_js;
    js_x = js_reach(j).traj_x_2;
    js_y = js_reach(j).traj_y_2;
    radial_pos = js_reach(j).radial_pos_2;
    
    time_joint = [1:round(end_time*Fs_joint)]./Fs_joint;
    js_x_anipose = data(k).Joystick_x-data(k).Joystick_x(1);
    js_y_anipose = data(k).Joystick_y-data(k).Joystick_y(1);
    js_z_anipose = data(k).Joystick_z-data(k).Joystick_z(1);
    
    hand_x_anipose = data(k).Hand_x-data(k).Hand_x(1);
    hand_y_anipose = data(k).Hand_y-data(k).Hand_y(1);
    hand_z_anipose = data(k).Hand_z-data(k).Hand_z(1);
    
    shoulder_x_anipose = data(k).Shoulder_x;
    shoulder_y_anipose = data(k).Shoulder_y;
    shoulder_z_anipose = data(k).Shoulder_z;
    
    elbow_x_anipose = data(k).Elbow_x;
    elbow_y_anipose = data(k).Elbow_y;
    elbow_z_anipose = data(k).Elbow_z;
    
    wrist_x_anipose = data(k).Wrist_x;
    wrist_y_anipose = data(k).Wrist_y;
    wrist_z_anipose = data(k).Wrist_z;
    
    elbow_angle = 180-data(k).elbow_angle;
    wrist_angle = data(k).wrist_angle;
    
    l1 = sqrt((shoulder_x_anipose-elbow_x_anipose).^2+(shoulder_z_anipose-elbow_z_anipose).^2);
    l1 = mean(l1(1:100));
    l2 = sqrt((wrist_x_anipose-elbow_x_anipose).^2+(wrist_z_anipose-elbow_z_anipose).^2);
    l2 = mean(l2(1:100));
    
    x_prime = l2*sin(deg2rad(elbow_angle));
    z_prime = l1-l2*cos(deg2rad(elbow_angle));
    shoulder_angle = atan2d(wrist_x_anipose.*x_prime+wrist_z_anipose.*z_prime,wrist_x_anipose.*z_prime-wrist_z_anipose.*x_prime);
    
    f1 = figure(1);
    movegui(f1,'northwest')
    ax1 = subplot(5,1,1);
    plot1 = plot(time_js,js_x(1:end_time*Fs_js),'color',[45, 49, 66]/255,'LineWidth',1);
    plot1.Color(4) = 1;
    ylabel({'Joystick','ML (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax2 = subplot(5,1,2);
    plot2 = plot(time_js,js_y(1:end_time*Fs_js),'color',[45, 49, 66]/255,'LineWidth',1);
    ylabel({'Joystick','AP (mm)'})
    plot2.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax3 = subplot(5,1,3);
    plot3 = plot(time_joint,js_x_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[35 140 204]/255);
    plot3.Color(4) = 1;
    ylabel({'Joystick','x (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax4 = subplot(5,1,4);
    plot4 = plot(time_joint,js_y_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[204 45 52]/255);
    plot4.Color(4) = 1;
    ylabel({'Joystick','y (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax5 = subplot(5,1,5);
    plot5 = plot(time_joint,js_z_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[45 49 66]/255);
    plot5.Color(4) = 1;
    ylabel({'Joystick','z (mm)'})
    xlabel('Time (sec)')
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    linkaxes([ax1 ax2 ax3 ax4 ax5],'x')
    
    f2 = figure(2);
    movegui(f2,'northeast')
    plot(js_x(1:end_time*Fs_js),js_y(1:end_time*Fs_js),'k','LineWidth',1)
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
    plot(js_x_anipose(1:round(end_time*Fs_joint)),js_y_anipose(1:round(end_time*Fs_joint)),'k','LineWidth',1)
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
    
    f4 = figure(4);
    movegui(f4,'southwest')
    ax1 = subplot(4,1,1);
    plot1 = plot(time_js,radial_pos(1:end_time*Fs_js),'color',[45, 49, 66]/255,'LineWidth',1);
    plot1.Color(4) = 1;
    ylabel({'Joystick','Radial Position (mm)'})
    hold on
    plot(time_js(target_onset:target_offset),radial_pos(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
    plot(time_js(hold_onset:hold_offset-1),radial_pos(hold_onset:hold_offset-1),'color',[225 218 174]/255,'LineWidth',2)
    plot(time_js(start_time:target_onset),radial_pos(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax2 = subplot(4,1,2);
    plot2 = plot(time_joint,shoulder_angle(1:round(end_time*Fs_joint)),'color',[35 140 204]/255,'LineWidth',1);
    ylabel({'Shoulder','Angle (deg)'})
    plot2.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax3 = subplot(4,1,3);
    plot3 = plot(time_joint,elbow_angle(1:round(end_time*Fs_joint)),'color',[204 45 52]/255,'LineWidth',1);
    ylabel({'Elbow','Angle (deg)'})
    plot3.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax4 = subplot(4,1,4);
    plot4 = plot(time_joint,wrist_angle(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[45 49 66]/255);
    plot4.Color(4) = 1;
    ylabel({'Wrist','Angle (deg)'})
    xlabel('Time (sec)')
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    linkaxes([ax1 ax2 ax3 ax4],'x')
    
    f5 = figure(5);
    movegui(f5,'northwest')
    ax1 = subplot(5,1,1);
    plot1 = plot(time_js,js_x(1:end_time*Fs_js),'color',[45, 49, 66]/255,'LineWidth',1);
    plot1.Color(4) = 1;
    ylabel({'Joystick','ML (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax2 = subplot(5,1,2);
    plot2 = plot(time_js,js_y(1:end_time*Fs_js),'color',[45, 49, 66]/255,'LineWidth',1);
    ylabel({'Joystick','AP (mm)'})
    plot2.Color(4) = 1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax3 = subplot(5,1,3);
    plot3 = plot(time_joint,hand_x_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[35 140 204]/255);
    plot3.Color(4) = 1;
    ylabel({'Hand','x (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax4 = subplot(5,1,4);
    plot4 = plot(time_joint,hand_y_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[204 45 52]/255);
    plot4.Color(4) = 1;
    ylabel({'Hand','y (mm)'})
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    ax5 = subplot(5,1,5);
    plot5 = plot(time_joint,hand_z_anipose(1:round(end_time*Fs_joint)),'LineWidth',1,'color',[45 49 66]/255);
    plot5.Color(4) = 1;
    ylabel({'Hand','z (mm)'})
    xlabel('Time (sec)')
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    linkaxes([ax1 ax2 ax3 ax4 ax5],'x')
            
end
