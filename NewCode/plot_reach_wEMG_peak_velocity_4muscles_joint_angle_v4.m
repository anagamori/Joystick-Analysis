close all
clear all
clc

code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode';
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

theta_plot = 0:0.01:2*pi;

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

cd([data_folder mouse_ID '\' data_ID ,'_v5'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
Fs_EMG = 10000;
Fs_joint = 1000;


lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',200,'PassbandRipple',0.01, ...
    'SampleRate',Fs_EMG);

start_offset = -0.01;
end_offset = 0.12;

time_js = start_offset:1/Fs_js:end_offset;
time_js = time_js*1000;
time_EMG = start_offset:1/Fs_EMG:end_offset;
time_EMG = time_EMG*1000;
time_joint = start_offset:1/Fs_joint:end_offset;
time_joint = time_joint*1000;
window_size = length(time_js);
        
js_pos_all = [];
js_vel_all = [];
js_acc_all = [];
mag_vel_all = [];
max_vel_all = [];

theta_all = zeros(6,window_size);
theta_1_all = [];
theta_2_all = [];

torque_1_int_all = [];
torque_1_self_all = [];
torque_1_grav_all = [];
torque_1_muscle_all = [];
torque_2_int_all = [];
torque_2_self_all = [];
torque_2_grav_all = [];
torque_2_muscle_all = [];

EMG_biceps_all = [];
EMG_triceps_all = [];
EMG_a_delt_all = [];
EMG_p_delt_all = [];
EMG_biceps_ds_all = [];
EMG_triceps_ds_all = [];
EMG_a_delt_ds_all = [];
EMG_p_delt_ds_all = [];

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

r_bi_theta_1_all = [];
r_tri_theta_1_all = [];
r_a_delt_theta_1_all = [];
r_p_delt_theta_1_all = [];

r_bi_theta_2_all = [];
r_tri_theta_2_all = [];
r_a_delt_theta_2_all = [];
r_p_delt_theta_2_all = [];

r_bi_Gamma_1_all = [];
r_tri_Gamma_1_all = [];
r_a_delt_Gamma_1_all = [];
r_p_delt_Gamma_1_all = [];

r_bi_Gamma_2_all = [];
r_tri_Gamma_2_all = [];
r_a_delt_Gamma_2_all = [];
r_p_delt_Gamma_2_all = [];

index_js_reach = 1:length(js_reach)-2;
index_EMG = 1:length(EMG_struct);

idx = 0;
trialIdx = [18 19 20 23 24 25];
for i = trialIdx %23:25 %length(index_js_reach) %nTrial
  
    j = index_js_reach(i);
    k = index_EMG(i);
    %if isempty(js_reach(i).reach_flag)
    if ~isempty(js_reach(j).start_time)
        start_idx_js = js_reach(j).start_time;
        end_idx_js = js_reach(j).end_time;
        target_onset = js_reach(j).target_onset;
        target_offset = js_reach(j).target_offset;
        hold_onset = js_reach(j).hold_onset;
        hold_offset = js_reach(j).hold_offset;
        start_time = js_reach(j).start_time;
        end_time = js_reach(j).end_time/Fs_js;
    
        start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
        end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
        
        start_idx_joint = round(start_idx_js*Fs_joint/Fs_js);
        end_idx_joint = round(end_idx_js*Fs_joint/Fs_js);
        

        
        if flag_noise(k) == 1 && length(data(k).elbow_angle)>250 && straightness(j) > 0.8 
           
            idx = idx+1;
            mag_vel = js_reach(j).mag_vel(start_idx_js:1*Fs_js);
            [~,loc_max_mag_vel] = max(mag_vel);
            js_pos_temp = js_reach(j).radial_pos;
            js_vel_temp = gradient(js_pos_temp)*Fs_js;
            js_acc_temp = gradient(js_vel_temp)*Fs_js;
            [~,loc_max_acc] = findpeaks(js_acc_temp);
            
            analysis_window_js = [start_time+start_offset*Fs_js:start_time+end_offset*Fs_js];
            analysis_window_EMG = [start_idx_EMG+start_offset*Fs_EMG:start_idx_EMG+end_offset*Fs_EMG];
            %analysis_window_joint = round(analysis_window_joint);
            
            js_pos_all = [js_pos_all; js_reach(j).radial_pos(analysis_window_js)];
            radial_pos = js_reach(j).radial_pos(analysis_window_js);
            js_vel = gradient(js_reach(j).radial_pos(analysis_window_js))*Fs_js;
            max_vel_all = [max_vel_all; (max(js_vel))];
            js_vel_all = [js_vel_all; js_vel];
            js_acc = gradient(js_vel)*Fs_js;
            js_acc_all = [js_acc_all; js_acc];
            
            traj_x = js_reach(j).traj_x(analysis_window_js);
            traj_y = js_reach(j).traj_y(analysis_window_js);
            
            % Joint kinematics and kinetics data 
            theta = rad2deg(data(k).theta(:,analysis_window_js)); 
            theta_all = theta_all + theta;
            theta_1_all = [theta_1_all; theta(1,:)];
            theta_2_all = [theta_2_all; theta(4,:)];
                
            torque_1_int_all = [torque_1_int_all;data(k).shoulder_torque_int(analysis_window_js)'];
            torque_1_self_all = [torque_1_self_all;data(k).shoulder_torque_self(analysis_window_js)'];
            torque_1_grav_all = [torque_1_grav_all;data(k).shoulder_torque_grav(analysis_window_js)'];
            torque_1_muscle_all =[torque_1_muscle_all;data(k).shoulder_torque_int(analysis_window_js)'+data(k).shoulder_torque_self(analysis_window_js)'+data(k).shoulder_torque_grav(analysis_window_js)'];
            torque_2_int_all = [torque_2_int_all;data(k).elbow_torque_int(analysis_window_js)'];
            torque_2_self_all = [torque_2_self_all;data(k).elbow_torque_self(analysis_window_js)'];
            torque_2_grav_all = [torque_2_grav_all;data(k).elbow_torque_grav(analysis_window_js)'];
            torque_2_muscle_all = [torque_2_muscle_all;data(k).elbow_torque_int(analysis_window_js)'+data(k).elbow_torque_self(analysis_window_js)'+data(k).elbow_torque_grav(analysis_window_js)'];
            
            
            shift = 5*Fs_EMG/Fs_js;
%             EMG_biceps_temp= abs(EMG_struct(k).biceps_raw);
%             EMG_biceps_temp = EMG_biceps_temp([shift:end,1:shift-1]);
%             EMG_biceps = conv(EMG_biceps_temp,gausswin(0.001*Fs_EMG)./sum(gausswin(0.001*Fs_EMG)),'same');
            EMG_biceps_temp = EMG_struct(k).biceps_zscore;
            EMG_biceps = EMG_biceps_temp([shift:end,1:shift-1]);
            %EMG_biceps = EMG_biceps(analysis_window_EMG);
            EMG_biceps = EMG_biceps(analysis_window_EMG);
            EMG_biceps_ds = downsample(EMG_biceps,10);
        
%             EMG_triceps_temp= abs(EMG_struct(k).triceps_raw);
%             EMG_triceps_temp = EMG_triceps_temp([shift:end,1:shift-1]);
%             EMG_triceps = conv(EMG_triceps_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
            EMG_triceps_temp = EMG_struct(k).triceps_zscore;
            EMG_triceps = EMG_triceps_temp([shift:end,1:shift-1]);
            EMG_triceps = EMG_triceps(analysis_window_EMG);
            EMG_triceps_ds = downsample(EMG_triceps,10);
                        
%             EMG_a_delt_temp= abs(EMG_struct(k).a_delt_raw);
%             EMG_a_delt_temp = EMG_a_delt_temp([shift:end,1:shift-1]);
%             EMG_a_delt = conv(EMG_a_delt_temp,gausswin(0.01*Fs_EMG)./sum(gausswin(0.01*Fs_EMG)),'same');
            EMG_a_delt_temp = EMG_struct(k).a_delt_zscore;
            EMG_a_delt = EMG_a_delt_temp([shift:end,1:shift-1]);
            EMG_a_delt = EMG_a_delt(analysis_window_EMG);
            EMG_a_delt_ds = downsample(EMG_a_delt,10);
            
%             EMG_p_delt_temp= abs(EMG_struct(k).p_delt_raw);
%             EMG_p_delt_temp = EMG_p_delt_temp([shift:end,1:shift-1]);
%             EMG_p_delt = conv(EMG_p_delt_temp,gausswin(0.02*Fs_EMG)./sum(gausswin(0.02*Fs_EMG)),'same');
            EMG_p_delt_temp = EMG_struct(k).p_delt_zscore;
            EMG_p_delt = EMG_p_delt_temp([shift:end,1:shift-1]);
            EMG_p_delt = EMG_p_delt(analysis_window_EMG);
            EMG_p_delt_ds = downsample(EMG_p_delt,10);
            
                             
            EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
            EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
            EMG_a_delt_all = [EMG_a_delt_all; EMG_a_delt'];
            EMG_p_delt_all = [EMG_p_delt_all; EMG_p_delt'];
            
            EMG_biceps_ds_all = [EMG_biceps_ds_all; EMG_biceps_ds'];
            EMG_triceps_ds_all = [EMG_triceps_ds_all; EMG_triceps_ds'];
            EMG_a_delt_ds_all = [EMG_a_delt_ds_all; EMG_a_delt_ds'];
            EMG_p_delt_ds_all = [EMG_p_delt_ds_all; EMG_p_delt_ds'];
          
            
            f1 = figure(1);
            movegui(f1,'northwest')
            ax1 = subplot(7,1,1);
            plot1 = plot(time_js,js_reach(j).radial_pos(analysis_window_js),'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax2 = subplot(7,1,2);
            plot1 = plot(time_joint,theta(1,:),'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax3 = subplot(7,1,3);
            plot1 = plot(time_joint,theta(4,:),'LineWidth',1,'color','k');
            plot1.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax4 = subplot(7,1,4);
            plot3 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color',[35 140 204]/255);
            plot3.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax5 = subplot(7,1,5);
            plot4 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color',[204 45 52]/255);
            plot4.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax6 = subplot(7,1,6);
            plot5 = plot(time_EMG,EMG_a_delt,'LineWidth',1,'color',[45 49 66]/255);
            plot5.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax7 = subplot(7,1,7);
            plot6 = plot(time_EMG,EMG_p_delt,'LineWidth',1,'color',[247 146 83]/255);
            plot6.Color(4) = 0.5;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')
            
            f2 = figure(2);
            movegui(f2,'southwest')
            ax1 = subplot(4,1,1);
            plot1 = plot(time_js,js_reach(j).radial_pos(analysis_window_js),'LineWidth',1,'color','k');
            plot1.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax2 = subplot(4,1,2);
            plot1 = plot(time_js,js_vel,'LineWidth',1,'color','k');
            plot1.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax3 = subplot(4,1,3);
            plot3 = plot(time_js,js_acc,'LineWidth',1,'color','k');
            plot3.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax4 = subplot(4,1,4);
            plot4 = plot(time_EMG,EMG_a_delt,'LineWidth',1,'color',[204 45 52]/255);
            plot4.Color(4) = 1;
            hold on
            set(gca,'TickDir','out')
            set(gca,'box','off')
            linkaxes([ax1 ax2 ax3 ax4],'x')
            
            f3 = figure(3);
            movegui(f3,'south')
            plot(traj_x,traj_y,'color',[45, 49, 66]/255,'LineWidth',1)
            hold on
            plot(js_reach(j).traj_x(start_time:target_onset),js_reach(j).traj_y(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            xlim([-7 7])
            ylim([-7 7])
            set(gca,'TickDir','out')
            set(gca,'box','off')
            hold on
            plot(hold_threshold*cos(theta_plot),hold_threshold*sin(theta_plot),'--','color','k')
            plot(outer_threshold*cos(theta_plot),outer_threshold*sin(theta_plot),'--','color','k')
            plot(max_distance*cos(theta_plot),max_distance*sin(theta_plot),'--','color','k')
            plot([0 7*cos(angle_1)],[0 7*sin(angle_1)],'color','m')
            plot([0 7*cos(angle_2)],[0 7*sin(angle_2)],'color','m')
            xlabel('ML (mm)')
            ylabel('AP (mm)')
            axis equal
            
            k
%             prompt = 'Move to nex? y/n: ';
%             str = input(prompt,'s');
%             if strcmp(str,'n')
%                 break
%             end
        end
        
    end
end

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';            
cd([data_folder mouse_ID '\' data_ID])
save('js_pos_all','js_pos_all')
save('js_vel_all','js_vel_all')
save('js_acc_all','js_acc_all')
save('theta_1_all','theta_1_all')
save('theta_2_all','theta_2_all')
save('torque_1_int_all','torque_1_int_all')
save('torque_1_self_all','torque_1_self_all')
save('torque_1_grav_all','torque_1_grav_all')
save('torque_1_muscle_all','torque_1_muscle_all')
save('torque_2_int_all','torque_2_int_all')
save('torque_2_self_all','torque_2_self_all')
save('torque_2_grav_all','torque_2_grav_all')
save('torque_2_muscle_all','torque_2_muscle_all')
save('EMG_biceps_all','EMG_biceps_all')
save('EMG_triceps_all','EMG_triceps_all')
save('EMG_a_delt_all','EMG_a_delt_all')
save('EMG_p_delt_all','EMG_p_delt_all')
save('EMG_biceps_ds_all','EMG_biceps_ds_all')
save('EMG_triceps_ds_all','EMG_triceps_ds_all')
save('EMG_a_delt_ds_all','EMG_a_delt_ds_all')
save('EMG_p_delt_ds_all','EMG_p_delt_ds_all')
cd(code_folder)

y_bi = mean(EMG_biceps_all);
iqr_bi = iqr(EMG_biceps_all); %std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
iqr_tri = iqr(EMG_triceps_all); %std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));
y_ad = mean(EMG_a_delt_all);
iqr_ad = iqr(EMG_a_delt_all); %std(EMG_a_delt_all,[],1)./(sqrt(size(EMG_a_delt_all,1)));
se_ad = std(EMG_a_delt_all,[],1)./(sqrt(size(EMG_a_delt_all,1)));
y_pd = mean(EMG_p_delt_all);
iqr_pd = iqr(EMG_p_delt_all); %std(EMG_p_delt_all,[],1)./(sqrt(size(EMG_p_delt_all,1)));
se_pd = std(EMG_p_delt_all,[],1)./(sqrt(size(EMG_p_delt_all,1)));


figure(1)
subplot(7,1,1)
plot(time_js,mean(js_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'--','color','k','LineWidth',2)
yline(max_distance,'--','color','k','LineWidth',2)
ylabel({'Radial','Postion (mm)'})
subplot(7,1,2)
plot(time_joint,mean(theta_1_all),'LineWidth',2,'color','k')
ylabel({'Shoulder','Angle (deg)'})
subplot(7,1,3)
plot(time_joint,mean(theta_2_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
subplot(7,1,4)
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color','k')
ylabel({'Biceps','(z-score)'})
subplot(7,1,5)
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color','k')
ylabel({'Triceps','(z-score)'})
subplot(7,1,6)
plot(time_EMG,mean(EMG_a_delt_all),'LineWidth',2,'color','k')
ylabel({'CB','(z-score)'})
subplot(7,1,7)
plot(time_EMG,mean(EMG_p_delt_all),'LineWidth',2,'color','k')
ylabel({'AD','(z-score)'})
xlabel('Time (ms)')

figure(4)
ax1 = subplot(3,1,1);
plot(time_js,mean(js_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'--','color','k','LineWidth',2)
yline(max_distance,'--','color','k','LineWidth',2)
ylabel({'Position';'(mm)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(time_joint,mean(theta_1_all),'LineWidth',2,'color','k')
ylabel({'Shoulder','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(time_joint,mean(theta_2_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3],'x')

figure(4)
ax1 = subplot(7,1,1);
plot(time_js,mean(js_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'--','color','k','LineWidth',2)
yline(max_distance,'--','color','k','LineWidth',2)
ylabel({'Position';'(mm/s)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(7,1,2);
plot(time_joint,mean(theta_1_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(7,1,3);
plot(time_joint,mean(theta_2_all),'LineWidth',2,'color','k')
ylabel({'Elbow','Angle (deg)'})
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(7,1,4);
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))],[35 140 204]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color',[35 140 204]/255)
ylabel('Biceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(7,1,5);
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))],[204 45 52]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color',[204 45 52]/255)
ylabel('Triceps')
set(gca,'TickDir','out')
set(gca,'box','off')
ax6 = subplot(7,1,6);
patch([time_EMG fliplr(time_EMG)], [y_ad(:)-se_ad(:);  flipud(y_ad(:)+se_ad(:))],[45 49 66]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_a_delt_all),'LineWidth',2,'color',[45 49 66]/255)
ylabel('CB')
set(gca,'TickDir','out')
set(gca,'box','off')
ax7 = subplot(7,1,7);
patch([time_EMG fliplr(time_EMG)], [y_pd(:)-se_pd(:);  flipud(y_pd(:)+se_pd(:))],[247 146 83]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_p_delt_all),'LineWidth',2,'color',[247 146 83]/255)
ylabel('AD')
xlabel('Time (ms)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')
                
theta_all = theta_all./idx;
mean_theta_1 = mean(theta_1_all);
mean_angle = mean(mean_theta_1);
p2p = max(mean_theta_1)-min(mean_theta_1);
figure(5)
ax1 = subplot(3,2,1);
plot(time_js,mean_theta_1,'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,p2p*(rescale(theta_all(2,:))-mean(rescale(theta_all(2,:))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,p2p*(rescale(theta_all(3,:))-mean(rescale(theta_all(3,:))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
legend('Shoulder Angle','Velocity','Acceleration')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,2,3);
plot(time_js,mean(torque_1_int_all),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,mean(torque_1_self_all),'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,mean(torque_1_grav_all),'color',[166, 145, 174]/255,'LineWidth',1)
plot(time_js,mean(torque_1_muscle_all),'color',[111, 222, 110]/255,'LineWidth',1)
ylabel({'Shoulder','Torque (Nm)'})
legend('Interaction','Net','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(3,2,5);
plot(time_EMG,mean(EMG_a_delt_all),'color',[10, 40, 75]/255,'LineWidth',1)
hold on
plot(time_EMG,mean(EMG_p_delt_all),'color',[255, 66, 66]/255,'LineWidth',1)
ylabel({'Shoulder','Torque (Nm)'})
set(gca,'TickDir','out')
set(gca,'box','off')
mean_theta_2 = mean(theta_2_all);
mean_angle = mean(mean_theta_2);
p2p = max(mean_theta_2)-min(mean_theta_2);
ax3 = subplot(3,2,2);
plot(time_js,mean_theta_2,'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,p2p*(rescale(theta_all(5,:))-mean(rescale(theta_all(5,:))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,p2p*(rescale(theta_all(6,:))-mean(rescale(theta_all(6,:))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
legend('Elbow Angle','Velocity','Acceleration')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(3,2,4);
plot(time_js,mean(torque_2_int_all),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_js,mean(torque_2_self_all),'color',[255, 66, 66]/255,'LineWidth',1)
plot(time_js,mean(torque_2_grav_all),'color',[166, 145, 174]/255,'LineWidth',1)
plot(time_js,mean(torque_2_muscle_all),'color',[111, 222, 110]/255,'LineWidth',1)
ylabel({'Elbow','Torque (Nm)'})
legend('Interaction','Net','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
ax6 = subplot(3,2,6);
plot(time_EMG,mean(EMG_biceps_all),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(time_EMG,mean(EMG_triceps_all),'color',[255, 66, 66]/255,'LineWidth',1)
ylabel({'Elbow','Torque (Nm)'})
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
%

%% Cross-correlation analysis
mean_EMG_biceps = mean(EMG_biceps_all);
mean_EMG_triceps = mean(EMG_triceps_all);
mean_EMG_a_delt = mean(EMG_a_delt_all);
mean_EMG_p_delt = mean(EMG_p_delt_all);

mean_EMG_biceps_ds = mean(EMG_biceps_ds_all);
mean_EMG_triceps_ds = mean(EMG_triceps_ds_all);
mean_EMG_a_delt_ds = mean(EMG_a_delt_ds_all);
mean_EMG_p_delt_ds = mean(EMG_p_delt_ds_all);

[r_bi_tri,lags] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_triceps-mean(mean_EMG_triceps),window_size*Fs_EMG/Fs_js,'coeff');
[r_bi_a_delt,~] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_a_delt-mean(mean_EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
[r_bi_p_delt,~] = xcorr(mean_EMG_biceps-mean(mean_EMG_biceps),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
[r_tri_a_delt,~] = xcorr(mean_EMG_triceps-mean(mean_EMG_triceps),mean_EMG_a_delt-mean(mean_EMG_a_delt),window_size*Fs_EMG/Fs_js,'coeff');
[r_tri_p_delt,~] = xcorr(mean_EMG_triceps-mean(mean_EMG_triceps),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');
[r_a_delt_p_delt,~] = xcorr(mean_EMG_a_delt-mean(mean_EMG_a_delt),mean_EMG_p_delt-mean(mean_EMG_p_delt),window_size*Fs_EMG/Fs_js,'coeff');

[r_bi_js_pos,] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
[r_tri_js_pos,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
[r_a_delt_js_pos,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');
[r_p_delt_js_pos,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),radial_pos-mean(radial_pos),window_size,'coeff');


[r_bi_js_vel,lags_js] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),js_vel-mean(js_vel),window_size,'coeff');
[r_tri_js_vel,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),js_vel-mean(js_vel),window_size,'coeff');
[r_a_delt_js_vel,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),js_vel-mean(js_vel),window_size,'coeff');
[r_p_delt_js_vel,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),js_vel-mean(js_vel),window_size,'coeff');


[r_bi_js_acc,~] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),js_acc-mean(js_acc),window_size,'coeff');
[r_tri_js_acc,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),js_acc-mean(js_acc),window_size,'coeff');
[r_a_delt_js_acc,] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),js_acc-mean(js_acc),window_size,'coeff');
[r_p_delt_js_acc,] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),js_acc-mean(js_acc),window_size,'coeff');


mean_theta_1 = theta_all(3,:); %mean(theta_1_all);
[r_bi_theta_1,lags_theta_1] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
[r_tri_theta_1,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
[r_a_delt_theta_1,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');
[r_p_delt_theta_1,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),mean_theta_1-mean(mean_theta_1),window_size,'coeff');

mean_theta_2 = theta_all(6,:); %mean(theta_2_all);
[r_bi_theta_2,lags_theta_2] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
[r_tri_theta_2,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
[r_a_delt_theta_2,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');
[r_p_delt_theta_2,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),mean_theta_2-mean(mean_theta_2),window_size,'coeff');

Gamma_1 = mean(torque_1_muscle_all);
Gamma_2 = mean(torque_2_muscle_all);

[r_bi_Gamma_1,lags_Gamma_1] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
[r_tri_Gamma_1,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
[r_a_delt_Gamma_1,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');
[r_p_delt_Gamma_1,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),Gamma_1-mean(Gamma_1),window_size,'coeff');


[r_bi_Gamma_2,lags_Gamma_2] = xcorr(mean_EMG_biceps_ds-mean(mean_EMG_biceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
[r_tri_Gamma_2,~] = xcorr(mean_EMG_triceps_ds-mean(mean_EMG_triceps_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
[r_a_delt_Gamma_2,~] = xcorr(mean_EMG_a_delt_ds-mean(mean_EMG_a_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
[r_p_delt_Gamma_2,~] = xcorr(mean_EMG_p_delt_ds-mean(mean_EMG_p_delt_ds),Gamma_2-mean(Gamma_2),window_size,'coeff');
            
figure(6)
subplot(2,2,1)
plot(lags_js/Fs_js*1000,r_bi_js_pos,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Position')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,r_tri_js_pos,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,r_a_delt_js_pos,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,r_p_delt_js_pos,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(7)
subplot(2,2,1)
plot(lags_js/Fs_js*1000,r_bi_js_vel,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Velocity')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,r_tri_js_vel,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,r_a_delt_js_vel,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,r_p_delt_js_vel,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')


figure(8)
subplot(2,2,1)
%title('Acceleration')
plot(lags_js/Fs_js*1000,r_bi_js_acc,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,2)
plot(lags_js/Fs_js*1000,r_tri_js_acc,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_js/Fs_js*1000,r_a_delt_js_acc,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_js/Fs_js*1000,r_p_delt_js_acc,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')


figure(9)
subplot(2,3,1)
plot(lags/Fs_EMG*1000,r_bi_tri,'LineWidth',2,'color','k')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,2)
plot(lags/Fs_EMG*1000,r_bi_a_delt,'LineWidth',2,'color','k');
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,3)
plot(lags/Fs_EMG*1000,r_bi_p_delt,'LineWidth',2,'color','k');
title('Biceps-AD')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,4)
plot(lags/Fs_EMG*1000,r_tri_a_delt,'LineWidth',2,'color','k');
title('Triceps-CB')
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,5)
plot(lags/Fs_EMG*1000,r_tri_p_delt,'LineWidth',2,'color','k');
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,3,6)
plot(lags/Fs_EMG*1000,r_a_delt_p_delt,'LineWidth',2,'color','k');
title('CB-AD')
set(gca,'TickDir','out')
set(gca,'box','off')

figure(10)
subplot(2,2,1)
plot(lags_theta_1/Fs_joint*1000,r_bi_theta_1,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Shoulder angle')
subplot(2,2,2)
plot(lags_theta_1/Fs_joint*1000,r_tri_theta_1,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_theta_1/Fs_joint*1000,r_a_delt_theta_1,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_theta_1/Fs_joint*1000,r_p_delt_theta_1,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(11)
subplot(2,2,1)
plot(lags_theta_1/Fs_joint*1000,r_bi_theta_2,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Elbow angle')
subplot(2,2,2)
plot(lags_theta_1/Fs_joint*1000,r_tri_theta_2,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_theta_1/Fs_joint*1000,r_a_delt_theta_2,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_theta_1/Fs_joint*1000,r_p_delt_theta_2,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(12)
subplot(2,2,1)
plot(lags_Gamma_1/Fs_joint*1000,r_bi_Gamma_1,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Shoulder torque')
subplot(2,2,2)
plot(lags_Gamma_1/Fs_joint*1000,r_tri_Gamma_1,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_Gamma_1/Fs_joint*1000,r_a_delt_Gamma_1,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_Gamma_1/Fs_joint*1000,r_p_delt_Gamma_1,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(13)
subplot(2,2,1)
plot(lags_Gamma_1/Fs_joint*1000,r_bi_Gamma_2,'LineWidth',2,'color',[35 140 204]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
title('Elbow torque')
subplot(2,2,2)
plot(lags_Gamma_1/Fs_joint*1000,r_tri_Gamma_2,'LineWidth',2,'color',[204 45 52]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,3)
plot(lags_Gamma_1/Fs_joint*1000,r_a_delt_Gamma_2,'LineWidth',2,'color',[45 49 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(2,2,4)
plot(lags_Gamma_1/Fs_joint*1000,r_p_delt_Gamma_2,'LineWidth',2,'color',[247 146 83]/255)
set(gca,'TickDir','out')
set(gca,'box','off')