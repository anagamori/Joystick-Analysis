close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
% mouse_ID = 'Box_4_F_081921_CT_EMG'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
% data_ID = '110721_60_80_050_0300_010_010_000_360_000_360_004';
condition_array = strsplit(data_ID,'_');


data_folder = 'D:\JoystickExpts\data\EMG\';
mouse_ID = 'F_081921_CT'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '111021';
data_name = 'data_30';

cd([data_folder mouse_ID '\' data_ID])
load(data_name)
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_EMG = 10000;
time_EMG = -1:1/Fs_EMG:0.5;
time_EMG(end) = [];
nTrial = length(EMG_struct);

radial_pos_all = [];
EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_biceps_raw_all = [];
EMG_triceps_raw_all = [];

for i = 1:nTrial
   
       EMG_biceps_all = [EMG_biceps_all; EMG_struct(i).biceps'];
       EMG_triceps_all = [EMG_triceps_all; EMG_struct(i).triceps'];
       EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(i).biceps_raw'];
       EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(i).triceps_raw'];
       figure(1)
       subplot(2,1,1)
       plot2 = plot(time_EMG,EMG_struct(i).biceps,'LineWidth',1,'color','b');
       plot2.Color(4) = 0.3;
       hold on 
       set(gca,'TickDir','out')
       set(gca,'box','off')
       subplot(2,1,2)
       plot3 = plot(time_EMG,EMG_struct(i).triceps,'LineWidth',1,'color','r');
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
ylabel('Biceps EMG (V)')
subplot(2,1,2)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')

figure(2)
subplot(2,1,1)
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on 
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(2,1,2)
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on 
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')

figure(3)
subplot(2,1,1)
plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(2,1,2)
plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')



