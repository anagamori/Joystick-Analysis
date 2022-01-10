close all
clear all
clc


data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN04'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '120721_50_80_050_10000_010_010_000_180_000_180_001';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'AN01'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '120721';

cd([data_folder mouse_ID '\' data_ID])
load('data_processed')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

start_offset = 0;
end_time = 0.12;
Fs_js = 1000;
time_js = start_offset:1/Fs_js:end_time;
Fs_EMG = 10000;
time_EMG = start_offset:1/Fs_EMG:end_time;
nTrial = length(js_reach);


norm_window = [0.1*Fs_EMG:0.2*Fs_EMG]+1*Fs_EMG;

radial_pos_all = [];
EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];

%index_js_reach = 3:83;
%index_EMG = 1:81;
index_js_reach = 1:43;
index_EMG = length(EMG_struct)-43+1:length(EMG_struct);

for i = 1:length(index_js_reach) %nTrial
    j = index_js_reach(i);
    k = index_EMG(i);
    if  js_reach(j).n_vel_peak_1 == 1
        radial_pos_all = [radial_pos_all; js_reach(j).radial_pos_2(js_reach(j).reach_start_time+start_offset*Fs_js:js_reach(j).reach_start_time+end_time*Fs_js)];
        
        EMG_biceps = EMG_struct(k).biceps_zscore(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG);
        EMG_triceps = EMG_struct(k).triceps_zscore(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG);
        EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
        EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
        
        EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(k).biceps_raw(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG)'];
        EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(k).triceps_raw(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG)'];
        figure(1)
        subplot(3,1,1)
        plot1 = plot(time_js,js_reach(j).radial_pos_2(js_reach(j).reach_start_time+start_offset*Fs_js:js_reach(j).reach_start_time+end_time*Fs_js),'LineWidth',1,'color','k');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        subplot(3,1,2)
        plot2 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color','b');
        plot2.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        subplot(3,1,3)
        plot3 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color','r');
        plot3.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        
        figure(3)
        subplot(3,1,1)
        plot1 = plot(time_js,js_reach(j).radial_pos_2(js_reach(j).reach_start_time+start_offset*Fs_js:js_reach(j).reach_start_time+end_time*Fs_js),'LineWidth',1,'color','k');
        plot1.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        subplot(3,1,2)
        plot2 = plot(time_EMG,EMG_struct(k).biceps_raw(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG),'LineWidth',1,'color','b');
        plot2.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        subplot(3,1,3)
        plot3 = plot(time_EMG,EMG_struct(k).triceps_raw(js_reach(j).reach_start_time*Fs_EMG/Fs_js+start_offset*Fs_EMG:js_reach(j).reach_start_time*Fs_EMG/Fs_js+end_time*Fs_EMG),'LineWidth',1,'color','r');
        plot3.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
    end
end

y_bi = mean(EMG_biceps_all);
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));

figure(1)
subplot(3,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
subplot(3,1,2)
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(3,1,3)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')

figure(2)
subplot(3,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
subplot(3,1,2)
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(3,1,3)
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')

figure(3)
subplot(3,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
subplot(3,1,2)
plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(3,1,3)
plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')



