close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN05'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '120921_50_80_010_10000_005_010_000_180_000_180_001';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'AN01'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '113021';

cd([data_folder mouse_ID '\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

start_offset = -0.05;
end_time = 0.25;
Fs_js = 1000;
time_js = -0.15:1/Fs_js:0.05;
%time_js(end) = [];
Fs_EMG = 10000;
time_EMG = -0.15:1/Fs_EMG:0.05;
%time_EMG(end) = [];
nTrial = length(js_reach);


analysis_window_js = [-0.15*Fs_js:0.05*Fs_js]+1*Fs_js;
analysis_window_EMG = [-0.15*Fs_EMG:0.05*Fs_EMG]+1*Fs_EMG;

radial_pos_all = [];
js_vel_all = [];
js_acc_all = [];

EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];

r_all = [];

r_bi_js_pos_all = [];
r_tri_js_pos_all = [];
r_bi_js_vel_all = [];
r_tri_js_vel_all = [];
r_bi_js_acc_all = [];
r_tri_js_acc_all = [];
        
        
index_js_reach = 1:length(js_reach);
index_EMG = [14:28 29:33];

for i = 1:length(index_js_reach) %nTrial
    %if flag_noise(i) == 1
        j = index_js_reach(i);
        %k = index_EMG(i);
        radial_pos_all = [radial_pos_all; js_reach(j).radial_pos_2(analysis_window_js)];
        radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
        js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
        js_vel_all = [js_vel_all; js_vel];
        js_acc = gradient(js_vel)*Fs_js;
        js_acc_all = [js_acc_all; js_acc];
        mag_vel = js_reach(j).mag_vel_2;
       
        figure(1)
        ax1 = subplot(3,1,1);
        plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax2 = subplot(3,1,2);
        plot2 = plot(time_js,js_vel,'LineWidth',1,'color','b');
        plot2.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax3 = subplot(3,1,3);
        plot3 = plot(time_js,js_acc,'LineWidth',1,'color','r');
        plot3.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        linkaxes([ax1 ax2 ax3],'x')
        
    %end
end

figure(1)
ax1 = subplot(3,1,1);
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(time_js,mean(js_vel_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm/s)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(time_js,mean(js_acc_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm/s^2)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3],'x')

