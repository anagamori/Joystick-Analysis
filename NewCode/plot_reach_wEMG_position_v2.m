close all
clear all
clc

code_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode';

Fs_js = 1000;
Fs_EMG = 10000;

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



theta = 0:0.01:2*pi;


for n = 3
    data_folder = 'D:\JoystickExpts\data\';
    mouse_ID = 'Box_4_AN04'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
    if n == 1
        data_ID = '031622_63_79_020_10000_020_016_030_150_030_150_000';
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
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        mouse_ID_array = strsplit(mouse_ID,'_');
        
        data_folder = 'D:\JoystickExpts\data\';
        mouse_ID = mouse_ID_array{3};
        data_ID = condition_array{1};
        
        cd([data_folder mouse_ID '\EMG\' data_ID])
        load('data_processed')
        load('flag_noise')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
           
        index_js_reach = 1:length(js_reach)-2;
        index_EMG = 6:length(EMG_struct);
    elseif n == 2
        data_ID = '031722_63_79_020_10000_020_016_030_150_030_150_000';
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
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        mouse_ID_array = strsplit(mouse_ID,'_');
        
        data_folder = 'D:\JoystickExpts\data\';
        mouse_ID = mouse_ID_array{3};
        data_ID = condition_array{1};
        
        cd([data_folder mouse_ID '\EMG\' data_ID])
        load('data_processed')
        load('flag_noise')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
           
        index_js_reach = 1:length(js_reach)-1;
        index_EMG = 1:length(EMG_struct);
    elseif n == 3
        data_ID = '031822_63_79_020_10000_020_016_030_150_030_150_000';
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
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        mouse_ID_array = strsplit(mouse_ID,'_');
        
        data_folder = 'D:\JoystickExpts\data\';
        mouse_ID = mouse_ID_array{3};
        data_ID = condition_array{1};
        
        cd([data_folder mouse_ID '\EMG\' data_ID])
        load('data_processed')
        load('flag_noise')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        index_js_reach = 3:length(js_reach)-1;
        index_EMG = 1:length(EMG_struct);
    elseif n == 4
        data_ID = '031522_63_79_020_10000_020_016_030_150_030_150_000';
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
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        mouse_ID_array = strsplit(mouse_ID,'_');
        
        data_folder = 'D:\JoystickExpts\data\';
        mouse_ID = mouse_ID_array{3};
        data_ID = condition_array{1};
        
        cd([data_folder mouse_ID '\EMG\' data_ID])
        load('data_processed')
        load('flag_noise')
        cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')
        
        index_js_reach = 3:length(js_reach)-1;
        index_EMG = 1:length(EMG_struct);
    end
    flag = zeros(4,length(index_js_reach));
    for i = 1:length(index_js_reach) %nTrial
        %if isempty(js_reach(i).reach_flag)
        
        j = index_js_reach(i);
        k = index_EMG(i);
        if ~isempty(js_reach(j).start_time) %% && path_length(j)<3.5
            
            
            start_idx_js = js_reach(j).start_time;
            end_idx_js = js_reach(j).start_time+0.15*Fs_js;
            
            start_idx_EMG = start_idx_js*Fs_EMG/Fs_js;
            end_idx_EMG = end_idx_js*Fs_EMG/Fs_js;
            
            start_offset = 0;
            time_js = -start_offset:1/Fs_js:(end_idx_js-start_idx_js)/Fs_js-1/Fs_js;
            time_EMG = -start_offset:1/Fs_EMG:(end_idx_EMG-start_idx_EMG)/Fs_EMG-1/Fs_EMG;
            analysis_window_js = [start_idx_js-start_offset*Fs_js:end_idx_js-1];
            analysis_window_EMG = [start_idx_EMG-start_offset*Fs_EMG:end_idx_EMG-1];
            window_size = (end_idx_js-start_idx_js);
            
            if flag_noise(k) == 1
                flag(1,i) = 1;
                flag(2,i) = j;
                flag(3,i) = k;
                j
                k
                hold_still_duration(j) 
                target_hold_duration(j) 
                reach_duration(j) 
                peak_velocity(j) 
                path_length(j) 
                
                radial_pos_all = [radial_pos_all; js_reach(j).radial_pos_2(analysis_window_js)];
                radial_pos = js_reach(j).radial_pos_2(analysis_window_js);
                js_vel = gradient(js_reach(j).radial_pos_2(analysis_window_js))*Fs_js;
                max_vel_all = [max_vel_all; (max(js_vel))];
                js_vel_all = [js_vel_all; js_vel];
                js_acc = gradient(js_vel)*Fs_js;
                js_acc_all = [js_acc_all; js_acc];
                mag_vel = js_reach(j).mag_vel_2(analysis_window_js);
                mag_vel_all = [mag_vel_all; mag_vel];
                EMG_biceps = EMG_struct(k).biceps_zscore(analysis_window_EMG);
                EMG_biceps_ds = downsample(EMG_biceps,10);
                EMG_triceps = EMG_struct(k).triceps_zscore(analysis_window_EMG);
                EMG_triceps_ds = downsample(EMG_triceps,10);
                
                [r,lags] = xcorr(EMG_triceps-mean(EMG_triceps),EMG_biceps-mean(EMG_biceps),window_size*Fs_EMG/Fs_js,'coeff');
                
                
                [r_bi_js_pos,] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
                [r_tri_js_pos,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),radial_pos-mean(radial_pos),window_size,'coeff');
                
                
                [r_bi_js_vel,lags_js] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_vel-mean(js_vel),window_size,'coeff');
                [r_tri_js_vel,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_vel-mean(js_vel),window_size,'coeff');
                
                
                [r_bi_js_acc,~] = xcorr(EMG_biceps_ds-mean(EMG_biceps_ds),js_acc-mean(js_acc),window_size,'coeff');
                [r_tri_js_acc,~] = xcorr(EMG_triceps_ds-mean(EMG_triceps_ds),js_acc-mean(js_acc),window_size,'coeff');
                
                
                
                f1 = figure(1);
                movegui(f1,'northwest')
                ax1 = subplot(4,1,1);
                plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
                plot1.Color(4) = 1;
                yline(hold_threshold,'--','color','k','LineWidth',2)
                yline(outer_threshold,'color','g','LineWidth',2)
                yline(max_distance,'color','g','LineWidth',2)
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                ax2 = subplot(4,1,2);
                plot1 = plot(time_js,mag_vel,'LineWidth',1,'color','k');
                plot1.Color(4) = 1;
                ylabel({'Ve;pcoty','(mm/s)'})
                set(gca,'TickDir','out')
                set(gca,'box','off')
                ax3 = subplot(4,1,3);
                plot3 = plot(time_EMG,EMG_biceps,'LineWidth',1,'color',[35 140 204]/255);
                plot3.Color(4) = 1;
                ylabel({'Biceps','(zscore)'})
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                ax4 = subplot(4,1,4);
                plot4 = plot(time_EMG,EMG_triceps,'LineWidth',1,'color',[204 45 52]/255);
                plot4.Color(4) = 1;
                ylabel({'Triceps','(zscore)'})
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                linkaxes([ax1 ax2 ax3 ax4],'x')
                
                f2 = figure(2);
                movegui(f2,'southwest')
                ax1 = subplot(3,1,1);
                plot1 = plot(time_js,js_reach(j).radial_pos_2(analysis_window_js),'LineWidth',1,'color','k');
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                ax2 = subplot(3,1,2);
                plot2 = plot(time_EMG,EMG_struct(k).biceps_raw(analysis_window_EMG),'LineWidth',1,'color',[35 140 204]/255);
                plot2.Color(4) = 1;
                ylabel({'Biceps','(mV^2)'})
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                ax3 = subplot(3,1,3);
                plot3 = plot(time_EMG,EMG_struct(k).triceps_raw(analysis_window_EMG),'LineWidth',1,'color',[204 45 52]/255);
                plot3.Color(4) = 1;
                ylabel({'Triceps','(mV^2)'})
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                linkaxes([ax1 ax2 ax3],'x')
                
                f3 = figure(3);
                movegui(f3,'north')
                plot(js_reach(j).traj_x_2,js_reach(j).traj_y_2,'k','LineWidth',1)
                hold on
                plot(js_reach(j).traj_x_2(analysis_window_js),js_reach(j).traj_y_2(analysis_window_js),'r','LineWidth',2)
                plot(js_reach(j).traj_x_2(analysis_window_js),js_reach(j).traj_y_2(analysis_window_js),'g','LineWidth',2)
                plot(js_reach(j).traj_x_2(analysis_window_js),js_reach(j).traj_y_2(analysis_window_js),'m','LineWidth',2)
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
                axis equal
                                           
                f4 = figure(4);
                movegui(f4,'south')
                subplot(2,1,1)              
                plot1 = plot(lags_js/Fs_js*1000,r_bi_js_pos,'LineWidth',1,'color',[35 140 204]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                title('Position')
                subplot(2,1,2)
                plot1 = plot(lags_js/Fs_js*1000,r_tri_js_pos,'LineWidth',1,'color',[204 45 52]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                
                
                f5 = figure(5);
                movegui(f5,'northeast')
                subplot(2,1,1)
                
                plot1 = plot(lags_js/Fs_js*1000,r_bi_js_vel,'LineWidth',1,'color',[35 140 204]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                title('Velocity')
                subplot(2,1,2)
                plot1 = plot(lags_js/Fs_js*1000,r_tri_js_vel,'LineWidth',1,'color',[204 45 52]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                
                f6 = figure(6);
                movegui(f6,'southeast')
                subplot(2,1,1)
                                
                plot1 = plot(lags_js/Fs_js*1000,r_bi_js_acc,'LineWidth',1,'color',[35 140 204]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                title('Acceleration')
                subplot(2,1,2)
                plot1 = plot(lags_js/Fs_js*1000,r_tri_js_acc,'LineWidth',1,'color',[204 45 52]/255);
                plot1.Color(4) = 1;
                hold on
                set(gca,'TickDir','out')
                set(gca,'box','off')
                
%                 figure(8)
%                 plot1 = plot(lags/Fs_EMG*1000,r,'LineWidth',1,'color','k');
%                 plot1.Color(4) = 0.3;
%                 hold on
%                 set(gca,'TickDir','out')
%                 set(gca,'box','off')
%                 
                %end
                prompt = 'Acceptable? y/n: ';
                str = input(prompt,'s');
                if strcmp(str,'n')
                    flag(4,i) = 0;
                else
                    flag(4,i) = 1;
                    r_all = [r_all r];
                    r_bi_js_pos_all = [r_bi_js_pos_all r_bi_js_pos];
                    r_tri_js_pos_all = [r_tri_js_pos_all r_tri_js_pos];
                    r_bi_js_vel_all = [r_bi_js_vel_all r_bi_js_vel];
                    r_tri_js_vel_all = [r_tri_js_vel_all r_tri_js_vel];
                    r_bi_js_acc_all = [r_bi_js_acc_all r_bi_js_acc];
                    r_tri_js_acc_all = [r_tri_js_acc_all r_tri_js_acc];
                
                    EMG_biceps_all = [EMG_biceps_all; EMG_biceps'];
                    EMG_triceps_all = [EMG_triceps_all; EMG_triceps'];
                
                    EMG_biceps_raw_all = [EMG_biceps_raw_all; EMG_struct(k).biceps_raw(analysis_window_EMG)'];
                    EMG_triceps_raw_all = [EMG_triceps_raw_all; EMG_struct(k).triceps_raw(analysis_window_EMG)'];
                
                end
                close all
            end
        end
        cd([data_folder mouse_ID '\' data_ID])
        save('flag','flag')
        cd(code_folder)
    end
    
end
y_bi = mean(EMG_biceps_all);
se_bi = std(EMG_biceps_all,[],1)./(sqrt(size(EMG_biceps_all,1)));
y_tri = mean(EMG_triceps_all);
se_tri = std(EMG_triceps_all,[],1)./(sqrt(size(EMG_triceps_all,1)));


figure(7)
ax1 = subplot(5,1,1);
plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
yline(hold_threshold,'--','color','k','LineWidth',2)
yline(outer_threshold,'color','g','LineWidth',2)
yline(max_distance,'color','g','LineWidth',2)
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(5,1,2);
plot(time_js,mean(js_vel_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(5,1,3);
plot(time_js,mean(js_acc_all),'LineWidth',2,'color','k')
ylabel('Radial Postion (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(5,1,4);
patch([time_EMG fliplr(time_EMG)], [y_bi(:)-se_bi(:);  flipud(y_bi(:)+se_bi(:))],[35 140 204]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_biceps_all),'LineWidth',2,'color',[35 140 204]/255)
ylabel('Biceps EMG (z-score)')
set(gca,'TickDir','out')
set(gca,'box','off')
ax5 = subplot(5,1,5);
patch([time_EMG fliplr(time_EMG)], [y_tri(:)-se_tri(:);  flipud(y_tri(:)+se_tri(:))], [204 45 52]/255, 'FaceAlpha',0.2, 'EdgeColor','none')
hold on
plot(time_EMG,mean(EMG_triceps_all),'LineWidth',2,'color',[204 45 52]/255)
ylabel('Triceps EMG (z-score)')
xlabel('Time (sec)')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1 ax2 ax3 ax4 ax5],'x')

% figure(3)
% subplot(3,1,1)
% plot(time_js,mean(radial_pos_all),'LineWidth',2,'color','k')
% yline(hold_threshold,'--','color','k','LineWidth',2)
% yline(outer_threshold,'color','g','LineWidth',2)
% yline(max_distance,'color','g','LineWidth',2)
% ylabel('Radial Postion (mm)')
% subplot(3,1,2)
% plot(time_EMG,mean(EMG_biceps_raw_all),'LineWidth',2,'color','b')
% ylabel('Biceps EMG (V)')
% subplot(3,1,3)
% plot(time_EMG,mean(EMG_triceps_raw_all),'LineWidth',2,'color','r')
% ylabel('Triceps EMG (V)')
% xlabel('Time (sec)')
% %

figure(4)
subplot(2,1,1)
plot(lags_js/Fs_js*1000,mean(r_bi_js_pos_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
title('Position')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_pos_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(5)
subplot(2,1,1)
plot(lags_js/Fs_js*1000,mean(r_bi_js_vel_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
title('Velocity')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_vel_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


figure(6)
subplot(2,1,1)
plot(lags_js/Fs_js*1000,mean(r_bi_js_acc_all,2),'LineWidth',2,'color','b')
set(gca,'TickDir','out')
set(gca,'box','off')
title('Acceleration')
subplot(2,1,2)
plot(lags_js/Fs_js*1000,mean(r_tri_js_acc_all,2),'LineWidth',2,'color','r')
set(gca,'TickDir','out')
set(gca,'box','off')


% figure(8)
% plot(lags/Fs_EMG*1000,mean(r_all,2),'LineWidth',2,'color','k')
% set(gca,'TickDir','out')
% set(gca,'box','off')