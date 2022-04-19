%--------------------------------------------------------------------------
% plot_js_reach
% Author: Akira Nagamori
% Last update: 2/28/2022
% Descriptions:
%--------------------------------------------------------------------------

close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_AN06';
data_ID = '040122_63_79_020_10000_020_016_030_150_030_150_000';
condition_array = strsplit(data_ID,'_');

pltOpt = 1;

cd([data_folder mouse_ID '\' data_ID])
load('js_reach')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

Fs_js = 1000;
nTrial = length(js_reach);

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
hold_duration = str2double(condition_array{6});
trial_duration = str2double(condition_array{5});
angle_1 = str2double(condition_array{8})/180*pi;
angle_2 = str2double(condition_array{9})/180*pi;

theta = 0:0.01:2*pi;

%%
target_hold_duration = [];
hold_still_duration = [];
reach_duration = [];
path_length = [];
straightness = [];
peak_velocity = [];

flag = [];
for i = 1:nTrial
    radial_pos_2 = js_reach(i).radial_pos_2;
    mag_vel_2 = js_reach(i).mag_vel_2;
    RoC_2 = js_reach(i).RoC_2;
    
    dx = gradient(js_reach(i).traj_x_2);
    dy = gradient(js_reach(i).traj_y_2);
    d_euclidean = sqrt(dx.^2+dy.^2);
    %% hold still duration immediately before successful reach
    idx_on_hold = find(radial_pos_2<hold_threshold);
    temp = idx_on_hold(idx_on_hold<1*Fs_js);
    if ~isempty(temp)
        i
        hold_offset = temp(end)+1;
        
        idx_off_hold = find(radial_pos_2>=hold_threshold);
        temp2 = idx_off_hold(idx_off_hold<hold_offset);
        if ~isempty(temp2)
            hold_onset = temp2(end)+1;
        else
            hold_onset = 1;
        end
        hold_still_duration = [hold_still_duration hold_offset-hold_onset];
        hold_still_duration(i)
        %% target hold duration
        idx_off_target = find(radial_pos_2<=outer_threshold|radial_pos_2>=max_distance);
        temp = idx_off_target(idx_off_target<1*Fs_js);
        target_onset = temp(end)+1;
        temp2 = idx_off_target(idx_off_target>1*Fs_js);
        target_offset = temp2(1);
        target_hold_duration = [target_hold_duration target_offset-target_onset];
        target_hold_duration(i)
        %% Reach duration
        reach_duration = [reach_duration target_onset-hold_offset];
        reach_duration(i)
        path_length = [path_length sum(d_euclidean(hold_offset:target_onset))];
        path_length(i)
        D = sqrt((js_reach(i).traj_x_2(target_onset)-js_reach(i).traj_x_2(hold_offset)).^2+(js_reach(i).traj_y_2(target_onset)-js_reach(i).traj_y_2(hold_offset)).^2);
        straightness = [straightness D/path_length(i)];
        straightness(i)
        %% Peak velocity
        [temp_peak_velocity,loc_peak_velocity] = max(mag_vel_2(hold_offset-1:target_onset));
        peak_velocity = [peak_velocity temp_peak_velocity];
        peak_velocity(i)
        %% Find conincident velocity and RoC local minima
        
        [min_vel_2,loc_min_vel_2] = findpeaks(-mag_vel_2);
        [min_RoC_2,loc_min_RoC_2] = findpeaks(-RoC_2);
        A_2 = repmat(loc_min_RoC_2',[1 length(loc_min_vel_2)]);
        [minValue_2,closestIndex_2] = min(abs(A_2-loc_min_vel_2),[],1);
        loc_min_vel_2(minValue_2>2) = [];
        closestIndex_2(minValue_2>2) = [];
        
        %% velocity minimum closest to reward
        [~,idx_min_vel_2_reward] = min(abs(loc_min_vel_2-1*Fs_js));
        loc_min_vel_2_reward = loc_min_vel_2(idx_min_vel_2_reward);
        
        %% Reach start
        % the last coincident velocity and RoC local minima within hold
        idx_min_vel_hold = loc_min_vel_2(loc_min_vel_2<hold_offset&loc_min_vel_2>hold_onset);
        if ~isempty(idx_min_vel_hold)
            start_time = idx_min_vel_hold(end);
        else
            start_time = hold_onset;
        end
        
        %% Reach end
        % the first coincident velocity and RoC local minima after reward
        idx_min_vel_end = loc_min_vel_2(loc_min_vel_2>target_offset);
        end_time = idx_min_vel_end(1);
        
        %     %% Plot data
        if pltOpt == 1
            time_reach = [1:length(js_reach(i).radial_pos_2)]./Fs_js;
            %loc_min_vel_2(loc_min_vel_2==loc_min_vel_2_reward) = [];
            f1 = figure(1);
            movegui(f1,'northwest')
            ax1 = subplot(3,1,1);
            plot(time_reach,radial_pos_2,'color',[45, 49, 66]/255,'LineWidth',1)
            hold on
            plot(time_reach(target_onset:target_offset),radial_pos_2(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
            plot(time_reach(hold_onset:hold_offset-1),radial_pos_2(hold_onset:hold_offset-1),'color',[225 218 174]/255,'LineWidth',2)
            plot(time_reach(start_time:target_onset),radial_pos_2(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            plot(time_reach(loc_min_vel_2_reward),radial_pos_2(loc_min_vel_2_reward),'o','color',[204 45 53]/255,'LineWidth',2)
            plot(time_reach(start_time),radial_pos_2(start_time),'o','color',[5,142 217]/255,'LineWidth',2)
            plot(time_reach(end_time),radial_pos_2(end_time),'o','color',[5,142 217]/255,'LineWidth',2)
            yline(hold_threshold,'--','color','k','LineWidth',2)
            yline(outer_threshold,'--','color','k','LineWidth',2)
            yline(max_distance,'--','color','k','LineWidth',2)
            ylabel({'Radial Position','(mm)'})
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax2 = subplot(3,1,2);
            plot(time_reach,mag_vel_2,'color',[45, 49, 66]/255,'LineWidth',1)
            hold on
            plot(time_reach(target_onset:target_offset),mag_vel_2(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
            plot(time_reach(hold_onset:hold_offset-1),mag_vel_2(hold_onset:hold_offset-1),'color',[225 218 174]/255,'LineWidth',2)
            plot(time_reach(start_time:target_onset),mag_vel_2(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            plot(time_reach(start_time),mag_vel_2(start_time),'o','color',[5,142 217]/255,'LineWidth',2)
            plot(time_reach(end_time),mag_vel_2(end_time),'o','color',[5,142 217]/255,'LineWidth',2)
            plot(time_reach(loc_min_vel_2),mag_vel_2(loc_min_vel_2),'o','color',[132, 143, 162]/255,'LineWidth',1)
            plot(time_reach(loc_min_vel_2_reward),mag_vel_2(loc_min_vel_2_reward),'o','color',[204 45 53]/255,'LineWidth',2)
            plot(time_reach(hold_offset-1+loc_peak_velocity),mag_vel_2(hold_offset-1+loc_peak_velocity),'o','color',[255,147,79]/255,'LineWidth',2)
            ylabel({'Speed','(mm/s)'})
            set(gca,'TickDir','out')
            set(gca,'box','off')
            ax3 = subplot(3,1,3);
            plot(time_reach,js_reach(i).RoC_2,'color',[45, 49, 66]/255,'LineWidth',1)
            hold on
            plot(time_reach(target_onset:target_offset),RoC_2(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
             plot(time_reach(hold_onset:hold_offset-1),RoC_2(hold_onset:hold_offset-1),'color',[225 218 174]/255,'LineWidth',2)
            plot(time_reach(start_time:target_onset),RoC_2(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            plot(time_reach(start_time),RoC_2(start_time),'o','color',[5,142 217]/255,'LineWidth',2)
            plot(time_reach(end_time),RoC_2(end_time),'o','color',[5,142 217]/255,'LineWidth',2)
            plot(time_reach(loc_min_vel_2),RoC_2(loc_min_vel_2),'o','color',[132, 143, 162]/255,'LineWidth',1)
            plot(time_reach(loc_min_vel_2_reward),RoC_2(loc_min_vel_2_reward),'o','color',[204 45 53]/255,'LineWidth',2)
            xlabel('Time (sec)')
            ylabel({'Radius of','Curvature'})
            set(gca, 'YScale', 'log')
            set(gca,'TickDir','out')
            set(gca,'box','off')
            linkaxes([ax1 ax2 ax3],'x')
            
            f2 = figure(2);
            movegui(f2,'northeast')
            subplot(2,1,1)
            plot(time_reach,js_reach(i).radial_pos,'k','LineWidth',1)
            hold on
            yline(hold_threshold,'--','color','k','LineWidth',2)
            yline(outer_threshold,'color','g','LineWidth',2)
            yline(max_distance,'color','g','LineWidth',2)
            subplot(2,1,2)
            plot(time_reach,js_reach(i).mag_vel,'k','LineWidth',1)
            
            
            f3 = figure(3);
            movegui(f3,'south')
            plot(js_reach(i).traj_x_2,js_reach(i).traj_y_2,'k','LineWidth',1)
            hold on
            plot(js_reach(i).traj_x_2(target_onset:target_offset),js_reach(i).traj_y_2(target_onset:target_offset),'color',[204 45 53]/255,'LineWidth',2)
            plot(js_reach(i).traj_x_2(hold_onset:hold_offset-1),js_reach(i).traj_y_2(hold_onset:hold_offset-1),'color',[225 218 174]/255,'LineWidth',2)
            plot(js_reach(i).traj_x_2(start_time:target_onset),js_reach(i).traj_y_2(start_time:target_onset),'color',[255,147,79]/255,'LineWidth',2)
            plot(js_reach(i).traj_x_2(loc_min_vel_2_reward),js_reach(i).traj_y_2(loc_min_vel_2_reward),'o','color',[204 45 53]/255,'LineWidth',2)
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
            
            prompt = 'Acceptable? y/n: ';
            str = input(prompt,'s');
            if strcmp(str,'n')
                flag = [flag i];
            end
            close all
        end
        js_reach(i).start_time = start_time;
        js_reach(i).end_time = end_time;
        js_reach(i).hold_onset = hold_onset;
        js_reach(i).hold_offset = hold_offset;
        js_reach(i).target_onset = target_onset;
        js_reach(i).target_offset = target_offset;
    end
    
end



cd([data_folder mouse_ID '\' data_ID])
save('js_reach','js_reach')
save('hold_still_duration','hold_still_duration')
save('target_hold_duration','target_hold_duration')
save('reach_duration','reach_duration')
save('peak_velocity','peak_velocity')
save('path_length','path_length')
save('straightness','straightness')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')


%%
hold_still_duration
target_hold_duration
reach_duration
peak_velocity

figure(1)
plot(reach_duration,peak_velocity,'o','LineWidth',1)
set(gca,'TickDir','out')
set(gca,'box','off')

figure(2)
plot(path_length,straightness,'o','LineWidth',1)
set(gca,'TickDir','out')
set(gca,'box','off')