close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN04'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '031522_63_79_020_10000_020_016_030_150_030_150_000';
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

idx = find(reach_duration<100);

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

radial_pos_fast_all = [];
js_vel_fast_all = [];
js_acc_fast_all = [];
radial_pos_slow_all = [];
js_vel_slow_all = [];
js_acc_slow_all = [];
mag_vel_all = [];
max_vel_all = [];

EMG_biceps_fast_all = [];
EMG_triceps_fast_all = [];
EMG_biceps_slow_all = [];
EMG_triceps_slow_all = [];

r_all = [];

r_bi_js_pos_all = [];
r_tri_js_pos_all = [];
r_bi_js_vel_all = [];
r_tri_js_vel_all = [];
r_bi_js_acc_all = [];
r_tri_js_acc_all = [];
        
index_js_reach = 1:length(EMG_struct);
index_EMG = 1:length(EMG_struct);

idx(idx>length(EMG_struct)) = [];
peak_velocity = peak_velocity(idx);
index_js_reach = index_js_reach(idx);
index_EMG = index_EMG(idx);
for i = 1:length(index_js_reach) %nTrial
     if ~isempty(js_reach(i).start_time)
    start_idx_js = js_reach(i).start_time;
    end_idx_js = js_reach(i).end_time;
    
    start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
    end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
    
    time_js = -0.1:1/Fs_js:0.1;
    time_EMG = -0.1:1/Fs_EMG:0.1;
    
    window_size = length(time_js);

    if flag_noise(i) == 1 &&  peak_velocity(i) >= 102.4030

        j = index_js_reach(i);
        k = index_EMG(i);
        
        mag_vel = js_reach(j).mag_vel_2(start_idx_js:1*Fs_js);
        [~,loc_max_mag_vel] = max(mag_vel);
        
        analysis_window_js = [loc_max_mag_vel+start_idx_js-0.1*Fs_js:loc_max_mag_vel+start_idx_js+0.1*Fs_js];
        analysis_window_EMG = [loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG-0.1*Fs_EMG:loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG+0.1*Fs_EMG];
    
        radial_pos_fast_all = [radial_pos_fast_all; js_reach(j).radial_pos_2(analysis_window_js)];
        radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
        js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
        max_vel_all = [max_vel_all; (max(js_vel))];
        js_vel_fast_all = [js_vel_fast_all; js_vel];
        js_acc = gradient(js_vel)*Fs_js;
        js_acc_fast_all = [js_acc_fast_all; js_acc];
        
        mag_vel_all = [mag_vel_all; js_reach(j).mag_vel_2(analysis_window_js)];
        EMG_biceps = EMG_struct(k).biceps_zscore(analysis_window_EMG);
        EMG_biceps_ds = downsample(EMG_biceps,10);
        EMG_triceps = EMG_struct(k).triceps_zscore(analysis_window_EMG);
        EMG_triceps_ds = downsample(EMG_triceps,10);
        
        
        EMG_biceps_fast_all = [EMG_biceps_fast_all; EMG_biceps'];
        EMG_triceps_fast_all = [EMG_triceps_fast_all; EMG_triceps'];

    elseif flag_noise(i) == 1 &&  peak_velocity(i) < 102.4030
        j = index_js_reach(i);
        k = index_EMG(i);
        
        mag_vel = js_reach(j).mag_vel_2(start_idx_js:1*Fs_js);
        [~,loc_max_mag_vel] = max(mag_vel);
        
        analysis_window_js = [loc_max_mag_vel+start_idx_js-0.1*Fs_js:loc_max_mag_vel+start_idx_js+0.1*Fs_js];
        analysis_window_EMG = [loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG-0.1*Fs_EMG:loc_max_mag_vel*Fs_EMG/Fs_js+start_idx_EMG+0.1*Fs_EMG];
    
        radial_pos_slow_all = [radial_pos_slow_all; js_reach(j).radial_pos_2(analysis_window_js)];
        radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
        js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
        max_vel_all = [max_vel_all; (max(js_vel))];
        js_vel_slow_all = [js_vel_slow_all; js_vel];
        js_acc = gradient(js_vel)*Fs_js;
        js_acc_slow_all = [js_acc_slow_all; js_acc];
        
        mag_vel_all = [mag_vel_all; js_reach(j).mag_vel_2(analysis_window_js)];
        EMG_biceps = EMG_struct(k).biceps_zscore(analysis_window_EMG);
        EMG_biceps_ds = downsample(EMG_biceps,10);
        EMG_triceps = EMG_struct(k).triceps_zscore(analysis_window_EMG);
        EMG_triceps_ds = downsample(EMG_triceps,10);
        
        
        EMG_biceps_slow_all = [EMG_biceps_slow_all; EMG_biceps'];
        EMG_triceps_slow_all = [EMG_triceps_slow_all; EMG_triceps'];
             
    end
    end
end

y_bi_fast = median(EMG_biceps_fast_all);
iqr_bi_fast = iqr(EMG_biceps_fast_all); %std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
%se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri_fast = median(EMG_triceps_fast_all);
iqr_tri_fast = iqr(EMG_triceps_fast_all); %std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
% se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));

y_bi_slow = median(EMG_biceps_slow_all);
iqr_bi_slow = iqr(EMG_biceps_slow_all); 
y_tri_slow = median(EMG_triceps_slow_all);
iqr_tri_slow = iqr(EMG_triceps_slow_all);

figure(2)
ax1 = subplot(5,1,1);
plot(time_js,mean(radial_pos_fast_all),'LineWidth',2,'color','b')
hold on 
plot(time_js,mean(radial_pos_slow_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
    yline(outer_threshold,'color','g','LineWidth',2)
    yline(max_distance,'color','g','LineWidth',2)
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(5,1,2);
plot(time_js,mean(js_vel_fast_all),'LineWidth',2,'color','b')
hold on 
plot(time_js,mean(js_vel_slow_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(5,1,3);
plot(time_js,mean(js_acc_fast_all),'LineWidth',2,'color','b')
hold on 
plot(time_js,mean(js_acc_slow_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(5,1,4);
patch([time_EMG fliplr(time_EMG)], [y_bi_fast(:)-iqr_bi_fast(:);  flipud(y_bi_fast(:)+iqr_bi_fast(:))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,median(EMG_biceps_fast_all),'LineWidth',2,'color','b')
patch([time_EMG fliplr(time_EMG)], [y_bi_slow(:)-iqr_bi_slow(:);  flipud(y_bi_slow(:)+iqr_bi_slow(:))], 'k', 'FaceAlpha',0.2, 'EdgeColor','none')
plot(time_EMG,median(EMG_biceps_slow_all),'LineWidth',2,'color','k')
ylabel('Biceps EMG (z-score)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(5,1,5);
patch([time_EMG fliplr(time_EMG)], [y_tri_fast(:)-iqr_tri_fast(:);  flipud(y_tri_fast(:)+iqr_tri_fast(:))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,median(EMG_triceps_fast_all),'LineWidth',2,'color','r')
patch([time_EMG fliplr(time_EMG)], [y_tri_slow(:)-iqr_tri_slow(:);  flipud(y_tri_slow(:)+iqr_tri_slow(:))], 'k', 'FaceAlpha',0.2, 'EdgeColor','none')
plot(time_EMG,median(EMG_triceps_slow_all),'LineWidth',2,'color','k')
ylabel('Triceps EMG (z-score)')
xlabel('Time (sec)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3 ax4 ax5],'x')

