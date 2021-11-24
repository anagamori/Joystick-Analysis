close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'AN01'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '112321';

cd([data_folder mouse_ID '\' data_ID])
load('data_processed')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

start_offset = -0.05;
end_time = 0.25;
Fs_EMG = 10000;
time_EMG = -1:1/Fs_EMG:0.5;
time_EMG(end) = [];
nTrial = length(EMG_struct);

norm_window = [0.1*Fs_EMG:0.2*Fs_EMG]+1*Fs_EMG;

radial_pos_all = [];
EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];
pxx_biceps_all = [];
pxx_triceps_all = [];

r_all = [];


for i = 34:46
    EMG_biceps = (EMG_struct(i).biceps - mean(EMG_struct(i).biceps(norm_window)))./std(EMG_struct(i).biceps(norm_window));
    EMG_triceps = (EMG_struct(i).triceps - mean(EMG_struct(i).triceps(norm_window)))./std(EMG_struct(i).triceps(norm_window));
    EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
    EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
    EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(i).biceps_raw'];
    EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(i).triceps_raw'];
    
    [pxx_bi,~] = pwelch(EMG_struct(i).biceps_raw-mean(EMG_struct(i).biceps_raw),[],[],0:1:5000,Fs_EMG);
    [pxx_tri,f] = pwelch(EMG_struct(i).triceps_raw-mean(EMG_struct(i).triceps_raw),[],[],0:1:5000,Fs_EMG);
    pxx_biceps_all = [pxx_biceps_all; pxx_bi];
    pxx_triceps_all = [pxx_triceps_all; pxx_tri];
    
    [r,lags] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_triceps-mean(EMG_triceps),500*Fs_EMG/1000,'coeff');
    r_all = [r_all r];
    figure(1)
    subplot(2,1,1)
    plot2 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color','b');
    plot2.Color(4) = 0.3;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    subplot(2,1,2)
    plot3 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color','r');
    plot3.Color(4) = 0.3;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    
    figure(3)
    subplot(2,1,1)
    plot2 = plot(time_EMG,EMG_struct(i).biceps_raw,'LineWidth',1,'color','b');
    plot2.Color(4) = 0.1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    subplot(2,1,2)
    plot3 = plot(time_EMG,EMG_struct(i).triceps_raw,'LineWidth',1,'color','r');
    plot3.Color(4) = 0.1;
    hold on
    set(gca,'TickDir','out')
    set(gca,'box','off')
    
end

y_bi = mean(EMG_biceps_all);
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));

figure(1)
subplot(2,1,1)
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (z-score)')
subplot(2,1,2)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (z-score)')
xlabel('Time (sec)')

figure(2)
subplot(2,1,1)
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (z-score)')
subplot(2,1,2)
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (z-score)')
xlabel('Time (sec)')

figure(3)
subplot(2,1,1)
plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(2,1,2)
plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')



