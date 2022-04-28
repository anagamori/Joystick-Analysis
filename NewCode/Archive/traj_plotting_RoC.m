close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_3_F_102320_CT';
data_ID = '081221_60_80_100_0400_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));

Fs = 1000;
[b,a] = butter(4,50/(Fs*2),'low');
index_reward = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).reward_onset)
        index_reward = [index_reward i];
    end
end

hold_threshold = str2double(condition_array{7})/100*6.35;
outer_threshold = str2double(condition_array{2})/100*6.35;
max_distance = str2double(condition_array{3})/100*6.35;
theta = 0:0.01:2*pi;
%%
for j = 1 %:length(index_reward) %1:50 %3:32
    
    n = index_reward(j);
    traj_x = filtfilt(b,a,jstruct(n).traj_x/100*6.35);
    vel_x = [0 diff(traj_x)*Fs];
    acc_x = [0 diff(vel_x)*Fs];
    traj_y = filtfilt(b,a,jstruct(n).traj_y/100*6.35);
    vel_y = [0 diff(traj_y)*Fs];
    acc_y = [0 diff(vel_y)*Fs];
    RoC = (vel_x.^2 + vel_y.^2).^(3/2)./abs(vel_x.*acc_y-vel_y.*acc_x);
    radial_position = sqrt(traj_x.^2+traj_y.^2);
    radial_vel = sqrt(vel_x.^2+vel_y.^2);
    onset_reward = jstruct(n).reward_onset;
    js_reward = find(jstruct(n).js_reward==1); %joystick contact for which reward was given
    onset_js = jstruct(n).js_pairs_r(js_reward,1);
    offset_js = jstruct(n).js_pairs_r(js_reward,2);
    
    for k = 1 %:length(js_reward)
        a_diff = find(jstruct(n).np_pairs(:,1)-onset_js(k)<0);
        
        onset_np = jstruct(n).np_pairs(a_diff(end),1);
        offset_np = jstruct(n).np_pairs(a_diff(end),2);
        
        b_diff = find(jstruct(n).js_pairs_l(:,1)-onset_js(k)<0);
        
        onset_js_l = jstruct(n).js_pairs_l(b_diff(end),1);
        offset_js_l = jstruct(n).js_pairs_l(b_diff(end),2);
        
        trial_live_idx = find(jstruct(n).trial_live(:,1)==onset_js(k));
        onset_trial = jstruct(n).trial_live(trial_live_idx,1);
        offset_trial = jstruct(n).trial_live(trial_live_idx,2);
        
        
        start_time = onset_js(k);
        
        [min_vel,loc_vel] = findpeaks(-radial_vel(start_time:offset_trial+0.3*Fs));
        [min_RoC,loc_RoC] = findpeaks(-RoC(start_time:offset_trial+0.3*Fs));
        
        A = repmat(loc_RoC',[1 length(loc_vel)]);
        [minValue,closestIndex] = min(abs(A-loc_vel),[],1);
        %[min_vel,loc_vel] = min(radial_vel(start_time:offset_trial));
        %[min_RoC,loc_RoC] = min(RoC(start_time:offset_trial));
        end_time = offset_trial+0.3*Fs; %start_time + loc_RoC + 0.2; %offset_trial+1*Fs; %offset_js(k);
        time = [1:end_time-start_time+1]./Fs;
        
        
        if plotOpt == 1           
            figure()
            subplot(4,1,1)
            plot(time,traj_x(start_time:end_time),'LineWidth',1)
            xlim([time(1)-0.1,time(end)])
            ylabel('x-position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            hold on
            subplot(4,1,2)
            plot(time,traj_y(start_time:end_time),'LineWidth',1)
            xlim([time(1)-0.1,time(end)])
            xlabel('Time (s)')
            ylabel('y-position (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            hold on
            subplot(4,1,3)
            plot(time,radial_position(start_time:end_time),'LineWidth',1)
            hold on
            plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
            plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
            plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
            xlim([time(1)-0.1,time(end)])
            ylabel('radial distance (mm)')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(4,1,4)
            plot(time(onset_reward(k)-onset_js(k)),0.1,'.r', 'MarkerSize',10)
            %plot([time(onset_reward(k)-onset_js(k)) time(onset_reward(k)-onset_js(k))],[0 1],'LineWidth',1)
            hold on
            plot(0,0.3,'.b', 'MarkerSize',10)
%            plot(time(offset_trial-onset_js(k)),0.5,'.m', 'MarkerSize',10)
%             plot(time(offset_js_l-onset_js(k)),0.7,'.k', 'MarkerSize',10)
            xlim([time(1)-0.1,time(end)])
%            legend('Reward','Trial Onset','Trial Offset')
            set(gca,'TickDir','out');
            set(gca,'box','off')
            
            figure()
            subplot(3,1,1)
            plot(time,radial_position(start_time:end_time),'LineWidth',1)
            hold on
            plot([time(1) time(end)],[hold_threshold hold_threshold],'--','color','k','LineWidth',1)
            plot([time(1) time(end)],[outer_threshold outer_threshold],'color','g','LineWidth',1)
            plot([time(1) time(end)],[max_distance max_distance],'color','g','LineWidth',1)
            xlim([time(1)-0.1,time(end)])
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,2)
            plot(time,radial_vel(start_time:end_time),'LineWidth',1)
            hold on 
            plot(time(loc_vel),radial_vel(loc_vel+start_time),'o')
            xlim([time(1)-0.1,time(end)])
            set(gca,'TickDir','out');
            set(gca,'box','off')
            subplot(3,1,3)
            semilogy(time,RoC(start_time:end_time),'LineWidth',1)
            hold on 
            semilogy(time(loc_RoC(closestIndex)),RoC(loc_RoC(closestIndex)+start_time),'o')
            xlim([time(1)-0.1,time(end)])
            set(gca,'TickDir','out');
            set(gca,'box','off')
        elseif plotOpt == 2
            figure(1)
            plot(traj_x(start_time:end_time),traj_y(start_time:end_time),'LineWidth',1)
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
        %
        %
        %         figure(2)
        %         plot(traj_x(start_time:end_time),traj_y(start_time:end_time),'LineWidth',1)
        %         xlabel('x-position (mm)')
        %         ylabel('y-position (mm)')
        %         xlim([-6.35 6.35])
        %         ylim([-6.35 6.35])
        %         %axis equal
        %         set(gca,'TickDir','out')
        %         set(gca,'box','off')
        %         hold on
        %         plot(hold_threshold*cos(theta),hold_threshold*sin(theta),'--','color','k')
        %         plot(outer_threshold*cos(theta),outer_threshold*sin(theta),'color','g')
        %         plot(max_distance*cos(theta),max_distance*sin(theta),'color','g')
        
        max_radial_position = [max_radial_position max(radial_position(start_time:onset_reward(k)))]; %[max_radial_position max(radial_position(onset_reward(k)))];
        %[max_radial_position(k),loc] = max(radial_position(start_time:end_time));
        
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
