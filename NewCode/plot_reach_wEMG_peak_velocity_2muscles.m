close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN04'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '031822_63_79_020_10000_020_016_030_150_030_150_000';
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
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

mouse_ID_array = strsplit(mouse_ID,'_');

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = mouse_ID_array{3};
data_ID = condition_array{1};

cd([data_folder mouse_ID '\EMG\' data_ID])
load('data_processed')
load('flag_noise')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;

trial_start_time_js =  1*Fs_js-0.25*Fs_js+1;
trial_start_time_EMG =  1*Fs_EMG-0.25*Fs_EMG+1;

nTrial = length(js_reach);

radial_pos_all = [];
js_vel_all = [];
js_acc_all = [];
mag_vel_all = [];
max_vel_all = [];

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
        
index_js_reach = 3:length(js_reach)-1;
index_EMG = 1:length(EMG_struct);


for i = 1:length(index_js_reach) %nTrial
    %if isempty(js_reach(i).reach_flag)
    if ~isempty(js_reach(i).start_time)
    start_idx_js = js_reach(i).start_time;
    end_idx_js = js_reach(i).end_time;
    
    start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
    end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
    
    time_js = -0.1:1/Fs_js:0.1;
    time_js = time_js*1000;
    time_EMG = -0.1:1/Fs_EMG:0.1;
    time_EMG = time_EMG*1000;
    
    window_size = length(time_js);

    if flag_noise(i) == 1 
        j = index_js_reach(i);
        k = index_EMG(i);
        
        mag_vel = js_reach(j).mag_vel_2(start_idx_js:1*Fs_js);
        [~,loc_max_mag_vel] = max(mag_vel);
        
        analysis_window_js = [loc_max_mag_vel+start_idx_js-0.1*Fs_js:loc_max_mag_vel+start_idx_js+0.1*Fs_js];
        analysis_window_EMG = [loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG-0.1*Fs_EMG:loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG+0.1*Fs_EMG];
    
        radial_pos_all = [radial_pos_all; js_reach(j).radial_pos_2(analysis_window_js)];
        radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
        js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
        max_vel_all = [max_vel_all; (max(js_vel))];
        js_vel_all = [js_vel_all; js_vel];
        js_acc = gradient(js_vel)*Fs_js;
        js_acc_all = [js_acc_all; js_acc];
        
        mag_vel_all = [mag_vel_all; js_reach(j).mag_vel_2(analysis_window_js)];
        EMG_biceps = EMG_struct(k).biceps_zscore(analysis_window_EMG);
        EMG_biceps_ds = downsample(EMG_biceps,10);
        EMG_triceps = EMG_struct(k).triceps_zscore(analysis_window_EMG);
        EMG_triceps_ds = downsample(EMG_triceps,10);
       
        [r,lags] = xcorr(EMG_biceps-mean(EMG_biceps),EMG_triceps-mean(EMG_triceps),window_size*Fs_EMG/Fs_js,'coeff');
        r_all = [r_all r];
        
        [r_bi_js_pos,] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');        
        [r_tri_js_pos,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
        r_bi_js_pos_all = [r_bi_js_pos_all r_bi_js_pos];
        r_tri_js_pos_all = [r_tri_js_pos_all r_tri_js_pos];
        
        [r_bi_js_vel,lags_js] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_vel-mean(js_vel),window_size,'coeff');
        [r_tri_js_vel,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_vel-mean(js_vel),window_size,'coeff');
        r_bi_js_vel_all = [r_bi_js_vel_all r_bi_js_vel];
        r_tri_js_vel_all = [r_tri_js_vel_all r_tri_js_vel];
        
        [r_bi_js_acc,~] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_acc-mean(js_acc),window_size,'coeff');
        [r_tri_js_acc,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_acc-mean(js_acc),window_size,'coeff');
        r_bi_js_acc_all = [r_bi_js_acc_all r_bi_js_acc];
        r_tri_js_acc_all = [r_tri_js_acc_all r_tri_js_acc];
        
        EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
        EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
        
        EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(k).biceps_raw(analysis_window_EMG)'];
        EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(k).triceps_raw(analysis_window_EMG)'];
    
        figure(1)
        ax1 = subplot(3,1,1);
        plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax2 = subplot(3,1,2);
        plot2 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color','b');
        plot2.Color(4) = 0.5;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax3 = subplot(3,1,3);
        plot3 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color','r');
        plot3.Color(4) = 0.5;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
      
        linkaxes([ax1 ax2 ax3],'x')
        
        figure(3)
        ax1 = subplot(3,1,1);
        plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
        plot1.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax2 = subplot(3,1,2);
        plot2 = plot(time_EMG,EMG_struct(k).biceps_raw(analysis_window_EMG),'LineWidth',1,'color','b');
        plot2.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        ax3 = subplot(3,1,3);
        plot3 = plot(time_EMG,EMG_struct(k).triceps_raw(analysis_window_EMG),'LineWidth',1,'color','r');
        plot3.Color(4) = 0.1;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        linkaxes([ax1 ax2 ax3],'x')
       
        
        figure(5)
        subplot(2,1,1)
        plot1 = plot(lags_js/Fs_js*1000,r_bi_js_pos,'LineWidth',1,'color','b');
        plot1.Color(4) = 0.3;
        hold on
        subplot(2,1,2)
        plot1 = plot(lags_js/Fs_js*1000,r_tri_js_pos,'LineWidth',1,'color','r');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        
        figure(6)
        subplot(2,1,1)
        plot1 = plot(lags_js/Fs_js*1000,r_bi_js_vel,'LineWidth',1,'color','b');
        plot1.Color(4) = 0.3;
        hold on
        subplot(2,1,2)
        plot1 = plot(lags_js/Fs_js*1000,r_tri_js_vel,'LineWidth',1,'color','r');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        
        figure(7)
        subplot(2,1,1)
        plot1 = plot(lags_js/Fs_js*1000,r_bi_js_acc,'LineWidth',1,'color','b');
        plot1.Color(4) = 0.3;
        hold on
        subplot(2,1,2)
        plot1 = plot(lags_js/Fs_js*1000,r_tri_js_acc,'LineWidth',1,'color','r');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        
        figure(8)
        plot1 = plot(lags/Fs_EMG*1000,r,'LineWidth',1,'color','k');
        plot1.Color(4) = 0.3;
        hold on
        set(gca,'TickDir','out')
        set(gca,'box','off')
        
    end
    end
end

y_bi = mean(EMG_biceps_all);
iqr_bi = iqr(EMG_biceps_all); %std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
iqr_tri = iqr(EMG_triceps_all); %std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));

figure(1)
subplot(3,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
ylabel('Radial Postion (mm)')
subplot(3,1,2)
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','k')
ylabel('Biceps EMG (V)')
subplot(3,1,3)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','k')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')

figure(2)
ax1 = subplot(5,1,1);
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
ylabel('Postion')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(5,1,2);
plot(time_js,mean(js_vel_all),'LineWidth',2,'color','k')
ylabel('Vel')
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(5,1,3);
plot(time_js,mean(js_acc_all),'LineWidth',2,'color','k')
ylabel('Acc')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(5,1,4);
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','b')
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(5,1,5);
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','r')
ylabel('Triceps')
xlabel('Time (sec)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3 ax4 ax5],'x')

figure(4)
ax1 = subplot(4,1,1);
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
ylabel({'Position';'(mm/s)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(4,1,2);
plot(time_js,mean(js_vel_all),'LineWidth',2,'color','k')
ylabel({'Velocity';'(mm/s)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(4,1,3);
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))],[35 140 204]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color',[35 140 204]/255)
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(4,1,4);
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))],[204 45 52]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color',[204 45 52]/255)
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax4 ax5],'x')

figure(3)
subplot(3,1,1)
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
ylabel('Radial Postion (mm)')
subplot(3,1,2)
plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
ylabel('Biceps EMG (V)')
subplot(3,1,3)
plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
ylabel('Triceps EMG (V)')
xlabel('Time (sec)')
%

figure(5)
subplot(2,1,1)
title('Position')
plot(lags_js/Fs_js*1000,mean(r_bi_js_pos_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_pos_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(6)
subplot(2,1,1)
title('Velocity')
plot(lags_js/Fs_js*1000,mean(r_bi_js_vel_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_vel_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(7)
subplot(2,1,1)
title('Acceleration')
plot(lags_js/Fs_js*1000,mean(r_bi_js_acc_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_acc_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(8)
plot(lags/Fs_EMG*1000,mean(r_all,2),'LineWidth',2,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')