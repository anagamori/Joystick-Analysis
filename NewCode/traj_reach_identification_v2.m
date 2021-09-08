close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_2_F_081920_CT';
data_ID = '081821_60_80_100_0200_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
index_rewardedTrial = [];
index_validTrial = [];
Fs = 1000;
[b,a] = butter(4,50/(Fs*2),'low');
index_reward = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
    end
end

% Contingency parameters
hold_threshold = str2double(condition_array{7})/100*6.35; % initial hold threshold
outer_threshold = str2double(condition_array{2})/100*6.35; % minimum target threshold
max_distance = str2double(condition_array{3})/100*6.35; % maximum target threshold
hold_duration = str2double(condition_array{6});

theta = 0:0.01:2*pi;
%%
% Go through individual trials within each entry of jstruct in which reward
% is given
for j = 1:length(index_reward)
    
    n = index_reward(j);
    
    % Preprocess trajectory data
    traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    radial_position = sqrt(traj_x.^2+traj_y.^2);
    radial_vel = sqrt(vel_x.^2+vel_y.^2);
    radial_vel_v2 = [0 diff(radial_position)*Fs];
    radial_acc = sqrt(acc_x.^2+acc_y.^2);
    radial_acc_v2 = [0 diff(radial_vel_v2)*Fs];
    
    
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    for k = 1:length(js_reward)
        trial_live_idx = find(jstruct(n).trial_live(:,1) == onset_js(k));
        onset_trial = jstruct(n).trial_live(trial_live_idx,1);
        offset_trial = jstruct(n).trial_live(trial_live_idx,2);
        
        start_time = onset_js(k)-0.05*Fs;
        
        radial_pos_trial = radial_position(start_time:offset_trial+0.05*Fs);
        radial_vel_trial = radial_vel(start_time:offset_trial+0.05*Fs);
        RoC_trial = RoC(start_time:offset_trial+0.05*Fs);
        
        [min_vel,loc_vel] = findpeaks(-radial_vel_trial);
        [min_RoC,loc_RoC] = findpeaks(-RoC_trial);
        
        A = repmat(loc_RoC',[1 length(loc_vel)]);
        [minValue,closestIndex] = min(abs(A-loc_vel),[],1);
        
        loc_vel(minValue>2) = [];
        closestIndex(minValue>2) = [];
        pos_min_vel = radial_pos_trial(loc_vel);
        [max_pos,max_pos_loc] = max(pos_min_vel);
        
        if all(radial_pos_trial(1:hold_duration) < hold_threshold) &&  radial_pos_trial(loc_vel(max_pos_loc)) > outer_threshold && radial_pos_trial(loc_vel(max_pos_loc)) < max_distance
            index_validTrial = [index_validTrial [j;k]];
            end_time = loc_vel(max_pos_loc) + 0.1*Fs; %offset_trial+0.3*Fs; %start_time + loc_RoC + 0.2; %offset_trial+1*Fs; %offset_js(k);
            time = -0.05:1/Fs:(end_time - 0.05*Fs)/Fs; %[-0.05*Fs:end_time]./Fs;
            time = time*1000;
            loc_vel(loc_vel>end_time) = [];
            loc_RoC(loc_RoC>end_time) = [];
            closestIndex(closestIndex>length(loc_RoC)) = [];
            if plotOpt == 1
                figure()
                subplot(3,1,1)
                plot(time,traj_x(start_time:end_time+start_time),'LineWidth',1)
                xlim([time(1),time(end)])
                ylabel('x-position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                hold on
                subplot(3,1,2)
                plot(time,traj_y(start_time:end_time+start_time),'LineWidth',1)
                xlim([time(1),time(end)])
                xlabel('Time (s)')
                ylabel('y-position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                hold on
                subplot(3,1,3)
                plot(time,radial_position(start_time:end_time+start_time),'LineWidth',1)
                hold on
                plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
                plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
                plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
                xlim([time(1),time(end)])
                ylabel('radial distance (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                
                figure()
                subplot(3,1,1)
                plot(time,radial_position(start_time:end_time+start_time),'LineWidth',1)
                hold on
                plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
                plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
                plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
                xlim([time(1),time(end)])
                ylabel('Radial Position (mm)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                subplot(3,1,2)
                plot(time,radial_vel(start_time:end_time+start_time),'LineWidth',1)
                hold on
                plot(time(loc_vel),radial_vel(loc_vel+start_time),'o')
                xlim([time(1),time(end)])
                ylabel('Radial Velocity (mm/s)')
                set(gca,'TickDir','out');
                set(gca,'box','off')
                subplot(3,1,3)
                semilogy(time,RoC(start_time:end_time+start_time),'LineWidth',1)
                hold on
                semilogy(time(loc_RoC(closestIndex)),RoC(loc_RoC(closestIndex)+start_time),'o')
                xlabel('Time (ms)')
                ylabel('Raidus of Curvature')
                xlim([time(1),time(end)])
                set(gca,'TickDir','out');
                set(gca,'box','off')
                
                figure()
                plot(traj_x(start_time:end_time+start_time),traj_y(start_time:end_time+start_time),'LineWidth',1)
                hold on
                plot(traj_x(loc_vel+start_time),traj_y(loc_vel+start_time),'o','LineWidth',1)
                xlim([-7 7])
                ylim([-7 7])
                set(gca,'TickDir','out')
                set(gca,'box','off')
                hold on
                plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
                plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
                plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
                axis equal
                
            elseif plotOpt == 2
                figure(1)
                plot(traj_x(start_time:end_time+start_time),traj_y(start_time:end_time+start_time),'LineWidth',1)
                hold on
                xlim([-7 7])
                ylim([-7 7])
                set(gca,'TickDir','out')
                set(gca,'box','off')
                hold on
                plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
                plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
                plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
                axis equal
            end
        end
        %[min_vel,loc_vel] = min(radial_vel(start_time:offset_trial));
        %[min_RoC,loc_RoC] = min(RoC(start_time:offset_trial));
        
        
        index_rewardedTrial = [index_rewardedTrial [j;k]];
    end
end

%%
% figure(11)
% histogram(max_radial_position,[0:6.35/50:6.35])
% hold on
% line([outer_threshold, outer_threshold], ylim, 'LineWidth', 2, 'Color', 'r');
% line([max_distance, max_distance], ylim, 'LineWidth', 2, 'Color', 'r');
%
% %
